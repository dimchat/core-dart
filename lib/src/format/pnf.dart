/* license: https://mit-license.org
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
import 'package:mkm/crypto.dart';
import 'package:mkm/format.dart';
import 'package:mkm/type.dart';

import 'wrapper.dart';


class PortableNetworkFile extends Dictionary implements TransportableFile {
  PortableNetworkFile(Map content, {
    TransportableData? data,
    String? filename,
    Uri? url,
    DecryptKey? password,
  }) : super(content) {
    _wrapper = TransportableFileWrapper.create(super.toMap(),
      data: data, filename: filename, url: url, password: password,
    );
  }

  late TransportableFileWrapper _wrapper;

  // protected
  String get uriString {
    // serialize
    Map dict = _wrapper.toMap();
    // check 'URL'
    Uri? remote = url;
    if (remote != null) {
      int count = dict.length;
      if (count == 1) {
        // this PNF info contains 'URL' only,
        // so return the URI string here.
        return remote.toString();
      } else if (count == 2 && containsKey('filename')) {
        // ignore 'filename'
        return remote.toString();
      }
      // this PNF info contains other params,
      // cannot serialize it as a string.
      return '';
    }
    // check data
    String? text = getString('data');
    if (text != null && text.startsWith('data:')) {
      int count = dict.length;
      if (count == 1) {
        // this PNF info contains 'data' only,
        // and it is a data URI,
        // so return the URI string here.
        return text;
      } else if (count == 2) {
        // check filename
        String? filename = getString('filename');
        if (filename != null && filename.isNotEmpty) {
          // TODO: add 'filename' to data URI
          return text;
        }
      }
      // this PNF info contains other params,
      // cannot serialize it as a string.
      return '';
    }
    // the file data was saved into local storage,
    // so there is just a 'filename' here,
    // cannot build URI string
    return '';
  }

  @override
  String toString() {
    var uri = uriString;
    if (uri.isNotEmpty) {
      return uri;
    }
    // return JSON string
    var dict = _wrapper.toMap();
    return JSONMap.encode(dict);
  }

  @override
  Map toMap() {
    return _wrapper.toMap();
  }

  @override
  Object serialize() {
    var uri = uriString;
    if (uri.isNotEmpty) {
      return uri;
    }
    // return inner map
    return _wrapper.toMap();
  }

  ///  file data

  @override
  TransportableData? get data => _wrapper.data;

  @override
  set data(TransportableData? ted) => _wrapper.data = ted;

  ///  file name

  @override
  String? get filename => _wrapper.filename;

  @override
  set filename(String? name) => _wrapper.filename = name;

  ///  download URL

  @override
  Uri? get url => _wrapper.url;

  @override
  set url(Uri? remote) => _wrapper.url = remote;

  ///  decrypt key

  @override
  DecryptKey? get password => _wrapper.password;

  @override
  set password(DecryptKey? key) => _wrapper.password = key;

}
