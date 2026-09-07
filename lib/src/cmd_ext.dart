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
import 'package:mkm/type.dart';
import 'package:dkd/protocol.dart';
import 'package:dkd/ext.dart';

import 'protocol/command.dart';

// -----------------------------------------------------------------------------
//  General Command Helpers
// -----------------------------------------------------------------------------

/// A helper interface for extracting command names from structured command content.
///
/// This interface provides a standardized way to retrieve command identifiers
/// from command payloads (typically Map-based), with support for default values.
///
/// Corresponds to the Java interface `chat.dim.ext.CommandHandler`.
abstract interface class CommandHandler /*implements CommandHelper */{

  //
  //  CMD - Command, Method, Declaration
  //

  /// Retrieves the command name from a structured command content Map.
  ///
  /// Looks up the command name key (e.g., "command")
  /// in the [content] Map and returns its value. If the key is not found or the value
  /// is null, returns the [defaultValue] (if provided).
  ///
  /// Parameters:
  /// - [content]      : The structured command payload (Map) to extract the command name from
  /// - [defaultValue] : Optional fallback value if the command name is not found
  ///
  /// Returns: Extracted command name (String), or [defaultValue], or null if neither exists
  String? getCmd(Mapping content, [String? defaultValue]);

  //
  //  Receipt
  //

  /// Create ReceiptCommand with original envelope info
  ///
  /// Extracts and cleans up metadata from the original message envelope/content
  /// to form the "origin" field in receipt commands (removes sensitive/redundant fields).
  ///
  /// Parameters:
  /// - [text]     : message
  /// - [envelope] : original message envelope
  /// - [content]  : original instant message content (Optional)
  ///
  /// Returns: ReceiptCommand
  Command createReceipt(String text, Envelope envelope, Content? content);

}

/// General Extensions
/// ~~~~~~~~~~~~~~~~~~

CommandHandler? _commandHandler;

extension GeneralCommandExtension on MessageExtensions {

  /// Get the general command handler
  ///
  /// Corresponds to the Java static field `SharedCommandExtensions.handler`.
  /// (Named `commandHandler` to avoid conflict with the `handler` getter
  /// of [MessageHandler] defined in the dkd package.)
  CommandHandler? get commandHandler => _commandHandler;
  set commandHandler(CommandHandler? ext) => _commandHandler = ext;

}
