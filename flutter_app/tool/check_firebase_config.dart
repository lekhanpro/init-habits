import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final strict = args.contains('--strict');
  var hasIssue = false;

  void issue(String message) {
    hasIssue = true;
    final prefix = Platform.environment.containsKey('GITHUB_ACTIONS')
        ? '::warning::'
        : 'warning: ';
    stderr.writeln('$prefix$message');
  }

  final androidConfig = File('android/app/google-services.json');
  if (!androidConfig.existsSync()) {
    issue(
      'android/app/google-services.json is missing. Android Firebase Auth and Google Sign-In will not initialize.',
    );
  } else {
    final json =
        jsonDecode(androidConfig.readAsStringSync()) as Map<String, dynamic>;
    final clients = (json['client'] as List? ?? const []);
    final oauthClients = clients
        .expand(
          (client) =>
              ((client as Map<String, dynamic>)['oauth_client'] as List? ??
              const []),
        )
        .cast<Map<String, dynamic>>()
        .toList();
    final hasAndroidOAuth = oauthClients.any(
      (client) => client['client_type'] == 1,
    );
    final hasWebOAuth = oauthClients.any(
      (client) => client['client_type'] == 3,
    );
    if (!hasAndroidOAuth) {
      issue(
        'google-services.json has no Android OAuth client (client_type 1). Add SHA-1/SHA-256 fingerprints for the signing key in Firebase, download the updated file, and rebuild.',
      );
    }
    if (!hasWebOAuth) {
      issue(
        'google-services.json has no Web OAuth client (client_type 3). Firebase Google Sign-In needs it as the server client ID.',
      );
    }
  }

  final iosConfig = File('ios/Runner/GoogleService-Info.plist');
  final infoPlist = File('ios/Runner/Info.plist');
  if (!iosConfig.existsSync()) {
    issue(
      'ios/Runner/GoogleService-Info.plist is missing. iOS Firebase Auth and Google Sign-In will not initialize.',
    );
  } else {
    final plist = iosConfig.readAsStringSync();
    final reversedClientId = RegExp(
      r'<key>REVERSED_CLIENT_ID</key>\s*<string>([^<]+)</string>',
      multiLine: true,
    ).firstMatch(plist)?.group(1);
    if (reversedClientId == null || reversedClientId.isEmpty) {
      issue('GoogleService-Info.plist does not contain REVERSED_CLIENT_ID.');
    } else if (!infoPlist.existsSync() ||
        !infoPlist.readAsStringSync().contains(reversedClientId)) {
      issue(
        'ios/Runner/Info.plist is missing the REVERSED_CLIENT_ID URL scheme required by Google Sign-In.',
      );
    }
  }

  if (hasIssue && strict) {
    exitCode = 1;
  }
}
