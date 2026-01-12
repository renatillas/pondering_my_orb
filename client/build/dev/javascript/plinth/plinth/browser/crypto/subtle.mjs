import * as $array from "../../../../gleam_javascript/gleam/javascript/array.mjs";
import * as $promise from "../../../../gleam_javascript/gleam/javascript/promise.mjs";
import * as $json from "../../../../gleam_json/gleam/json.mjs";
import * as $list from "../../../../gleam_stdlib/gleam/list.mjs";
import { toList, CustomType as $CustomType } from "../../../gleam.mjs";
import {
  digest as do_digest,
  exportJwk as export_jwk,
  generateKey as do_generate_key,
  importKey as do_import_key,
  importJwk as do_import_jwk,
  sign as do_sign,
  verify as do_verify,
} from "../../../plinth_browser_crypto_subtle_ffi.mjs";

export { export_jwk };

export class SHA1 extends $CustomType {}
export const DigestAlgorithm$SHA1 = () => new SHA1();
export const DigestAlgorithm$isSHA1 = (value) => value instanceof SHA1;

export class SHA256 extends $CustomType {}
export const DigestAlgorithm$SHA256 = () => new SHA256();
export const DigestAlgorithm$isSHA256 = (value) => value instanceof SHA256;

export class SHA384 extends $CustomType {}
export const DigestAlgorithm$SHA384 = () => new SHA384();
export const DigestAlgorithm$isSHA384 = (value) => value instanceof SHA384;

export class SHA512 extends $CustomType {}
export const DigestAlgorithm$SHA512 = () => new SHA512();
export const DigestAlgorithm$isSHA512 = (value) => value instanceof SHA512;

export class RsaHashedKeyGenParams extends $CustomType {
  constructor(name, modulus_length, public_exponent, hash) {
    super();
    this.name = name;
    this.modulus_length = modulus_length;
    this.public_exponent = public_exponent;
    this.hash = hash;
  }
}
export const PublicKeyAlgorithm$RsaHashedKeyGenParams = (name, modulus_length, public_exponent, hash) =>
  new RsaHashedKeyGenParams(name, modulus_length, public_exponent, hash);
export const PublicKeyAlgorithm$isRsaHashedKeyGenParams = (value) =>
  value instanceof RsaHashedKeyGenParams;
export const PublicKeyAlgorithm$RsaHashedKeyGenParams$name = (value) =>
  value.name;
export const PublicKeyAlgorithm$RsaHashedKeyGenParams$0 = (value) => value.name;
export const PublicKeyAlgorithm$RsaHashedKeyGenParams$modulus_length = (value) =>
  value.modulus_length;
export const PublicKeyAlgorithm$RsaHashedKeyGenParams$1 = (value) =>
  value.modulus_length;
export const PublicKeyAlgorithm$RsaHashedKeyGenParams$public_exponent = (value) =>
  value.public_exponent;
export const PublicKeyAlgorithm$RsaHashedKeyGenParams$2 = (value) =>
  value.public_exponent;
export const PublicKeyAlgorithm$RsaHashedKeyGenParams$hash = (value) =>
  value.hash;
export const PublicKeyAlgorithm$RsaHashedKeyGenParams$3 = (value) => value.hash;

export class EcKeyGenParams extends $CustomType {
  constructor(name, named_curve) {
    super();
    this.name = name;
    this.named_curve = named_curve;
  }
}
export const PublicKeyAlgorithm$EcKeyGenParams = (name, named_curve) =>
  new EcKeyGenParams(name, named_curve);
export const PublicKeyAlgorithm$isEcKeyGenParams = (value) =>
  value instanceof EcKeyGenParams;
export const PublicKeyAlgorithm$EcKeyGenParams$name = (value) => value.name;
export const PublicKeyAlgorithm$EcKeyGenParams$0 = (value) => value.name;
export const PublicKeyAlgorithm$EcKeyGenParams$named_curve = (value) =>
  value.named_curve;
export const PublicKeyAlgorithm$EcKeyGenParams$1 = (value) => value.named_curve;

export const PublicKeyAlgorithm$name = (value) => value.name;

export class Encrypt extends $CustomType {}
export const KeyUsage$Encrypt = () => new Encrypt();
export const KeyUsage$isEncrypt = (value) => value instanceof Encrypt;

export class Decrypt extends $CustomType {}
export const KeyUsage$Decrypt = () => new Decrypt();
export const KeyUsage$isDecrypt = (value) => value instanceof Decrypt;

export class Sign extends $CustomType {}
export const KeyUsage$Sign = () => new Sign();
export const KeyUsage$isSign = (value) => value instanceof Sign;

export class Verify extends $CustomType {}
export const KeyUsage$Verify = () => new Verify();
export const KeyUsage$isVerify = (value) => value instanceof Verify;

export class DeriveKey extends $CustomType {}
export const KeyUsage$DeriveKey = () => new DeriveKey();
export const KeyUsage$isDeriveKey = (value) => value instanceof DeriveKey;

export class DeriveBits extends $CustomType {}
export const KeyUsage$DeriveBits = () => new DeriveBits();
export const KeyUsage$isDeriveBits = (value) => value instanceof DeriveBits;

export class WrapKey extends $CustomType {}
export const KeyUsage$WrapKey = () => new WrapKey();
export const KeyUsage$isWrapKey = (value) => value instanceof WrapKey;

export class UnwrapKey extends $CustomType {}
export const KeyUsage$UnwrapKey = () => new UnwrapKey();
export const KeyUsage$isUnwrapKey = (value) => value instanceof UnwrapKey;

export class RsaHashedImportParams extends $CustomType {
  constructor(name, hash) {
    super();
    this.name = name;
    this.hash = hash;
  }
}
export const ImportAlgorithm$RsaHashedImportParams = (name, hash) =>
  new RsaHashedImportParams(name, hash);
export const ImportAlgorithm$isRsaHashedImportParams = (value) =>
  value instanceof RsaHashedImportParams;
export const ImportAlgorithm$RsaHashedImportParams$name = (value) => value.name;
export const ImportAlgorithm$RsaHashedImportParams$0 = (value) => value.name;
export const ImportAlgorithm$RsaHashedImportParams$hash = (value) => value.hash;
export const ImportAlgorithm$RsaHashedImportParams$1 = (value) => value.hash;

export class EcKeyImportParams extends $CustomType {
  constructor(name, named_curve) {
    super();
    this.name = name;
    this.named_curve = named_curve;
  }
}
export const ImportAlgorithm$EcKeyImportParams = (name, named_curve) =>
  new EcKeyImportParams(name, named_curve);
export const ImportAlgorithm$isEcKeyImportParams = (value) =>
  value instanceof EcKeyImportParams;
export const ImportAlgorithm$EcKeyImportParams$name = (value) => value.name;
export const ImportAlgorithm$EcKeyImportParams$0 = (value) => value.name;
export const ImportAlgorithm$EcKeyImportParams$named_curve = (value) =>
  value.named_curve;
export const ImportAlgorithm$EcKeyImportParams$1 = (value) => value.named_curve;

export class HmacImportParams extends $CustomType {
  constructor(hash) {
    super();
    this.hash = hash;
  }
}
export const ImportAlgorithm$HmacImportParams = (hash) =>
  new HmacImportParams(hash);
export const ImportAlgorithm$isHmacImportParams = (value) =>
  value instanceof HmacImportParams;
export const ImportAlgorithm$HmacImportParams$hash = (value) => value.hash;
export const ImportAlgorithm$HmacImportParams$0 = (value) => value.hash;

export class OtherImportParams extends $CustomType {
  constructor(name) {
    super();
    this.name = name;
  }
}
export const ImportAlgorithm$OtherImportParams = (name) =>
  new OtherImportParams(name);
export const ImportAlgorithm$isOtherImportParams = (value) =>
  value instanceof OtherImportParams;
export const ImportAlgorithm$OtherImportParams$name = (value) => value.name;
export const ImportAlgorithm$OtherImportParams$0 = (value) => value.name;

export class P256 extends $CustomType {}
export const NamedCurve$P256 = () => new P256();
export const NamedCurve$isP256 = (value) => value instanceof P256;

export class P384 extends $CustomType {}
export const NamedCurve$P384 = () => new P384();
export const NamedCurve$isP384 = (value) => value instanceof P384;

export class P521 extends $CustomType {}
export const NamedCurve$P521 = () => new P521();
export const NamedCurve$isP521 = (value) => value instanceof P521;

export class RsaSsaPkcs1v15 extends $CustomType {}
export const SignAlgorithm$RsaSsaPkcs1v15 = () => new RsaSsaPkcs1v15();
export const SignAlgorithm$isRsaSsaPkcs1v15 = (value) =>
  value instanceof RsaSsaPkcs1v15;

export class RsaPssParams extends $CustomType {
  constructor(salt_length) {
    super();
    this.salt_length = salt_length;
  }
}
export const SignAlgorithm$RsaPssParams = (salt_length) =>
  new RsaPssParams(salt_length);
export const SignAlgorithm$isRsaPssParams = (value) =>
  value instanceof RsaPssParams;
export const SignAlgorithm$RsaPssParams$salt_length = (value) =>
  value.salt_length;
export const SignAlgorithm$RsaPssParams$0 = (value) => value.salt_length;

export class EcdsaParams extends $CustomType {
  constructor(hash) {
    super();
    this.hash = hash;
  }
}
export const SignAlgorithm$EcdsaParams = (hash) => new EcdsaParams(hash);
export const SignAlgorithm$isEcdsaParams = (value) =>
  value instanceof EcdsaParams;
export const SignAlgorithm$EcdsaParams$hash = (value) => value.hash;
export const SignAlgorithm$EcdsaParams$0 = (value) => value.hash;

export class Hmac extends $CustomType {}
export const SignAlgorithm$Hmac = () => new Hmac();
export const SignAlgorithm$isHmac = (value) => value instanceof Hmac;

export class Ed25519 extends $CustomType {}
export const SignAlgorithm$Ed25519 = () => new Ed25519();
export const SignAlgorithm$isEd25519 = (value) => value instanceof Ed25519;

export function digest_algorithm_to_string(algorithm) {
  if (algorithm instanceof SHA1) {
    return "SHA-1";
  } else if (algorithm instanceof SHA256) {
    return "SHA-256";
  } else if (algorithm instanceof SHA384) {
    return "SHA-384";
  } else {
    return "SHA-512";
  }
}

export function digest(algorithm, data) {
  return do_digest(digest_algorithm_to_string(algorithm), data);
}

function key_usage_to_string(key_usage) {
  if (key_usage instanceof Encrypt) {
    return "encrypt";
  } else if (key_usage instanceof Decrypt) {
    return "decrypt";
  } else if (key_usage instanceof Sign) {
    return "sign";
  } else if (key_usage instanceof Verify) {
    return "verify";
  } else if (key_usage instanceof DeriveKey) {
    return "deriveKey";
  } else if (key_usage instanceof DeriveBits) {
    return "deriveBits";
  } else if (key_usage instanceof WrapKey) {
    return "wrapKey";
  } else {
    return "unwrapKey";
  }
}

export function generate_key(algorithm, extractable, key_usages) {
  let _block;
  let _pipe = key_usages;
  let _pipe$1 = $list.map(_pipe, key_usage_to_string);
  _block = $array.from_list(_pipe$1);
  let key_usages$1 = _block;
  return do_generate_key(algorithm, extractable, key_usages$1);
}

function named_curve_to_string(named_curve) {
  if (named_curve instanceof P256) {
    return "P-256";
  } else if (named_curve instanceof P384) {
    return "P-384";
  } else {
    return "P-521";
  }
}

function import_algorithm_to_json(algorithm_parameters) {
  if (algorithm_parameters instanceof RsaHashedImportParams) {
    let name = algorithm_parameters.name;
    let hash = algorithm_parameters.hash;
    return $json.object(
      toList([
        ["name", $json.string(name)],
        ["hash", $json.string(digest_algorithm_to_string(hash))],
      ]),
    );
  } else if (algorithm_parameters instanceof EcKeyImportParams) {
    let name = algorithm_parameters.name;
    let named_curve = algorithm_parameters.named_curve;
    return $json.object(
      toList([
        ["name", $json.string(name)],
        ["namedCurve", $json.string(named_curve_to_string(named_curve))],
      ]),
    );
  } else if (algorithm_parameters instanceof HmacImportParams) {
    let hash = algorithm_parameters.hash;
    return $json.object(
      toList([
        ["name", $json.string("HMAC")],
        ["hash", $json.string(digest_algorithm_to_string(hash))],
      ]),
    );
  } else {
    let name = algorithm_parameters.name;
    return $json.object(toList([["name", $json.string(name)]]));
  }
}

export function import_key(format, key_data, algorithm, extractable, key_usages) {
  let algorithm$1 = import_algorithm_to_json(algorithm);
  let _block;
  let _pipe = key_usages;
  let _pipe$1 = $list.map(_pipe, key_usage_to_string);
  _block = $array.from_list(_pipe$1);
  let key_usages$1 = _block;
  return do_import_key(format, key_data, algorithm$1, extractable, key_usages$1);
}

export function import_jwk(key_data, algorithm, extractable, key_usages) {
  let algorithm$1 = import_algorithm_to_json(algorithm);
  let _block;
  let _pipe = key_usages;
  let _pipe$1 = $list.map(_pipe, key_usage_to_string);
  _block = $array.from_list(_pipe$1);
  let key_usages$1 = _block;
  return do_import_jwk(key_data, algorithm$1, extractable, key_usages$1);
}

function sign_algorithm_to_json(key_algorithm) {
  if (key_algorithm instanceof RsaSsaPkcs1v15) {
    return $json.object(toList([["name", $json.string("RSASSA-PKCS1-v1_5")]]));
  } else if (key_algorithm instanceof RsaPssParams) {
    let salt_length = key_algorithm.salt_length;
    return $json.object(
      toList([
        ["name", $json.string("RSA-PSS")],
        ["saltLength", $json.int(salt_length)],
      ]),
    );
  } else if (key_algorithm instanceof EcdsaParams) {
    let hash = key_algorithm.hash;
    return $json.object(
      toList([
        ["name", $json.string("ECDSA")],
        ["hash", $json.string(digest_algorithm_to_string(hash))],
      ]),
    );
  } else if (key_algorithm instanceof Hmac) {
    return $json.object(toList([["name", $json.string("HMAC")]]));
  } else {
    return $json.object(toList([["name", $json.string("Ed25519")]]));
  }
}

export function sign(algorithm, key, data) {
  let algorithm$1 = sign_algorithm_to_json(algorithm);
  return do_sign(algorithm$1, key, data);
}

export function verify(algorithm, key, signature, data) {
  let algorithm$1 = sign_algorithm_to_json(algorithm);
  return do_verify(algorithm$1, key, signature, data);
}
