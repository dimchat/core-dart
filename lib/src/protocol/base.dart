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
import 'package:dkd/ext.dart';
import 'package:dkd/protocol.dart';

import 'helpers.dart';


/// Command message content interface.
///
/// Base interface for all command-type messages, which are used to send
/// operational instructions with parameters between entities.
///
/// JSON format:
/// ```json
/// {
///   "type" : i2s(0x88),
///   "sn"   : 123,
///
///   "command" : "...",  // Unique command name/identifier
///   "extra"   : info    // Optional command parameters (dynamic structure)
/// }
/// ```
abstract interface class Command implements Content {
  // ignore_for_file: constant_identifier_names

  //-------- command names begin --------
  static const String META      = 'meta';       // querying/updating entity metadata
  static const String DOCUMENTS = 'documents';  // querying/updating entity documents
  static const String RECEIPT   = 'receipt';    // message receipt/acknowledgment
  //-------- command names end --------

  ///  Get command name
  ///
  /// @return command/method/declaration
  String get cmd;

  //
  //  Factory method
  //

  static Command? parse(Object? content) {
    var helper = sharedMessageExtensions.commandHelper;
    return helper!.parseCommand(content);
  }

  static CommandFactory? getFactory(String cmd) {
    var helper = sharedMessageExtensions.commandHelper;
    return helper!.getCommandFactory(cmd);
  }
  static void setFactory(String cmd, CommandFactory factory) {
    var helper = sharedMessageExtensions.commandHelper;
    helper!.setCommandFactory(cmd, factory);
  }
}

/// Factory interface for parsing command messages from map objects.
///
/// Provides a standardized way to convert raw map data (from JSON) into
/// strongly-typed [Command] instances.
abstract interface class CommandFactory {

  /// Parses a map object (from JSON) into a [Command] instance.
  ///
  /// @param content - Raw map data containing command information
  ///
  /// @return A [Command] instance if parsing succeeds, null otherwise
  Command? parseCommand(Map content);
}
