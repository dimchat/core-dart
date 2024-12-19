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


abstract interface class MetaHelper {

  static bool checkMeta(Meta meta) {
    VerifyKey key = meta.publicKey;
    String? seed = meta.seed;
    Uint8List? fingerprint = meta.fingerprint;
    // check meta seed & signature
    if (seed == null || seed.isEmpty) {
      // this meta has no seed, so no fingerprint too
      return fingerprint == null || fingerprint.isEmpty;
    } else if (fingerprint == null || fingerprint.isEmpty) {
      // fingerprint should not be empty here
      return false;
    }
    // verify fingerprint
    Uint8List data = UTF8.encode(seed);
    return key.verify(data, fingerprint);
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
    String? seed = meta.seed;
    if (seed == null || seed.isEmpty) {
      // NOTICE: ID with BTC/ETH address has no username, so
      //         just compare the key.data to check matching
      return false;
    }
    Uint8List? fingerprint = meta.fingerprint;
    if (fingerprint == null || fingerprint.isEmpty) {
      // fingerprint should not be empty here
      return false;
    }
    // check whether keys equal by verifying signature
    Uint8List data = UTF8.encode(seed);
    return pKey.verify(data, fingerprint);
  }

}
