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
import 'package:dkd/protocol.dart';
import 'package:mkm/protocol.dart';

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
  PlainMessage([super.dict]);

  /// message body
  Content? _content;

  PlainMessage.from(Envelope head, Content body) : super.fromEnvelope(head) {
    content = body;
  }

  @override
  DateTime? get time => content.time ?? envelope.time;

  @override
  ID? get group => content.group;

  @override
  String get type => content.type;

  @override
  Content get content {
    Content? body = _content;
    if (body == null) {
      var info = this['content'];
      body = Content.parse(info);
      assert(body != null, 'message content error: $toMap()');
      _content = body;
    }
    return body!;
  }

  // @override
  set content(Content body) {
    setMap('content', body);
    _content = body;
  }

}
