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


abstract interface class TransportableFileWrapper {

  ///  Serialize data
  Map toMap();

  ///
  ///  File data
  ///
  TransportableData? get data;
  set data(TransportableData? ted);

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

  //
  //  Factory
  //

  static TransportableFileWrapper create(Map content, {
    TransportableData? data,
    String? filename,
    Uri? url,
    DecryptKey? password,
  }) {
    var factory = SharedNetworkFormatAccess().pnfWrapperFactory;
    return factory.createTransportableFileWrapper(content,
      data: data, filename: filename, url: url, password: password,
    );
  }

}


abstract interface class TransportableFileWrapperFactory {

  TransportableFileWrapper createTransportableFileWrapper(Map content, {
    TransportableData? data,
    String? filename,
    Uri? url,
    DecryptKey? password,
  });
}


///
///  Singleton
///
class SharedNetworkFormatAccess {
  factory SharedNetworkFormatAccess() => _instance;
  static final SharedNetworkFormatAccess _instance = SharedNetworkFormatAccess._internal();
  SharedNetworkFormatAccess._internal();

  TransportableFileWrapperFactory pnfWrapperFactory = _PNFWrapperFactory();

}


class _PNFWrapperFactory implements TransportableFileWrapperFactory {

  @override
  TransportableFileWrapper createTransportableFileWrapper(Map content, {
    TransportableData? data, String? filename, Uri? url, DecryptKey? password,
  }) {
    var wrapper = PortableNetworkFileWrapper(content);
    if (data != null) {
      wrapper.data = data;
    }
    if (filename != null) {
      wrapper.filename = filename;
    }
    if (url != null) {
      wrapper.url = url;
    }
    if (password != null) {
      wrapper.password = password;
    }
    return wrapper;
  }

}


///  File Content MixIn: {
///
///      "data"     : "...",        // base64_encode(fileContent)
///      "filename" : "photo.png",
///
///      "URL"      : "http://...", // download from CDN
///      // before fileContent uploaded to a public CDN,
///      // it should be encrypted by a symmetric key
///      "key"      : {             // symmetric key to decrypt file content
///          "algorithm" : "AES",   // "DES", ...
///          "data"      : "{BASE64_ENCODE}",
///          ...
///      }
///  }
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
    setMap('key', key);
    _password = key;
  }

}
