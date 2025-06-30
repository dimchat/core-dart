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
import 'package:mkm/type.dart';


class BaseDocument extends Dictionary implements Document {
  BaseDocument(super.dict);

  ID? _identifier;

  String? _json;            // JsON.encode(properties)
  TransportableData? _sig;  // LocalUser(identifier).sign(data)

  Map<String, dynamic>? _properties;
  int _status = 0;          // 1 for valid, -1 for invalid

  ///  1. Create a new empty document
  ///  2. Create entity document with data and signature loaded from local storage
  ///
  /// @param identifier - entity ID
  /// @param docType    - document type
  /// @param data       - document data in JsON format
  /// @param signature  - signature of document data in Base64 format
  BaseDocument.from(ID identifier, String docType, {String? data, TransportableData? signature})
      : super(null) {
    // ID
    this['did'] = identifier.toString();
    _identifier = identifier;

    // document type
    assert(docType.isNotEmpty && docType != '*', 'document type error: $docType');
    this['type'] = docType;

    // document data(Json) & signature(Base64)
    if (data == null || signature == null) {
      assert(data == null && signature == null, 'document data/signature error: $data, $signature');
      // 1. Create a new empty document
      _json = null;
      _sig = null;
      // initialize properties with created time
      _properties = {
        'type': docType,  // deprecated
        'created_time': DateTime.now().millisecondsSinceEpoch / 1000.0,
      };
      _status = 0;
    } else {
      assert(data.isNotEmpty && signature.isNotEmpty, 'document data/signature error: $data, $signature');
      // 2. Create entity document with data and signature loaded from local storage
      this['data'] = data;
      this['signature'] = signature.toObject();
      _json = data;
      _sig = signature;
      _properties = null;  // lazy
      // all documents must be verified before saving into local storage
      _status = 1;
    }
  }

  @override
  bool get isValid => _status > 0;

  @override
  ID get identifier {
    _identifier ??= ID.parse(this['did']);
    return _identifier!;
  }

  ///  Get serialized properties
  ///
  /// @return JsON string
  String? _getData() {
    _json ??= getString('data', null);
    return _json;
  }

  ///  Get signature for serialized properties
  ///
  /// @return signature data
  Uint8List? _getSignature() {
    TransportableData? ted = _sig;
    if (ted == null) {
      Object base64 = this['signature'];
      _sig = ted = TransportableData.parse(base64);
    }
    return ted?.data;
  }

  @override
  Map<String, dynamic>? get properties {
    if (_status < 0) {
      // invalid
      return null;
    }
    if (_properties == null) {
      String? data = _getData();
      if (data == null) {
        // create new properties
        _properties = {};
      } else {
        var info = JSONMap.decode(data);
        if (info is Map<String, dynamic>) {
          _properties = info;
        } else {
          assert(false, 'document data error: $data');
        }
      }
    }
    return _properties;
  }

  @override
  dynamic getProperty(String name) => properties?[name];

  @override
  void setProperty(String name, Object? value) {
    // 1. reset status
    assert(_status >= 0, 'status error: $this');
    _status = 0;
    // 2. update property value with name
    Map? dict = properties;
    if (dict == null) {
      assert(false, 'failed to get properties: $this');
    } else if (value == null) {
      dict.remove(name);
    } else {
      dict[name] = value;
    }
    // 3. clear data signature after properties changed
    remove('data');
    remove('signature');
    _json = null;
    _sig = null;
  }

  @override
  bool verify(VerifyKey publicKey) {
    if (_status > 0) {
      // already verify OK
      return true;
    }
    String? data = _getData();
    Uint8List? signature = _getSignature();
    if (data == null) {
      // NOTICE: if data is empty, signature should be empty at the same time
      //         this happen while entity document not found
      if (signature == null) {
        _status = 0;
      } else {
        // data signature error
        _status = -1;
      }
    } else if (signature == null) {
      // data signature error
      _status = -1;
    } else if (publicKey.verify(UTF8.encode(data), signature)) {
      // signature matched
      _status = 1;
    }
    // NOTICE: if status is 0, it doesn't mean the entity document is invalid,
    //         try another key
    return _status == 1;
  }

  @override
  Uint8List? sign(SignKey privateKey) {
    Uint8List? signature;
    if (_status > 0) {
      // already signed/verified
      assert(_json != null, 'document data error: $this');
      signature = _getSignature();
      assert(signature != null, 'document signature error: $this');
      return signature;
    }
    // 1. update sign time
    setProperty('time', DateTime.now().millisecondsSinceEpoch / 1000.0);
    // 2. encode & sign
    Map? dict = properties;
    if (dict == null) {
      assert(false, 'document invalid: ${toMap()}');
      return null;
    }
    String data = JSONMap.encode(dict);
    if (data.isEmpty) {
      assert(false, 'should not happen: $dict');
      return null;
    }
    signature = privateKey.sign(UTF8.encode(data));
    if (signature.isEmpty) {
      assert(false, 'should not happen');
      return null;
    }
    TransportableData ted = TransportableData.create(signature);
    // 3. update 'data' & 'signature' fields
    this['data'] = data;                 // JSON string
    this['signature'] = ted.toObject();  // BASE-64
    _json = data;
    _sig = ted;
    // 4. update status
    _status = 1;
    return signature;
  }

  //---- properties getter/setter

  @override
  DateTime? get time => Converter.getDateTime(getProperty('time'), null);

  @override
  String? get name => Converter.getString(getProperty('name'), null);

  @override
  set name(String? value) => setProperty('name', value);
}
