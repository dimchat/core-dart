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
import 'dart:typed_data';

import 'package:mkm/format.dart';
import 'package:mkm/type.dart';

import 'base_string.dart';


abstract class BaseData extends BaseString implements TransportableData {
  BaseData(String encoded, Uint8List? bytes) : super(encoded) {
    _bytes = bytes;
  }

  Uint8List? _bytes;

  // protected
  Uint8List? getDecodedBytes() => _bytes;
  void setDecodedBytes(Uint8List bytes) => _bytes = bytes;

  @override
  bool get isEmpty {
    var b = getDecodedBytes();
    if (b != null && b.isNotEmpty) {
      return false;
    }
    var s = getEncodedString();
    return s.isEmpty;
  }

  @override
  bool get isNotEmpty {
    var b = getDecodedBytes();
    if (b != null && b.isNotEmpty) {
      return true;
    }
    var s = getEncodedString();
    return s.isNotEmpty;
  }

  //
  //  TransportableData
  //

  @override
  int get lengthInBytes => bytes?.length ?? 0;

  @override
  int get length => bytes?.length ?? 0;

  @override
  String toString() => throw UnimplementedError();

  //
  //  TransportableResource
  //

  @override
  Object serialize() => toString();

  //
  //  IObject
  //

  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      // same object
      return true;
    } else if (other is BaseData) {
      // compare as base data
      return _dataEquals(this, other);
    } else if (other is TransportableData) {
      // compare as ted
      return _tedEquals(this, other);
    } else if (other is Stringer) {
      // compare with inner string
      return other.toString() == toString();
    }
    return other is String && other == toString();
  }

}

bool _dataEquals(BaseData self, BaseData other) {
  if (other.isEmpty) {
    return self.isEmpty;
  }
  // compare with inner string
  String thisString = self.getEncodedString();
  String thatString = other.getEncodedString();
  if (thisString != '' && thatString != '') {
    return thisString == thatString;
  }
  // compare with inner bytes
  Uint8List? thisBytes = self.getDecodedBytes();
  Uint8List? thatBytes = other.getDecodedBytes();
  if (thisBytes != null && thatBytes != null) {
    return thisBytes == thatBytes;
  }
  // compare with decoded bytes
  return self.bytes == other.bytes;
}

bool _tedEquals(BaseData self, TransportableData other) {
  if (other.isEmpty) {
    return self.isEmpty;
  }
  // compare with encoded string
  String thisString = self.getEncodedString();
  if (thisString != '') {
    String thatString = other.toString();
    return thisString == thatString;
  }
  // compare with decoded bytes
  Uint8List? thisBytes = self.getDecodedBytes();
  Uint8List? thatBytes = other.bytes;
  return thisBytes == thatBytes;
}
