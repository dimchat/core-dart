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
  EncryptedMessage(super.dict);

  Uint8List? _data;
  Uint8List? _key;
  Map<String, dynamic>? _keys;

  @override
  SecureMessageDelegate? get delegate {
    MessageDelegate? transceiver = super.delegate;
    if (transceiver == null) {
      return null;
    }
    assert(transceiver is SecureMessageDelegate, 'delegate error: $transceiver');
    return transceiver as SecureMessageDelegate;
  }

  @override
  Future<Uint8List> get data async {
    if (_data == null) {
      Object? b64 = this['data'];
      if (b64 == null) {
        assert(false, 'message data not found: $dictionary');
      } else {
        _data = await delegate?.decodeData(b64, this);
        assert(_data != null, 'message data error: $b64');
      }
    }
    return _data!;
  }

  @override
  Future<Uint8List?> get encryptedKey async {
    if (_key == null) {
      Object? b64 = this['key'];
      if (b64 == null) {
        // check 'keys'
        Map? keys = encryptedKeys;
        if (keys != null) {
          b64 = keys[receiver.string];
        }
      }
      if (b64 != null) {
        _key = await delegate?.decodeKey(b64, this);
        assert(_key != null, 'message key error: $b64');
      }
    }
    return _key;
  }

  @override
  Map<String, dynamic>? get encryptedKeys {
    _keys ??= this['keys'];
    return _keys;
  }

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
  @override
  Future<InstantMessage?> decrypt() async {
    ID from = sender;
    ID to;
    ID? gid = group;
    if (gid == null) {
      // personal message
      // not split group message
      to = receiver;
    } else {
      // group message
      to = gid;
    }

    // 1. decrypt 'message.key' to symmetric key
    SecureMessageDelegate transceiver = delegate!;
    // 1.1. decode encrypted key data
    Uint8List? key = await encryptedKey;
    // 1.2. decrypt key data
    if (key != null) {
      key = await transceiver.decryptKey(key, from, to, this);
      if (key == null) {
        throw Exception('failed to decrypt key in msg: $dictionary');
      }
    }
    // 1.3. deserialize key
    //      if key is empty, means it should be reused, get it from key cache
    SymmetricKey? pwd = await transceiver.deserializeKey(key, from, to, this);
    if (pwd == null) {
      throw Exception('failed to get msg key: $from -> $to, $key');
    }

    // 2. decrypt 'message.data' to 'message.content'
    // 2.1. decode encrypted content data
    Uint8List ciphertext = await data;
    // 2.2. decrypt content data
    Uint8List? plaintext = await transceiver.decryptContent(ciphertext, pwd, this);
    if (plaintext == null) {
      throw Exception('failed to decrypt data with key: $pwd');
    }
    // 2.3. deserialize content
    Content? content = await transceiver.deserializeContent(plaintext, pwd, this);
    if (content == null) {
      throw Exception('failed to deserialize content: $plaintext');
    }
    // 2.4. check attachment for File/Image/Audio/Video message content
    //      if file data not download yet,
    //          decrypt file data with password;
    //      else,
    //          save password to 'message.content.password'.
    //      (do it in 'core' module)

    // 3. pack message
    Map info = copyMap(false);
    info.remove('key');
    info.remove('keys');
    info.remove('data');
    info['content'] = content.dictionary;
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
  @override
  Future<ReliableMessage> sign() async {
    SecureMessageDelegate transceiver = delegate!;
    // 1. sign with sender's private key
    Uint8List signature = await transceiver.signData(await data, sender, this);
    // 2. encode signature
    Object b64 = await transceiver.encodeSignature(signature, this);
    // 3. pack message
    Map info = copyMap(false);
    info['signature'] = b64;
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
  @override
  List<SecureMessage> split(List<ID> members) {
    Map info = copyMap(false);
    // check 'keys'
    Map<String, dynamic>? keys = encryptedKeys;
    if (keys == null) {
      keys = {};
    } else {
      info.remove('keys');
    }

    // 1. move the receiver(group ID) to 'group'
    //    this will help the receiver knows the group ID
    //    when the group message separated to multi-messages;
    //    if don't want the others know your membership,
    //    DON'T do this.
    info['group'] = receiver.string;

    List<SecureMessage> messages = [];
    Object? b64;
    SecureMessage? item;
    for (ID mem in members) {
      // 2. change 'receiver' to each group member
      info['receiver'] = mem.string;
      // 3. get encrypted key
      b64 = keys[mem.string];
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
  @override
  SecureMessage trim(ID member) {
    Map info = copyMap(false);
    // check 'keys'
    Map<String, dynamic>? keys = encryptedKeys;
    if (keys != null) {
      // move key data from 'keys' to 'key'
      Object? b64 = keys[member.string];
      if (b64 != null) {
        info['key'] = b64;
      }
      info.remove('keys');
    }
    // check 'group'
    if (group == null) {
      // if 'group' not exists, the 'receiver' must be a group ID here, and
      // it will not be equal to the member of course,
      // so move 'receiver' to 'group'
      info['group'] = receiver.string;
    }
    info['receiver'] = member.string;
    // repack
    return SecureMessage.parse(info)!;
  }
}
