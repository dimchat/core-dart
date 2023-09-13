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
  BaseFileContent(super.dict) : _attachment = null, _remoteURL = null, _password = null;

  /// file data (not encrypted)
  TransportableData? _attachment;

  /// download from CDN
  Uri? _remoteURL;

  /// key to decrypt data downloaded from CDN
  DecryptKey? _password;

  BaseFileContent.from(int? msgType,
      {Uri? url, DecryptKey? password, Uint8List? data, String? filename})
      : super.fromType(msgType ?? ContentType.kFile) {
    //
    //  file data
    //
    if (data == null) {
      _attachment = null;
    } else {
      this.data = data;
    }
    //
    //  filename
    //
    if (filename != null) {
      this['filename'] = filename;
    }
    //
    //  remote URL
    //
    if (url == null) {
      _remoteURL = null;
    } else {
      this.url = url;
    }
    //
    //  decrypt key
    //
    if (password == null) {
      _password = null;
    } else {
      this.password = password;
    }
  }

  @override
  Uint8List? get data {
    TransportableData? ted = _attachment;
    if (ted == null) {
      Object? base64 = this['data'];
      _attachment = ted = TransportableData.parse(base64);
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
    _attachment = ted;
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
  Uri? get url {
    Uri? location = _remoteURL;
    if (location == null) {
      String? remote = getString('URL', null);
      if (remote != null/* && remote.isNotEmpty*/) {
        _remoteURL = location = Uri.parse(remote);
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
    _remoteURL = location;
  }

  @override
  DecryptKey? get password {
    _password ??= SymmetricKey.parse(this['password']);
    return _password;
  }

  @override
  set password(DecryptKey? key) {
    setMap('password', key);
    _password = key;
  }
}


///
/// ImageContent
///
class ImageFileContent extends BaseFileContent implements ImageContent {
  ImageFileContent(super.dict) : _thumbnail = null;

  /// small image
  TransportableData? _thumbnail;

  ImageFileContent.from({Uri? url, DecryptKey? password, Uint8List? data, String? filename})
      : super.from(ContentType.kImage, url: url, password: password, data: data, filename: filename);

  @override
  Uint8List? get thumbnail {
    TransportableData? ted = _thumbnail;
    if (ted == null) {
      Object? base64 = this['thumbnail'];
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

  AudioFileContent.from({Uri? url, DecryptKey? password, Uint8List? data, String? filename})
      : super.from(ContentType.kAudio, url: url, password: password, data: data, filename: filename);

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

  VideoFileContent.from({Uri? url, DecryptKey? password, Uint8List? data, String? filename})
      : super.from(ContentType.kVideo, url: url, password: password, data: data, filename: filename);

  @override
  Uint8List? get snapshot {
    TransportableData? ted = _snapshot;
    if (ted == null) {
      Object? base64 = this['snapshot'];
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
