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

import '../protocol/types.dart';
import '../protocol/contents.dart';

import 'base.dart';


/// TextContent
class BaseTextContent extends BaseContent implements TextContent {
  BaseTextContent([super.dict]);

  BaseTextContent.fromText(String message)
      : super.fromType(ContentType.TEXT) {
    this['text'] = message;
  }

  @override
  String get text => getString('text') ?? '';
}


/// PageContent
class WebPageContent extends BaseContent implements PageContent {
  WebPageContent([super.dict]);

  /// web URL
  Uri? _url;

  /// small image
  PortableNetworkFile? _icon;

  WebPageContent.from({required Uri? url, required String? html,
    required String title, PortableNetworkFile? icon, String? desc,})
      : super.fromType(ContentType.PAGE) {
    // URL or HTML
    this.url = url;
    this.html = html;
    // title, icon, description
    this.title = title;
    this.desc = desc;
    this.icon = icon;
  }

  //
  //  title
  //

  @override
  String get title => getString('title') ?? '';

  @override
  set title(String string) => this['title'] = string;

  //
  //  favicon.ico
  //

  @override
  PortableNetworkFile? get icon {
    PortableNetworkFile? img = _icon;
    if (img == null) {
      var base64 = getString('icon');
      img = _icon = PortableNetworkFile.parse(base64);
    }
    return img;
  }

  @override
  set icon(PortableNetworkFile? img) {
    if (img == null) {
      remove('icon');
    } else {
      this['icon'] = img.toObject();
    }
    _icon = img;
  }

  //
  //   keywords / descriptions
  //

  @override
  String? get desc => getString('desc');

  @override
  set desc(String? string) => this['desc'] = string;

  //
  //  URL
  //

  @override
  Uri? get url {
    var locator = _url;
    if (locator == null) {
      var str = getString('URL');
      if (str != null) {
        _url = locator = createURL(str);
      }
    }
    return locator;
  }
  // protected
  Uri? createURL(String str) => Uri.parse(str);

  @override
  set url(Uri? locator) {
    this['URL'] = locator?.toString();
    _url = locator;
  }

  //
  //  HTML
  //

  @override
  String? get html => getString('html');

  @override
  set html(String? content) => this['html'] = content;

}


/// NameCard
class NameCardContent extends BaseContent implements NameCard {
  NameCardContent([super.dict]);

  PortableNetworkFile? _image;

  NameCardContent.from(ID identifier, String name, PortableNetworkFile? avatar)
      : super.fromType(ContentType.NAME_CARD) {
    // ID
    this['did'] = identifier.toString();
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
  ID get identifier => ID.parse(this['did'])!;

  @override
  String get name => getString('name') ?? '';

  @override
  PortableNetworkFile? get avatar {
    PortableNetworkFile? img = _image;
    if (img == null) {
      var url = this['avatar'];
      img = PortableNetworkFile.parse(url);
      _image = img;
    }
    return img;
  }

}
