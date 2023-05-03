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

import 'secure.dart';

///  Reliable Message signed by an asymmetric key
///  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
///  This class is used to sign the SecureMessage
///  It contains a 'signature' field which signed with sender's private key
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
///      },
///      //-- signature
///      signature: "..."   // base64_encode()
///  }
class NetworkMessage extends EncryptedMessage implements ReliableMessage {
  NetworkMessage(super.dict) : _signature = null, _meta = null, _visa = null;

  Uint8List? _signature;

  /// user info for 'handshake' command
  Meta? _meta;
  Visa? _visa;

  @override
  ReliableMessageDelegate? get delegate {
    MessageDelegate? transceiver = super.delegate;
    if (transceiver == null) {
      return null;
    }
    assert(transceiver is ReliableMessageDelegate, 'delegate error: $transceiver');
    return transceiver as ReliableMessageDelegate;
  }

  ///  Sender's Meta
  ///  ~~~~~~~~~~~~~
  ///  Extends for the first message package of 'Handshake' protocol.
  ///
  /// @param info - Meta object or dictionary
  @override
  Meta? get meta {
    _meta ??= Meta.parse(this['meta']);
    return _meta;
  }
  @override
  set meta(Meta? info) {
    setMap('meta', info);
    _meta = info;
  }

  ///  Sender's Visa
  ///  ~~~~~~~~~~~~~
  ///  Extends for the first message package of 'Handshake' protocol.
  ///
  /// @param doc - visa document
  @override
  Visa? get visa {
    if (_visa == null) {
      Document? doc = Document.parse(this['visa']);
      if (doc is Visa) {
        _visa = doc;
      } else {
        assert(doc == null, 'visa document error: $doc');
      }
    }
    return _visa;
  }
  @override
  set visa(Visa? doc) {
    setMap('visa', doc);
    _visa = doc;
  }

  @override
  Future<Uint8List> get signature async {
    if (_signature == null) {
      ReliableMessageDelegate? transceiver = delegate;
      Object? b64 = this['signature'];
      if (b64 == null) {
        assert(false, 'message signature not found: $this');
      } else {
        _signature = await transceiver?.decodeSignature(b64, this);
        assert(_signature != null, 'message signature error: $b64');
      }
    }
    return _signature!;
  }

  /*
   *  Verify the Reliable Message to Secure Message
   *
   *    +----------+      +----------+
   *    | sender   |      | sender   |
   *    | receiver |      | receiver |
   *    | time     |  ->  | time     |
   *    |          |      |          |
   *    | data     |      | data     |  1. verify(data, signature, sender.PK)
   *    | key/keys |      | key/keys |
   *    | signature|      +----------+
   *    +----------+
   */

  ///  Verify 'data' and 'signature' field with sender's public key
  ///
  /// @return SecureMessage object
  @override
  Future<SecureMessage?> verify() async {
    ReliableMessageDelegate? transceiver = delegate;
    // 1. verify data signature with sender's public key
    Uint8List ct = await data;
    Uint8List sig = await signature;
    if (await transceiver!.verifyDataSignature(ct, sig, sender, this)) {
      // 2. pack message
      Map info = copyMap(false);
      info.remove('signature');
      return SecureMessage.parse(info);
    } else {
      // assert(false, 'message signature not match: $this');
      // TODO: check whether visa is expired, query new document for this contact
      return null;
    }
  }

}
