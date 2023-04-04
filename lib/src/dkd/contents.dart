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

import '../protocol/contents.dart';
import 'base.dart';


/// TextContent
class BaseTextContent extends BaseContent implements TextContent {
  BaseTextContent(super.dict);

  BaseTextContent.fromText(String message)
      : super.fromType(ContentType.kText) {
    this['text'] = message;
  }

  @override
  String get text => getString('text')!;

  @override
  set text(String message) => this['text'] = message;
}


/// ArrayContent
class ListContent extends BaseContent implements ArrayContent {
  ListContent(super.dict) : _list = null;

  ListContent.fromContents(List<Content> contents)
      : super.fromType(ContentType.kArray) {
    // set contents
    this['contents'] = revert(contents);
    _list = contents;
  }

  List<Content>? _list;

  @override
  List<Content> get contents {
    if (_list == null) {
      var info = this['contents'];
      if (info != null/* && info is List*/) {
        _list = convert(info);
      } else {
        _list = [];
      }
    }
    return _list!;
  }

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
      array.add(item.dictionary);
    }
    return array;
  }
}


/// CustomizedContent
class AppCustomizedContent extends BaseContent implements CustomizedContent {
  AppCustomizedContent(super.dict);

  AppCustomizedContent.from({int? type, required String app, required String mod, required String act})
      : super.fromType(type ?? ContentType.kCustomized) {
    this['app'] = app;
    this['mod'] = mod;
    this['act'] = act;
  }

  @override
  String get action => getString('app')!;

  @override
  String get application => getString('mod')!;

  @override
  String get module => getString('act')!;
}


/// ForwardContent
class SecretContent extends BaseContent implements ForwardContent {
  SecretContent(super.dict) : _forward = null, _secrets = null;

  SecretContent.fromMessage(ReliableMessage msg)
      : super.fromType(ContentType.kForward) {
    _forward = msg;
    _secrets = null;
    this['forward'] = msg.dictionary;
  }
  SecretContent.fromMessages(List<ReliableMessage> messages)
      : super.fromType(ContentType.kForward) {
    _forward = null;
    _secrets = messages;
    this['secrets'] = revert(messages);
  }

  ReliableMessage? _forward;
  List<ReliableMessage>? _secrets;

  @override
  ReliableMessage? get forward {
    _forward ??= ReliableMessage.parse(this['forward']);
    return _forward;
  }

  @override
  List<ReliableMessage> get secrets {
    if (_secrets == null) {
      var info = this['secrets'];
      if (info != null) {
        // get from secrets
        _secrets = convert(info);
      } else {
        // get from 'forward'
        List<ReliableMessage> messages = [];
        ReliableMessage? msg = forward;
        if (msg != null) {
          messages.add(msg);
        }
        _secrets = messages;
      }
    }
    return _secrets!;
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
      array.add(msg.dictionary);
    }
    return array;
  }
}


/// PageContent
class WebPageContent extends BaseContent implements PageContent {
  WebPageContent(super.dict) : _icon = null;

  WebPageContent.from({required String url, required String title, String? desc, Uint8List? icon})
      : super.fromType(ContentType.kPage) {
    this.url = url;
    this.title = title;
    this.desc = desc;
    this.icon = icon;
  }

  /// small image
  Uint8List? _icon;

  @override
  String get url => getString('URL')!;

  @override
  set url(String location) => this['URL'] = location;

  @override
  String get title => getString('title')!;

  @override
  set title(String string) => this['title'] = string;

  @override
  String? get desc => getString('desc');

  @override
  set desc(String? string)
  => string == null ? remove('desc') : this['desc'] = string;

  @override
  Uint8List? get icon {
    if (_icon == null) {
      String? b64 = getString('icon');
      if (b64 != null) {
        _icon = Base64.decode(b64);
      }
    }
    return _icon;
  }

  @override
  set icon(Uint8List? image) {
    if (image != null/* && image.isNotEmpty*/) {
      this['icon'] = Base64.encode(image);
    } else {
      remove('icon');
    }
    _icon = image;
  }
}


/// MoneyContent
class BaseMoneyContent extends BaseContent implements MoneyContent {
  BaseMoneyContent(super.dict);

  BaseMoneyContent.from({int? type, required String currency, required int amount})
      : super.fromType(type ?? ContentType.kMoney) {
    this['currency'] = currency;
    this['amount'] = amount;
  }

  @override
  String get currency => getString('currency')!;

  @override
  int get amount => getInt('amount');

  @override
  set amount(int value) => this['amount'] = value;
}

/// TransferContent
class TransferMoneyContent extends BaseMoneyContent implements TransferContent {
  TransferMoneyContent(super.dict);

  TransferMoneyContent.from({required String currency, required int amount})
      : super.from(type: ContentType.kTransfer, currency: currency, amount: amount);

  @override
  ID get remitter => ID.parse(getString('remitter'))!;

  @override
  set remitter(ID sender) => setString('remitter', sender);

  @override
  ID get remittee => ID.parse(getString('remittee'))!;

  @override
  set remittee(ID receiver) => setString('remittee', receiver);
}
