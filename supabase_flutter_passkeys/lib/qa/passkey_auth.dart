// The passkey API of supabase_flutter is still marked as experimental.
// ignore_for_file: experimental_member_use

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';
import 'package:supabase_flutter_passkeys/config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supabase = Supabase.instance.client;
final _authenticator = PasskeyAuthenticator();

/// True while [createAccountWithPasskey] runs. The account is signed in as
/// soon as it is created, but it is only usable once the passkey is added.
final accountSetupInProgress = ValueNotifier(false);

/// Creates a guest account for [name] and registers a passkey for it.
///
/// Supabase only adds passkeys to non-anonymous users, so the account gets a
/// generated email address and a random password that nobody ever sees. After
/// this call the passkey is the only way back into the account.
Future<void> createAccountWithPasskey(String name) async {
  accountSetupInProgress.value = true;
  try {
    await _createAccountWithPasskey(name);
  } finally {
    accountSetupInProgress.value = false;
  }
}

Future<void> _createAccountWithPasskey(String name) async {
  final response = await _supabase.auth.signUp(
    email: '${_randomId(12)}@${Config.guestEmailDomain}',
    password: _randomId(32),
    data: {'display_name': name},
  );
  if (response.session == null) {
    throw const PasskeyFlowException(
      'The account needs to be confirmed by email. Turn off "Confirm email" '
      'in the Supabase dashboard for guest accounts to work.',
    );
  }

  try {
    await _supabase.auth.registerPasskey(
      _NamedAuthenticator(_authenticator, name),
    );
  } catch (_) {
    // Without a passkey the account can never be signed in to again.
    await _supabase.auth.signOut();
    rethrow;
  }
}

/// Signs in with a passkey that was created earlier on this or a synced device.
Future<void> signInWithPasskey() =>
    _supabase.auth.signInWithPasskey(_authenticator);

/// The display name chosen when the account was created.
String displayNameOf(User user) =>
    (user.userMetadata['display_name'] as String?) ?? 'Anonymous';

/// A readable message for anything the passkey flows can throw.
String describeError(Object error) => switch (error) {
  PasskeyFlowException(:final message) => message,
  PasskeyAuthCancelledException() => 'The passkey prompt was cancelled.',
  NoCredentialsAvailableException() =>
    'No passkey for this site on this device yet. Create one first.',
  DomainNotAssociatedException() =>
    'This domain is not set up as the relying party in Supabase.',
  PasskeyUnsupportedException() => 'This browser does not support passkeys.',
  AuthApiException(errorCode: 'passkey_disabled') =>
    'Passkeys are not enabled for this Supabase project yet.',
  AuthException(:final message) => message,
  AuthenticatorException() => 'The passkey prompt failed: $error',
  _ => 'Something went wrong: $error',
};

class PasskeyFlowException implements Exception {
  const PasskeyFlowException(this.message);

  final String message;

  @override
  String toString() => message;
}

String _randomId(int bytes) {
  final random = Random.secure();
  return base64Url
      .encode(List.generate(bytes, (_) => random.nextInt(256)))
      .replaceAll('=', '')
      .replaceAll('-', '')
      .replaceAll('_', '')
      .toLowerCase();
}

/// Shows [name] in the passkey prompt and the password manager, instead of
/// the generated email address that the server puts in the options.
class _NamedAuthenticator implements PasskeyAuthenticatorInterface {
  _NamedAuthenticator(this._delegate, this._name);

  final PasskeyAuthenticatorInterface _delegate;
  final String _name;

  @override
  Future<RegisterResponseType> register(RegisterRequestType request) {
    return _delegate.register(
      RegisterRequestType(
        challenge: request.challenge,
        relyingParty: request.relyingParty,
        user: UserType(displayName: _name, name: _name, id: request.user.id),
        excludeCredentials: request.excludeCredentials,
        authSelectionType: request.authSelectionType,
        pubKeyCredParams: request.pubKeyCredParams,
        timeout: request.timeout,
        attestation: request.attestation,
        prf: request.prf,
        mediation: request.mediation,
      ),
    );
  }

  @override
  Future<AuthenticateResponseType> authenticate(
    AuthenticateRequestType request,
  ) => _delegate.authenticate(request);

  @override
  Future<void> signalUnknownCredential(
    SignalUnknownCredentialRequestType request,
  ) => _delegate.signalUnknownCredential(request);

  @override
  Future<void> signalAllAcceptedCredentials(
    SignalAllAcceptedCredentialsRequestType request,
  ) => _delegate.signalAllAcceptedCredentials(request);
}
