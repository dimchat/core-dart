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

import 'package:mkm/format.dart';
import 'package:mkm/mkm.dart';
import 'package:dkd/dkd.dart';

import '../dkd/contents.dart';


///  Text message: {
///      type : 0x01,
///      sn   : 123,
///
///      text : "..."
///  }
abstract interface class TextContent implements Content {

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
abstract interface class ArrayContent implements Content {

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


///  Top-Secret message: {
///      type : 0xFF,
///      sn   : 456,
///
///      forward : {...}  // reliable (secure + certified) message
///      secrets : [...]  // reliable (secure + certified) messages
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
///      title : "...",                // Web title
///      icon  : "...",                // base64_encode(icon)
///      desc  : "...",
///
///      URL   : "https://github.com/moky/dimp",
///
///      HTML      : "...",            // Web content
///      mime_type : "text/html",      // Content-Type
///      encoding  : "utf8",
///      base      : "about:blank"     // Base URL
///
///  }
abstract interface class PageContent implements Content {

  String get title;
  set title(String string);

  Uint8List? get icon;
  set icon(Uint8List? image);

  String? get desc;
  set desc(String? string);

  Uri? get url;
  set url(Uri? locator);

  String? get html;
  set html(String? content);

  //
  //  Factories
  //

  static PageContent create({Uri? url, String? html,
    required String title, TransportableData? icon, String? desc}) =>
      WebPageContent.from(url: url, html: html,
        title: title, icon: icon, desc: desc);

  static PageContent createFromURL(Uri url, {
    required String title, TransportableData? icon, String? desc}) =>
      create(url: url, html: null, title: title, icon: icon, desc: desc);

  static PageContent createFromHTML(String html, {
    required String title, TransportableData? icon, String? desc}) =>
      create(url: null, html: html, title: title, icon: icon, desc: desc);

}


///  Name Card content: {
///      type : 0x33,
///      sn   : 123,
///
///      ID     : "{ID}",        // contact's ID
///      name   : "{nickname}}", // contact's name
///      avatar : "{URL}",       // avatar - PNF(URL)
///  }
abstract interface class NameCard implements Content {

  ID get identifier;

  String get name;

  PortableNetworkFile? get avatar;

  //
  //  Factory
  //

  static NameCard create(ID identifier, String name, PortableNetworkFile? avatar) =>
      NameCardContent.from(identifier, name, avatar);

}
