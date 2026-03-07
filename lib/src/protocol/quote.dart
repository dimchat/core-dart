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
import 'package:dkd/ext.dart';
import 'package:dkd/protocol.dart';

import '../dkd/quote.dart';
import 'helpers.dart';


/// Quote reply message content interface.
///
/// Used to create "quote reply" messages that reference a previous message
/// (the "original" message) with additional text commentary.
///
/// JSON format:
/// ```json
/// {
///   "type" : i2s(0x37),
///   "sn"   : 678.90,
///
///   "text"   : "...",  // Reply text content
///   "origin" : {       // Metadata of the original message being quoted
///     "sender"   : "...",      // Sender ID of the original message
///     "receiver" : "...",      // Receiver ID (or group ID) of the original message
///     "type"     : i2s(0x01),  // Content type of the original message
///     "sn"       : 123.45      // Serial number of the original message
///   }
/// }
/// ```
abstract interface class QuoteContent implements Content {

  /// Gets the reply text content of the quote message.
  ///
  /// This is the user's new commentary/response to the original quoted message.
  String get text;

  /// Gets the envelope of the original message being quoted.
  ///
  /// Contains sender/receiver/time metadata of the message being replied to.
  Envelope? get originalEnvelope;

  /// Gets the serial number (SN) of the original message being quoted.
  ///
  /// Unique identifier of the original message, used to locate it in conversation history.
  int? get originalSerialNumber;

  //
  //  Factory method
  //

  /// Creates a [QuoteContent] instance with reply text and original message metadata.
  ///
  /// Automatically purifies the original message's envelope/content using [QuoteHelper]
  /// to generate the "origin" field in the quote message.
  ///
  /// @param text - User's reply text to the original message
  ///
  /// @param head - Envelope of the original message being quoted
  ///
  /// @param body - Content of the original message being quoted
  ///
  /// @return A new [QuoteContent] instance
  static QuoteContent create(String text, Envelope head, Content body) {
    var helper = sharedMessageExtensions.quoteHelper;
    Map origin = helper.purifyForQuote(head, body);
    return BaseQuoteContent.from(text, origin);
  }

}
