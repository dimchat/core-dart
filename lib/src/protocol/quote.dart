/* license: https://mit-license.org
 *
 *  DIMP : Decentralized Instant Messaging Protocol
 *
 *                                Written in 2024 by Moky <albert.moky@gmail.com>
 *
 * ==============================================================================
 * The MIT License (MIT)
 *
 * Copyright (c) 2024 Albert Moky
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

import '../dkd/quote.dart';


///  Quote message: {
///      type : 0x37,
///      sn   : 456,
///
///      text    : "...",  // text message
///      origin  : {       // original message envelope
///          sender    : "...",
///          receiver  : "...",
///
///          type      : 0x01,
///          sn        : 123,
///      }
///  }
abstract interface class QuoteContent implements Content {

  String get text;

  Envelope? get originalEnvelope;
  int? get originalSerialNumber;

  //
  //  Factory method
  //

  /// Create quote content with text & original message info
  static QuoteContent create(String text, Envelope head, Content body) {
    Map info = purify(head);
    info['type'] = body.type;
    info['sn'] = body.sn;
    // update: receiver -> group
    ID? group = body.group;
    if (group != null) {
      info['receiver'] = group.toString();
    }
    return BaseQuoteContent.from(text, info);
  }

  static Map purify(Envelope envelope) {
    ID from = envelope.sender;
    ID? to = envelope.group;
    to ??= envelope.receiver;
    // build origin info
    Map info = {
      'sender': from.toString(),
      'receiver': to.toString(),
    };
    return info;
  }

}


///  Combine Forward message: {
///      type : 0xCF,
///      sn   : 123,
///
///      title    : "...",  // chat title
///      messages : [...]   // chat history
///  }
abstract interface class CombineContent implements Content {

  String get title;

  List<InstantMessage> get messages;

  //
  //  Factory
  //

  static CombineContent create(String title, List<InstantMessage> messages) =>
      CombineForwardContent.from(title, messages);


  static List<InstantMessage> convert(Iterable messages) {
    List<InstantMessage> array = [];
    InstantMessage? msg;
    for (var item in messages) {
      msg = InstantMessage.parse(item);
      if (msg != null) {
        array.add(msg);
      }
    }
    return array;
  }

  static List<Map> revert(Iterable<InstantMessage> contents) {
    List<Map> array = [];
    for (InstantMessage item in contents) {
      array.add(item.toMap());
    }
    return array;
  }

}
