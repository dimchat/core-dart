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
import 'package:dkd/protocol.dart';
import 'package:mkm/protocol.dart';

import 'base.dart';


///  General Helper
///  ~~~~~~~~~~~~~~

abstract interface class CommandHelper {

  void setCommandFactory(String cmd, CommandFactory factory);
  CommandFactory? getCommandFactory(String cmd);

  Command? parseCommand(Object? content);

}

/// Command FactoryManager
/// ~~~~~~~~~~~~~~~~~~~~~~
// protected
class CommandExtensions {
  factory CommandExtensions() => _instance;
  static final CommandExtensions _instance = CommandExtensions._internal();
  CommandExtensions._internal();

  CommandHelper? cmdHelper;

  QuoteHelper quoteHelper = QuotePurifier();

}


///
///  Helper for QuoteContent & ReceiptCommand
///
abstract interface class QuoteHelper {

  /// purify for QuoteContent
  Map purifyForQuote(Envelope envelope, Content content);

  /// purify for ReceiptCommand
  Map? purifyForReceipt(Envelope? envelope, Content? content);

}

class QuotePurifier implements QuoteHelper {

  @override
  Map purifyForQuote(Envelope head, Content body) {
    ID from = head.sender;
    ID? to = body.group;
    to ??= head.receiver;
    // build origin info
    return {
      'sender': from.toString(),
      'receiver': to.toString(),
      'type': body.type,
      'sn': body.sn,
    };
  }

  @override
  Map? purifyForReceipt(Envelope? head, Content? body) {
    if (head == null) {
      return null;
    }
    Map origin = head.copyMap();
    if (origin.containsKey('data')) {
      origin.remove('data');
      origin.remove('key');
      origin.remove('keys');
      origin.remove('meta');
      origin.remove('visa');
    }
    if (body != null) {
      origin['sn'] = body.sn;
    }
    return origin;
  }

}
