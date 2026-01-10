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

import 'package:mkm/crypto.dart';
import 'package:mkm/format.dart';

import 'wrapper.dart';

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
class BaseFileWrapper extends BaseNetworkFormatWrapper implements PortableNetworkFileWrapper {
  BaseFileWrapper(super.dict);

  /// file data (not encrypted)
  TransportableData? _attachment;

  /// download from CDN
  Uri? _remoteURL;

  /// key to decrypt data downloaded from CDN
  DecryptKey? _password;

  @override
  Map toMap() {
    Object? base64 = this['data'];
    TransportableData? ted = _attachment;
    if (base64 == null && ted != null) {
      this['data'] = ted.toObject();
    }
    return super.toMap();
  }

  //-------- getters/setters --------

  @override
  TransportableData? get data {
    TransportableData? ted = _attachment;
    if (ted == null) {
      Object? base64 = this['data'];
      ted = TransportableData.parse(base64);
      _attachment = ted;
    }
    return ted;
  }

  @override
  set data(TransportableData? ted) {
    remove('data');
    // if (ted != null) {
    //   this['data'] = ted.toObject();
    // }
    _attachment = ted;
  }

  @override
  void setBinary(Uint8List? binary) {
    remove('data');
    if (binary == null || binary.isEmpty) {
      _attachment = null;
    } else {
      _attachment = TransportableData.create(binary);
    }
  }

  @override
  String? get filename => getString('filename');

  @override
  set filename(String? name) {
    if (name == null/* || name.isEmpty*/) {
      remove('filename');
    } else {
      this['filename'] = name;
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
      remove('URL');
    } else {
      this['URL'] = remote.toString();
    }
    _remoteURL = remote;
  }

  @override
  DecryptKey? get password {
    DecryptKey? key = _password;
    if (key == null) {
      key = SymmetricKey.parse(this['key']);
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
