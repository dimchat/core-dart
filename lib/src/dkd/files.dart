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

import '../protocol/files.dart';
import 'base.dart';


///
/// File Content
///
class BaseFileContent extends BaseContent implements FileContent {
  BaseFileContent(super.dict) : _url = null, _key = null, _data = null;

  /// download from CDN
  Uri? _url;

  /// key to decrypt data downloaded from CDN
  DecryptKey? _key;

  /// file data (not encrypted)
  TransportableData? _data;

  BaseFileContent.from(int? msgType,
      {Uri? url, DecryptKey? key, Uint8List? data, String? filename})
      : super.fromType(msgType ?? ContentType.kFile) {
    // remote URL
    if (url != null) {
      this['URL'] = url.toString();
    }
    _url = url;
    // decrypt key
    if (key != null) {
      this['key'] = key.toMap();
    }
    _key = key;
    // file data
    TransportableData? ted;
    if (data != null) {
      ted = TransportableData.create(data);
      this['data'] = ted.toObject();
    }
    _data = ted;
    // filename
    if (filename != null) {
      this['filename'] = filename;
    }
  }

  @override
  Uri? get url {
    Uri? location = _url;
    if (location == null) {
      String? remote = getString('URL', null);
      if (remote != null) {
        _url = location = Uri.parse(remote);
      }
    }
    return location;
  }

  @override
  set url(Uri? location) {
    if (location == null) {
      remove('URL');
    } else {
      this['URL'] = location.toString();
    }
    _url = location;
  }

  @override
  Uint8List? get data {
    TransportableData? ted = _data;
    if (ted == null) {
      String? base64 = getString('data', null);
      _data = ted = TransportableData.parse(base64);
    }
    return ted?.data;
  }

  @override
  set data(Uint8List? fileData) {
    TransportableData? ted;
    if (fileData == null/* || fileData.isEmpty*/) {
      remove('data');
    } else {
      ted = TransportableData.create(fileData);
      this['data'] = ted.toObject();
    }
    _data = ted;
  }

  @override
  String? get filename => getString('filename', null);

  @override
  set filename(String? name) {
    if (name == null/* || name.isEmpty*/) {
      remove('filename');
    } else {
      this['filename'] = name;
    }
  }

  @override
  DecryptKey? get password {
    _key ??= SymmetricKey.parse(this['password']);
    return _key;
  }

  @override
  set password(DecryptKey? key) {
    setMap('password', key);
    _key = key;
  }
}


///
/// ImageContent
///
class ImageFileContent extends BaseFileContent implements ImageContent {
  ImageFileContent(super.dict) : _thumbnail = null;

  /// small image
  TransportableData? _thumbnail;

  ImageFileContent.from({Uri? url, DecryptKey? key, Uint8List? data, String? filename})
      : super.from(ContentType.kImage, url: url, key: key, data: data, filename: filename);

  @override
  Uint8List? get thumbnail {
    TransportableData? ted = _thumbnail;
    if (ted == null) {
      String? base64 = getString('thumbnail', null);
      _thumbnail = ted = TransportableData.parse(base64);
    }
    return ted?.data;
  }

  @override
  set thumbnail(Uint8List? image) {
    TransportableData? ted;
    if (image == null/* || image.isEmpty*/) {
      remove('thumbnail');
    } else {
      ted = TransportableData.create(image);
      this['thumbnail'] = ted.toObject();
    }
    _thumbnail = ted;
  }
}


///
/// AudioContent
///
class AudioFileContent extends BaseFileContent implements AudioContent {
  AudioFileContent(super.dict);

  AudioFileContent.from({Uri? url, DecryptKey? key, Uint8List? data, String? filename})
      : super.from(ContentType.kAudio, url: url, key: key, data: data, filename: filename);

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
  TransportableData? _snapshot;

  VideoFileContent.from({Uri? url, DecryptKey? key, Uint8List? data, String? filename})
      : super.from(ContentType.kVideo, url: url, key: key, data: data, filename: filename);

  @override
  Uint8List? get snapshot {
    TransportableData? ted = _snapshot;
    if (ted == null) {
      String? base64 = getString('snapshot', null);
      _snapshot = ted = TransportableData.parse(base64);
    }
    return ted?.data;
  }

  @override
  set snapshot(Uint8List? image) {
    TransportableData? ted;
    if (image == null/* || image.isEmpty*/) {
      remove('snapshot');
    } else {
      ted = TransportableData.create(image);
      this['snapshot'] = ted.toObject();
    }
    _snapshot = ted;
  }
}
