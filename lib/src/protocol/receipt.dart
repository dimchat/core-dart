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
import 'package:dkd/protocol.dart';
import 'package:mkm/protocol.dart';

import '../dkd/receipt.dart';

import 'base.dart';

///  Command message: {
///      "type" : i2s(0x88),
///      "sn"   : 456,
///
///      "command" : "receipt",
///      "text"    : "...",  // text message
///      "origin"  : {       // original message envelope
///          "sender"    : "...",
///          "receiver"  : "...",
///          "time"      : 0,
///
///          "sn"        : 123,
///          "signature" : "..."
///      }
///  }
abstract interface class ReceiptCommand implements Command {

  String get text;

  Envelope? get originalEnvelope;
  int? get originalSerialNumber;
  String? get originalSignature;

  //
  //  Factory method
  //

  /// Create base receipt command with text & original message info
  static ReceiptCommand create(String text, Envelope? head, Content? body) {
    Map? origin;
    if (head == null) {
      origin = null;
    } else if (body == null) {
      origin = purify(head);
    } else {
      origin = purify(head);
      origin['sn'] = body.sn;
    }
    var command = BaseReceiptCommand.from(text, origin);
    if (body != null) {
      // check group
      ID? group = body.group;
      if (group != null) {
        command.group = group;
      }
    }
    return command;
  }

  static Map purify(Envelope envelope) {
    Map origin = envelope.copyMap();
    if (origin.containsKey('data')) {
      origin.remove('data');
      origin.remove('key');
      origin.remove('keys');
      origin.remove('meta');
      origin.remove('visa');
    }
    return origin;
  }

}
