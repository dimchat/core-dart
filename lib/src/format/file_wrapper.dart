/* license: https://mit-license.org
 * ==============================================================================
 * The MIT License (MIT)
 *
 * Copyright (c) 2026 Albert Moky
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
import 'package:mkm/ext.dart';
import 'package:mkm/format.dart';

import 'helper.dart';


/// A wrapper interface for serializing/deserializing [TransportableFile] data to/from a Map.
///
/// The serialized Map follows this structure:
/// ```json
/// {
///   "data": "<base64-encoded file content>", // From [TransportableData]
///   "filename": "photo.png",                 // Original file name
///
///   "URL": "http://example.com/photo.png",   // Remote CDN URL (alternative to `data`)
///   "key": {                                 // Symmetric decryption key (for encrypted CDN content)
///     "algorithm": "AES",                    // Encryption algorithm (e.g., "AES", "DES")
///     "data": "<base64-encoded key data>"    // Key material (base64 encoded)
///   }
/// }
/// ```
///
/// Key notes:
/// - `data` and `URL` are mutually exclusive for large files (prefer `URL` to reduce payload size)
/// - `key` is required only if the CDN-hosted content is encrypted
abstract interface class TransportableFileWrapper {

  /// Converts the wrapper's state to a structured Map (matches the format defined in this class).
  ///
  /// Core logic:
  /// - Serializes the [data] property (TransportableData) into the "data" field of the Map
  /// - Subclasses may override this method to implement lazy serialization for other properties
  ///   (e.g., defer encoding large file data until this method is called)
  ///
  /// Returns: Serialized Map containing the file metadata and serialized [data]
  Map toMap();

  /// Binary file data (encoded as [TransportableData]).
  ///
  /// For large files, use [url] instead to avoid large payloads.
  TransportableData? get data;
  set data(TransportableData? ted);

  /// Original filename of the file (e.g., "avatar.png").
  String? get filename;
  set filename(String? name);

  /// Remote CDN URL to download the file (alternative to [data] for large files).
  Uri? get url;
  set url(Uri? remote);

  /// Symmetric decryption key for encrypted file content from [url].
  ///
  /// Aliased as `password` for legacy compatibility (actual value is a [DecryptKey]).
  DecryptKey? get password;
  set password(DecryptKey? key);

  //
  //  Factory
  //

  static TransportableFileWrapper create(Map content, {
    TransportableData? data,
    String? filename,
    Uri? url,
    DecryptKey? password,
  }) {
    var factory = sharedFormatExtensions.pnfWrapperFactory;
    return factory.createTransportableFileWrapper(content,
      data: data, filename: filename, url: url, password: password,
    );
  }

}


/// Factory interface for creating [TransportableFileWrapper] instances.
///
/// Implement this interface to provide custom wrapper implementations
/// (e.g., for different serialization formats).
abstract interface class TransportableFileWrapperFactory {

  /// Creates a [TransportableFileWrapper] instance with the given parameters.
  ///
  /// Parameters:
  /// - [content]  : Base Map to initialize the wrapper (may contain partial metadata)
  /// - [data]     : Binary file data (overrides `content["data"]` if provided)
  /// - [filename] : Original file name (overrides `content["filename"]` if provided)
  /// - [url]      : Remote CDN URL (overrides `content["URL"]` if provided)
  /// - [password] : Decryption key (overrides `content["key"]` if provided)
  ///
  /// Returns: Custom [TransportableFileWrapper] implementation
  TransportableFileWrapper createTransportableFileWrapper(Map content, {
    TransportableData? data,
    String? filename,
    Uri? url,
    DecryptKey? password,
  });
}
