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

import '../protocol/commands.dart';
import '../protocol/contents.dart';
import '../protocol/receipt.dart';
import 'commands.dart';

class BaseReceipt extends BaseCommand implements ReceiptCommand {
  BaseReceipt(super.dict) : _env = null;

  /// original message envelope
  Envelope? _env;

  BaseReceipt.from(int msgType, String text, {Envelope? envelope, int? sn, String? signature})
      : super.fromType(msgType, Command.kReceipt) {
    // text message
    this['text'] = text;
    // original envelope
    _env = envelope;
    // envelope of the message responding to
    Map origin;
    if (envelope == null) {
      origin = {};
    } else {
      origin = envelope.toMap();
    }
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
  String get text => getString('text') ?? '';

  @override
  Map? get origin => this['origin'];

  @override
  Envelope? get originalEnvelope {
    if (_env == null) {
      // origin: { sender: "...", receiver: "...", time: 0 }
      Map? info = origin;
      if (info != null && info.containsKey('sender')) {
        _env = Envelope.parse(info);
      }
    }
    return _env;
  }

  @override
  int? get originalSerialNumber {
    Map? info = origin;
    return info?['sn'];
  }

  @override
  String? get originalSignature {
    Map? info = origin;
    return info?['signature'];
  }

}


class BaseReceiptCommand extends BaseReceipt with ReceiptCommandMixIn {
  BaseReceiptCommand(super.dict);

  BaseReceiptCommand.from(String text, {Envelope? envelope, int? sn, String? signature})
      : super.from(ContentType.kCommand, text, envelope: envelope, sn: sn, signature: signature);

}


class TextReceiptCommand extends BaseReceipt implements TextContent {
  TextReceiptCommand(super.dict);

  TextReceiptCommand.from(String text) : super.from(ContentType.kText, text);

}
