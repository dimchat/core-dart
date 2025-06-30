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
import 'package:dkd/dkd.dart';
import 'package:mkm/type.dart';

/*
 *  Message Transforming
 *  ~~~~~~~~~~~~~~~~~~~~
 *
 *     Instant Message <-> Secure Message <-> Reliable Message
 *     +-------------+     +------------+     +--------------+
 *     |  sender     |     |  sender    |     |  sender      |
 *     |  receiver   |     |  receiver  |     |  receiver    |
 *     |  time       |     |  time      |     |  time        |
 *     |             |     |            |     |              |
 *     |  content    |     |  data      |     |  data        |
 *     +-------------+     |  key/keys  |     |  key/keys    |
 *                         +------------+     |  signature   |
 *                                            +--------------+
 *     Algorithm:
 *         data      = password.encrypt(content)
 *         key       = receiver.public_key.encrypt(password)
 *         signature = sender.private_key.sign(data)
 */

///  Message with Envelope
///  ~~~~~~~~~~~~~~~~~~~~~
///  Base classes for messages
///  This class is used to create a message
///  with the envelope fields, such as 'sender', 'receiver', and 'time'
///
///  data format: {
///      //-- envelope
///      sender   : "moki@xxx",
///      receiver : "hulk@yyy",
///      time     : 123,
///      //-- body
///      ...
///  }
abstract class BaseMessage extends Dictionary implements Message {
  BaseMessage(super.dict);

  Envelope? _envelope;

  BaseMessage.fromEnvelope(Envelope env) : super(env.toMap()) {
    _envelope = env;
  }

  @override
  Envelope get envelope {
    _envelope ??= Envelope.parse(toMap());
    return _envelope!;
  }

  //--------

  @override
  ID get sender => envelope.sender;

  @override
  ID get receiver => envelope.receiver;

  @override
  DateTime? get time => envelope.time;

  @override
  ID? get group => envelope.group;

  @override
  String? get type => envelope.type;

  //--------

  static bool isBroadcast(Message msg) {
    if (msg.receiver.isBroadcast) {
      return true;
    }
    // check exposed group
    Object? overtGroup = msg['group'];
    if (overtGroup == null) {
      return false;
    }
    ID? group = ID.parse(overtGroup);
    return group != null && group.isBroadcast;
  }

}
