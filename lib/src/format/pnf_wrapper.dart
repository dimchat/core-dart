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
import 'package:mkm/format.dart';
import 'package:mkm/type.dart';

import 'file_wrapper.dart';


class PortableNetworkFileWrapper implements TransportableFileWrapper {
  PortableNetworkFileWrapper(Map dict)
      : _map = dict is Mapper ? dict.toMap() : dict;

  final Map _map;

  /// file data (not encrypted)
  TransportableData? _attachment;

  /// download from CDN
  Uri? _remoteURL;

  /// key to decrypt data downloaded from CDN
  DecryptKey? _password;

  // get
  dynamic operator [](Object? key) => _map[key];
  // put
  void operator []=(String key, dynamic value) => _map[key] = value;

  dynamic remove(Object? key) => _map.remove(key);

  bool containsKey(Object? key) => _map.containsKey(key);

  String? getString(String key, [String? defaultValue]) =>
      Converter.getString(_map[key], defaultValue);

  void setMap(String key, Mapper? mapper) {
    if (mapper == null) {
      _map.remove(key);
    } else {
      _map[key] = mapper.toMap();
    }
  }

  @override
  Map toMap() {
    // serialize 'data'
    var ted = _attachment;
    if (ted != null && !containsKey('data')) {
      _map['data'] = ted.serialize();
    }
    // serialize 'key'
    var pwd = _password;
    if (pwd != null && !containsKey('key')) {
      _map['key'] = pwd.toMap();
    }
    // OK
    return _map;
  }

  @override
  TransportableData? get data {
    TransportableData? ted = _attachment;
    if (ted == null) {
      Object? base64 = _map['data'];
      ted = TransportableData.parse(base64);
      _attachment = ted;
    }
    return ted;
  }

  @override
  set data(TransportableData? ted) {
    _map.remove('data');
    // _map['data'] = ted?.serialize();
    _attachment = ted;
  }

  @override
  String? get filename => getString('filename');

  @override
  set filename(String? name) {
    if (name == null/* || name.isEmpty*/) {
      _map.remove('filename');
    } else {
      _map['filename'] = name;
    }
  }

  @override
  Uri? get url {
    Uri? remote = _remoteURL;
    if (remote == null) {
      String? locator = getString('URL');
      if (locator != null && locator.isNotEmpty) {
        _remoteURL = remote = Uri.parse(locator);
      }
    }
    return remote;
  }

  @override
  set url(Uri? remote) {
    if (remote == null) {
      _map.remove('URL');
    } else {
      _map['URL'] = remote.toString();
    }
    _remoteURL = remote;
  }

  @override
  DecryptKey? get password {
    DecryptKey? key = _password;
    if (key == null) {
      key = SymmetricKey.parse(_map['key']);
      _password = key;
    }
    return key;
  }

  @override
  set password(DecryptKey? key) {
    _map.remove('key');
    // setMap('key', key);
    // _map['key'] = key?.toMap();
    _password = key;
  }

}
