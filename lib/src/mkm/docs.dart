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
import 'package:mkm/format.dart';
import 'package:mkm/type.dart';
import 'package:mkm/protocol.dart';

import '../format/file.dart';
import '../protocol/version.dart';
import '../protocol/docs.dart';

import 'document.dart';


///
/// Base Document for User
/// ~~~~~~~~~~~~~~~~~~~~~~
///
class BaseVisa extends BaseDocument implements Visa {
  BaseVisa([super.dict]);

  /// Public Key for encryption
  /// ~~~~~~~~~~~~~~~~~~~~~~~~~
  /// For safety considerations, the visa.key which used to encrypt message data
  /// should be different with meta.key
  EncryptKey? _key;

  /// Avatar URL
  TransportableFile? _image;

  /// Document from local storage
  BaseVisa.fromData({
    required String data,
    required TransportableData signature
  }) : super.fromType(DocumentType.VISA, data: data, signature: signature);

  /// New document
  BaseVisa.empty() : super.fromType(DocumentType.VISA);

  @override
  String? get name => Converter.getString(getProperty('name'));

  @override
  set name(String? nickname) => setProperty('name', nickname);

  @override
  EncryptKey? get publicKey {
    EncryptKey? visaKey = _key;
    if (visaKey == null) {
      Object? info = getProperty('key');
      // assert(info != null, 'visa key not found: ${toMap()}');
      PublicKey? pKey = PublicKey.parse(info);
      if (pKey is EncryptKey) {
        visaKey = pKey as EncryptKey;
        _key = visaKey;
      } else {
        assert(info == null, 'visa key error: $info');
      }
    }
    return visaKey;
  }

  @override
  set publicKey(EncryptKey? publicKey) {
    setProperty('key', publicKey?.toMap());
    _key = publicKey;
  }

  @override
  TransportableFile? get avatar {
    TransportableFile? img = _image;
    if (img == null) {
      var uri = getProperty('avatar');
      img = TransportableFile.parse(uri);
      _image = img;
    }
    return img;
  }

  @override
  set avatar(TransportableFile? img) {
    if (img == null || img.isEmpty) {
      setProperty('avatar', null);
    } else {
      setProperty('avatar', img.serialize());
    }
    _image = img;
  }

}


///
/// Base Document for Group
/// ~~~~~~~~~~~~~~~~~~~~~~~
///
class BaseBulletin extends BaseDocument implements Bulletin {
  BaseBulletin([super.dict]);

  /// Document from local storage
  BaseBulletin.fromData({
    required String data,
    required TransportableData signature
  }) : super.fromType(DocumentType.BULLETIN, data: data, signature: signature);

  /// New document
  BaseBulletin.empty() : super.fromType(DocumentType.BULLETIN);

  @override
  String? get name => Converter.getString(getProperty('name'));

  @override
  set name(String? title) => setProperty('name', title);

  @override
  ID? get founder => ID.parse(getProperty('founder'));

}
