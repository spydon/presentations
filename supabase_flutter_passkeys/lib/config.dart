/// Project settings, overridable at build time with `--dart-define`.
///
/// The publishable key is meant to ship in client apps, row level security
/// is what protects the data.
abstract final class Config {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://yfuopyskosovekwridvg.supabase.co',
  );

  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_GZ6rRg8N0VwU9c2gY_8VmA_4L_w44k2',
  );

  /// The public URL of the audience Q&A page, encoded in the QR code.
  ///
  /// Defaults to the origin the deck is served from, so a deployed deck
  /// points at itself. Set it explicitly when presenting from localhost.
  static const _qaUrl = String.fromEnvironment('QA_URL');

  static String get qaUrl {
    if (_qaUrl.isNotEmpty) return _qaUrl;
    return Uri.base.removeFragment().replace(query: 'qa').toString();
  }

  /// Guest accounts get a generated email address on this domain, since a
  /// passkey can only be added to a non-anonymous user. Nothing is ever sent
  /// to it, which requires "Confirm email" to be turned off for the project.
  static const guestEmailDomain = String.fromEnvironment(
    'GUEST_EMAIL_DOMAIN',
    defaultValue: 'guests.passkeys-demo.invalid',
  );
}
