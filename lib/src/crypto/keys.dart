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
import 'package:mkm/crypto.dart';

///
/// Base Keys
///

abstract class BaseKey extends Dictionary implements CryptographyKey {
  BaseKey(super.dict);

  @override
  String get algorithm => getKeyAlgorithm(toMap());

  //
  //  Conveniences
  //

  static String getKeyAlgorithm(Map key) {
    CryptographyKeyFactoryManager man = CryptographyKeyFactoryManager();
    return man.generalFactory.getAlgorithm(key, '')!;
  }

  static bool matchEncryptKey(EncryptKey pKey, DecryptKey sKey) {
    CryptographyKeyFactoryManager man = CryptographyKeyFactoryManager();
    return man.generalFactory.matchSymmetricKeys(pKey, sKey);
  }

  static bool matchSignKey(SignKey sKey, VerifyKey pKey) {
    CryptographyKeyFactoryManager man = CryptographyKeyFactoryManager();
    return man.generalFactory.matchAsymmetricKeys(sKey, pKey);
  }

  static bool symmetricKeyEquals(SymmetricKey a, SymmetricKey b) {
    if (identical(a, b)) {
      // same object
      return true;
    }
    // compare by encryption
    return matchEncryptKey(a, b);
  }

  static bool privateKeyEquals(PrivateKey a, PrivateKey b) {
    if (identical(a, b)) {
      // same object
      return true;
    }
    // compare by signature
    return matchSignKey(a, b.publicKey);
  }
}


///
/// Symmetric Key
///

abstract class BaseSymmetricKey extends Dictionary implements SymmetricKey {
  BaseSymmetricKey(super.dict);

  @override
  bool operator ==(Object other) =>
      other is SymmetricKey && BaseKey.symmetricKeyEquals(other, this);

  @override
  int get hashCode => toMap().hashCode;

  @override
  String get algorithm => BaseKey.getKeyAlgorithm(toMap());

  @override
  bool matchEncryptKey(EncryptKey pKey) => BaseKey.matchEncryptKey(pKey, this);
}


///
/// Asymmetric Keys
///

abstract class BaseAsymmetricKey extends Dictionary implements AsymmetricKey {
  BaseAsymmetricKey(super.dict);

  @override
  String get algorithm => BaseKey.getKeyAlgorithm(toMap());
}


abstract class BasePrivateKey extends Dictionary implements PrivateKey {
  BasePrivateKey(super.dict);

  @override
  bool operator ==(Object other) =>
      other is PrivateKey && BaseKey.privateKeyEquals(other, this);

  @override
  int get hashCode => toMap().hashCode;

  @override
  String get algorithm => BaseKey.getKeyAlgorithm(toMap());
}


abstract class BasePublicKey extends Dictionary implements PublicKey {
  BasePublicKey(super.dict);

  @override
  String get algorithm => BaseKey.getKeyAlgorithm(toMap());

  @override
  bool matchSignKey(SignKey sKey) => BaseKey.matchSignKey(sKey, this);
}
