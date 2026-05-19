import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final bundlePath =
      _argValue(args, '--aab') ??
      'build/app/outputs/bundle/release/app-release.aab';
  final keytoolPath = _argValue(args, '--keytool') ?? 'keytool';

  final bundle = File(bundlePath);
  if (!bundle.existsSync()) {
    _fail('App Bundle not found at $bundlePath.');
  }

  final firebaseShas = _firebaseAndroidSha1s();
  if (firebaseShas.isEmpty) {
    _fail(
      'android/app/google-services.json has no Android OAuth SHA-1 entries for the current package.',
    );
  }

  final result = Process.runSync(
    keytoolPath,
    ['-printcert', '-jarfile', bundle.path],
    runInShell: Platform.isWindows,
  );

  stdout.write(result.stdout);
  stderr.write(result.stderr);

  if (result.exitCode != 0) {
    _fail('keytool failed with exit code ${result.exitCode}.');
  }

  final output = '${result.stdout}\n${result.stderr}';
  final bundleSha1 = RegExp(
    r'SHA1:\s*([0-9a-fA-F:]+)',
  ).firstMatch(output)?.group(1);
  final bundleSha256 = RegExp(
    r'SHA256:\s*([0-9a-fA-F:]+)',
  ).firstMatch(output)?.group(1);

  if (bundleSha1 == null || bundleSha1.isEmpty) {
    _fail('Could not read App Bundle signer SHA-1 from keytool output.');
  }

  final normalizedBundleSha1 = _normalizeSha(bundleSha1);

  stdout.writeln('AAB signer SHA-1: ${_formatSha(normalizedBundleSha1)}');
  if (bundleSha256 != null && bundleSha256.isNotEmpty) {
    stdout.writeln(
      'AAB signer SHA-256: ${_formatSha(_normalizeSha(bundleSha256))}',
    );
  }
  stdout.writeln('Firebase Android OAuth SHA-1 entries:');
  for (final sha in firebaseShas) {
    stdout.writeln('- ${_formatSha(sha)}');
  }

  if (!firebaseShas.contains(normalizedBundleSha1)) {
    _fail(
      'App Bundle signing SHA-1 does not match Firebase Android OAuth. '
      'Add the upload/app signing SHA-1/SHA-256 to Firebase, download a fresh '
      'google-services.json, and rebuild.',
    );
  }

  stdout.writeln(
    'App Bundle signing certificate matches Firebase Android OAuth.',
  );
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

  final packageName = _androidApplicationId();
  final json = jsonDecode(config.readAsStringSync()) as Map<String, dynamic>;
  final clients = (json['client'] as List? ?? const []);
  final shas = <String>{};

  for (final client in clients.cast<Map<String, dynamic>>()) {
    final oauthClients = (client['oauth_client'] as List? ?? const []);
    for (final oauth in oauthClients.cast<Map<String, dynamic>>()) {
      final androidInfo = oauth['android_info'] as Map<String, dynamic>?;
      if (oauth['client_type'] != 1 ||
          androidInfo?['package_name'] != packageName) {
        continue;
      }
      final hash = androidInfo?['certificate_hash'] as String?;
      if (hash != null && hash.isNotEmpty) {
        shas.add(_normalizeSha(hash));
      }
    }
  }

  return shas.toList()..sort();
}

String _androidApplicationId() {
  final gradleFile = File('android/app/build.gradle.kts');
  if (!gradleFile.existsSync()) {
    return 'com.inithabits.app';
  }

  final content = gradleFile.readAsStringSync();
  return RegExp(
        r'applicationId\s*=\s*"([^"]+)"',
      ).firstMatch(content)?.group(1) ??
      'com.inithabits.app';
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
