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
import 'package:dkd/protocol.dart';
import 'package:mkm/crypto.dart';
import 'package:mkm/format.dart';

import '../dkd/files.dart';
import '../format/file.dart';
import 'types.dart';


/// File message content interface.
///
/// Defines the base structure for all file-type messages (image, audio, video, etc.).
/// Files can be embedded as base64 data or downloaded via CDN URL (with encryption).
///
/// JSON format:
/// ```json
/// {
///   "type" : i2s(0x10),
///   "sn"   : 123,
///
///   "data"     : "...",         // Base64 encoded file content
///   "filename" : "photo.png",
///
///   "URL"      : "http://...",  // CDN download URL (file is encrypted before upload)
///   "key"      : {              // Symmetric key to decrypt CDN-downloaded file
///     "algorithm" : "AES",      // Encryption algorithm (e.g. AES, DES)
///     "data"      : "{BASE64_ENCODE}"
///   }
/// }
/// ```
abstract interface class FileContent implements Content {

  /// Embedded file content (Base64 encoded).
  ///
  /// Null if file is only available via CDN URL.
  TransportableData? get data;
  set data(TransportableData? fileData);

  /// Original filename of the file (including extension).
  ///
  /// e.g. "photo.png", "document.pdf"
  String? get filename;
  set filename(String? name);

  /// CDN URL for downloading the encrypted file content.
  ///
  /// File content on CDN is encrypted with a symmetric key ([password]).
  Uri? get url;
  set url(Uri? remote);

  /// Symmetric decryption key for CDN-downloaded file content.
  ///
  /// Required to decrypt files downloaded from [url] (file is encrypted before upload to CDN).
  DecryptKey? get password;
  set password(DecryptKey? key);

  //
  //  PNF transforming
  //

  TransportableFile toTransportableFile();

  //
  //  Factories
  //

  static FileContent create(String msgType, {
    TransportableData? data, String? filename,
    Uri? url, DecryptKey? password,
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

  static FileContent file({
    TransportableData? data, String? filename,
    Uri? url, DecryptKey? password,
  }) => BaseFileContent.from(ContentType.FILE, data, filename, url, password);

  static ImageContent image({
    TransportableData? data, String? filename,
    Uri? url, DecryptKey? password,
  }) => ImageFileContent.from(data, filename, url, password);

  static AudioContent audio({
    TransportableData? data, String? filename,
    Uri? url, DecryptKey? password,
  }) => AudioFileContent.from(data, filename, url, password);

  static VideoContent video({
    TransportableData? data, String? filename,
    Uri? url, DecryptKey? password,
  }) => VideoFileContent.from(data, filename, url, password);

}


/// Image message content interface.
///
/// Extends [FileContent] with thumbnail support for previewing images.
///
/// JSON format:
/// ```json
/// {
///   "type" : i2s(0x12),
///   "sn"   : 123,
///
///   "data"     : "...",         // Base64 encoded image content
///   "filename" : "photo.png",
///
///   "URL"      : "http://...",  // CDN download URL (encrypted)
///   "key"      : {              // Symmetric key to decrypt image
///     "algorithm" : "AES",
///     "data"      : "{BASE64_ENCODE}"
///   },
///   "thumbnail": "data:image/jpeg;base64,..."
/// }
/// ```
abstract interface class ImageContent implements FileContent {

  /// Thumbnail preview of the image (Base64 encoded).
  ///
  /// Used for quick preview without downloading the full image file.
  TransportableFile? get thumbnail;
  set thumbnail(TransportableFile? img);

}


/// Audio message content interface.
///
/// Extends [FileContent] with speech-to-text (ASR) support for audio messages.
///
/// JSON format:
/// ```json
/// {
///   "type" : i2s(0x14),
///   "sn"   : 123,
///
///   "data"     : "...",         // Base64 encoded audio content
///   "filename" : "voice.mp4",
///
///   "URL"      : "http://...",  // CDN download URL (encrypted)
///   "key"      : {              // Symmetric key to decrypt audio
///     "algorithm" : "AES",
///     "data"      : "{BASE64_ENCODE}"
///   },
///   "text": "..."               // Automatic Speech Recognition (ASR) result
/// }
/// ```
abstract interface class AudioContent implements FileContent {

  /// Automatic Speech Recognition (ASR) text of the audio.
  ///
  /// Transcribed text from the audio content (null if not transcribed).
  String? get text;
  set text(String? asr);

}


/// Video message content interface.
///
/// Extends [FileContent] with snapshot support for previewing videos.
///
/// JSON format:
/// ```json
/// {
///   "type" : i2s(0x16),
///   "sn"   : 123,
///
///   "data"     : "...",         // Base64 encoded video content
///   "filename" : "movie.mp4",
///
///   "URL"      : "http://...",  // CDN download URL (encrypted)
///   "key"      : {              // Symmetric key to decrypt video
///     "algorithm" : "AES",
///     "data"      : "{BASE64_ENCODE}"
///   },
///   "snapshot": "data:image/jpeg;base64,..."
/// }
/// ```
abstract interface class VideoContent implements FileContent {

  /// Snapshot (preview image) of the video (Base64 encoded).
  ///
  /// Usually the first frame of the video for quick preview.
  TransportableFile? get snapshot;
  set snapshot(TransportableFile? img);

}
