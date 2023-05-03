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

class BaseDocument extends Dictionary implements Document {
  BaseDocument(super.dict)
      : _identifier = null, _json = null, _sig = null, _properties = null, _status = 0;

  ///  Create entity document with data and signature loaded from local storage
  ///
  /// @param identifier - entity ID
  /// @param data - document data in JsON format
  /// @param signature - signature of document data in Base64 format
  BaseDocument.fromData(ID identifier, {required String data, required String signature})
      : super(null) {
    // ID
    setString('ID', identifier);
    _identifier = identifier;

    // json data
    this['data'] = data;
    _json = data;

    // signature
    this['signature'] = signature;
    _sig = null;  // lazy

    _properties = null;

    // all documents must be verified before saving into local storage
    _status = 1;
  }

  ///  Create a new empty document
  ///
  /// @param identifier - entity ID
  /// @param docType    - document type
  BaseDocument.fromType(ID identifier, String? docType) : super(null) {
    // ID
    setString('ID', identifier);
    _identifier = identifier;

    _json = null;
    _sig = null;

    if (docType == null || docType.isEmpty) {
      _properties = null;
    } else {
      _properties = {'type': docType};
    }

    _status = 0;
  }

  ID? _identifier;

  String? _json;    // JsON.encode(properties)
  Uint8List? _sig;  // LocalUser(identifier).sign(data)

  Map? _properties;
  int _status = 0;  // 1 for valid, -1 for invalid

  @override
  bool get isValid => _status > 0;

  @override
  String? get type {
    String? docType = getProperty('type');
    return docType ?? getString('type');
  }

  @override
  ID get identifier {
    _identifier ??= ID.parse(this['ID']);
    return _identifier!;
  }

  ///  Get serialized properties
  ///
  /// @return JsON string
  String? _data() {
    _json ??= getString('data');
    return _json;
  }

  ///  Get signature for serialized properties
  ///
  /// @return signature data
  Uint8List? _signature() {
    if (_sig == null) {
      String? b64 = getString('signature');
      if (b64 != null) {
        _sig = Base64.decode(b64);
        assert(_sig != null, 'document signature error: $b64');
      }
    }
    return _sig;
  }

  @override
  Map? get properties {
    if (_status < 0) {
      // invalid
      return null;
    }
    if (_properties == null) {
      String? data = _data();
      if (data == null) {
        // create new properties
        _properties = {};
      } else {
        _properties = JSONMap.decode(data);
        assert(_properties != null, 'document data error: $data');
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
    assert(dict != null, 'failed to get properties: $this');
    if (value == null) {
      dict?.remove(name);
    } else {
      dict?[name] = value;
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
    String? data = _data();
    Uint8List? signature = _signature();
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
    if (_status > 0) {
      // already signed/verified
      assert(_json != null, 'document data error: $this');
      return _signature()!;
    }
    // 1. update sign time
    setProperty('time', DateTime.now().millisecondsSinceEpoch / 1000.0);
    // 2. encode & sign
    Map? dict = properties;
    if (dict == null) {
      // properties empty
      return null;
    }
    String data = JSONMap.encode(dict);
    assert(data.isNotEmpty, 'properties error: $dict');
    Uint8List signature = privateKey.sign(UTF8.encode(data));
    if (signature.isEmpty) {
      // signature error
      return null;
    }
    // 3. update 'data' & 'signature' fields
    this['data'] = data;
    this['signature'] = Base64.encode(signature);
    _json = data;
    _sig = signature;
    // 4. update status
    _status = 1;
    return _sig;
  }

  //---- properties getter/setter

  @override
  DateTime? get time {
    // timestamp
    var seconds = getProperty('time');
    return Converter.getTime(seconds);
  }

  @override
  String? get name => getProperty('name');

  @override
  set name(String? value) => setProperty('name', value);
}
