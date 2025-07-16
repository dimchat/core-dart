/* license: https://mit-license.org
 *
 *  DIMP : Decentralized Instant Messaging Protocol
 *
 *                                Written in 2023 by Moky <albert.moky@gmail.com>
 *
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
import 'package:dkd/dkd.dart';
import 'package:mkm/type.dart';

import '../protocol/base.dart';
import '../protocol/receipt.dart';

import 'base.dart';


class BaseReceiptCommand extends BaseCommand implements ReceiptCommand {
  BaseReceiptCommand([super.dict]);

  /// original message envelope
  Envelope? _env;

  BaseReceiptCommand.from(String text, Map? origin) : super.fromName(Command.RECEIPT) {
    // text message
    this['text'] = text;
    // original envelope of message responding to,
    // includes 'sn' and 'signature'
    if (origin != null) {
      assert(!(origin.isEmpty ||
          origin.containsKey('data') ||
          origin.containsKey('key') ||
          origin.containsKey('keys') ||
          origin.containsKey('meta') ||
          origin.containsKey('visa')), 'impure envelope: $origin');
      this['origin'] = origin;
    }
  }

  @override
  String get text => getString('text') ?? '';

  // protected
  Map? get origin => this['origin'];

  @override
  Envelope? get originalEnvelope {
    // origin: { sender: "...", receiver: "...", time: 0 }
    _env ??= Envelope.parse(origin);
    return _env;
  }

  @override
  int? get originalSerialNumber => Converter.getInt(origin?['sn']);

  @override
  String? get originalSignature => Converter.getString(origin?['signature']);

}
