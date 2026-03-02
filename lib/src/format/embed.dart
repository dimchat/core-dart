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


///  RFC 2397
///  ~~~~~~~~
///  https://www.rfc-editor.org/rfc/rfc2397
///
///      data:[<mime type>][;charset=<charset>][;<encoding>],<encoded data>

class EmbedData extends BaseData {
  EmbedData(super.encoded, super.bytes);

  UriData? _dataUri;

  // data uri headers
  String? _mimeType;  // default is "text/plain"
  Map<String, String>? _parameters;

  EmbedData.from(String? encoded, Uint8List? bytes, {
    UriData? uri,
    String? mimeType,
    Map<String, String>? parameters,
  }) : super(encoded ?? '', bytes) {
    _dataUri = uri;
    _mimeType = mimeType;
    _parameters = parameters;
  }

  factory EmbedData.create(String dataUri, Uint8List bytes, {UriData? uri}) =>
      EmbedData.from(dataUri, bytes, uri: uri);

  factory EmbedData.createWithUri(UriData uri) =>
      EmbedData.from(uri.toString(), null, uri: uri);

  factory EmbedData.createWithString(String dataUri) =>
      EmbedData.from(dataUri, null);

  factory EmbedData.createWithBytes(Uint8List bytes, {required String mimeType}) =>
      EmbedData.from('', bytes, mimeType: mimeType);

  //
  //  Data URI:
  //
  //      "data:image/jpg;base64,{BASE64_ENCODE}"
  //      "data:audio/mp4;base64,{BASE64_ENCODE}"
  //

  factory EmbedData.image(Uint8List jpeg) =>
      EmbedData.from('', jpeg, mimeType: 'image/jpeg');

  factory EmbedData.audio(Uint8List mp4) =>
      EmbedData.from('', mp4, mimeType: 'audio/mp4');

  //
  //  Uri Headers
  //

  UriData? get uri => _dataUri;

  // default is "text/plain"
  String? get mimeType => _mimeType ?? (uri?.mimeType);
  // default is "us-ascii"
  String? get charset => parameters?['charset'] ?? (uri?.charset);
  // "avatar.png"
  String? get filename => parameters?['filename'];

  Map<String, String>? get parameters => _parameters ?? (uri?.parameters);

  //
  //  Build Uri
  //

  // protected
  UriData? get encodeDataURI {
    var uri = _dataUri;
    if (uri == null) {
      Uint8List? bin = getDecodedBytes();
      if (bin == null || bin.isEmpty) {
        return null;
      }
      // build header
      String header = _mimeType ?? 'text/plain';
      _parameters?.forEach((key, value) {
        header += ';$key=$value';
      });
      // encode body
      String body = Base64.encode(bin);
      uri = UriData.parse('data:$header;base64,$body');
      _dataUri = uri;
    }
    return uri;
  }

  // protected
  UriData? get decodeDataURI {
    var uri = _dataUri;
    if (uri == null) {
      String txt = getEncodedString();
      if (txt.isEmpty) {
        return null;
      }
      assert(txt.startsWith('data:'), 'data uri error: $txt');
      // parse uri
      uri = UriData.parse(txt);
      _dataUri = uri;
    }
    return uri;
  }

//
  //  TransportableData
  //

  @override
  String? get encoding => EncodeAlgorithms.BASE_64;

  @override
  Uint8List? get bytes {
    Uint8List? bin = getDecodedBytes();
    if (bin == null) {
      var uri = decodeDataURI;
      if (uri == null) {
        assert(false, 'failed to decode data uri');
        return null;
      }
      bin = uri.contentAsBytes();
      setDecodedBytes(bin);
    }
    return bin;
  }


  @override
  String toString() {
    String txt = getEncodedString();
    if (txt == '') {
      var uri = encodeDataURI;
      if (uri == null) {
        assert(false, 'failed to encode data uri');
        return '';
      }
      txt = uri.toString();
      setEncodedString(txt);
    }
    return txt;
  }

}
