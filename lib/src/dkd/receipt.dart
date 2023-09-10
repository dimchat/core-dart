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
import 'package:mkm/mkm.dart';

import '../protocol/commands.dart';
import '../protocol/receipt.dart';
import 'commands.dart';

abstract class BaseReceipt extends BaseCommand implements ReceiptCommand {
  BaseReceipt(super.dict) : _env = null;

  /// original message envelope
  Envelope? _env;

  BaseReceipt.from(String text, {Envelope? envelope, int? sn, String? signature})
      : super.fromName(Command.kReceipt) {
    // text message
    this['text'] = text;
    // original envelope
    _env = envelope;
    // envelope of the message responding to
    Map origin = envelope == null ? {} : envelope.toMap();
    // sn of the message responding to
    if (sn != null) {
      origin['sn'] = sn;
    }
    // signature of the message responding to
    if (signature != null) {
      origin['signature'] = signature;
    }
    if (origin.isNotEmpty) {
      this['origin'] = origin;
    }
  }

  @override
  String get text => getString('text', '')!;

  @override
  Map? get origin => this['origin'];

  @override
  Envelope? get originalEnvelope {
    // origin: { sender: "...", receiver: "...", time: 0 }
    _env ??= Envelope.parse(origin);
    return _env;
  }

  @override
  int? get originalSerialNumber =>
      Converter.getInt(origin?['sn'], null);

  @override
  String? get originalSignature =>
      Converter.getString(origin?['signature'], null);

}


class BaseReceiptCommand extends BaseReceipt with ReceiptCommandMixIn {
  BaseReceiptCommand(super.dict);

  BaseReceiptCommand.from(String text, {Envelope? envelope, int? sn, String? signature})
      : super.from(text, envelope: envelope, sn: sn, signature: signature);

}
