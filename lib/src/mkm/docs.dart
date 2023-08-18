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

  BaseVisa.fromData(ID identifier,
      {required String data, required String signature})
      : super.fromData(identifier, data: data, signature: signature) {
    // lazy
    _key = null;
  }

  BaseVisa.fromID(ID identifier) : super.fromType(identifier, Document.kVisa) {
    // lazy
    _key = null;
  }

  /// Public Key for encryption
  /// ~~~~~~~~~~~~~~~~~~~~~~~~~
  /// For safety considerations, the visa.key which used to encrypt message data
  /// should be different with meta.key
  EncryptKey? _key;

  @override
  EncryptKey? get key {
    if (_key == null) {
      Object? info = getProperty('key');
      if (info != null) {
        PublicKey? pKey = PublicKey.parse(info);
        if (pKey is EncryptKey) {
          _key = pKey as EncryptKey;
        }
        assert(_key != null, 'visa key error: $info');
      }
    }
    return _key;
  }

  @override
  set key(EncryptKey? publicKey) {
    setProperty('key', publicKey?.toMap());
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

  BaseBulletin.fromData(ID identifier,
      {required String data, required String signature})
      : super.fromData(identifier, data: data, signature: signature) {
    // lazy
    _bots = null;
  }

  BaseBulletin.fromID(ID identifier)
      : super.fromType(identifier, Document.kBulletin) {
    // lazy
    _bots = null;
  }

  /// Group bots for split and distribute group messages
  List<ID>? _bots;

  @override
  ID? get founder => ID.parse(this['founder']);

  @override
  List<ID>? get assistants {
    if (_bots == null) {
      Object? bots = getProperty('assistants');
      if (bots is List) {
        _bots = ID.convert(bots);
      }
    }
    return _bots;
  }

  @override
  set assistants(List<ID>? bots) {
    if (bots == null) {
      setProperty('assistants', null);
    } else {
      setProperty('assistants', ID.revert(bots));
    }
    _bots = bots;
  }

  @override
  DateTime? get createdTime => Converter.getTime(getProperty('created_time'));

  @override
  DateTime? get modifiedTime {
    var timestamp = getProperty('modified_time');
    if (timestamp == null) {
      return time;
    }
    return Converter.getTime(timestamp);
  }

}


///
/// General Document Factory
///
class GeneralDocumentFactory implements DocumentFactory {
  GeneralDocumentFactory(String docType) : _type = docType;

  final String _type;

  @override
  Document createDocument(ID identifier, {String? data, String? signature}) {
    String docType = _getType(_type, identifier);
    if (data == null || signature == null || data.isEmpty || signature.isEmpty) {
      // create empty document
      if (docType == Document.kVisa) {
        return BaseVisa.fromID(identifier);
      } else if (docType == Document.kBulletin) {
        return BaseBulletin.fromID(identifier);
      } else {
        return BaseDocument.fromType(identifier, docType);
      }
    } else {
      // create document with data & signature from local storage
      if (docType == Document.kVisa) {
        return BaseVisa.fromData(identifier, data: data, signature: signature);
      } else if (docType == Document.kBulletin) {
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
      assert(false, 'document ID not found: $doc');
      return null;
    }
    AccountFactoryManager man = AccountFactoryManager();
    String? docType = man.generalFactory.getDocumentType(doc);
    docType ??= _getType('*', identifier);
    if (docType == Document.kVisa) {
      return BaseVisa(doc);
    } else if (docType == Document.kBulletin) {
      return BaseBulletin(doc);
    } else {
      return BaseDocument(doc);
    }
  }
}

String _getType(String docType, ID identifier) {
  if (docType == '*') {
    if (identifier.isGroup) {
      return Document.kBulletin;
    } else if (identifier.isUser) {
      return Document.kVisa;
    } else {
      return Document.kProfile;
    }
  } else {
    return docType;
  }
}
