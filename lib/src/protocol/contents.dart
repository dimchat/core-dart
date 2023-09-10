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

import '../dkd/contents.dart';


///  Text message: {
///      type : 0x01,
///      sn   : 123,
///
///      text : "..."
///  }
abstract class TextContent implements Content {

  String get text;

  //
  //  Factory
  //

  static TextContent create(String message) =>
      BaseTextContent.fromText(message);
}


///  Content Array message: {
///      type : 0xCA,
///      sn   : 123,
///
///      contents : [...]  // content array
///  }
abstract class ArrayContent implements Content {

  List<Content> get contents;

  //
  //  Factory
  //

  static ArrayContent create(List<Content> contents) =>
      ListContent.fromContents(contents);


  static List<Content> convert(List contents) {
    List<Content> array = [];
    Content? res;
    for (var item in contents) {
      res = Content.parse(item);
      if (res != null) {
        array.add(res);
      }
    }
    return array;
  }

  static List<Map> revert(List<Content> contents) {
    List<Map> array = [];
    for (Content item in contents) {
      array.add(item.toMap());
    }
    return array;
  }

}


///  Application Customized message: {
///      type : 0xCC,
///      sn   : 123,
///
///      app   : "{APP_ID}",  // application (e.g.: "chat.dim.sechat")
///      mod   : "{MODULE}",  // module name (e.g.: "drift_bottle")
///      act   : "{ACTION}",  // action name (3.g.: "throw")
///      extra : info         // action parameters
///  }
abstract class CustomizedContent implements Content {

  /// get App ID
  String get application;

  /// get Module name
  String get module;

  /// get Action name
  String get action;

  //
  //  Factory
  //

  static CustomizedContent create({required String app, required String mod, required String act}) =>
      AppCustomizedContent.from(app: app, mod: mod, act: act);
}


///  Top-Secret message: {
///      type : 0xFF,
///      sn   : 456,
///
///      forward : {...}  // reliable (secure + certified) message
///      secrets : [...]  // reliable (secure + certified) messages
///  }
abstract class ForwardContent implements Content {

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


  static List<ReliableMessage> convert(List messages) {
    List<ReliableMessage> array = [];
    ReliableMessage? msg;
    for (var item in messages) {
      msg = ReliableMessage.parse(item);
      if (msg != null) {
        array.add(msg);
      }
    }
    return array;
  }

  static List<Map> revert(List<ReliableMessage> messages) {
    List<Map> array = [];
    for (ReliableMessage msg in messages) {
      array.add(msg.toMap());
    }
    return array;
  }

}


///  Web Page message: {
///      type : 0x20,
///      sn   : 123,
///
///      URL   : "https://github.com/moky/dimp", // Page URL
///      icon  : "...",                          // base64_encode(icon)
///      title : "...",
///      desc  : "..."
///  }
abstract class PageContent implements Content {

  Uri get url;
  set url(Uri location);

  String get title;
  set title(String string);

  String? get desc;
  set desc(String? string);

  Uint8List? get icon;
  set icon(Uint8List? image);

  //
  //  Factory
  //

  static PageContent create({required Uri url, required String title, String? desc, Uint8List? icon}) =>
      WebPageContent.from(url: url, title: title, desc: desc, icon: icon);
}


///  Money message: {
///      type : 0x40,
///      sn   : 123,
///
///      currency : "RMB", // USD, USDT, ...
///      amount   : 100.00
///  }
abstract class MoneyContent implements Content {

  String get currency;

  double get amount;
  set amount(double value);

  //
  //  Factory
  //

  static MoneyContent create(int? msgType, {required String currency, required double amount}) {
    if (msgType == null) {
      return BaseMoneyContent.from(currency: currency, amount: amount);
    } else {
      return BaseMoneyContent.fromType(msgType, currency: currency, amount: amount);
    }
  }
}

///  Transfer money message: {
///      type : 0x41,
///      sn   : 123,
///
///      currency : "RMB",    // USD, USDT, ...
///      amount   : 100.00,
///      remitter : "{FROM}", // sender ID
///      remittee : "{TO}"    // receiver ID
///  }
abstract class TransferContent implements MoneyContent {

  /// sender
  ID get remitter;
  set remitter(ID sender);

  /// receiver
  ID get remittee;
  set remittee(ID receiver);

  //
  //  Factory
  //

  static TransferContent create({required String currency, required double amount}) =>
      TransferMoneyContent.from(currency: currency, amount: amount);
}
