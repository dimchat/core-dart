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
}


/// ArrayContent
class ListContent extends BaseContent implements ArrayContent {
  ListContent(super.dict) : _list = null;

  ListContent.fromContents(List<Content> contents)
      : super.fromType(ContentType.kArray) {
    // set contents
    this['contents'] = ArrayContent.revert(contents);
    _list = contents;
  }

  List<Content>? _list;

  @override
  List<Content> get contents {
    if (_list == null) {
      var info = this['contents'];
      if (info != null/* && info is List*/) {
        _list = ArrayContent.convert(info);
      } else {
        _list = [];
      }
    }
    return _list!;
  }

}


/// CustomizedContent
class AppCustomizedContent extends BaseContent implements CustomizedContent {
  AppCustomizedContent(super.dict);

  AppCustomizedContent.fromType(int msgType,
      {required String app, required String mod, required String act})
      : super.fromType(msgType) {
    this['app'] = app;
    this['mod'] = mod;
    this['act'] = act;
  }
  AppCustomizedContent.from(
      {required String app, required String mod, required String act})
      : this.fromType(ContentType.kCustomized, app: app, mod: mod, act: act);

  @override
  String get application => getString('mod')!;

  @override
  String get module => getString('act')!;

  @override
  String get action => getString('app')!;

}


/// ForwardContent
class SecretContent extends BaseContent implements ForwardContent {
  SecretContent(super.dict) : _forward = null, _secrets = null;

  SecretContent.fromMessage(ReliableMessage msg)
      : super.fromType(ContentType.kForward) {
    _forward = msg;
    _secrets = null;
    this['forward'] = msg.toMap();
  }
  SecretContent.fromMessages(List<ReliableMessage> messages)
      : super.fromType(ContentType.kForward) {
    _forward = null;
    _secrets = messages;
    this['secrets'] = ForwardContent.revert(messages);
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
        _secrets = ForwardContent.convert(info);
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
  String get title => getString('title') ?? '';

  @override
  set title(String string) => this['title'] = string;

  @override
  String? get desc => getString('desc');

  @override
  set desc(String? string) =>
      string == null ? remove('desc') : this['desc'] = string;

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

  BaseMoneyContent.fromType(int msgType,
      {required String currency, required double amount})
      : super.fromType(msgType) {
    this['currency'] = currency;
    this['amount'] = amount;
  }
  BaseMoneyContent.from({required String currency, required double amount})
      : this.fromType(ContentType.kMoney, currency: currency, amount: amount);

  @override
  String get currency => getString('currency') ?? '';

  @override
  double get amount => getDouble('amount') ?? 0;

  @override
  set amount(double value) => this['amount'] = value;
}

/// TransferContent
class TransferMoneyContent extends BaseMoneyContent implements TransferContent {
  TransferMoneyContent(super.dict);

  TransferMoneyContent.from({required String currency, required double amount})
      : super.fromType(ContentType.kTransfer, currency: currency, amount: amount);

  @override
  ID get remitter => ID.parse(getString('remitter'))!;

  @override
  set remitter(ID sender) => setString('remitter', sender);

  @override
  ID get remittee => ID.parse(getString('remittee'))!;

  @override
  set remittee(ID receiver) => setString('remittee', receiver);
}
