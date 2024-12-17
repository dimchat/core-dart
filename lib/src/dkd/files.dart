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
import 'package:mkm/crypto.dart';

import '../crypto/pnf.dart';
import '../protocol/files.dart';
import 'base.dart';


///
/// File Content
///
class BaseFileContent extends BaseContent implements FileContent {
  BaseFileContent(super.dict);

  late final BaseFileWrapper _wrapper = BaseFileWrapper(toMap());

  BaseFileContent.from(int? msgType, TransportableData? data, String? filename,
      Uri? url, DecryptKey? password)
      : super.fromType(msgType ?? ContentType.FILE) {
    // file data
    if (data != null) {
      _wrapper.data = data;
    }
    // file name
    if (filename != null) {
      _wrapper.filename = filename;
    }
    // remote URL
    if (url != null) {
      _wrapper.url = url;
    }
    // decrypt key
    if (password != null) {
      _wrapper.password = password;
    }
  }

  /// file data

  @override
  Uint8List? get data => _wrapper.data?.data;

  @override
  set data(Uint8List? binary) => _wrapper.setDate(binary);

  /// file name

  @override
  String? get filename => _wrapper.filename;

  @override
  set filename(String? name) => _wrapper.filename = name;

  /// download URL

  @override
  Uri? get url => _wrapper.url;

  @override
  set url(Uri? remote) => _wrapper.url = remote;

  /// decrypt key

  @override
  DecryptKey? get password => _wrapper.password;

  @override
  set password(DecryptKey? key) => _wrapper.password = key;

}


///
/// ImageContent
///
class ImageFileContent extends BaseFileContent implements ImageContent {
  ImageFileContent(super.dict) : _thumbnail = null;

  /// small image
  PortableNetworkFile? _thumbnail;

  ImageFileContent.from(TransportableData? data, String? filename,
      Uri? url, DecryptKey? password)
      : super.from(ContentType.IMAGE, data, filename, url, password);

  @override
  PortableNetworkFile? get thumbnail {
    PortableNetworkFile? img = _thumbnail;
    if (img == null) {
      var base64 = getString('thumbnail', null);
      img = _thumbnail = PortableNetworkFile.parse(base64);
    }
    return img;
  }

  @override
  set thumbnail(PortableNetworkFile? img) {
    if (img == null) {
      remove('thumbnail');
    } else {
      this['thumbnail'] = img.toObject();
    }
    _thumbnail = img;
  }

}


///
/// AudioContent
///
class AudioFileContent extends BaseFileContent implements AudioContent {
  AudioFileContent(super.dict);

  AudioFileContent.from(TransportableData? data, String? filename,
      Uri? url, DecryptKey? password)
      : super.from(ContentType.AUDIO, data, filename, url, password);

  @override
  String? get text => getString('text', null);

  @override
  set text(String? asr) => this['text'] = asr;

}


///
/// VideoContent
///
class VideoFileContent extends BaseFileContent implements VideoContent {
  VideoFileContent(super.dict) : _snapshot = null;

  /// small image
  PortableNetworkFile? _snapshot;

  VideoFileContent.from(TransportableData? data, String? filename,
      Uri? url, DecryptKey? password)
      : super.from(ContentType.VIDEO, data, filename, url, password);

  @override
  PortableNetworkFile? get snapshot {
    PortableNetworkFile? img = _snapshot;
    if (img == null) {
      var base64 = getString('snapshot', null);
      img = _snapshot = PortableNetworkFile.parse(base64);
    }
    return img;
  }

  @override
  set snapshot(PortableNetworkFile? img) {
    if (img == null) {
      remove('snapshot');
    } else {
      this['snapshot'] = img.toObject();
    }
    _snapshot = img;
  }

}
