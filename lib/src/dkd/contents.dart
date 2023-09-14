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
  String get text => getString('text', '')!;
}


/// ArrayContent
class ListContent extends BaseContent implements ArrayContent {
  ListContent(super.dict) : _list = null;

  List<Content>? _list;

  ListContent.fromContents(List<Content> contents)
      : super.fromType(ContentType.kArray) {
    // set contents
    this['contents'] = ArrayContent.revert(contents);
    _list = contents;
  }

  @override
  List<Content> get contents {
    if (_list == null) {
      var info = this['contents'];
      if (info is List) {
        _list = ArrayContent.convert(info);
      } else {
        _list = [];
      }
    }
    return _list!;
  }

}


/// ForwardContent
class SecretContent extends BaseContent implements ForwardContent {
  SecretContent(super.dict) : _forward = null, _secrets = null;

  ReliableMessage? _forward;
  List<ReliableMessage>? _secrets;

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

  @override
  ReliableMessage? get forward {
    _forward ??= ReliableMessage.parse(this['forward']);
    return _forward;
  }

  @override
  List<ReliableMessage> get secrets {
    if (_secrets == null) {
      var info = this['secrets'];
      if (info is List) {
        // get from secrets
        _secrets = ForwardContent.convert(info);
      } else {
        // get from 'forward'
        ReliableMessage? msg = forward;
        _secrets = msg == null ? [] : [msg];
      }
    }
    return _secrets!;
  }

}


/// PageContent
class WebPageContent extends BaseContent implements PageContent {
  WebPageContent(super.dict) : _url = null, _icon = null;

  /// web URL
  Uri? _url;

  /// small image
  TransportableData? _icon;

  WebPageContent.from({required Uri url, required String title, String? desc, Uint8List? icon})
      : super.fromType(ContentType.kPage) {
    this.url = url;
    this.title = title;
    this.desc = desc;
    this.icon = icon;
  }

  @override
  Uri get url {
    _url ??= Uri.parse(getString('URL', null)!);
    return _url!;
  }

  @override
  set url(Uri location) {
    this['URL'] = location.toString();
    _url = location;
  }

  @override
  String get title => getString('title', null)!;

  @override
  set title(String string) => this['title'] = string;

  @override
  String? get desc => getString('desc', null);

  @override
  set desc(String? string) =>
      string == null ? remove('desc') : this['desc'] = string;

  @override
  Uint8List? get icon {
    TransportableData? ted = _icon;
    if (ted == null) {
      Object? base64 = this['icon'];
      _icon = ted = TransportableData.parse(base64);
    }
    return ted?.data;
  }

  @override
  set icon(Uint8List? image) {
    if (image == null || image.isEmpty) {
      remove('icon');
      _icon = null;
    } else {
      TransportableData ted = TransportableData.create(image);
      this['icon'] = ted.toObject();
      _icon = ted;
    }
  }
}


/// NameCard
class NameCardContent extends BaseContent implements NameCard {
  NameCardContent(super.dict) : _image = null;

  PortableNetworkFile? _image;

  NameCardContent.from(ID identifier, String name, PortableNetworkFile? avatar)
      : super.fromType(ContentType.kNameCard) {
    // ID
    this['ID'] = identifier.toString();
    // name
    this['name'] = name;
    // avatar
    if (avatar != null) {
      // encode
      this['avatar'] = avatar.toObject();
    }
    _image = avatar;
  }

  @override
  ID get identifier => ID.parse(this['ID'])!;

  @override
  String get name => getString('name', '')!;

  @override
  PortableNetworkFile? get avatar {
    _image ??= PortableNetworkFile.parse(this['avatar']);
    return _image;
  }

}
