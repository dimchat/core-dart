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
abstract class BaseMeta extends Dictionary implements Meta {
  BaseMeta(super.dict) : _type = 0, _key = null, _seed = null, _fingerprint = null;

  BaseMeta.from(int type, VerifyKey key, String? seed, Uint8List? fingerprint)
      : super(null) {
    //
    //  meta type
    //
    this['type'] = type;
    _type = type;
    //
    //  public key
    //
    setMap('key', key);
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
      this['fingerprint'] = Base64.encode(fingerprint);
    }
    _fingerprint = fingerprint;
  }

  ///  Meta algorithm version
  ///
  ///      0x01 - username@address
  ///      0x02 - btc_address
  ///      0x03 - username@btc_address
  int _type = 0;

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
  Uint8List? _fingerprint;

  @override
  int get type {
    if (_type == 0) {
      _type = getInt('type');
    }
    return _type;
  }

  @override
  VerifyKey get key {
    _key ??= PublicKey.parse(this['key']);
    assert(_key != null, 'meta key error: $dictionary');
    return _key!;
  }

  @override
  String? get seed {
    if (_seed == null && MetaType.hasSeed(type)) {
      String? name = getString('seed');
      assert(name != null && name.isNotEmpty, 'meta.seed empty: $dictionary');
      _seed = name;
    }
    return _seed;
  }

  @override
  Uint8List? get fingerprint {
    if (_fingerprint == null && MetaType.hasSeed(type)) {
      String? b64 = getString('fingerprint');
      assert(b64 != null, 'meta.fingerprint empty: $dictionary');
      _fingerprint = b64 == null ? null : Base64.decode(b64);
      assert(_fingerprint != null, 'meta.fingerprint error: $dictionary');
    }
    return _fingerprint;
  }
}
