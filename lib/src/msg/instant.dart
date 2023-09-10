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

///  Instant Message
///  ~~~~~~~~~~~~~~~
///
///  data format: {
///      //-- envelope
///      sender   : "moki@xxx",
///      receiver : "hulk@yyy",
///      time     : 123,
///      //-- content
///      content  : {...}
///  }
class PlainMessage extends BaseMessage implements InstantMessage {
  PlainMessage(super.dict) : _body = null;

  /// message body
  Content? _body;

  PlainMessage.from(Envelope head, Content body) : super.fromEnvelope(head) {
    // content
    setMap('content', body);
    _body = body;
  }

  @override
  DateTime? get time => content.time ?? envelope.time;

  @override
  ID? get group => content.group;

  @override
  int get type => content.type;

  @override
  Content get content {
    _body ??= Content.parse(this['content']);
    assert(_body != null, 'message content not found: $this');
    return _body!;
  }

  @override
  set content(Content body) {
    this['content'] = body.toMap();
    _body = body;
  }

}


class PlainMessagePacker {
  PlainMessagePacker(InstantMessageDelegate delegate)
      : _transceiver = WeakReference(delegate);

  final WeakReference<InstantMessageDelegate> _transceiver;

  InstantMessageDelegate get delegate => _transceiver.target!;

  /*
   *  Encrypt the Instant Message to Secure Message
   *
   *    +----------+      +----------+
   *    | sender   |      | sender   |
   *    | receiver |      | receiver |
   *    | time     |  ->  | time     |
   *    |          |      |          |
   *    | content  |      | data     |  1. data = encrypt(content, PW)
   *    +----------+      | key/keys |  2. key  = encrypt(PW, receiver.PK)
   *                      +----------+
   */

  /// 1. Encrypt message, replace 'content' field with encrypted 'data'
  /// 2. Encrypt group message, replace 'content' field with encrypted 'data'
  ///
  /// @param password - symmetric key
  /// @param members  - group members for group message
  /// @return SecureMessage object, null on visa not found
  Future<SecureMessage?> encrypt(InstantMessage iMsg, SymmetricKey password, {List<ID>? members}) async {
    // 0. check attachment for File/Image/Audio/Video message content
    //    (do it in application level)

    // 1. encrypt 'message.content' to 'message.data'
    InstantMessageDelegate transceiver = delegate;
    // 1.1. serialize message content
    Uint8List body = await transceiver.serializeContent(iMsg.content, password, iMsg);
    // 1.2. encrypt content data with password
    Uint8List ciphertext = await transceiver.encryptContent(body, password, iMsg);
    // 1.3. encode encrypted data
    Object? encoded;
    if (BaseMessage.isBroadcast(iMsg)) {
      // broadcast message content will not be encrypted (just encoded to JsON),
      // so no need to encode to Base64 here
      encoded = UTF8.decode(ciphertext);
    } else {
      // message content had been encrypted by a symmetric key,
      // so the data should be encoded here (with algorithm 'base64' as default).
      encoded = TransportableData.encode(ciphertext);
    }
    assert(encoded != null, 'failed to encode content data: $ciphertext');
    // 1.4. replace 'content' with encrypted 'data'
    Map info = iMsg.copyMap(false);
    info.remove('content');
    info['data'] = encoded;

    // 2. encrypt symmetric key(password) to 'message.key'
    // 2.1. serialize symmetric key
    Uint8List? pwd = await transceiver.serializeKey(password, iMsg);
    if (pwd == null) {
      // A) broadcast message has no key
      // B) reused key
      return SecureMessage.parse(info);
    }

    // 2.2. encrypt symmetric key data
    Uint8List? key;
    if (members == null) {
      // personal message
      key = await transceiver.encryptKey(pwd, iMsg.receiver, iMsg);
      if (key == null) {
        // public key for encryption not found
        // TODO: suspend this message for waiting receiver's visa
        return null;
      }
      // 2.3. encode encrypted key data
      encoded = TransportableData.encode(key);
      // 2.4. insert as 'key'
      info['key'] = encoded;
    } else {
      // group message
      Map keys = {};
      for (ID item in members) {
        // 2.2. encrypt symmetric key data
        key = await transceiver.encryptKey(pwd, item, iMsg);
        if (key == null) {
          // public key for member not found
          // TODO: suspend this message for waiting member's visa
          continue;
        }
        // 2.3. encode encrypted key data
        encoded = TransportableData.encode(key);
        // 2.4. insert to 'message.keys' with member ID
        keys[item.toString()] = encoded;
      }
      if (keys.isEmpty) {
        // public key for member(s) not found
        // TODO: suspend this message for waiting member's visa
        return null;
      }
      info['keys'] = keys;
    }

    // 3. pack message
    return SecureMessage.parse(info);
  }
}
