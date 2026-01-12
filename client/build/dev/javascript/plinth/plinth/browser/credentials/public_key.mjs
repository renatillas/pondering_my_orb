import * as $promise from "../../../../gleam_javascript/gleam/javascript/promise.mjs";
import * as $json from "../../../../gleam_json/gleam/json.mjs";
import * as $bit_array from "../../../../gleam_stdlib/gleam/bit_array.mjs";
import * as $io from "../../../../gleam_stdlib/gleam/io.mjs";
import * as $option from "../../../../gleam_stdlib/gleam/option.mjs";
import { None } from "../../../../gleam_stdlib/gleam/option.mjs";
import { Ok, toList, CustomType as $CustomType, makeError } from "../../../gleam.mjs";
import * as $credentials from "../../../plinth/browser/credentials.mjs";
import {
  isConditionalMediationAvailable as is_conditional_mediation_available,
  isUserVerifyingPlatformAuthenticatorAvailable as is_user_verifying_platform_authenticator_available,
  parseCreationOptionsFromJSON as parse_creation_options_from_json,
  createForPublicKey as do_create,
  JSONObject as json_object,
  parseRequestOptionsFromJSON as parse_request_options_from_json,
  getForPublicKey as do_get,
  toJSON as to_json,
  authenticatorAttachment as do_authenticator_attachment,
  id,
  rawId as raw_id,
  clientDataJSON as client_data_json,
  attestationObject as attestation_object,
  getAuthenticatorData as get_authenticator_data,
  getPublicKey as get_public_key,
  getPublicKeyAlgorithm as get_public_key_algorithm,
  getTransports as get_transports,
  authenticatorData as authenticator_data,
  signature,
  userHandle as user_handle,
} from "../../../plinth_browser_credentials_ffi.mjs";

export {
  attestation_object,
  authenticator_data,
  client_data_json,
  do_create,
  do_get,
  get_authenticator_data,
  get_public_key,
  get_public_key_algorithm,
  get_transports,
  id,
  is_conditional_mediation_available,
  is_user_verifying_platform_authenticator_available,
  parse_creation_options_from_json,
  parse_request_options_from_json,
  raw_id,
  signature,
  to_json,
  user_handle,
};

const FILEPATH = "src/plinth/browser/credentials/public_key.gleam";

export class CreationOptions extends $CustomType {
  constructor(attestation, attestation_formats, authenticator_attachement, resident_key, user_verification, challenge, exclude_credentials, public_key_credential_parameters, relaying_party_id, relaying_party_name, timeout, user_id, user_name, user_display_name, hints) {
    super();
    this.attestation = attestation;
    this.attestation_formats = attestation_formats;
    this.authenticator_attachement = authenticator_attachement;
    this.resident_key = resident_key;
    this.user_verification = user_verification;
    this.challenge = challenge;
    this.exclude_credentials = exclude_credentials;
    this.public_key_credential_parameters = public_key_credential_parameters;
    this.relaying_party_id = relaying_party_id;
    this.relaying_party_name = relaying_party_name;
    this.timeout = timeout;
    this.user_id = user_id;
    this.user_name = user_name;
    this.user_display_name = user_display_name;
    this.hints = hints;
  }
}
export const CreationOptions$CreationOptions = (attestation, attestation_formats, authenticator_attachement, resident_key, user_verification, challenge, exclude_credentials, public_key_credential_parameters, relaying_party_id, relaying_party_name, timeout, user_id, user_name, user_display_name, hints) =>
  new CreationOptions(attestation,
  attestation_formats,
  authenticator_attachement,
  resident_key,
  user_verification,
  challenge,
  exclude_credentials,
  public_key_credential_parameters,
  relaying_party_id,
  relaying_party_name,
  timeout,
  user_id,
  user_name,
  user_display_name,
  hints);
export const CreationOptions$isCreationOptions = (value) =>
  value instanceof CreationOptions;
export const CreationOptions$CreationOptions$attestation = (value) =>
  value.attestation;
export const CreationOptions$CreationOptions$0 = (value) => value.attestation;
export const CreationOptions$CreationOptions$attestation_formats = (value) =>
  value.attestation_formats;
export const CreationOptions$CreationOptions$1 = (value) =>
  value.attestation_formats;
export const CreationOptions$CreationOptions$authenticator_attachement = (value) =>
  value.authenticator_attachement;
export const CreationOptions$CreationOptions$2 = (value) =>
  value.authenticator_attachement;
export const CreationOptions$CreationOptions$resident_key = (value) =>
  value.resident_key;
export const CreationOptions$CreationOptions$3 = (value) => value.resident_key;
export const CreationOptions$CreationOptions$user_verification = (value) =>
  value.user_verification;
export const CreationOptions$CreationOptions$4 = (value) =>
  value.user_verification;
export const CreationOptions$CreationOptions$challenge = (value) =>
  value.challenge;
export const CreationOptions$CreationOptions$5 = (value) => value.challenge;
export const CreationOptions$CreationOptions$exclude_credentials = (value) =>
  value.exclude_credentials;
export const CreationOptions$CreationOptions$6 = (value) =>
  value.exclude_credentials;
export const CreationOptions$CreationOptions$public_key_credential_parameters = (value) =>
  value.public_key_credential_parameters;
export const CreationOptions$CreationOptions$7 = (value) =>
  value.public_key_credential_parameters;
export const CreationOptions$CreationOptions$relaying_party_id = (value) =>
  value.relaying_party_id;
export const CreationOptions$CreationOptions$8 = (value) =>
  value.relaying_party_id;
export const CreationOptions$CreationOptions$relaying_party_name = (value) =>
  value.relaying_party_name;
export const CreationOptions$CreationOptions$9 = (value) =>
  value.relaying_party_name;
export const CreationOptions$CreationOptions$timeout = (value) => value.timeout;
export const CreationOptions$CreationOptions$10 = (value) => value.timeout;
export const CreationOptions$CreationOptions$user_id = (value) => value.user_id;
export const CreationOptions$CreationOptions$11 = (value) => value.user_id;
export const CreationOptions$CreationOptions$user_name = (value) =>
  value.user_name;
export const CreationOptions$CreationOptions$12 = (value) => value.user_name;
export const CreationOptions$CreationOptions$user_display_name = (value) =>
  value.user_display_name;
export const CreationOptions$CreationOptions$13 = (value) =>
  value.user_display_name;
export const CreationOptions$CreationOptions$hints = (value) => value.hints;
export const CreationOptions$CreationOptions$14 = (value) => value.hints;

export class RequestOptions extends $CustomType {
  constructor(allow_credentials, challenge, hints, relaying_party_id, timeout, user_verification) {
    super();
    this.allow_credentials = allow_credentials;
    this.challenge = challenge;
    this.hints = hints;
    this.relaying_party_id = relaying_party_id;
    this.timeout = timeout;
    this.user_verification = user_verification;
  }
}
export const RequestOptions$RequestOptions = (allow_credentials, challenge, hints, relaying_party_id, timeout, user_verification) =>
  new RequestOptions(allow_credentials,
  challenge,
  hints,
  relaying_party_id,
  timeout,
  user_verification);
export const RequestOptions$isRequestOptions = (value) =>
  value instanceof RequestOptions;
export const RequestOptions$RequestOptions$allow_credentials = (value) =>
  value.allow_credentials;
export const RequestOptions$RequestOptions$0 = (value) =>
  value.allow_credentials;
export const RequestOptions$RequestOptions$challenge = (value) =>
  value.challenge;
export const RequestOptions$RequestOptions$1 = (value) => value.challenge;
export const RequestOptions$RequestOptions$hints = (value) => value.hints;
export const RequestOptions$RequestOptions$2 = (value) => value.hints;
export const RequestOptions$RequestOptions$relaying_party_id = (value) =>
  value.relaying_party_id;
export const RequestOptions$RequestOptions$3 = (value) =>
  value.relaying_party_id;
export const RequestOptions$RequestOptions$timeout = (value) => value.timeout;
export const RequestOptions$RequestOptions$4 = (value) => value.timeout;
export const RequestOptions$RequestOptions$user_verification = (value) =>
  value.user_verification;
export const RequestOptions$RequestOptions$5 = (value) =>
  value.user_verification;

export class NoAttestation extends $CustomType {}
export const Attestation$NoAttestation = () => new NoAttestation();
export const Attestation$isNoAttestation = (value) =>
  value instanceof NoAttestation;

export class Direct extends $CustomType {}
export const Attestation$Direct = () => new Direct();
export const Attestation$isDirect = (value) => value instanceof Direct;

export class Enterprise extends $CustomType {}
export const Attestation$Enterprise = () => new Enterprise();
export const Attestation$isEnterprise = (value) => value instanceof Enterprise;

export class Indirect extends $CustomType {}
export const Attestation$Indirect = () => new Indirect();
export const Attestation$isIndirect = (value) => value instanceof Indirect;

export class Platform extends $CustomType {}
export const AuthenticatorAttachement$Platform = () => new Platform();
export const AuthenticatorAttachement$isPlatform = (value) =>
  value instanceof Platform;

export class CrossPlatform extends $CustomType {}
export const AuthenticatorAttachement$CrossPlatform = () => new CrossPlatform();
export const AuthenticatorAttachement$isCrossPlatform = (value) =>
  value instanceof CrossPlatform;

export class Ed25519 extends $CustomType {}
export const Algorithm$Ed25519 = () => new Ed25519();
export const Algorithm$isEd25519 = (value) => value instanceof Ed25519;

export class ES256 extends $CustomType {}
export const Algorithm$ES256 = () => new ES256();
export const Algorithm$isES256 = (value) => value instanceof ES256;

export class RS256 extends $CustomType {}
export const Algorithm$RS256 = () => new RS256();
export const Algorithm$isRS256 = (value) => value instanceof RS256;

export class Required extends $CustomType {}
export const Requirement$Required = () => new Required();
export const Requirement$isRequired = (value) => value instanceof Required;

export class Preferred extends $CustomType {}
export const Requirement$Preferred = () => new Preferred();
export const Requirement$isPreferred = (value) => value instanceof Preferred;

export class Discouraged extends $CustomType {}
export const Requirement$Discouraged = () => new Discouraged();
export const Requirement$isDiscouraged = (value) =>
  value instanceof Discouraged;

export class Ble extends $CustomType {}
export const Transport$Ble = () => new Ble();
export const Transport$isBle = (value) => value instanceof Ble;

export class HybridTransport extends $CustomType {}
export const Transport$HybridTransport = () => new HybridTransport();
export const Transport$isHybridTransport = (value) =>
  value instanceof HybridTransport;

export class Internal extends $CustomType {}
export const Transport$Internal = () => new Internal();
export const Transport$isInternal = (value) => value instanceof Internal;

export class Nfc extends $CustomType {}
export const Transport$Nfc = () => new Nfc();
export const Transport$isNfc = (value) => value instanceof Nfc;

export class Usb extends $CustomType {}
export const Transport$Usb = () => new Usb();
export const Transport$isUsb = (value) => value instanceof Usb;

export class SecurityKey extends $CustomType {}
export const Hint$SecurityKey = () => new SecurityKey();
export const Hint$isSecurityKey = (value) => value instanceof SecurityKey;

export class ClientDevice extends $CustomType {}
export const Hint$ClientDevice = () => new ClientDevice();
export const Hint$isClientDevice = (value) => value instanceof ClientDevice;

export class HybridHint extends $CustomType {}
export const Hint$HybridHint = () => new HybridHint();
export const Hint$isHybridHint = (value) => value instanceof HybridHint;

/**
 * Create an object with all the default creation options set.
 * The arguments to this function are the creation options that must be unique to each creation.
 */
export function creation(
  challenge,
  algorithm,
  relaying_party_name,
  user_id,
  user_name,
  user_display_name
) {
  return new CreationOptions(
    new NoAttestation(),
    toList([]),
    new None(),
    new Discouraged(),
    new Preferred(),
    challenge,
    toList([]),
    toList([algorithm]),
    new None(),
    relaying_party_name,
    new None(),
    user_id,
    user_name,
    user_display_name,
    toList([]),
  );
}

export function request(challenge) {
  return new RequestOptions(
    toList([]),
    challenge,
    toList([]),
    new None(),
    new None(),
    new Preferred(),
  );
}

function attestation_to_string(attestation) {
  if (attestation instanceof NoAttestation) {
    return "none";
  } else if (attestation instanceof Direct) {
    return "direct";
  } else if (attestation instanceof Enterprise) {
    return "enterprise";
  } else {
    return "indirect";
  }
}

function authenticator_attachment_to_string(authenticator_attachment) {
  if (authenticator_attachment instanceof Platform) {
    return "platform";
  } else {
    return "cross-platform";
  }
}

export function algorithm_to_number(algorithm) {
  if (algorithm instanceof Ed25519) {
    return -8;
  } else if (algorithm instanceof ES256) {
    return -7;
  } else {
    return -257;
  }
}

function requirement_to_string(requirement) {
  if (requirement instanceof Required) {
    return "required";
  } else if (requirement instanceof Preferred) {
    return "preferred";
  } else {
    return "discouraged";
  }
}

function transport_to_string(transport) {
  if (transport instanceof Ble) {
    return "ble";
  } else if (transport instanceof HybridTransport) {
    return "hybrid";
  } else if (transport instanceof Internal) {
    return "internal";
  } else if (transport instanceof Nfc) {
    return "nfc";
  } else {
    return "usb";
  }
}

function hint_to_string(hint) {
  if (hint instanceof SecurityKey) {
    return "security-key";
  } else if (hint instanceof ClientDevice) {
    return "client-device";
  } else {
    return "hybrid";
  }
}

function json_bitarry(bytes) {
  return $json.string($bit_array.base64_url_encode(bytes, false));
}

function allow_exclude_credential_to_json(credential_id) {
  let id$1;
  let transports;
  id$1 = credential_id[0];
  transports = credential_id[1];
  return $json.object(
    toList([
      ["id", json_bitarry(id$1)],
      [
        "transports",
        $json.array(
          transports,
          (x) => { return $json.string(transport_to_string(x)); },
        ),
      ],
      ["type", $json.string("public-key")],
    ]),
  );
}

function creation_options_to_native(options) {
  let options$1 = json_object(
    toList([
      ["attestation", $json.string(attestation_to_string(options.attestation))],
      [
        "attestation_formats",
        $json.array(options.attestation_formats, $json.string),
      ],
      [
        "authenticatorSelection",
        $json.object(
          toList([
            [
              "authenticatorAttachement",
              $json.nullable(
                options.authenticator_attachement,
                (x) => {
                  return $json.string(authenticator_attachment_to_string(x));
                },
              ),
            ],
            [
              "residentKey",
              $json.string(requirement_to_string(options.resident_key)),
            ],
            [
              "userVerification",
              $json.string(requirement_to_string(options.user_verification)),
            ],
          ]),
        ),
      ],
      ["challenge", json_bitarry(options.challenge)],
      [
        "excludeCredentials",
        $json.array(
          options.exclude_credentials,
          allow_exclude_credential_to_json,
        ),
      ],
      [
        "pubKeyCredParams",
        $json.array(
          options.public_key_credential_parameters,
          (a) => {
            return $json.object(
              toList([
                ["alg", $json.int(algorithm_to_number(a))],
                ["type", $json.string("public-key")],
              ]),
            );
          },
        ),
      ],
      [
        "rp",
        json_object(
          toList([
            ["id", $json.nullable(options.relaying_party_id, $json.string)],
            ["name", $json.string(options.relaying_party_name)],
          ]),
        ),
      ],
      ["timeout", $json.nullable(options.timeout, $json.int)],
      [
        "user",
        $json.object(
          toList([
            ["displayName", $json.string(options.user_display_name)],
            ["id", json_bitarry(options.user_id)],
            ["name", $json.string(options.user_name)],
          ]),
        ),
      ],
      [
        "hints",
        $json.array(
          options.hints,
          (h) => { return $json.string(hint_to_string(h)); },
        ),
      ],
    ]),
  );
  let $ = parse_creation_options_from_json(options$1);
  if ($ instanceof Ok) {
    let options$2 = $[0];
    return options$2;
  } else {
    let reason = $[0];
    $io.println(reason);
    throw makeError(
      "panic",
      FILEPATH,
      "plinth/browser/credentials/public_key",
      270,
      "creation_options_to_native",
      "should be valid by construction",
      {}
    )
  }
}

/**
 * Create a new public key credential.
 */
export function create(container, options) {
  return do_create(container, creation_options_to_native(options));
}

function request_options_to_native(options) {
  let options$1 = json_object(
    toList([
      [
        "allowCredentials",
        $json.array(options.allow_credentials, allow_exclude_credential_to_json),
      ],
      ["challenge", json_bitarry(options.challenge)],
      [
        "hints",
        $json.array(
          options.hints,
          (h) => { return $json.string(hint_to_string(h)); },
        ),
      ],
      ["rpId", $json.nullable(options.relaying_party_id, $json.string)],
      ["timeout", $json.nullable(options.timeout, $json.int)],
      [
        "userVerification",
        $json.string(requirement_to_string(options.user_verification)),
      ],
    ]),
  );
  let $ = parse_request_options_from_json(options$1);
  if ($ instanceof Ok) {
    let options$2 = $[0];
    return options$2;
  } else {
    let reason = $[0];
    $io.println(reason);
    throw makeError(
      "panic",
      FILEPATH,
      "plinth/browser/credentials/public_key",
      328,
      "request_options_to_native",
      "should be valid by construction",
      {}
    )
  }
}

export function get(container, options) {
  return do_get(container, request_options_to_native(options));
}

export function authenticator_attachment(credential) {
  let $ = do_authenticator_attachment(credential);
  if ($ === "platform") {
    return new Platform();
  } else if ($ === "cross-platform") {
    return new CrossPlatform();
  } else {
    throw makeError(
      "panic",
      FILEPATH,
      "plinth/browser/credentials/public_key",
      354,
      "authenticator_attachment",
      "An invalid value of authenticator attachement was returned from the credential.",
      {}
    )
  }
}
