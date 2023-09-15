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
import 'dart:typed_data';

import 'package:mkm/mkm.dart';

///  Transportable Data Mixin: {
///
///     algorithm : "base64",
///     data      : "...",      // base64_encode(data)
///     ...
///  }
///
///  data format:
///     0. "{BASE64_ENCODE}"
///     1. "base64,{BASE64_ENCODE}"
///     2. "data:image/png;base64,{BASE64_ENCODE}"
class BaseDataWrapper extends Dictionary {
  BaseDataWrapper(super.dict) : _binary = null;

  /// binary data
  Uint8List? _binary;

  @override
  String toString() {
    String encoded = getString('data', '')!;
    if (encoded.isEmpty) {
      return encoded;
    }
    String alg = getString('algorithm', '')!;
    if (alg == TransportableData.kDefault) {
      alg = '';
    }
    if (alg.isEmpty) {
      // 0. "{BASE64_ENCODE}"
      return encoded;
    } else {
      // 1. "base64,{BASE64_ENCODE}"
      return '$alg,$encoded';
    }
  }

  /// toString(mimeType)
  String encode(String mimeType) {
    assert(!mimeType.contains(' '), 'content-type error: $mimeType');
    // get encoded data
    String encoded = getString('data', '')!;
    if (encoded.isEmpty) {
      return encoded;
    }
    String alg = algorithm;
    // 2. "data:image/png;base64,{BASE64_ENCODE}"
    return 'data:$mimeType;$alg,$encoded';
  }

  ///
  /// encode algorithm
  ///
  String get algorithm {
    String alg = getString('algorithm', '')!;
    if (alg.isEmpty) {
      alg = TransportableData.kDefault;
    }
    return alg;
  }

  set algorithm(String name) {
    if (name.isEmpty/* || name == TransportableData.kDefault*/) {
      remove('algorithm');
    } else {
      this['algorithm'] = name;
    }
  }

  ///
  /// binary data
  ///
  Uint8List? get data {
    if (_binary == null) {
      String encoded = getString('data', '')!;
      if (encoded.isNotEmpty) {
        String alg = algorithm;
        if (alg == TransportableData.kBASE_64) {
          _binary = Base64.decode(encoded);
        } else if (alg == TransportableData.kBASE_58) {
          _binary = Base58.decode(encoded);
        } else if (alg == TransportableData.kHEX) {
          _binary = Hex.decode(encoded);
        } else {
          assert(false, 'data algorithm not support: $alg');
        }
      }
    }
    return _binary;
  }

  set data(Uint8List? binary) {
    if (binary == null || binary.isEmpty) {
      remove('data');
    } else {
      String encoded = '';
      String alg = algorithm;
      if (alg == TransportableData.kBASE_64) {
        encoded = Base64.encode(binary);
      } else if (alg == TransportableData.kBASE_58) {
        encoded = Base58.encode(binary);
      } else if (alg == TransportableData.kHEX) {
        encoded = Hex.encode(binary);
      } else {
        assert(false, 'data algorithm not support: $alg');
      }
      this['data'] = encoded;
    }
    _binary = binary;
  }

}