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

import '../protocol/forward.dart';
import '../protocol/types.dart';

import 'base.dart';


/// ForwardContent
class SecretContent extends BaseContent implements ForwardContent {
  SecretContent([super.dict]);

  List<ReliableMessage>? _secrets;

  SecretContent.fromMessages(List<ReliableMessage> messages)
      : super.fromType(ContentType.FORWARD) {
    // secret messages
    _secrets = messages;
    // this['secrets'] = ReliableMessage.revert(messages);
  }

  @override
  Map toMap() {
    // serialize secret messages
    var messages = _secrets;
    if (messages != null && !containsKey('secrets')) {
      this['secrets'] = ReliableMessage.revert(messages);
      remove('forward');
    }
    // OK
    return super.toMap();
  }

  @override
  List<ReliableMessage> get secrets {
    List<ReliableMessage>? messages = _secrets;
    if (messages == null) {
      var info = this['secrets'];
      if (info is List) {
        // get from secrets
        messages = ReliableMessage.convert(info);
      } else {
        assert(info == null, 'secret messages error: $info');
        // get from 'forward'
        var forward = this['forward'];
        var msg = ReliableMessage.parse(forward);
        if (msg != null) {
          messages = [msg];
        } else {
          messages = [];
        }
      }
      _secrets = messages;
    }
    return messages;
  }

}


/// CombineContent
class CombineForwardContent extends BaseContent implements CombineContent {
  CombineForwardContent([super.dict]);

  List<InstantMessage>? _history;

  CombineForwardContent.fromTitle(String title, List<InstantMessage> messages)
      : super.fromType(ContentType.COMBINE_FORWARD) {
    // chat name
    this['title'] = title;
    // chat history
    _history = messages;
    // this['messages'] = InstantMessage.revert(messages);
  }

  @override
  Map toMap() {
    // serialize 'messages' messages
    var messages = _history;
    if (messages != null && !containsKey('messages')) {
      this['messages'] = InstantMessage.revert(messages);
    }
    // OK
    return super.toMap();
  }

  @override
  String get title => getString('title') ?? '';

  @override
  List<InstantMessage> get messages {
    List<InstantMessage>? array = _history;
    if (array == null) {
      var info = this['messages'];
      if (info is List) {
        array = InstantMessage.convert(info);
      } else {
        assert(info == null, 'combined messages error: $info');
        array = [];
      }
      _history = array;
    }
    return array;
  }

}


/// ArrayContent
class ListContent extends BaseContent implements ArrayContent {
  ListContent([super.dict]);

  List<Content>? _list;

  ListContent.fromContents(List<Content> contents)
      : super.fromType(ContentType.ARRAY) {
    // content list
    _list = contents;
    // this['contents'] = Content.revert(contents);
  }

  @override
  Map toMap() {
    // serialize 'contents'
    var contents = _list;
    if (contents != null && !containsKey('contents')) {
      this['contents'] = Content.revert(contents);
    }
    // OK
    return super.toMap();
  }

  @override
  List<Content> get contents {
    var array = _list;
    if (array == null) {
      var info = this['contents'];
      if (info is List) {
        array = Content.convert(info);
      } else {
        array = [];
      }
      _list = array;
    }
    return array;
  }

}
