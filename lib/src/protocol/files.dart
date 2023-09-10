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

import '../dkd/files.dart';


///  File message: {
///      type : 0x10,
///      sn   : 123,
///
///      URL      : "http://...", // download from CDN
///      data     : "...",        // base64_encode(fileContent)
///      filename : "photo.png",
///      key      : {             // symmetric key to decrypt file content
///          algorithm : "AES",   // "DES", ...
///          data      : "{BASE64_ENCODE}",
///          ...
///      }
///  }
abstract class FileContent implements Content {

  Uri? get url;
  set url(Uri? location);

  Uint8List? get data;
  set data(Uint8List? fileData);

  String? get filename;
  set filename(String? name);

  /// symmetric key to decrypt the encrypted data from URL
  DecryptKey? get password;
  set password(DecryptKey? key);

  //
  //  Factories
  //

  static FileContent create(int msgType, {Uri? url, DecryptKey? key, Uint8List? data, String? filename}) {
    return BaseFileContent.from(msgType, url: url, key: key, data: data, filename: filename);
  }

  static FileContent file({Uri? url, DecryptKey? key, Uint8List? data, String? filename}) {
    return BaseFileContent.from(ContentType.kFile, url: url, key: key, data: data, filename: filename);
  }

  static ImageContent image({Uri? url, DecryptKey? key, Uint8List? data, String? filename}) {
    return ImageFileContent.from(url: url, key: key, data: data, filename: filename);
  }

  static AudioContent audio({Uri? url, DecryptKey? key, Uint8List? data, String? filename}) {
    return AudioFileContent.from(url: url, key: key, data: data, filename: filename);
  }

  static VideoContent video({Uri? url, DecryptKey? key, Uint8List? data, String? filename}) {
    return VideoFileContent.from(url: url, key: key, data: data, filename: filename);
  }
}


///  Image message: {
///      type : 0x12,
///      sn   : 123,
///
///      URL      : "http://...", // download from CDN
///      data     : "...",        // base64_encode(fileContent)
///      filename : "photo.png",
///      key      : {             // symmetric key to decrypt file content
///          algorithm : "AES",   // "DES", ...
///          data      : "{BASE64_ENCODE}",
///          ...
///      },
///      thumbnail : "..."        // base64_encode(smallImage)
///  }
abstract class ImageContent implements FileContent {

  Uint8List? get thumbnail;
  set thumbnail(Uint8List? image);
}


///  Audio message: {
///      type : 0x14,
///      sn   : 123,
///
///      URL      : "http://...", // download from CDN
///      data     : "...",        // base64_encode(fileContent)
///      filename : "voice.mp4",
///      key      : {             // symmetric key to decrypt file content
///          algorithm : "AES",   // "DES", ...
///          data      : "{BASE64_ENCODE}",
///          ...
///      },
///      text     : "..."         // Automatic Speech Recognition
///  }
abstract class AudioContent implements FileContent {

  String? get text;
  set text(String? asr);
}


///  Video message: {
///      type : 0x16,
///      sn   : 123,
///
///      URL      : "http://...", // download from CDN
///      data     : "...",        // base64_encode(fileContent)
///      filename : "movie.mp4",
///      key      : {             // symmetric key to decrypt file content
///          algorithm : "AES",   // "DES", ...
///          data      : "{BASE64_ENCODE}",
///          ...
///      },
///      snapshot : "..."        // base64_encode(smallImage)
///  }
abstract class VideoContent implements FileContent {

  Uint8List? get snapshot;
  set snapshot(Uint8List? image);
}
