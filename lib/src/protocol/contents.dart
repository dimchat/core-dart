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
import 'package:mkm/format.dart';
import 'package:mkm/mkm.dart';
import 'package:dkd/dkd.dart';

import '../dkd/contents.dart';


///  Text message: {
///      type : i2s(0x01),
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
///      type : i2s(0xCA),
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

}


///  Top-Secret message: {
///      type : i2s(0xFF),
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

}


///  Web Page message: {
///      type : i2s(0x20),
///      sn   : 123,
///
///      title : "...",                // Web title
///      desc  : "...",
///      icon  : "data:image/x-icon;base64,...",
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

  /// Base-64 image
  PortableNetworkFile? get icon;
  set icon(PortableNetworkFile? img);

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
    required String title, PortableNetworkFile? icon, String? desc}) =>
      WebPageContent.from(url: url, html: html,
        title: title, icon: icon, desc: desc);

  static PageContent createFromURL(Uri url, {
    required String title, PortableNetworkFile? icon, String? desc}) =>
      create(url: url, html: null, title: title, icon: icon, desc: desc);

  static PageContent createFromHTML(String html, {
    required String title, PortableNetworkFile? icon, String? desc}) =>
      create(url: null, html: html, title: title, icon: icon, desc: desc);

}


///  Name Card content: {
///      type : i2s(0x33),
///      sn   : 123,
///
///      did    : "{ID}",        // contact's ID
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
