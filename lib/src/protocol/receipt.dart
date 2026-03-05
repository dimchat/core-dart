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
import 'helpers.dart';


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

/// Receipt command interface (message acknowledgment/receipt).
///
/// Used to send receipt/acknowledgment for a previously received message,
/// confirming delivery or providing status feedback (via text).
///
/// JSON format:
/// ```json
/// {
///   "type" : i2s(0x88),
///   "sn"   : 678.90,
///
///   "command": "receipt",  // Fixed command name for receipt messages
///
///   "text"   : "...",      // Receipt comment/feedback text
///   "origin" : {           // Metadata of the original message being acknowledged
///     "sender"   : "...",  // Sender ID of the original message
///     "receiver" : "...",  // Receiver ID of the original message
///     "time"     : 123.45, // Timestamp of the original message
///     "sn"       : 123,    // Serial number of the original message
///     "signature": "..."   // Signature of the original message (for verification)
///   }
/// }
/// ```
abstract interface class ReceiptCommand implements Command {

  /// Gets the receipt comment/feedback text.
  ///
  /// Can be used to provide status info (e.g., "Message read", "Delivery failed")
  /// or custom feedback about the original message.
  String get text;

  /// Gets the envelope of the original message being acknowledged.
  ///
  /// Contains sender/receiver/time metadata of the message being receipted.
  Envelope? get originalEnvelope;

  /// Gets the serial number (SN) of the original message being acknowledged.
  ///
  /// Unique identifier of the original message, used to locate it in conversation history.
  int? get originalSerialNumber;

  /// Gets the digital signature of the original message being acknowledged.
  ///
  /// Used to verify the authenticity of the original message in the receipt.
  String? get originalSignature;

  //
  //  Factory method
  //

  /// Creates a [ReceiptCommand] instance with receipt text and original message metadata.
  ///
  /// Automatically purifies the original message's envelope/content using [QuoteHelper]
  /// to generate the "origin" field (removes sensitive data). Also handles group message
  /// receipt by setting the group ID if present in the original content.
  ///
  /// @param text - Receipt comment/feedback text
  ///
  /// @param head - Optional envelope of the original message being acknowledged
  ///
  /// @param body - Optional content of the original message being acknowledged
  ///
  /// @return A new [ReceiptCommand] instance
  static ReceiptCommand create(String text, Envelope? head, Content? body) {
    var helper = CommandExtensions.quoteHelper;
    Map? origin = helper.purifyForReceipt(head, body);
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

}
