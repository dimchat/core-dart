/* license: https://mit-license.org
 *
 *  DIMP : Decentralized Instant Messaging Protocol
 *
 *                                Written in 2024 by Moky <albert.moky@gmail.com>
 *
 * ==============================================================================
 * The MIT License (MIT)
 *
 * Copyright (c) 2024 Albert Moky
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
import 'package:dkd/dkd.dart';
import 'package:mkm/type.dart';

import '../protocol/types.dart';
import '../protocol/quote.dart';

import 'base.dart';


/// QuoteContent
class BaseQuoteContent extends BaseContent implements QuoteContent {
  BaseQuoteContent([super.dict]);

  /// original message envelope
  Envelope? _env;

  BaseQuoteContent.from(String text, Map origin) : super.fromType(ContentType.QUOTE) {
    // text message
    this['text'] = text;
    // original envelope of message quote with,
    // includes 'sender', 'receiver', 'type' and 'sn'
    this['origin'] = origin;
  }

  @override
  String get text => getString('text') ?? '';

  // protected
  Map? get origin {
    var info = this['origin'];
    if (info is Map) {
      return info;
    }
    assert(info == null, 'origin error: $info');
    return null;
  }

  @override
  Envelope? get originalEnvelope {
    // origin: { sender: "...", receiver: "...", time: 0 }
    _env ??= Envelope.parse(origin);
    return _env;
  }

  @override
  int? get originalSerialNumber =>
      Converter.getInt(origin?['sn']);

}
