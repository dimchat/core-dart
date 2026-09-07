/* license: https://mit-license.org
 * =============================================================================
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
 * =============================================================================
 */
import 'package:mkm/crypto.dart';
import 'package:mkm/ext.dart';
import 'package:mkm/format.dart';

import 'pnf.dart';


// -----------------------------------------------------------------------------
//  Format Helpers
// -----------------------------------------------------------------------------

/// Helper interface for creating/parsing [TransportableFile] instances.
///
/// Provides factory methods to abstract the creation logic of [TransportableFile] implementations.
abstract interface class TransportableFileHelper {

  /// Set transportable file factory
  void setTransportableFileFactory(TransportableFileFactory factory);

  /// Get transportable file factory
  TransportableFileFactory? getTransportableFileFactory();

  /// Creates a [TransportableFile] instance with the given metadata.
  ///
  /// [data] is the binary file data (encoded as [TransportableData]).
  /// [filename] is the original file name (e.g., "document.pdf").
  /// [url] is the remote CDN URL (alternative to [data] for large files).
  /// [password] is the decryption key for encrypted CDN content.
  ///
  /// Returns an initialized [TransportableFile] instance.
  TransportableFile createTransportableFile(TransportableData? data, String? filename,
      Uri? url, DecryptKey? password);

  /// Parses a raw object into a [TransportableFile] instance.
  ///
  /// Converts arbitrary raw data (e.g., string, map) into a standardized
  /// TransportableFile object.
  ///
  /// [pnf] is the raw data object to parse.
  ///
  /// Returns a parsed [TransportableFile] instance (null if parsing fails).
  TransportableFile? parseTransportableFile(Object? pnf);

}

// -----------------------------------------------------------------------------
//  Format Extension Manager
// -----------------------------------------------------------------------------

/// PNF extension
TransportableFileHelper? _pnfHelper;

extension TransportableFileExtension on FormatExtensions {

  /// Get PNF helper
  TransportableFileHelper? get pnfHelper => _pnfHelper;

  /// Set PNF helper
  set pnfHelper(TransportableFileHelper? ext) => _pnfHelper = ext;

}
