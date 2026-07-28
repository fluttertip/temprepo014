/// Centralized runtime configuration sourced from --dart-define at build time.
///
/// v1 hardcoded the Cloudinary cloud name + upload preset AND the web Google
/// OAuth client id directly inside widget code. That leaks config into source
/// control and makes staging/prod impossible. Everything now flows through
/// compile-time defines:
///
///   flutter run \
///     --dart-define=CLOUDINARY_CLOUD_NAME=ds1gaxnav \
///     --dart-define=CLOUDINARY_UPLOAD_PRESET=room_upload \
///     --dart-define=GOOGLE_WEB_CLIENT_ID=xxxx.apps.googleusercontent.com
///
/// For CI, commit a `dart_define.json` (gitignored) and pass
/// `--dart-define-from-file=dart_define.json`.
class AppConfig {
  AppConfig._();

  static const String cloudinaryCloudName =
      String.fromEnvironment('CLOUDINARY_CLOUD_NAME', defaultValue: '');

  static const String cloudinaryUploadPreset =
      String.fromEnvironment('CLOUDINARY_UPLOAD_PRESET', defaultValue: '');

  static const String googleWebClientId =
      String.fromEnvironment('GOOGLE_WEB_CLIENT_ID', defaultValue: '');

  /// Fail fast in debug if a required value is missing, instead of a confusing
  /// runtime 401 from Cloudinary or a silent Google sign-in failure.
  static void assertValid() {
    assert(
      cloudinaryCloudName.isNotEmpty && cloudinaryUploadPreset.isNotEmpty,
      'Cloudinary config missing. Pass --dart-define=CLOUDINARY_CLOUD_NAME and '
      'CLOUDINARY_UPLOAD_PRESET.',
    );
  }

  static const String appName = 'KothaKhoj';
  static const String appVersion = '2.0.0';
}