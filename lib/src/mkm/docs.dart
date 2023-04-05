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
import 'package:mkm/mkm.dart';

import 'document.dart';


///
/// Base User Document
///
class BaseVisa extends BaseDocument implements Visa {
  BaseVisa(super.dict) : _key = null;

  BaseVisa.fromData(ID identifier, {required String data, required String signature})
      : super.fromData(identifier, data: data, signature: signature) {
    // lazy
    _key = null;
  }

  BaseVisa.fromID(ID identifier)
      : super.fromType(identifier, type: Document.kVisa) {
    // lazy
    _key = null;
  }

  ///  Public key (used for encryption, can be same with meta.key)
  ///
  ///      RSA
  EncryptKey? _key;

  @override
  EncryptKey get key {
    if (_key == null) {
      Object? info = getProperty('key');
      assert(info != null, 'visa key nt found: $dictionary');
      PublicKey? pKey = PublicKey.parse(info);
      if (pKey is EncryptKey) {
        _key = pKey as EncryptKey;
      }
      assert(_key != null, 'visa key error: $info');
    }
    return _key!;
  }

  @override
  set key(EncryptKey publicKey) {
    setProperty('key', publicKey.dictionary);
    _key = publicKey;
  }

  @override
  String? get avatar => getProperty('avatar');

  @override
  set avatar(String? url) => setProperty('avatar', url);
}


///
/// Base Group Document
///
class BaseBulletin extends BaseDocument implements Bulletin {
  BaseBulletin(super.dict) : _bots = null;

  BaseBulletin.fromData(ID identifier, {required String data, required String signature})
      : super.fromData(identifier, data: data, signature: signature) {
    // lazy
    _bots = null;
  }

  BaseBulletin.fromID(ID identifier)
      : super.fromType(identifier, type: Document.kBulletin) {
    // lazy
    _bots = null;
  }

  /// Group bots for split and distribute group messages
  List<ID>? _bots;

  @override
  List<ID> get assistants {
    if (_bots == null) {
      Object? array = getProperty('assistants');
      if (array is List) {
        _bots = ID.convert(array);
      } else {
        // placeholder
        _bots = [];
      }
    }
    return _bots!;
  }

  @override
  set assistants(List<ID> bots) {
    if (bots.isEmpty) {
      setProperty('assistants', null);
    } else {
      setProperty('assistants', ID.revert(bots));
    }
    _bots = bots;
  }
}


///
/// General Document Factory
///
class GeneralDocumentFactory implements DocumentFactory {
  GeneralDocumentFactory(String type) : _type = type;

  final String _type;

  @override
  Document createDocument(ID identifier, {String? data, String? signature}) {
    String type = getType(_type, identifier);
    if (data == null || signature == null || data.isEmpty || signature.isEmpty) {
      // create empty document
      if (type == Document.kVisa) {
        return BaseVisa.fromID(identifier);
      } else if (type == Document.kBulletin) {
        return BaseBulletin.fromID(identifier);
      } else {
        return BaseDocument.fromType(identifier, type: '');
      }
    } else {
      // create document with data & signature from local storage
      if (type == Document.kVisa) {
        return BaseVisa.fromData(identifier, data: data, signature: signature);
      } else if (type == Document.kBulletin) {
        return BaseBulletin.fromData(identifier, data: data, signature: signature);
      } else {
        return BaseDocument.fromData(identifier, data: data, signature: signature);
      }
    }
  }

  @override
  Document? parseDocument(Map doc) {
    ID? identifier = ID.parse(doc['ID']);
    if (identifier == null) {
      // doc ID not found
      return null;
    }
    AccountFactoryManager man = AccountFactoryManager();
    String? type = man.generalFactory.getDocumentType(doc);
    type ??= getType('*', identifier);
    if (type == Document.kVisa) {
      return BaseVisa(doc);
    } else if (type == Document.kBulletin) {
      return BaseBulletin(doc);
    } else {
      return BaseDocument(doc);
    }
  }
}

String getType(String type, ID identifier) {
  if (type == '*') {
    if (identifier.isGroup) {
      return Document.kBulletin;
    } else if (identifier.isUser) {
      return Document.kVisa;
    } else {
      return Document.kProfile;
    }
  } else {
    return type;
  }
}
