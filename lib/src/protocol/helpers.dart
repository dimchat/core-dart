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


/// Helper interface for processing quote/receipt metadata.
///
/// Provides methods to purify (normalize) message envelope and content data
/// for [QuoteContent] (quote reply) and [ReceiptCommand] (message receipt) scenarios,
/// ensuring consistent structure of the "origin" field in these messages.
abstract interface class QuoteHelper {

  /// Purifies message data for use in [QuoteContent].
  ///
  /// Extracts core metadata (sender, receiver, type, serial number) from the original
  /// message envelope and content to form the "origin" field in quote messages.
  ///
  /// @param envelope - Envelope of the original message being quoted
  ///
  /// @param content - Content of the original message being quoted
  ///
  /// @return Normalized map containing core quote origin metadata
  Map purifyForQuote(Envelope envelope, Content content);

  /// Purifies message data for use in [ReceiptCommand].
  ///
  /// Extracts and cleans up metadata from the original message envelope/content
  /// to form the "origin" field in receipt commands (removes sensitive/redundant fields).
  /// Returns null if the envelope is null (invalid original message).
  ///
  /// @param envelope - Optional envelope of the original message for receipt
  ///
  /// @param content - Optional content of the original message for receipt
  ///
  /// @return Normalized map containing core receipt origin metadata (null if envelope is null)
  Map? purifyForReceipt(Envelope? envelope, Content? content);

}


/// Default implementation of [QuoteHelper] for quote/receipt data purification.
///
/// Provides standard logic to extract and normalize origin metadata for
/// quote messages and receipt commands.
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
