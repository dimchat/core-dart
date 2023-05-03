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

import 'entity.dart';

///  User account for communication
///  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
///  This class is for creating user account
///
///  functions:
///      (User)
///      1. verify(data, signature) - verify (encrypted content) data and signature
///      2. encrypt(data)           - encrypt (symmetric key) data
///      (LocalUser)
///      3. sign(data)    - calculate signature of (encrypted content) data
///      4. decrypt(data) - decrypt (symmetric key) data
abstract class User implements Entity {

  /// user document
  Future<Visa?> get visa;

  ///  Get all contacts of the user
  ///
  /// @return contact list
  Future<List<ID>> get contacts;

  ///  Verify data and signature with user's public keys
  ///
  /// @param data - message data
  /// @param signature - message signature
  /// @return true on correct
  Future<bool> verify(Uint8List data, Uint8List signature);

  ///  Encrypt data, try visa.key first, if not found, use meta.key
  ///
  /// @param plaintext - message data
  /// @return encrypted data
  Future<Uint8List> encrypt(Uint8List plaintext);

  //
  //  Interfaces for Local User
  //

  ///  Sign data with user's private key
  ///
  /// @param data - message data
  /// @return signature
  Future<Uint8List> sign(Uint8List data);

  ///  Decrypt data with user's private key(s)
  ///
  /// @param ciphertext - encrypted data
  /// @return plain text
  Future<Uint8List?> decrypt(Uint8List ciphertext);

  //
  //  Interfaces for Visa
  //
  Future<Visa?> signVisa(Visa doc);
  Future<bool> verifyVisa(Visa doc);
}

///  User Data Source
///  ~~~~~~~~~~~~~~~~
///
///  (Encryption/decryption)
///  1. public key for encryption
///     if visa.key not exists, means it is the same key with meta.key
///  2. private keys for decryption
///     the private keys paired with [visa.key, meta.key]
///
///  (Signature/Verification)
///  3. private key for signature
///     the private key paired with visa.key or meta.key
///  4. public keys for verification
///     [visa.key, meta.key]
///
///  (Visa Document)
///  5. private key for visa signature
///     the private key pared with meta.key
///  6. public key for visa verification
///     meta.key only
abstract class UserDataSource implements EntityDataSource {

  ///  Get contacts list
  ///
  /// @param user - user ID
  /// @return contacts list (ID)
  Future<List<ID>> getContacts(ID user);

  ///  Get user's public key for encryption
  ///  (visa.key or meta.key)
  ///
  /// @param user - user ID
  /// @return visa.key or meta.key
  Future<EncryptKey?> getPublicKeyForEncryption(ID user);

  ///  Get user's public keys for verification
  ///  [visa.key, meta.key]
  ///
  /// @param user - user ID
  /// @return public keys
  Future<List<VerifyKey>> getPublicKeysForVerification(ID user);

  ///  Get user's private keys for decryption
  ///  (which paired with [visa.key, meta.key])
  ///
  /// @param user - user ID
  /// @return private keys
  Future<List<DecryptKey>> getPrivateKeysForDecryption(ID user);

  ///  Get user's private key for signature
  ///  (which paired with visa.key or meta.key)
  ///
  /// @param user - user ID
  /// @return private key
  Future<SignKey?> getPrivateKeyForSignature(ID user);

  ///  Get user's private key for signing visa
  ///
  /// @param user - user ID
  /// @return private key
  Future<SignKey?> getPrivateKeyForVisaSignature(ID user);
}

//
//  Base User
//

class BaseUser extends BaseEntity implements User {
  BaseUser(super.id);

  @override
  UserDataSource? get dataSource {
    EntityDataSource? barrack = super.dataSource;
    if (barrack == null) {
      return null;
    }
    assert(barrack is UserDataSource, 'user data source error: $barrack');
    return barrack as UserDataSource;
  }

  @override
  Future<Visa?> get visa async {
    Document? doc = await getDocument(Document.kBulletin);
    return doc is Visa ? doc : null;
  }

  @override
  Future<List<ID>> get contacts async =>
      await dataSource!.getContacts(identifier);

  @override
  Future<bool> verify(Uint8List data, Uint8List signature) async {
    UserDataSource? barrack = dataSource;
    assert(barrack != null, 'user data source not set yet');
    // NOTICE: I suggest using the private key paired with meta.key to sign message
    //         so here should return the meta.key
    List<VerifyKey> keys = await barrack!.getPublicKeysForVerification(identifier);
    for (VerifyKey pKey in keys) {
      if (pKey.verify(data, signature)) {
        // matched!
        return true;
      }
    }
    // signature not match
    // TODO: check whether visa is expired, query new document for this contact
    return false;
  }

  @override
  Future<Uint8List> encrypt(Uint8List plaintext) async {
    UserDataSource? barrack = dataSource;
    assert(barrack != null, 'user data source not set yet');
    // NOTICE: meta.key will never changed, so use visa.key to encrypt message
    //         is a better way
    EncryptKey? pKey = await barrack!.getPublicKeyForEncryption(identifier);
    assert(pKey != null, 'failed to get encrypt key for user: $identifier');
    return pKey!.encrypt(plaintext);
  }

  //
  //  Interfaces for Local User
  //

  @override
  Future<Uint8List> sign(Uint8List data) async {
    UserDataSource? barrack = dataSource;
    assert(barrack != null, 'user data source not set yet');
    // NOTICE: I suggest use the private key which paired to visa.key
    //         to sign message
    SignKey? sKey = await barrack!.getPrivateKeyForSignature(identifier);
    assert(sKey != null, 'failed to get sign key for user: $identifier');
    return sKey!.sign(data);
  }

  @override
  Future<Uint8List?> decrypt(Uint8List ciphertext) async {
    UserDataSource? barrack = dataSource;
    assert(barrack != null, 'user data source not set yet');
    // NOTICE: if you provide a public key in visa for encryption,
    //         here you should return the private key paired with visa.key
    List<DecryptKey> keys = await barrack!.getPrivateKeysForDecryption(identifier);
    assert(keys.isNotEmpty, 'failed to get decrypt keys for user: $identifier');
    Uint8List? plaintext;
    for (DecryptKey sKey in keys) {
      // try decrypting it with each private key
      plaintext = sKey.decrypt(ciphertext);
      if (plaintext != null) {
        // OK!
        return plaintext;
      }
    }
    // decryption failed
    // TODO: check whether my visa key is changed, push new visa to this contact
    return null;
  }

  @override
  Future<Visa?> signVisa(Visa doc) async {
    assert(doc.identifier == identifier, 'visa ID not match: $identifier, ${doc.identifier}');
    UserDataSource? barrack = dataSource;
    assert(barrack != null, 'user data source not set yet');
    // NOTICE: only sign visa with the private key paired with your meta.key
    SignKey? sKey = await barrack!.getPrivateKeyForVisaSignature(identifier);
    assert(sKey != null, 'failed to get sign key for visa: $identifier');
    return sKey == null || doc.sign(sKey) == null ? null : doc;
  }

  @override
  Future<bool> verifyVisa(Visa doc) async {
    // NOTICE: only verify visa with meta.key
    if (identifier != doc.identifier) {
      // visa ID not match
      return false;
    }
    // if meta not exists, user won't be created
    VerifyKey pKey = (await meta).key;
    return doc.verify(pKey);
  }
}
