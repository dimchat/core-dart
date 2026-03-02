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

import 'base_data.dart';


///
///  Base-64 encoding
///

class Base64Data extends BaseData {
  Base64Data(super.encoded, super.bytes);

  factory Base64Data.create(String encoded, Uint8List bytes)=>
      Base64Data(encoded, bytes);

  factory Base64Data.createWithString(String encoded) =>
      Base64Data(encoded, null);

  factory Base64Data.createWithBytes(Uint8List bytes) =>
      Base64Data('', bytes);

  //
  //  TransportableData
  //

  @override
  String? get encoding => EncodeAlgorithms.BASE_64;

  @override
  Uint8List? get bytes {
    Uint8List? bin = getDecodedBytes();
    if (bin == null) {
      String base64 = getEncodedString();
      bin = Base64.decode(base64);
      if (bin != null) {
        setDecodedBytes(bin);
      } else {
        assert(false, 'base64 string error: $base64');
      }
    }
    return bin;
  }


  @override
  String toString() {
    String base64 = getEncodedString();
    if (base64 == '') {
      Uint8List? bin = getDecodedBytes();
      if (bin != null) {
        base64 = Base64.encode(bin);
        setEncodedString(base64);
      }
      assert(base64.isNotEmpty, 'base64 data error: $bin');
    }
    return base64;
  }

}


///
///  UTF-8 encoding
///

class PlainData extends BaseData {
  PlainData(super.encoded, super.bytes);

  /// empty data
  factory PlainData.zero() => PlainData('', Uint8List(0));

  factory PlainData.create(String encoded, Uint8List bytes) =>
      PlainData(encoded, bytes);

  factory PlainData.createWithString(String encoded) =>
      PlainData(encoded, null);

  factory PlainData.createWithBytes(Uint8List bytes) =>
      PlainData('', bytes);

  //
  //  TransportableData
  //

  @override
  String? get encoding => '';  // 'PLAIN'

  @override
  Uint8List? get bytes {
    Uint8List? bin = getDecodedBytes();
    if (bin == null) {
      String txt = getEncodedString();
      bin = UTF8.encode(txt);
      setDecodedBytes(bin);
    }
    return bin;
  }


  @override
  String toString() {
    String txt = getEncodedString();
    if (txt == '') {
      Uint8List? bin = getDecodedBytes();
      if (bin != null) {
        txt = UTF8.decode(bin) ?? '';
        setEncodedString(txt);
      }
      assert(txt.isNotEmpty, 'plain data error: $bin');
    }
    return txt;
  }

}
