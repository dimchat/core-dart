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


/// Top-secret forward content.
/// Wraps secure and certified messages.
///
/// JSON format:
/// ```json
/// {
///   "type" : i2s(0xFF),
///   "sn"   : 456,
///
///   "forward" : {...},  // reliable (secure + certified) message
///   "secrets" : [...]   // reliable (secure + certified) messages
/// }
/// ```
abstract interface class ForwardContent implements Content {

  /// List of secure, certified reliable messages.
  List<ReliableMessage> get secrets;

  //
  //  Factory
  //

  static ForwardContent create({List<ReliableMessage>? secrets}) =>
      SecretContent.fromMessages(secrets!);

}


/// Combined forward content for chat history forwarding.
///
/// Special message format designed to forward a set of chat records as a single message.
///
/// JSON format:
/// ```json
/// {
///   "type" : i2s(0xCF),
///   "sn"   : 123,
///
///   "title"    : "...",  // Chat history title
///   "messages" : [...]   // List of chat records to forward
/// }
/// ```
abstract interface class CombineContent implements Content {

  /// Title for the forwarded chat history set.
  String get title;

  /// List of chat records (instant messages) to be forwarded.
  List<InstantMessage> get messages;

  //
  //  Factory
  //

  static CombineContent create(String title, List<InstantMessage> messages) =>
      CombineForwardContent.fromTitle(title, messages);

}


/// Content array interface for sending multiple contents in one message.
///
/// Enables packaging multiple different types of [Content] into a single message.
///
/// JSON format:
/// ```json
/// {
///   "type" : i2s(0xCA),
///   "sn"   : 123,
///
///   "contents" : [...]  // Array of different content types
/// }
/// ```
abstract interface class ArrayContent implements Content {

  /// Array of multiple message contents (can be different types).
  List<Content> get contents;

  //
  //  Factory
  //

  static ArrayContent create(List<Content> contents) =>
      ListContent.fromContents(contents);

}
