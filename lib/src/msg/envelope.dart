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

///  Envelope for message
///  ~~~~~~~~~~~~~~~~~~~~
///  This class is used to create a message envelope
///  which contains 'sender', 'receiver' and 'time'
///
///  data format: {
///      sender   : "moki@xxx",
///      receiver : "hulk@yyy",
///      time     : 123
///  }
class MessageEnvelope extends Dictionary implements Envelope {
  MessageEnvelope(super.dict);

  ID? _sender;
  ID? _receiver;
  DateTime? _time;

  MessageEnvelope.from({required ID sender, required ID? receiver, DateTime? time})
      : super(null) {
    receiver ??= ID.ANYONE;
    time ??= DateTime.now();
    _sender = sender;
    _receiver = receiver;
    _time = time;
    setString('sender', sender);
    setString('receiver', receiver);
    setDateTime('time', time);
  }

  @override
  ID get sender {
    _sender ??= ID.parse(this['sender']);
    assert(_sender != null, 'message sender not found: $this');
    return _sender!;
  }

  @override
  ID get receiver {
    if (_receiver == null) {
      _receiver = ID.parse(this['receiver']);
      _receiver ??= ID.ANYONE;
    }
    return _receiver!;
  }

  @override
  DateTime? get time {
    _time ??= getDateTime('time', null);
    return _time;
  }

  /*
   *  Group ID
   *  ~~~~~~~~
   *  when a group message was split/trimmed to a single message
   *  the 'receiver' will be changed to a member ID, and
   *  the group ID will be saved as 'group'.
   */
  @override
  ID? get group => ID.parse(this['group']);

  @override
  set group(ID? gid) => setString('group', gid);

  /*
   *  Message Type
   *  ~~~~~~~~~~~~
   *  because the message content will be encrypted, so
   *  the intermediate nodes(station) cannot recognize what kind of it.
   *  we pick out the content type and set it in envelope
   *  to let the station do its job.
   */
  @override
  String? get type => getString('type', null);

  @override
  set type(String? msgType) => this['type'] = msgType;
}
