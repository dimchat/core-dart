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
/// FileContent
///
class BaseFileContent extends BaseContent implements FileContent {
  BaseFileContent(super.dict) : _data = null, _key = null;

  BaseFileContent.from(int type, String filename, Uint8List? binary, String? encoded)
      : super.fromType(type) {
    if (filename.isNotEmpty) {
      this['filename'] = filename;
    }
    if (encoded != null) {
      this['data'] = encoded;
    } else if (binary != null) {
      this['data'] = Base64.encode(binary);
    }
    _data = binary;
    _key = null;
  }

  BaseFileContent.fromData(String filename, Uint8List binary)
      : this.from(ContentType.kFile, filename, binary, null);

  BaseFileContent.fromEncodedData(String filename, String encoded)
      : this.from(ContentType.kFile, filename, null, encoded);

  /// file data (plaintext)
  late Uint8List? _data;

  /// key to decrypt data
  late DecryptKey? _key;

  @override
  String? get url => getString('URL');

  @override
  set url(String? location) {
    if (location != null/* && location.isNotEmpty*/) {
      this['URL'] = location;
    } else {
      remove('URL');
    }
  }

  @override
  Uint8List? get data {
    if (_data == null) {
      String? b64 = getString('data');
      if (b64 != null/* && b64.isNotEmpty*/) {
        _data = Base64.decode(b64);
      }
    }
    return _data;
  }

  @override
  set data(Uint8List? fileData) {
    if (fileData != null/* && fileData.isNotEmpty*/) {
      this['data'] = Base64.encode(fileData);
    } else {
      remove('data');
    }
    _data = fileData;
  }

  @override
  String? get filename => getString('filename');

  @override
  set filename(String? name) {
    if (name != null/* && name.isNotEmpty*/) {
      this['filename'] = name;
    } else {
      remove('filename');
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
  ImageFileContent(super.dict);

  ImageFileContent.fromData(String filename, Uint8List binary)
      : super.from(ContentType.kImage, filename, binary, null);

  ImageFileContent.fromEncodedData(String filename, String encode)
      : super.from(ContentType.kImage, filename, null, encode);

  /// small image
  late Uint8List? _thumbnail;

  @override
  Uint8List? get thumbnail {
    if (_thumbnail == null) {
      String? b64 = getString('thumbnail');
      if (b64 != null/* && b64.isNotEmpty*/) {
        _thumbnail = Base64.decode(b64);
      }
    }
    return _thumbnail;
  }

  @override
  set thumbnail(Uint8List? image) {
    if (image != null/* && image.isNotEmpty*/) {
      this['thumbnail'] = Base64.encode(image);
    } else {
      remove('thumbnail');
    }
    _thumbnail = image;
  }
}


///
/// AudioContent
///
class AudioFileContent extends BaseFileContent implements AudioContent {
  AudioFileContent(super.dict);

  AudioFileContent.fromData(String filename, Uint8List binary)
      : super.from(ContentType.kAudio, filename, binary, null);

  AudioFileContent.fromEncodedData(String filename, String encode)
      : super.from(ContentType.kAudio, filename, null, encode);

  @override
  String? get text => getString('text');

  @override
  set text(String? asr) => this['text'] = asr;
}


///
/// VideoContent
///
class VideoFileContent extends BaseFileContent implements VideoContent {
  VideoFileContent(super.dict);

  VideoFileContent.fromData(String filename, Uint8List binary)
      : super.from(ContentType.kVideo, filename, binary, null);

  VideoFileContent.fromEncodedData(String filename, String encode)
      : super.from(ContentType.kVideo, filename, null, encode);

  /// small image
  late Uint8List? _snapshot;

  @override
  Uint8List? get snapshot {
    if (_snapshot == null) {
      String? b64 = getString('snapshot');
      if (b64 != null/* && b64.isNotEmpty*/) {
        _snapshot = Base64.decode(b64);
      }
    }
    return _snapshot;
  }

  @override
  set snapshot(Uint8List? image) {
    if (image != null/* && image.isNotEmpty*/) {
      this['snapshot'] = Base64.encode(image);
    } else {
      remove('snapshot');
    }
    _snapshot = image;
  }
}
