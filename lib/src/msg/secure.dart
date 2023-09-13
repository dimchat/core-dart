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

import 'package:dkd/dkd.dart';
import 'package:mkm/mkm.dart';

import 'base.dart';

///  Secure Message
///  ~~~~~~~~~~~~~~
///  Instant Message encrypted by a symmetric key
///
///  data format: {
///      //-- envelope
///      sender   : "moki@xxx",
///      receiver : "hulk@yyy",
///      time     : 123,
///      //-- content data and key/keys
///      data     : "...",  // base64_encode( symmetric_encrypt(content))
///      key      : "...",  // base64_encode(asymmetric_encrypt(password))
///      keys     : {
///          "ID1": "key1", // base64_encode(asymmetric_encrypt(password))
///      }
///  }
class EncryptedMessage extends BaseMessage implements SecureMessage {
  EncryptedMessage(super.dict) : _body = null, _encKey = null, _encKeys = null;

  TransportableData? _body;
  TransportableData? _encKey;
  Map? _encKeys;  // String => String

  @override
  Future<Uint8List> get data async {
    TransportableData? ted = _body;
    if (ted == null) {
      Object? base64 = this['data'];
      assert(base64 != null, 'message data cannot be empty: $this');
      if (!BaseMessage.isBroadcast(this)) {
        // message content had been encrypted by a symmetric key,
        // so the data should be encoded here (with algorithm 'base64' as default).
        _body = ted = TransportableData.parse(base64);
      } else if (base64 is String) {
        // broadcast message content will not be encrypted (just encoded to JsON),
        // so return the string data directly
        Uint8List plaintext = UTF8.encode(base64);  // JsON
        _body = ted = TransportableData.create(plaintext);
      } else {
        assert(false, 'content data error: $base64');
      }
    }
    return ted!.data;
  }

  @override
  Future<Uint8List?> get encryptedKey async {
    TransportableData? ted = _encKey;
    if (ted == null) {
      Object? base64 = this['key'];
      if (base64 == null) {
        // check 'keys
        Map? keys = await encryptedKeys;
        if (keys != null) {
          base64 = keys[receiver.toString()];
        }
      }
      _encKey = ted = TransportableData.parse(base64);
    }
    return ted?.data;
  }

  @override
  Future<Map?> get encryptedKeys async {
    _encKeys ??= this['keys'];
    return _encKeys;
  }

}
