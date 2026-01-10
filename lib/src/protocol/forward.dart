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

import '../dkd/forward.dart';


///  Top-Secret message: {
///      "type" : i2s(0xFF),
///      "sn"   : 456,
///
///      "forward" : {...}  // reliable (secure + certified) message
///      "secrets" : [...]  // reliable (secure + certified) messages
///  }
abstract interface class ForwardContent implements Content {

  /// forward message
  ReliableMessage? get forward;

  /// secret messages
  List<ReliableMessage> get secrets;

  //
  //  Factory
  //

  static ForwardContent create({ReliableMessage? forward, List<ReliableMessage>? secrets}) {
    if (forward != null) {
      assert(secrets == null, 'parameters error');
      return SecretContent.fromMessage(forward);
    } else {
      assert(secrets != null, 'parameters error');
      return SecretContent.fromMessages(secrets!);
    }
  }

}


///  Combine Forward message: {
///      "type" : i2s(0xCF),
///      "sn"   : 123,
///
///      "title"    : "...",  // chat title
///      "messages" : [...]   // chat history
///  }
abstract interface class CombineContent implements Content {

  String get title;

  List<InstantMessage> get messages;

  //
  //  Factory
  //

  static CombineContent create(String title, List<InstantMessage> messages) =>
      CombineForwardContent.from(title, messages);

}


///  Content Array message: {
///      "type" : i2s(0xCA),
///      "sn"   : 123,
///
///      "contents" : [...]  // content array
///  }
abstract interface class ArrayContent implements Content {

  List<Content> get contents;

  //
  //  Factory
  //

  static ArrayContent create(List<Content> contents) =>
      ListContent.fromContents(contents);

}
