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
import 'package:mkm/protocol.dart';

import '../dkd/commands.dart';

import 'base.dart';


//--------  Core Commands


///  Command message: {
///      type : i2s(0x88),
///      sn   : 123,
///
///      command : "meta", // command name
///      did     : "{ID}", // contact's ID
///      meta    : {...}   // when meta is empty, means query meta for ID
///  }
abstract interface class MetaCommand implements Command {

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
      BaseMetaCommand.from(identifier, Command.META, meta);

  ///  Query Meta
  ///
  /// @param identifier - entity ID
  static MetaCommand query(ID identifier) =>
      BaseMetaCommand.from(identifier, Command.META, null);

}

///  Command message: {
///      type : i2s(0x88),
///      sn   : 123,
///
///      command   : "documents", // command name
///      did       : "{ID}",      // entity ID
///      meta      : {...},       // only for handshaking with new friend
///      documents : [...],       // when this is null, means to query
///      last_time : 12345        // old document time for querying
///  }
abstract interface class DocumentCommand implements MetaCommand {

  ///  Entity documents
  List<Document>? get documents;

  ///  Last document time for querying
  DateTime? get lastTime;

  //
  //  Factories
  //

  /// 1. Send Meta and Document to new friend
  /// 2. Response Entity Document
  ///
  /// @param identifier - entity ID
  /// @param meta       - entity Meta
  /// @param docs       - entity Document
  static DocumentCommand response(ID identifier, Meta? meta, List<Document> docs) =>
      BaseDocumentCommand.from(identifier, meta, docs);

  /// 1. Query Entity Document
  /// 2. Query Entity Document for updating with last time
  ///
  /// @param identifier - entity ID
  /// @param lastTime   - last document time
  static DocumentCommand query(ID identifier, [DateTime? lastTime]) =>
      BaseDocumentCommand.query(identifier, lastTime);

}
