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

  UriData? dataUri;

  // data uri header
  String mimeType = '';  // default is "text/plain"
  String charset  = '';  // default is "us-ascii"
  String filename = '';  // "avatar.png"

  factory EmbedData.createWithUri(UriData? uri) {
    var data = EmbedData('', null);
    data.dataUri = uri;
    return data;
  }

  factory EmbedData.createWithString(String dataUri) {
    var uri = UriData.parse(dataUri);
    var data = EmbedData('', null);
    data.dataUri = uri;
    return data;
  }

  factory EmbedData.createWithBytes(Uint8List bytes, {
    String? mimeType, String? charset, String? filename,
  }) {
    var data = EmbedData('', bytes);
    data.mimeType = mimeType ?? 'text/plain';
    data.charset = charset ?? '';
    data.filename = filename ?? '';
    return data;
  }

  factory EmbedData.create(String? encoded, Uint8List? bytes, {
    UriData? uri,
    String? mimeType, String? charset, String? filename,
  }) {
    var data = EmbedData(encoded ?? '', bytes);
    data.dataUri = uri;
    // data uri headers
    data.mimeType = mimeType ?? 'text/plain';
    data.charset = charset ?? '';
    data.filename = filename ?? '';
    return data;
  }

  // protected
  UriData? get encodeDataURI {
    var uri = dataUri;
    if (uri == null) {
      Uint8List? bin = getDecodedBytes();
      if (bin == null || bin.isEmpty) {
        return null;
      }
      String base64 = Base64.encode(bin);
      // build header for data uri
      String header = mimeType;
      if (charset.isNotEmpty) {
        header = '$header;charset=$charset';
      }
      if (filename.isNotEmpty) {
        header = '$header;filename=$filename';
      }
      uri = UriData.parse('data:$header;base64,$base64');
      dataUri = uri;
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
      var uri = dataUri;
      if (uri == null) {
        assert(false, 'data uri error');
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
      if (uri != null) {
        txt = uri.toString();
        setEncodedString(txt);
      }
      assert(txt.isNotEmpty, 'base64 data error: $uri');
    }
    return txt;
  }

}
