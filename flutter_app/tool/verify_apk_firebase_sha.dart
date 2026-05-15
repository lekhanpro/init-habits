import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final apkPath =
      _argValue(args, '--apk') ??
      'build/app/outputs/flutter-apk/app-release.apk';
  final apksignerPath = _argValue(args, '--apksigner') ?? _findApksigner();

  if (apksignerPath == null) {
    _fail(
      'Could not find apksigner. Set ANDROID_HOME or pass --apksigner <path>.',
    );
  }

  final apk = File(apkPath);
  if (!apk.existsSync()) {
    _fail('APK not found at $apkPath.');
  }

  final firebaseShas = _firebaseAndroidSha1s();
  if (firebaseShas.isEmpty) {
    _fail(
      'android/app/google-services.json has no Android OAuth SHA-1 entries.',
    );
  }

  final result = Process.runSync(apksignerPath!, [
    'verify',
    '--print-certs',
    apk.path,
  ], runInShell: Platform.isWindows);

  stdout.write(result.stdout);
  stderr.write(result.stderr);

  if (result.exitCode != 0) {
    _fail('apksigner failed with exit code ${result.exitCode}.');
  }

  final output = '${result.stdout}\n${result.stderr}';
  final apkSha1 = RegExp(
    r'Signer #1 certificate SHA-1 digest:\s*([0-9a-fA-F:]+)',
  ).firstMatch(output)?.group(1);
  final apkSha256 = RegExp(
    r'Signer #1 certificate SHA-256 digest:\s*([0-9a-fA-F:]+)',
  ).firstMatch(output)?.group(1);

  if (apkSha1 == null || apkSha1.isEmpty) {
    _fail('Could not read APK signer SHA-1 from apksigner output.');
  }

  final normalizedApkSha1 = _normalizeSha(apkSha1);

  stdout.writeln('APK signer SHA-1: ${_formatSha(normalizedApkSha1)}');
  if (apkSha256 != null && apkSha256.isNotEmpty) {
    stdout.writeln(
      'APK signer SHA-256: ${_formatSha(_normalizeSha(apkSha256))}',
    );
  }
  stdout.writeln('Firebase Android OAuth SHA-1 entries:');
  for (final sha in firebaseShas) {
    stdout.writeln('- ${_formatSha(sha)}');
  }

  if (!firebaseShas.contains(normalizedApkSha1)) {
    _fail(
      'APK signing SHA-1 does not match Firebase Android OAuth. '
      'Add the APK SHA-1/SHA-256 to Firebase and download a fresh '
      'google-services.json, or configure CI to sign with the registered '
      'release keystore.',
    );
  }

  stdout.writeln('APK signing certificate matches Firebase Android OAuth.');
}

String? _argValue(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index == -1 || index + 1 >= args.length) {
    return null;
  }
  return args[index + 1];
}

List<String> _firebaseAndroidSha1s() {
  final config = File('android/app/google-services.json');
  if (!config.existsSync()) {
    _fail('android/app/google-services.json is missing.');
  }

  final json = jsonDecode(config.readAsStringSync()) as Map<String, dynamic>;
  final clients = (json['client'] as List? ?? const []);
  final shas = <String>{};

  for (final client in clients.cast<Map<String, dynamic>>()) {
    final oauthClients = (client['oauth_client'] as List? ?? const []);
    for (final oauth in oauthClients.cast<Map<String, dynamic>>()) {
      if (oauth['client_type'] != 1) {
        continue;
      }
      final androidInfo = oauth['android_info'] as Map<String, dynamic>?;
      final hash = androidInfo?['certificate_hash'] as String?;
      if (hash != null && hash.isNotEmpty) {
        shas.add(_normalizeSha(hash));
      }
    }
  }

  return shas.toList()..sort();
}

String? _findApksigner() {
  final sdkRoot =
      Platform.environment['ANDROID_HOME'] ??
      Platform.environment['ANDROID_SDK_ROOT'];
  if (sdkRoot == null || sdkRoot.isEmpty) {
    return null;
  }

  final separator = Platform.isWindows ? r'\' : '/';
  final buildTools = Directory('$sdkRoot${separator}build-tools');
  if (!buildTools.existsSync()) {
    return null;
  }

  final executable = Platform.isWindows ? 'apksigner.bat' : 'apksigner';
  final candidates =
      buildTools
          .listSync()
          .whereType<Directory>()
          .map((dir) => File('${dir.path}$separator$executable'))
          .where((file) => file.existsSync())
          .map((file) => file.path)
          .toList()
        ..sort();

  if (candidates.isEmpty) {
    return null;
  }
  return candidates.last;
}

String _normalizeSha(String value) =>
    value.replaceAll(':', '').replaceAll(RegExp(r'\s+'), '').toLowerCase();

String _formatSha(String normalized) {
  final pairs = <String>[];
  for (var index = 0; index < normalized.length; index += 2) {
    final end = index + 2 > normalized.length ? normalized.length : index + 2;
    pairs.add(normalized.substring(index, end).toUpperCase());
  }
  return pairs.join(':');
}

Never _fail(String message) {
  final prefix = Platform.environment.containsKey('GITHUB_ACTIONS')
      ? '::error::'
      : 'error: ';
  stderr.writeln('$prefix$message');
  exit(1);
}
