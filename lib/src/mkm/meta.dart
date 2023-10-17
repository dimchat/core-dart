/* license: https://mit-license.org
 *
 *  DIMP : Decentralized Instant Messaging Protocol
 *
 *                                Written in 2023 by Moky <albert.moky@gmail.com>
 *
 * ==============================================================================
 * The MIT License (MIT)
 *
 * Copyright (c) 2023 Albert Moky
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * ==============================================================================
 */
import 'dart:typed_data';

import 'package:mkm/crypto.dart';
import 'package:mkm/mkm.dart';

///  User/Group Meta data
///  ~~~~~~~~~~~~~~~~~~~~
///  This class is used to generate entity ID
///
///      data format: {
///          type: 1,             // algorithm version
///          seed: "moKy",        // user/group name
///          key: "{public key}", // PK = secp256k1(SK);
///          fingerprint: "..."   // CT = sign(seed, SK);
///      }
///
///      algorithm:
///          fingerprint = sign(seed, SK);
///
///  abstract method:
///      - Address generateAddress(int? network);
abstract class BaseMeta extends Dictionary implements Meta {
  BaseMeta(super.dict) : _type = null, _key = null, _seed = null, _fingerprint = null, _status = 0;

  ///  Meta algorithm version
  ///
  ///      0x01 - username@address
  ///      0x02 - btc_address
  ///      0x03 - username@btc_address
  int? _type;

  ///  Public key (used for signature)
  ///
  ///      RSA / ECC
  VerifyKey? _key;

  ///  Seed to generate fingerprint
  ///
  ///      Username / Group-X
  String? _seed;

  ///  Fingerprint to verify ID and public key
  ///
  ///      Build: fingerprint = sign(seed, privateKey)
  ///      Check: verify(seed, fingerprint, publicKey)
  TransportableData? _fingerprint;

  int _status = 0;  // 1 for valid, -1 for invalid

  BaseMeta.from(int version, VerifyKey key, {String? seed, TransportableData? fingerprint})
      : super(null) {
    //
    //  meta type
    //
    this['type'] = version;
    _type = version;
    //
    //  public key
    //
    this['key'] = key.toMap();
    _key = key;
    //
    //  ID name
    //
    if (seed != null) {
      this['seed'] = seed;
    }
    _seed = seed;
    //
    //  fingerprint
    //
    if (fingerprint != null) {
      this['fingerprint'] = fingerprint.toObject();
    }
    _fingerprint = fingerprint;

    // generated meta, or loaded from local storage,
    // no need to verify again.
    _status = 1;
  }

  @override
  int get type {
    _type ??= AccountFactoryManager().generalFactory.getMetaType(toMap(), 0);
    // _type ??= getInt('type', 0);
    return _type!;
  }

  @override
  VerifyKey get publicKey {
    _key ??= PublicKey.parse(this['key']);
    assert(_key != null, 'meta key error: $this');
    return _key!;
  }

  @override
  String? get seed {
    if (_seed == null && MetaType.hasSeed(type)) {
      _seed = getString('seed', null);
      assert(_seed!.isNotEmpty, 'meta.seed empty: $this');
    }
    return _seed;
  }

  @override
  Uint8List? get fingerprint {
    TransportableData? ted = _fingerprint;
    if (ted == null && MetaType.hasSeed(type)) {
      Object? base64 = this['fingerprint'];
      assert(base64 != null, 'meta.fingerprint should not be empty: $this');
      _fingerprint = ted = TransportableData.parse(base64);
      assert(ted != null, 'meta.fingerprint error: $base64');
    }
    return ted?.data;
  }

  //
  //  Validation
  //

  @override
  bool get isValid {
    if (_status == 0) {
      // meta from network, try to verify
      if (MetaHelper.checkMeta(this)) {
        // correct
        _status = 1;
      } else {
        // error
        _status = -1;
      }
    }
    return _status > 0;
  }

  @override
  bool matchIdentifier(ID identifier) => MetaHelper.matchIdentifier(identifier, this);

  @override
  bool matchPublicKey(VerifyKey pKey) => MetaHelper.matchPublicKey(pKey, this);

}

abstract class MetaHelper {

  static bool checkMeta(Meta meta) {
    VerifyKey key = meta.publicKey;
    // assert(key != null, 'meta.key should not be empty: $meta');
    String? seed = meta.seed;
    Uint8List? fingerprint = meta.fingerprint;
    bool noSeed = seed == null || seed.isEmpty;
    bool noSig = fingerprint == null || fingerprint.isEmpty;
    // check meta version
    if (!MetaType.hasSeed(meta.type)) {
      // this meta has no seed, so no fingerprint too
      return noSeed && noSig;
    } else if (noSeed || noSig) {
      // seed and fingerprint should not be empty
      return false;
    }
    // verify fingerprint
    return key.verify(UTF8.encode(seed), fingerprint);
  }

  static bool matchIdentifier(ID identifier, Meta meta) {
    assert(meta.isValid, 'meta not valid: $meta');
    // check ID.name
    String? seed = meta.seed;
    String? name = identifier.name;
    if (name == null || name.isEmpty) {
      if (seed != null && seed.isNotEmpty) {
        return false;
      }
    } else if (name != seed) {
      return false;
    }
    // check ID.address
    Address old = identifier.address;
    Address gen = Address.generate(meta, old.type);
    return old == gen;
  }

  static bool matchPublicKey(VerifyKey pKey, Meta meta) {
    assert(meta.isValid, 'meta not valid: $meta');
    // check whether the public key equals to meta.key
    if (pKey == meta.publicKey) {
      return true;
    }
    // check with seed & fingerprint
    if (MetaType.hasSeed(meta.type)) {
      // check whether keys equal by verifying signature
      String? seed = meta.seed;
      Uint8List? fingerprint = meta.fingerprint;
      return pKey.verify(UTF8.encode(seed!), fingerprint!);
    } else {
      // NOTICE: ID with BTC/ETH address has no username, so
      //         just compare the key.data to check matching
      return false;
    }
  }

}
