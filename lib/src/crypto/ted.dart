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

import 'package:mkm/format.dart';
import 'package:mkm/type.dart';

import 'algorithms.dart';

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
  BaseDataWrapper(super.dict);

  /// binary data
  Uint8List? _data;

  @override
  bool get isEmpty {
    if (super.isEmpty) {
      return true;
    }
    Uint8List? binary = data;
    return binary == null || binary.isEmpty;
  }

  @override
  String toString() {
    String? text = getString('data', null);
    if (text == null/* || text.isEmpty*/) {
      return '';
    }
    String? alg = getString('algorithm', null);
    if (alg == null || alg == EncodeAlgorithms.DEFAULT) {
      alg = '';
    }
    if (alg.isEmpty) {
      // 0. "{BASE64_ENCODE}"
      return text;
    } else {
      // 1. "base64,{BASE64_ENCODE}"
      return '$alg,$text';
    }
  }

  /// Encode with 'Content-Type'
  /// ~~~~~~~~~~~~~~~~~~~~~~~~~~
  /// toString(mimeType)
  String encode(String mimeType) {
    assert(!mimeType.contains(' '), 'content-type error: $mimeType');
    // get encoded data
    String? text = getString('data', null);
    if (text == null/* || text.isEmpty*/) {
      return '';
    }
    String alg = algorithm;
    // 2. "data:image/png;base64,{BASE64_ENCODE}"
    return 'data:$mimeType;$alg,$text';
  }

  ///
  /// encode algorithm
  ///
  String get algorithm {
    String? alg = getString('algorithm', null);
    if (alg == null || alg.isEmpty) {
      alg = EncodeAlgorithms.DEFAULT;
    }
    return alg;
  }

  set algorithm(String name) {
    if (name.isEmpty/* || name == EncodeAlgorithms.kDefault*/) {
      remove('algorithm');
    } else {
      this['algorithm'] = name;
    }
  }

  ///
  /// binary data
  ///
  Uint8List? get data {
    Uint8List? binary = _data;
    if (binary == null) {
      String? text = getString('data', null);
      if (text == null || text.isEmpty) {
        assert(false, 'TED data empty: ${toMap()}');
        return null;
      } else {
        String alg = algorithm;
        switch (alg) {
          case EncodeAlgorithms.BASE_64:
            binary = Base64.decode(text);
            break;
          case EncodeAlgorithms.BASE_58:
            binary = Base58.decode(text);
            break;
          case EncodeAlgorithms.HEX:
            binary = Hex.decode(text);
            break;
          default:
            assert(false, 'data algorithm not support: $alg');
            break;
        }
      }
      _data = binary;
    }
    return binary;
  }

  set data(Uint8List? binary) {
    if (binary == null || binary.isEmpty) {
      remove('data');
    } else {
      String text;
      String alg = algorithm;
      switch (alg) {
        case EncodeAlgorithms.BASE_64:
          text = Base64.encode(binary);
          break;
        case EncodeAlgorithms.BASE_58:
          text = Base58.encode(binary);
          break;
        case EncodeAlgorithms.HEX:
          text = Hex.encode(binary);
          break;
        default:
          throw FormatException('data algorithm not support: $alg');
          // assert(false, 'data algorithm not support: $alg');
      }
      this['data'] = text;
    }
    _data = binary;
  }

}