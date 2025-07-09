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
import 'package:mkm/mkm.dart';

import '../protocol/version.dart';
import '../protocol/docs.dart';

import 'document.dart';


///
/// Base Document for User
/// ~~~~~~~~~~~~~~~~~~~~~~
///
class BaseVisa extends BaseDocument implements Visa {
  BaseVisa(super.dict);

  /// Public Key for encryption
  /// ~~~~~~~~~~~~~~~~~~~~~~~~~
  /// For safety considerations, the visa.key which used to encrypt message data
  /// should be different with meta.key
  EncryptKey? _key;

  /// Avatar URL
  PortableNetworkFile? _avatar;

  BaseVisa.from(ID identifier, {String? data, TransportableData? signature})
      : super.from(identifier, DocumentType.VISA, data: data, signature: signature);

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
  PortableNetworkFile? get avatar {
    PortableNetworkFile? img = _avatar;
    if (img == null) {
      var url = getProperty('avatar');
      if (url is String && url.isEmpty) {
        // ignore empty URL
      } else {
        img = PortableNetworkFile.parse(url);
        _avatar = img;
      }
    }
    return img;
  }

  @override
  set avatar(PortableNetworkFile? img) {
    setProperty('avatar', img?.toObject());
    _avatar = img;
  }
}


///
/// Base Document for Group
/// ~~~~~~~~~~~~~~~~~~~~~~~
///
class BaseBulletin extends BaseDocument implements Bulletin {
  BaseBulletin(super.dict);

  /// Group bots for split and distribute group messages
  List<ID>? _bots;

  BaseBulletin.from(ID identifier, {String? data, TransportableData? signature})
      : super.from(identifier, DocumentType.BULLETIN, data: data, signature: signature);

  @override
  ID? get founder => ID.parse(getProperty('founder'));

  @override
  List<ID>? get assistants {
    if (_bots == null) {
      Object? bots = getProperty('assistants');
      if (bots is List) {
        _bots = ID.convert(bots);
      } else {
        // get from 'assistant'
        ID? single = ID.parse(getProperty('assistant'));
        _bots = single == null ? [] : [single];
      }
    }
    return _bots;
  }

  @override
  set assistants(List<ID>? bots) {
    setProperty('assistants', bots == null ? null : ID.revert(bots));
    setProperty('assistant', null);
    _bots = bots;
  }

}
