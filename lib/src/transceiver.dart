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

import 'mkm/entity.dart';
import 'mkm/user.dart';

///  Message Transceiver
///  ~~~~~~~~~~~~~~~~~~~
///
///  Converting message format between PlainMessage and NetworkMessage
abstract class Transceiver implements InstantMessageDelegate, ReliableMessageDelegate {

  // protected
  EntityDelegate? get entityDelegate;  // barrack

  //-------- InstantMessageDelegate

  @override
  Uint8List serializeContent(Content content, SymmetricKey password, InstantMessage iMsg) {
    // NOTICE: check attachment for File/Image/Audio/Video message content
    //         before serialize content, this job should be do in subclass
    return UTF8.encode(JSON.encode(content));
  }

  @override
  Uint8List encryptContent(Uint8List data, SymmetricKey password, InstantMessage iMsg) {
    return password.encrypt(data);
  }

  @override
  Object encodeData(Uint8List data, InstantMessage iMsg) {
    if (isBroadcastMessage(iMsg)) {
      // broadcast message content will not be encrypted (just encoded to JsON),
      // so no need to encode to Base64 here
      return UTF8.decode(data)!;
    }
    return Base64.encode(data);
  }

  @override
  Uint8List? serializeKey(SymmetricKey password, InstantMessage iMsg) {
    if (isBroadcastMessage(iMsg)) {
      // broadcast message has no key
      return null;
    }
    return UTF8.encode(JSON.encode(password));
  }

  @override
  Uint8List? encryptKey(Uint8List key, ID receiver, InstantMessage iMsg) {
    assert(!isBroadcastMessage(iMsg), 'broadcast message has no key: $iMsg');
    EntityDelegate? barrack = entityDelegate;
    assert(barrack != null, "entity delegate not set yet");
    // TODO: make sure the receiver's public key exists
    User? contact = barrack?.getUser(receiver);
    assert(contact != null, 'failed to encrypt for receiver: $receiver');
    // encrypt with receiver's public key
    return contact?.encrypt(key);
  }

  @override
  Object encodeKey(Uint8List key, InstantMessage iMsg) {
    assert(!isBroadcastMessage(iMsg), 'broadcast message has no key: $iMsg');
    return Base64.encode(key);
  }

  //-------- SecureMessageDelegate

  @override
  Uint8List? decodeKey(Object key, SecureMessage sMsg) {
    assert(!isBroadcastMessage(sMsg), 'broadcast message has no key: $sMsg');
    return Base64.decode(key as String);
  }

  @override
  Uint8List? decryptKey(Uint8List key, ID sender, ID receiver, SecureMessage sMsg) {
    // NOTICE: the receiver will be group ID in a group message here
    assert(!isBroadcastMessage(sMsg), 'broadcast message has no key: $sMsg');
    EntityDelegate? barrack = entityDelegate;
    assert(barrack != null, "entity delegate not set yet");
    // decrypt key data with the receiver/group member's private key
    ID identifier = sMsg.receiver;
    User? user = barrack?.getUser(identifier);
    assert(user != null, 'failed to create local user: $identifier');
    return user?.decrypt(key);
  }

  @override
  SymmetricKey? deserializeKey(Uint8List? key, ID sender, ID receiver, SecureMessage sMsg) {
    // NOTICE: the receiver will be group ID in a group message here
    assert(!isBroadcastMessage(sMsg), 'broadcast message has no key: $sMsg');
    assert(key != null, 'reused key? get it from local cache: $sender -> $receiver');
    String? json = UTF8.decode(key!);
    assert(json != null, 'key data error: $key');
    Object? dict = JSON.decode(json!);
    // TODO: translate short keys
    //       'A' -> 'algorithm'
    //       'D' -> 'data'
    //       'V' -> 'iv'
    //       'M' -> 'mode'
    //       'P' -> 'padding'
    return SymmetricKey.parse(dict);
  }

  @override
  Uint8List? decodeData(Object data, SecureMessage sMsg) {
    if (isBroadcastMessage(sMsg)) {
      // broadcast message content will not be encrypted (just encoded to JsON),
      // so return the string data directly
      return UTF8.encode(data as String);
    }
    return Base64.decode(data as String);
  }

  @override
  Uint8List? decryptContent(Uint8List data, SymmetricKey password, SecureMessage sMsg) {
    return password.decrypt(data);
  }

  @override
  Content? deserializeContent(Uint8List data, SymmetricKey password, SecureMessage sMsg) {
    // assert(sMsg.data.isNotEmpty, "message data empty");
    String? json = UTF8.decode(data);
    assert(json != null, 'content data error: $data');
    Object? dict = JSON.decode(json!);
    // TODO: translate short keys
    //       'T' -> 'type'
    //       'N' -> 'sn'
    //       'W' -> 'time'
    //       'G' -> 'group'
    return Content.parse(dict);
  }

  @override
  Uint8List signData(Uint8List data, ID sender, SecureMessage sMsg) {
    EntityDelegate? barrack = entityDelegate;
    assert(barrack != null, 'entity delegate not set yet');
    User? user = barrack?.getUser(sender);
    assert(user != null, 'failed to sign with sender: $sender');
    return user!.sign(data);
  }

  @override
  Object encodeSignature(Uint8List signature, SecureMessage sMsg) {
    return Base64.encode(signature);
  }

  //-------- ReliableMessageDelegate

  @override
  Uint8List? decodeSignature(Object signature, ReliableMessage rMsg) {
    return Base64.decode(signature as String);
  }

  @override
  bool verifyDataSignature(Uint8List data, Uint8List signature, ID sender, ReliableMessage rMsg) {
    EntityDelegate? barrack = entityDelegate;
    assert(barrack != null, 'entity delegate not set yet');
    User? contact = barrack?.getUser(sender);
    assert(contact != null, 'failed to verify signature for sender: $sender');
    return contact!.verify(data, signature);
  }
}

bool isBroadcastMessage(Message msg) {
  ID? receiver = msg.group;
  receiver ??= msg.receiver;
  return receiver.isBroadcast;
}
