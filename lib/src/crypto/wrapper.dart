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

import 'package:mkm/crypto.dart';
import 'package:mkm/format.dart';
import 'package:mkm/type.dart';


abstract interface class TransportableDataWrapper {

  bool get isEmpty;
  bool get isNotEmpty;

  ///  0. "{BASE64_ENCODE}"
  ///  1. "base64,{BASE64_ENCODE}"
  @override
  String toString();

  ///  Encode with 'Content-Type'
  ///
  ///  toString(mimeType)
  String encode(String mimeType);

  ///
  ///  Encode Algorithm
  ///
  String get algorithm;
  set algorithm(String name);

  ///
  ///  Binary Data
  ///
  Uint8List? get data;
  set data(Uint8List? binary);

}


abstract interface class PortableNetworkFileWrapper {

  ///  Serialize data
  Map toMap();

  ///
  ///  File data
  ///
  TransportableData? get data;
  set data(TransportableData? ted);
  /// set binary data
  void setBinary(Uint8List? binary);

  ///
  ///  File name
  ///
  String? get filename;
  set filename(String? name);

  ///
  ///  Download URL
  ///
  Uri? get url;
  set url(Uri? remote);

  ///
  ///  Decrypt key
  ///
  DecryptKey? get password;
  set password(DecryptKey? key);

}


abstract class BaseNetworkFormatWrapper {

  final Map _map;

  BaseNetworkFormatWrapper(Map dict)
      : _map = dict is Mapper ? dict.toMap() : dict;

  Map toMap() => _map;

  // get
  dynamic operator [](Object? key) => _map[key];
  // put
  void operator []=(String key, dynamic value) => _map[key] = value;

  dynamic remove(Object? key) => _map.remove(key);

  String? getString(String key, [String? defaultValue]) =>
      Converter.getString(_map[key], defaultValue);

  void setMap(String key, Mapper? mapper) {
    if (mapper == null) {
      _map.remove(key);
    } else {
      _map[key] = mapper.toMap();
    }
  }

}
