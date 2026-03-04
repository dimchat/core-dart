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
import 'package:mkm/crypto.dart';
import 'package:mkm/format.dart';

import '../format/wrapper.dart';
import '../protocol/types.dart';
import '../protocol/files.dart';
import 'base.dart';


///
/// File Content
///
class BaseFileContent extends BaseContent implements FileContent {
  BaseFileContent([super.dict]) {
    _wrapper = TransportableFileWrapper.create(super.toMap());
  }

  late final TransportableFileWrapper _wrapper;

  BaseFileContent.from(String? msgType, TransportableData? data, String? filename,
      Uri? url, DecryptKey? password)
      : super.fromType(msgType ?? ContentType.FILE) {
    _wrapper = TransportableFileWrapper.create(super.toMap(),
      data: data, filename: filename, url: url, password: password,
    );
  }

  @override
  Map toMap() {
    // call wrapper to serialize 'data' & 'key"
    return _wrapper.toMap();
  }

  /// file data

  @override
  TransportableData? get data => _wrapper.data;

  @override
  set data(TransportableData? binary) => _wrapper.data = data;

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
  ImageFileContent([super.dict]);

  /// small image
  TransportableFile? _thumbnail;

  ImageFileContent.from(TransportableData? data, String? filename,
      Uri? url, DecryptKey? password)
      : super.from(ContentType.IMAGE, data, filename, url, password);

  @override
  Map toMap() {
    // serialize 'thumbnail'
    var img = _thumbnail;
    if (img != null && !containsKey('thumbnail')) {
      this['thumbnail'] = img.serialize();
    }
    // OK
    return super.toMap();
  }

  @override
  TransportableFile? get thumbnail {
    TransportableFile? img = _thumbnail;
    if (img == null) {
      var uri = this['thumbnail'];
      img = TransportableFile.parse(uri);
      _thumbnail = img;
    }
    return img;
  }

  @override
  set thumbnail(TransportableFile? img) {
    remove('thumbnail');
    // this['thumbnail'] = img?.serialize();
    _thumbnail = img;
  }

}


///
/// AudioContent
///
class AudioFileContent extends BaseFileContent implements AudioContent {
  AudioFileContent([super.dict]);

  AudioFileContent.from(TransportableData? data, String? filename,
      Uri? url, DecryptKey? password)
      : super.from(ContentType.AUDIO, data, filename, url, password);

  @override
  String? get text => getString('text');

  @override
  set text(String? asr) => this['text'] = asr;

}


///
/// VideoContent
///
class VideoFileContent extends BaseFileContent implements VideoContent {
  VideoFileContent([super.dict]);

  /// small image
  TransportableFile? _snapshot;

  VideoFileContent.from(TransportableData? data, String? filename,
      Uri? url, DecryptKey? password)
      : super.from(ContentType.VIDEO, data, filename, url, password);

  @override
  Map toMap() {
    // serialize 'snapshot'
    var img = _snapshot;
    if (img != null && !containsKey('snapshot')) {
      this['snapshot'] = img.serialize();
    }
    // OK
    return super.toMap();
  }

  @override
  TransportableFile? get snapshot {
    TransportableFile? img = _snapshot;
    if (img == null) {
      var uri = this['snapshot'];
      img = TransportableFile.parse(uri);
      _snapshot = img;
    }
    return img;
  }

  @override
  set snapshot(TransportableFile? img) {
    remove('snapshot');
    // this['snapshot'] = img?.serialize();
    _snapshot = img;
  }

}
