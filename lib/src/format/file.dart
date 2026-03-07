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
import 'package:mkm/ext.dart';
import 'package:mkm/format.dart';
import 'package:mkm/type.dart';

import 'helper.dart';


/// Portable Network File (PNF) - transportable file with metadata and encryption support.
///
/// Extends [TransportableResource] to represent files with additional metadata
/// (filename, URL, encryption key) for network transmission.
///
/// Supported formats (extends [TransportableResource]):
/// 2. Data URI format: `"data:image/png;base64,{BASE64_ENCODE}"`
/// 3. Structured JSON object (with metadata and encryption):
///
/// ```json
/// {
///   "data"     : "...",         // Base64-encoded file content
///   "filename" : "avatar.png",
///   "URL"      : "http://...",  // CDN download URL (alternative to inline data)
///   "key"      : {              // Symmetric encryption key (for encrypted content)
///     "algorithm" : "AES",      // Encryption algorithm (e.g., "AES", "DES")
///     "data"      : "{BASE64_ENCODE}"
///   }
/// }
/// ```
abstract interface class TransportableFile implements Mapper, TransportableResource {

  /// Binary file data (encoded as [TransportableData]).
  ///
  /// For large files, it's recommended to use [url] instead of inline [data]
  /// to reduce payload size (upload to CDN first, then reference via URL).
  TransportableData? get data;
  set data(TransportableData? fileData);

  /// Original filename of the file (e.g., "avatar.png").
  String? get filename;
  set filename(String? name);

  /// Remote URL to download the file (typically from CDN).
  ///
  /// Alternative to inline [data] for large files.
  Uri? get url;
  set url(Uri? location);

  /// Decryption key for encrypted file content from CDN.
  ///
  /// Defaults to a plain key (returns original data when decrypted) if not specified.
  DecryptKey? get password;
  set password(DecryptKey? key);

  /// Returns string representation of the PNF.
  ///
  /// Returns:
  /// - URL string (if only [url] and [filename] are present)
  /// - JSON string of the structured object (for full metadata)
  @override
  String toString();

  /// Converts the PNF to a structured Map (format 3).
  ///
  /// Core logic:
  /// - Serializes the [data] property (TransportableData) into the "data" field of the Map
  /// - Subclasses may override this method to implement lazy serialization for other properties
  ///   (e.g., defer encoding large file data until this method is called)
  /// - Updates internal state with the serialized [data] before returning the Map
  ///
  /// Returns: Map representation of the PNF (matches JSON structure)
  @override
  Map toMap();

  /// Serializes the PNF to a transportable format.
  ///
  /// Serialization logic:
  /// - If only [url] and [filename] exist: returns URL string (toString())
  /// - Otherwise: returns structured Map (toMap())
  @override
  Object serialize();

  //
  //  Factory methods
  //

  /// Create from remote URL
  static TransportableFile createFromURL(Uri url, DecryptKey? password) {
    return create(null, null, url, password);
  }
  /// Create from file data
  static TransportableFile createFromData(TransportableData data, String? filename) {
    return create(data, filename, null, null);
  }

  static TransportableFile create(TransportableData? data, String? filename,
      Uri? url, DecryptKey? password) {
    var helper = sharedFormatExtensions.pnfHelper;
    return helper!.createTransportableFile(data, filename, url, password);
  }

  static TransportableFile? parse(Object? pnf) {
    var helper = sharedFormatExtensions.pnfHelper;
    return helper!.parseTransportableFile(pnf);
  }

  static TransportableFileFactory? getFactory() {
    var helper = sharedFormatExtensions.pnfHelper;
    return helper!.getTransportableFileFactory();
  }
  static void setFactory(TransportableFileFactory factory) {
    var helper = sharedFormatExtensions.pnfHelper;
    helper!.setTransportableFileFactory(factory);
  }
}


/// Factory interface for creating [TransportableFile] (PNF) instances.
abstract interface class TransportableFileFactory {

  /// Creates a [TransportableFile] instance with the given parameters.
  ///
  /// [data]: Encoded file content (null if using [url] instead)
  ///
  /// [filename]: Original filename of the file
  ///
  /// [url]: CDN download URL (alternative to [data])
  ///
  /// [password]: Decryption key for encrypted content
  ///
  /// Returns: New [TransportableFile] instance
  TransportableFile createTransportableFile(TransportableData? data, String? filename,
      Uri? url, DecryptKey? password);

  /// Parses a structured Map into a [TransportableFile] instance.
  ///
  /// [pnf]: Map representation of PNF (matches format 3 JSON structure)
  ///
  /// Returns: [TransportableFile] instance, or null if parsing fails
  TransportableFile? parseTransportableFile(Map pnf);
}
