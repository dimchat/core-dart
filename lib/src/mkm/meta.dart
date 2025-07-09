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
import 'package:mkm/format.dart';
import 'package:mkm/mkm.dart';
import 'package:mkm/plugins.dart';
import 'package:mkm/type.dart';

///  User/Group Meta data
///  ~~~~~~~~~~~~~~~~~~~~
///  This class is used to generate entity ID
///
///      data format: {
///          type        : 1,              // algorithm version
///          key         : "{public key}", // PK = secp256k1(SK);
///          seed        : "moKy",         // user/group name
///          fingerprint : "..."           // CT = sign(seed, SK);
///      }
///
///      algorithm:
///          fingerprint = sign(seed, SK);
///
///  abstract method:
///      - Address generateAddress(int? network);
abstract class BaseMeta extends Dictionary implements Meta {
  BaseMeta(super.dict);

  ///  Meta algorithm version
  ///
  ///      1 = MKM : username@address (default)
  ///      2 = BTC : btc_address
  ///      4 = ETH : eth_address
  ///      ...
  String? _type;

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

  BaseMeta.from(String type, VerifyKey key, {String? seed, TransportableData? fingerprint})
      : super(null) {
    //
    //  meta type
    //
    this['type'] = type;
    _type = type;
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
  String get type {
    _type ??= SharedAccountExtensions().helper!.getMetaType(toMap(), '');
    // _type ??= getInt('type', 0);
    return _type ?? '';
  }

  @override
  VerifyKey get publicKey {
    _key ??= PublicKey.parse(this['key']);
    assert(_key != null, 'meta key error: $this');
    return _key!;
  }

  // protected
  bool get hasSeed;
  // bool get hasSeed {
  //   String algorithm = type;
  //   return algorithm == '1' || algorithm == 'MKM';
  // }

  @override
  String? get seed {
    if (_seed == null && hasSeed) {
      _seed = getString('seed', '');
      assert(_seed!.isNotEmpty, 'meta.seed empty: $this');
    }
    return _seed;
  }

  @override
  Uint8List? get fingerprint {
    TransportableData? ted = _fingerprint;
    if (ted == null && hasSeed) {
      Object? base64 = this['fingerprint'];
      assert(base64 != null, 'meta.fingerprint should not be empty: ${toMap()}');
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
      if (checkValid()) {
        // correct
        _status = 1;
      } else {
        // error
        _status = -1;
      }
    }
    return _status > 0;
  }

  // private
  bool checkValid() {
    VerifyKey key = publicKey;
    if (hasSeed) {
      // check 'seed' & 'fingerprint'
    } else if (containsKey('seed') || containsKey('fingerprint')) {
      // this meta has no seed, so
      // it should not contains 'seed' or 'fingerprint'
      return false;
    } else {
      // this meta has no seed, so it's always valid
      // when the public key exists
      return true;
    }
    String? name = seed;
    Uint8List? signature = fingerprint;
    // check meta seed & signature
    if (signature == null || signature.isEmpty ||
        name == null || name.isEmpty) {
      assert(false, 'meta error: $toMap()');
      return false;
    }
    // verify fingerprint
    Uint8List data = UTF8.encode(name);
    return key.verify(data, signature);
  }

}
