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

import 'package:dkd/protocol.dart';
import 'package:mkm/protocol.dart';

import '../dkd/files.dart';
import 'types.dart';


///  File message: {
///      type : i2s(0x10),
///      sn   : 123,
///
///      data     : "...",        // base64_encode(fileContent)
///      filename : "photo.png",
///
///      URL      : "http://...", // download from CDN
///      // before fileContent uploaded to a public CDN,
///      // it should be encrypted by a symmetric key
///      key      : {             // symmetric key to decrypt file content
///          algorithm : "AES",   // "DES", ...
///          data      : "{BASE64_ENCODE}",
///          ...
///      }
///  }
abstract interface class FileContent implements Content {

  Uint8List? get data;
  set data(Uint8List? fileData);

  String? get filename;
  set filename(String? name);

  // URL for download the file data from CDN
  Uri? get url;
  set url(Uri? remote);

  /// symmetric key to decrypt the downloaded data from URL
  DecryptKey? get password;
  set password(DecryptKey? key);

  //
  //  Factories
  //

  static FileContent create(String msgType, {
    TransportableData? data, String? filename,
    Uri? url, DecryptKey? password
  }) {
    if (msgType == ContentType.IMAGE) {
      return ImageFileContent.from(data, filename, url, password);
    } else if (msgType == ContentType.AUDIO) {
      return AudioFileContent.from(data, filename, url, password);
    } else if (msgType == ContentType.VIDEO) {
      return VideoFileContent.from(data, filename, url, password);
    }
    return BaseFileContent.from(msgType, data, filename, url, password);
  }

  static FileContent file({TransportableData? data, String? filename,
                           Uri? url, DecryptKey? password}) {
    return BaseFileContent.from(ContentType.FILE, data, filename, url, password);
  }

  static ImageContent image({TransportableData? data, String? filename,
                             Uri? url, DecryptKey? password}) {
    return ImageFileContent.from(data, filename, url, password);
  }

  static AudioContent audio({TransportableData? data, String? filename,
                             Uri? url, DecryptKey? password}) {
    return AudioFileContent.from(data, filename, url, password);
  }

  static VideoContent video({TransportableData? data, String? filename,
                             Uri? url, DecryptKey? password}) {
    return VideoFileContent.from(data, filename, url, password);
  }

}


///  Image message: {
///      type : i2s(0x12),
///      sn   : 123,
///
///      data     : "...",        // base64_encode(fileContent)
///      filename : "photo.png",
///
///      URL      : "http://...", // download from CDN
///      // before fileContent uploaded to a public CDN,
///      // it should be encrypted by a symmetric key
///      key      : {             // symmetric key to decrypt file content
///          algorithm : "AES",   // "DES", ...
///          data      : "{BASE64_ENCODE}",
///          ...
///      },
///      thumbnail : "data:image/jpeg;base64,..."
///  }
abstract interface class ImageContent implements FileContent {

  /// Base-64 image
  PortableNetworkFile? get thumbnail;
  set thumbnail(PortableNetworkFile? img);

}


///  Audio message: {
///      type : i2s(0x14),
///      sn   : 123,
///
///      data     : "...",        // base64_encode(fileContent)
///      filename : "voice.mp4",
///
///      URL      : "http://...", // download from CDN
///      // before fileContent uploaded to a public CDN,
///      // it should be encrypted by a symmetric key
///      key      : {             // symmetric key to decrypt file content
///          algorithm : "AES",   // "DES", ...
///          data      : "{BASE64_ENCODE}",
///          ...
///      },
///      text     : "..."         // Automatic Speech Recognition
///  }
abstract interface class AudioContent implements FileContent {

  String? get text;
  set text(String? asr);

}


///  Video message: {
///      type : i2s(0x16),
///      sn   : 123,
///
///      data     : "...",        // base64_encode(fileContent)
///      filename : "movie.mp4",
///
///      URL      : "http://...", // download from CDN
///      // before fileContent uploaded to a public CDN,
///      // it should be encrypted by a symmetric key
///      key      : {             // symmetric key to decrypt file content
///          algorithm : "AES",   // "DES", ...
///          data      : "{BASE64_ENCODE}",
///          ...
///      },
///      snapshot : "data:image/jpeg;base64,..."
///  }
abstract interface class VideoContent implements FileContent {

  /// Base-64 image
  PortableNetworkFile? get snapshot;
  set snapshot(PortableNetworkFile? img);

}
