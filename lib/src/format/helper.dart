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
import 'package:mkm/type.dart';

import 'file_wrapper.dart';
import 'pnf_wrapper.dart';


// -----------------------------------------------------------------------------
//  Format Helpers
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//  Format Extension Manager
// -----------------------------------------------------------------------------

extension TransportableFileWrapperExtension on FormatExtensions {

  TransportableFileWrapperFactory get pnfWrapperFactory => _pnfWrapperFactory;
  set pnfWrapperFactory(TransportableFileWrapperFactory ext) => _pnfWrapperFactory = ext;

}

/// PNF wrapper extension
TransportableFileWrapperFactory _pnfWrapperFactory = _PNFWrapperFactory();

/// Private implementation of [TransportableFileWrapperFactory].
///
/// Creates [PortableNetworkFileWrapper] instances with the given parameters.
final class _PNFWrapperFactory implements TransportableFileWrapperFactory {

  @override
  TransportableFileWrapper createTransportableFileWrapper(Mapping content, {
    TransportableData? data, String? filename, Uri? url, DecryptKey? password,
  }) {
    final wrapper = PortableNetworkFileWrapper(content);
    // file data
    if (data != null) {
      wrapper.data = data;
    }
    // file name
    if (filename != null) {
      wrapper.filename = filename;
    }
    // remote URL
    if (url != null) {
      wrapper.url = url;
    }
    // decrypt key
    if (password != null) {
      wrapper.password = password;
    }
    return wrapper;
  }

}
