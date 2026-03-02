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


/// Meta command interface for querying/updating entity metadata.
///
/// Used to request or respond with an entity's core metadata (e.g. user/group info).
///
/// JSON format:
/// ```json
/// {
///   "type" : i2s(0x88),
///   "sn"   : 123,
///
///   "command" : "meta",  // Fixed command name
///   "did"     : "{ID}",  // Target entity ID (user/group ID)
///   "meta"    : {...}    // Entity metadata (null = query request)
/// }
/// ```
abstract interface class MetaCommand implements Command {

  /// Gets the target entity ID (user/group ID) for this meta command.
  ///
  /// This ID identifies the entity whose metadata is being queried or updated.
  ID get identifier;

  /// Gets the entity metadata associated with this command.
  ///
  /// - Non-null: Response with metadata for the target [identifier]
  /// - Null: Query request for metadata of the target [identifier]
  Meta? get meta;

  //
  //  Factories
  //

  /// Creates a response meta command with entity metadata.
  ///
  /// # Use this to send metadata back to a query request.
  ///
  /// @param did - Target entity ID (user/group ID)
  ///
  /// @param meta - Metadata to return for the entity
  ///
  /// @return A [MetaCommand] instance containing the metadata
  static MetaCommand response(ID did, Meta meta) =>
      BaseMetaCommand.fromCmd(Command.META, did, meta);

  /// Creates a query meta command to request entity metadata.
  ///
  /// # Use this to ask for metadata of a specific entity (meta field will be null).
  ///
  /// @param did - Target entity ID (user/group ID) to query
  ///
  /// @return A [MetaCommand] instance for metadata query
  static MetaCommand query(ID did) =>
      BaseMetaCommand.fromCmd(Command.META, did, null);

}


/// Document command interface for querying/updating entity documents.
///
/// Extends [MetaCommand] to support document operations (Visa for users, Bulletin for groups).
/// Used to exchange entity documents or request updates.
///
/// JSON format:
/// ```json
/// {
///   "type" : i2s(0x88),
///   "sn"   : 123,
///
///   "command"   : "documents",  // Fixed command name
///   "did"       : "{ID}",       // Target entity ID (user/group ID)
///   "meta"      : {...},        // Optional metadata (for new friend handshakes)
///   "documents" : [...],        // Entity documents (null = query request)
///   "last_time" : 123.45        // Optional: Timestamp for incremental updates
/// }
/// ```
abstract interface class DocumentCommand implements MetaCommand {

  /// Gets the list of entity documents (Visa/Bulletin) for this command.
  ///
  /// - Non-null: Response with documents for the target [identifier]
  /// - Null: Query request for documents of the target [identifier]
  List<Document>? get documents;

  /// Gets the timestamp for incremental document queries.
  ///
  /// Used to request only documents updated after this time (for efficient sync).
  DateTime? get lastTime;

  //
  //  Factories
  //

  /// Creates a response document command with entity documents.
  ///
  /// Use this to:
  /// 1. Send metadata + documents to a new friend (handshake)
  /// 2. Respond to a document query request
  ///
  /// @param did - Target entity ID (user/group ID)
  ///
  /// @param meta - Optional metadata (for handshake scenarios)
  ///
  /// @param docs - List of documents to return for the entity
  ///
  /// @return A [DocumentCommand] instance containing the documents
  static DocumentCommand response(ID did, Meta? meta, List<Document> docs) =>
      BaseDocumentCommand.from(did, meta, docs);

  /// Creates a query document command to request entity documents.
  ///
  /// Use this to:
  /// 1. Query all documents for an entity (omit [lastTime])
  /// 2. Query incremental updates (provide [lastTime] for updates since then)
  ///
  /// @param did - Target entity ID (user/group ID) to query
  ///
  /// @param lastTime - Optional: Timestamp for incremental updates
  ///
  /// @return A [DocumentCommand] instance for document query
  static DocumentCommand query(ID did, [DateTime? lastTime]) =>
      BaseDocumentCommand.query(did, lastTime);

}
