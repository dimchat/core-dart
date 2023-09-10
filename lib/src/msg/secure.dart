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
///      data     : "...",  // base64_encode(symmetric)
///      key      : "...",  // base64_encode(asymmetric)
///      keys     : {
///          "ID1": "key1", // base64_encode(asymmetric)
///      }
///  }
class EncryptedMessage extends BaseMessage implements SecureMessage {
  EncryptedMessage(super.dict) : _data = null, _encKey = null, _encKeys = null;

  TransportableData? _data;
  TransportableData? _encKey;
  Map<String, dynamic>? _encKeys;

  @override
  Future<Uint8List> get data async {
    TransportableData? ted = _data;
    if (ted == null) {
      String text = getString('data', '')!;
      assert(text.isNotEmpty, 'content data cannot be empty: $this');
      if (BaseMessage.isBroadcast(this)) {
        // broadcast message content will not be encrypted (just encoded to JsON),
        // so return the string data directly
        Uint8List plaintext = UTF8.encode(text);
        _data = ted = TransportableData.create(plaintext);
      } else {
        // message content had been encrypted by a symmetric key,
        // so the data should be encoded here (with algorithm 'base64' as default).
        _data = ted = TransportableData.parse(text);
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


class EncryptedMessagePacker {
  EncryptedMessagePacker(SecureMessageDelegate delegate)
      : _transceiver = WeakReference(delegate);

  final WeakReference<SecureMessageDelegate> _transceiver;

  SecureMessageDelegate get delegate => _transceiver.target!;

  /*
   *  Decrypt the Secure Message to Instant Message
   *
   *    +----------+      +----------+
   *    | sender   |      | sender   |
   *    | receiver |      | receiver |
   *    | time     |  ->  | time     |
   *    |          |      |          |  1. PW      = decrypt(key, receiver.SK)
   *    | data     |      | content  |  2. content = decrypt(data, PW)
   *    | key/keys |      +----------+
   *    +----------+
   */

  ///  Decrypt message, replace encrypted 'data' with 'content' field
  ///
  /// @return InstantMessage object
  Future<InstantMessage?> decrypt(SecureMessage sMsg) async {
    ID to;
    ID? gid = sMsg.group;
    if (gid == null) {
      // personal message
      // not split group message
      to = sMsg.receiver;
    } else {
      // group message
      to = gid;
    }

    // 1. decrypt 'message.key' to symmetric key
    SecureMessageDelegate transceiver = delegate;
    // 1.1. decode encrypted key data
    Uint8List? key = await sMsg.encryptedKey;
    // 1.2. decrypt key data
    if (key != null) {
      key = await transceiver.decryptKey(key, to, sMsg);
      if (key == null) {
        // assert(false, 'failed to decrypt key in msg: $this');
        // TODO: check whether my visa key is changed, push new visa to this contact
        return null;
      }
    }
    // 1.3. deserialize key
    //      if key is empty, means it should be reused, get it from key cache
    SymmetricKey? pwd = await transceiver.deserializeKey(key, to, sMsg);
    if (pwd == null) {
      assert(false, 'failed to get msg key: ${sMsg.sender} -> $to, $key');
      return null;
    }

    // 2. decrypt 'message.data' to 'message.content'
    // 2.1. decode encrypted content data
    Uint8List ciphertext = await sMsg.data;
    // 2.2. decrypt content data
    Uint8List? plaintext = await transceiver.decryptContent(ciphertext, pwd, sMsg);
    if (plaintext == null) {
      assert(false, 'failed to decrypt data with key: $pwd');
      return null;
    }
    // 2.3. deserialize content
    Content? content = await transceiver.deserializeContent(plaintext, pwd, sMsg);
    if (content == null) {
      assert(false, 'failed to deserialize content: $plaintext');
      return null;
    }
    // 2.4. check attachment for File/Image/Audio/Video message content
    //      if file data not download yet,
    //          decrypt file data with password;
    //      else,
    //          save password to 'message.content.password'.
    //      (do it in application level)

    // 3. pack message
    Map info = sMsg.copyMap(false);
    info.remove('key');
    info.remove('keys');
    info.remove('data');
    info['content'] = content.toMap();
    return InstantMessage.parse(info);
  }

  /*
   *  Sign the Secure Message to Reliable Message
   *
   *    +----------+      +----------+
   *    | sender   |      | sender   |
   *    | receiver |      | receiver |
   *    | time     |  ->  | time     |
   *    |          |      |          |
   *    | data     |      | data     |
   *    | key/keys |      | key/keys |
   *    +----------+      | signature|  1. signature = sign(data, sender.SK)
   *                      +----------+
   */

  ///  Sign message.data, add 'signature' field
  ///
  /// @return ReliableMessage object
  Future<ReliableMessage> sign(SecureMessage sMsg) async {
    SecureMessageDelegate transceiver = delegate;
    // 1. sign with sender's private key
    Uint8List signature = await transceiver.signData(await sMsg.data, sMsg);
    // 2. encode signature
    Object base64 = TransportableData.encode(signature);
    // 3. pack message
    Map info = sMsg.copyMap(false);
    info['signature'] = base64;
    return ReliableMessage.parse(info)!;
  }

  /*
   *  Split/Trim group message
   *
   *  for each members, get key from 'keys' and replace 'receiver' to member ID
   */

  ///  Split the group message to single person messages
  ///
  ///  @param members - group members
  ///  @return secure/reliable message(s)
  Future<List<SecureMessage>> split(SecureMessage sMsg, List<ID> members) async {
    Map info = sMsg.copyMap(false);
    // check 'keys'
    Map? keys = await sMsg.encryptedKeys;
    if (keys == null) {
      keys = {};
    } else {
      info.remove('keys');
    }
    ID receiver = sMsg.receiver;

    // 1. move the receiver(group ID) to 'group'
    //    this will help the receiver knows the group ID
    //    when the group message separated to multi-messages;
    //    if don't want the others know your membership,
    //    DON'T do this.
    assert(receiver.isGroup, 'receiver error: $receiver');
    info['group'] = receiver.toString();

    List<SecureMessage> messages = [];
    Object? b64;
    SecureMessage? item;
    for (ID mem in members) {
      // 2. change 'receiver' to each group member
      info['receiver'] = mem.toString();
      // 3. get encrypted key
      b64 = keys[mem.toString()];
      if (b64 == null) {
        info.remove('key');
      } else {
        info['key'] = b64;
      }
      // 4. repack message
      item = SecureMessage.parse(Copier.copyMap(info));
      if (item != null) {
        messages.add(item);
      }
    }

    return messages;
  }

  ///  Trim the group message for a member
  ///
  /// @param member - group member ID/string
  /// @return SecureMessage
  Future<SecureMessage> trim(SecureMessage sMsg, ID member) async {
    Map info = sMsg.copyMap(false);
    // check 'keys'
    Map? keys = await sMsg.encryptedKeys;
    if (keys != null) {
      // move key data from 'keys' to 'key'
      Object? b64 = keys[member.toString()];
      if (b64 != null) {
        info['key'] = b64;
      }
      info.remove('keys');
    }
    // check 'group'
    if (sMsg.group == null) {
      ID receiver = sMsg.receiver;
      // if 'group' not exists, the 'receiver' must be a group ID here, and
      // it will not be equal to the member of course,
      // so move 'receiver' to 'group'
      assert(receiver.isGroup, 'receiver error: $receiver');
      info['group'] = receiver.toString();
    }
    // replace receiver
    info['receiver'] = member.toString();
    // repack
    return SecureMessage.parse(info)!;
  }
}
