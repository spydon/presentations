// A dependency free port of the passkeys_web bundle (passkeys_web 2.11.0,
// javascript/src). It defines the `PasskeyAuthenticator` global that
// package:passkeys_web calls through js_interop, converting between the JSON
// the plugin sends (binary fields as base64url strings) and the
// ArrayBuffers that navigator.credentials expects.
(function () {
  'use strict';

  var ABORTED_BY_USER = 'operation aborted by user.';
  var abortController;

  function base64urlToBuffer(value) {
    var base64 = value.replace(/-/g, '+').replace(/_/g, '/');
    var padded = base64 + '='.repeat((4 - (base64.length % 4)) % 4);
    var binary = atob(padded);
    var bytes = new Uint8Array(binary.length);
    for (var i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
    return bytes.buffer;
  }

  function bufferToBase64url(buffer) {
    if (!buffer) return null;
    var bytes = new Uint8Array(buffer);
    var binary = '';
    for (var i = 0; i < bytes.length; i++) binary += String.fromCharCode(bytes[i]);
    return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
  }

  // The plugin serializes absent optional fields as null, which the
  // WebAuthn dictionaries reject, so drop them.
  function withoutNulls(value) {
    if (Array.isArray(value)) return value.map(withoutNulls);
    if (value && typeof value === 'object') {
      var out = {};
      Object.keys(value).forEach(function (key) {
        if (value[key] !== null && value[key] !== undefined) {
          out[key] = withoutNulls(value[key]);
        }
      });
      return out;
    }
    return value;
  }

  function credentialDescriptors(list) {
    return (list || []).map(function (credential) {
      var descriptor = { type: credential.type, id: base64urlToBuffer(credential.id) };
      if (credential.transports && credential.transports.length) {
        descriptor.transports = credential.transports;
      }
      return descriptor;
    });
  }

  function applyPrfInput(publicKey, extensions) {
    var evalInput = extensions && extensions.prf && extensions.prf.eval;
    if (!evalInput) return;
    var prf = { eval: { first: base64urlToBuffer(evalInput.first) } };
    if (evalInput.second) prf.eval.second = base64urlToBuffer(evalInput.second);
    publicKey.extensions = Object.assign({}, publicKey.extensions || {}, { prf: prf });
  }

  function extensionResults(credential) {
    var results = {};
    var raw = credential.getClientExtensionResults ? credential.getClientExtensionResults() : {};
    if (raw.credProps) results.credProps = raw.credProps;
    if (raw.prf) {
      var prf = {};
      if (typeof raw.prf.enabled === 'boolean') prf.enabled = raw.prf.enabled;
      if (raw.prf.results && raw.prf.results.first) {
        prf.results = { first: bufferToBase64url(raw.prf.results.first) };
        if (raw.prf.results.second) prf.results.second = bufferToBase64url(raw.prf.results.second);
      }
      results.prf = prf;
    }
    return results;
  }

  function platformError(code, message) {
    return JSON.stringify({ code: code, message: message, details: '' });
  }

  function errorFromDOMException(error) {
    if (error.name === 'NotAllowedError') {
      return platformError('cancelled', 'operation was cancelled by the user.');
    }
    return platformError(error.name, error.message);
  }

  async function isConditionalCreateAvailable() {
    var pkc = window.PublicKeyCredential;
    if (!pkc || typeof pkc.getClientCapabilities !== 'function') return false;
    try {
      var capabilities = await pkc.getClientCapabilities();
      return !!capabilities && capabilities.conditionalCreate === true;
    } catch (e) {
      return false;
    }
  }

  async function register(params) {
    var isConditional = false;
    try {
      abortController = new AbortController();
      var parsed = JSON.parse(params);
      isConditional = parsed.mediation === 'conditional';
      var json = withoutNulls(parsed.publicKey);
      var publicKey = Object.assign({}, json, {
        challenge: base64urlToBuffer(json.challenge),
        user: Object.assign({}, json.user, { id: base64urlToBuffer(json.user.id) }),
        excludeCredentials: credentialDescriptors(json.excludeCredentials),
      });
      applyPrfInput(publicKey, json.extensions);
      if (publicKey.extensions && publicKey.extensions.prf === undefined) {
        delete publicKey.extensions.prf;
      }

      var request = { publicKey: publicKey, signal: abortController.signal };
      if (isConditional) {
        if (!(await isConditionalCreateAvailable())) {
          throw { platform: platformError('conditional-create-unsupported',
            'This browser does not support conditional passkey creation.') };
        }
        request.mediation = 'conditional';
      }

      var credential = await navigator.credentials.create(request);
      var response = credential.response;
      return JSON.stringify({
        type: credential.type,
        id: credential.id,
        rawId: bufferToBase64url(credential.rawId),
        authenticatorAttachment: credential.authenticatorAttachment || null,
        response: {
          clientDataJSON: bufferToBase64url(response.clientDataJSON),
          attestationObject: bufferToBase64url(response.attestationObject),
          transports: response.getTransports ? response.getTransports() : [],
        },
        clientExtensionResults: extensionResults(credential),
      });
    } catch (e) {
      var error;
      if (e && e.platform) {
        error = e.platform;
      } else if (e === ABORTED_BY_USER) {
        error = platformError('cancelled', 'operation was cancelled by the user.');
      } else if (e instanceof DOMException) {
        if (e.name === 'InvalidStateError') {
          error = platformError('exclude-credentials-match', e.message);
        } else if (e.name === 'NotAllowedError' && isConditional) {
          error = platformError('not-eligible', e.message);
        } else {
          error = errorFromDOMException(e);
        }
      } else {
        error = platformError('unknown', String(e));
      }
      console.log(error);
      throw error;
    }
  }

  async function login(params) {
    try {
      abortController = new AbortController();
      var parsed = JSON.parse(params);
      var json = withoutNulls(parsed.publicKey);
      var publicKey = Object.assign({}, json, {
        challenge: base64urlToBuffer(json.challenge),
        allowCredentials: credentialDescriptors(json.allowCredentials),
      });
      delete publicKey.loginExtensions;
      applyPrfInput(publicKey, json.extensions);

      var request = { publicKey: publicKey, signal: abortController.signal };
      if (parsed.mediation) request.mediation = parsed.mediation;

      var credential = await navigator.credentials.get(request);
      var response = credential.response;
      return JSON.stringify({
        type: credential.type,
        id: credential.id,
        rawId: bufferToBase64url(credential.rawId),
        authenticatorAttachment: credential.authenticatorAttachment || null,
        response: {
          clientDataJSON: bufferToBase64url(response.clientDataJSON),
          authenticatorData: bufferToBase64url(response.authenticatorData),
          signature: bufferToBase64url(response.signature),
          userHandle: bufferToBase64url(response.userHandle),
        },
        clientExtensionResults: extensionResults(credential),
      });
    } catch (e) {
      var error;
      if (e === ABORTED_BY_USER) {
        error = platformError('suppressed', e);
      } else if (e instanceof DOMException) {
        error = errorFromDOMException(e);
      } else {
        error = platformError('unknown', String(e));
      }
      throw error;
    }
  }

  window.PasskeyAuthenticator = {
    init: function () { abortController = undefined; },
    register: register,
    login: login,
    cancelCurrentAuthenticatorOperation: function () {
      if (abortController) abortController.abort(ABORTED_BY_USER);
    },
    hasPasskeySupport: function () { return Boolean(window.PublicKeyCredential); },
    isUserVerifyingPlatformAuthenticatorAvailable: async function () {
      if (!window.PublicKeyCredential) return undefined;
      try {
        return await PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable();
      } catch (e) {
        return undefined;
      }
    },
    isConditionalMediationAvailable: async function () {
      if (!window.PublicKeyCredential || !PublicKeyCredential.isConditionalMediationAvailable) {
        return undefined;
      }
      try {
        return await PublicKeyCredential.isConditionalMediationAvailable();
      } catch (e) {
        return undefined;
      }
    },
  };
})();
