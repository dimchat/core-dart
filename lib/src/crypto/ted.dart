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

import '../protocol/algorithms.dart';
import 'wrapper.dart';

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
class BaseDataWrapper extends BaseNetworkFormatWrapper implements TransportableDataWrapper {
  BaseDataWrapper(super.dict);

  /// binary data
  Uint8List? _data;

  @override
  bool get isEmpty {
    Uint8List? binary = data;
    if (binary != null && binary.isNotEmpty) {
      return false;
    }
    String? text = getString('data');
    return text == null || text.isEmpty;
  }

  @override
  bool get isNotEmpty {
    Uint8List? binary = data;
    if (binary != null && binary.isNotEmpty) {
      return true;
    }
    String? text = getString('data');
    return text != null && text.isNotEmpty;
  }

  @override
  String toString() {
    // get encoded data
    String? text = encodedData;
    if (text == null/* || text.isEmpty*/) {
      return '';
    }
    String? alg = getString('algorithm');
    if (alg == null || alg == EncodeAlgorithms.DEFAULT) {
      alg = '';
    }
    if (alg.isEmpty) {
      // 0. "{BASE64_ENCODE}"
      return text;
    }
    String? mimeType = getString('mime-type');
    if (mimeType == null || mimeType.isEmpty) {
      // 1. "base64,{BASE64_ENCODE}"
      return '$alg,$text';
    } else {
      // 2. "data:image/png;base64,{BASE64_ENCODE}"
      return 'data:$mimeType;$alg,$text';
    }
  }

  @override
  String encode(String mimeType) {
    assert(!mimeType.contains(' '), 'content-type error: $mimeType');
    // get encoded data
    String? text = encodedData;
    if (text == null/* || text.isEmpty*/) {
      return '';
    }
    String alg = algorithm;
    // 2. "data:image/png;base64,{BASE64_ENCODE}"
    return 'data:$mimeType;$alg,$text';
  }

  @override
  String get algorithm {
    String? alg = getString('algorithm');
    if (alg == null || alg.isEmpty) {
      alg = EncodeAlgorithms.DEFAULT;
    }
    return alg;
  }

  @override
  set algorithm(String name) {
    if (name.isEmpty/* || name == EncodeAlgorithms.kDefault*/) {
      remove('algorithm');
    } else {
      this['algorithm'] = name;
    }
  }

  @override
  Uint8List? get data {
    Uint8List? binary = _data;
    if (binary == null) {
      String? text = getString('data');
      if (text == null || text.isEmpty) {
        assert(false, 'TED data empty: ${toMap()}');
        return null;
      }
      binary = decodeData(text, algorithm);
      _data = binary;
    }
    return binary;
  }

  @override
  set data(Uint8List? binary) {
    remove('data');
    // if (binary != null && binary.isNotEmpty) {
    //   String text = encodeData(binary, algorithm);
    //   this['data'] = text;
    // }
    _data = binary;
  }

  //
  //  Encoding
  //

  // protected
  String? get encodedData {
    String? text = getString('data');
    if (text == null || text.isEmpty) {
      Uint8List? binary = _data;
      if (binary == null || binary.isEmpty) {
        return null;
      }
      text = encodeData(binary, algorithm);
      assert(text.isNotEmpty, 'failed to encode data: ${binary.length}');
      this['data'] = text;
    }
    return text;
  }

  // protected
  String encodeData(Uint8List binary, String? alg) {
    switch (alg) {

      case EncodeAlgorithms.BASE_64:
        return Base64.encode(binary);

      case EncodeAlgorithms.BASE_58:
        return Base58.encode(binary);

      case EncodeAlgorithms.HEX:
        return Hex.encode(binary);

      default:
        throw FormatException('data algorithm not support: $alg');
        // assert(false, 'data algorithm not support: $alg');
    }
  }

  // protected
  Uint8List? decodeData(String text, String alg) {
    switch (alg) {

      case EncodeAlgorithms.BASE_64:
        return Base64.decode(text);

      case EncodeAlgorithms.BASE_58:
        return Base58.decode(text);

      case EncodeAlgorithms.HEX:
        return Hex.decode(text);

      default:
        assert(false, 'data algorithm not support: $alg');
        return null;
    }
  }

}