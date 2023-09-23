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

import '../dkd/commands.dart';
import '../dkd/factory.dart';

///  Command message: {
///      type : 0x88,
///      sn   : 123,
///
///      command : "...", // command name
///      extra   : info   // command parameters
///  }
abstract class Command implements Content {

  //-------- command names begin --------
  static const String kMeta = 'meta';
  static const String kDocument = 'document';
  static const String kReceipt = 'receipt';
  //-------- command names end --------

  ///  Get command name
  ///
  /// @return command name string
  String get cmd;

  //
  //  Factory method
  //

  static Command? parse(Object? content) {
    CommandFactoryManager man = CommandFactoryManager();
    return man.generalFactory.parseCommand(content);
  }

  static CommandFactory? getFactory(String cmd) {
    CommandFactoryManager man = CommandFactoryManager();
    return man.generalFactory.getCommandFactory(cmd);
  }
  static void setFactory(String cmd, CommandFactory factory) {
    CommandFactoryManager man = CommandFactoryManager();
    man.generalFactory.setCommandFactory(cmd, factory);
  }
}

///  Command Factory
///  ~~~~~~~~~~~~~~~
abstract class CommandFactory {

  ///  Parse map object to command
  ///
  /// @param content - command content
  /// @return Command
  Command? parseCommand(Map content);
}


///  Command message: {
///      type : 0x88,
///      sn   : 123,
///
///      command : "meta", // command name
///      ID      : "{ID}", // contact's ID
///      meta    : {...}   // when meta is empty, means query meta for ID
///  }
abstract class MetaCommand implements Command {

  ///  Entity ID
  ID get identifier;

  ///  Entity Meta
  Meta? get meta;

  //
  //  Factories
  //

  ///  Response Meta
  ///
  /// @param identifier - entity ID
  /// @param meta - entity Meta
  static MetaCommand response(ID identifier, Meta meta) =>
      BaseMetaCommand.from(identifier, meta: meta);

  ///  Query Meta
  ///
  /// @param identifier - entity ID
  static MetaCommand query(ID identifier) =>
      BaseMetaCommand.from(identifier);

}

///  Command message: {
///      type : 0x88,
///      sn   : 123,
///
///      command   : "document", // command name
///      ID        : "{ID}",     // entity ID
///      meta      : {...},      // only for handshaking with new friend
///      document  : {...},      // when document is empty, means query for ID
///      signature : "..."       // old document's signature for querying
///  }
abstract class DocumentCommand implements MetaCommand {

  ///  Entity Document
  Document? get document;

  ///  Document's signature (just for querying new document)
  String? get signature;

  //
  //  Factories
  //

  /// 1. Send Meta and Document to new friend
  /// 2. Response Entity Document
  ///
  /// @param identifier - entity ID
  /// @param meta - entity Meta
  /// @param doc - entity Document
  static DocumentCommand response(ID identifier, Meta? meta, Document doc) =>
      BaseDocumentCommand.from(identifier, meta: meta, document: doc);

  /// 1. Query Entity Document
  /// 2. Query Entity Document for updating with current signature
  ///
  /// @param identifier - entity ID
  /// @param signature - document signature
  static DocumentCommand query(ID identifier, String? signature) =>
      BaseDocumentCommand.from(identifier, signature: signature);

}
