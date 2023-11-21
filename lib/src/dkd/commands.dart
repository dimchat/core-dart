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

import '../protocol/commands.dart';
import 'base.dart';
import 'factory.dart';


///
/// Command
///
class BaseCommand extends BaseContent implements Command  {
  BaseCommand(super.dict);

  BaseCommand.fromType(int msgType, String cmd) : super.fromType(msgType) {
    this['command'] = cmd;
  }
  BaseCommand.fromName(String cmd) : this.fromType(ContentType.kCommand, cmd);

  @override
  String get cmd {
    CommandFactoryManager man = CommandFactoryManager();
    return man.generalFactory.getCmd(toMap(), '')!;
    // return getString('command', '')!;
  }
}


///
/// MetaCommand
///
class BaseMetaCommand extends BaseCommand implements MetaCommand {
  BaseMetaCommand(super.dict) : _id = null, _meta = null;

  ID? _id;
  Meta? _meta;

  BaseMetaCommand.from(ID identifier, {String? cmd, Meta? meta})
      : super.fromName(cmd ?? Command.kMeta) {
    // ID
    this['ID'] = identifier.toString();
    _id = identifier;
    // meta
    if (meta != null) {
      this['meta'] = meta.toMap();
    }
    _meta = meta;
  }

  @override
  ID get identifier {
    _id ??= ID.parse(this['ID']);
    return _id!;
  }

  @override
  Meta? get meta {
    _meta ??= Meta.parse(this['meta']);
    return _meta;
  }
}

///
/// DocumentCommand
///
class BaseDocumentCommand extends BaseMetaCommand implements DocumentCommand {
  BaseDocumentCommand(super.dict) : _doc = null;

  Document? _doc;

  BaseDocumentCommand.from(ID identifier, {Meta? meta, Document? document})
      : super.from(identifier, cmd: Command.kDocument, meta: meta) {
    // document
    if (document != null) {
      this['document'] = document.toMap();
    }
    _doc = document;
  }
  BaseDocumentCommand.query(ID identifier, DateTime? lastTime)
      : super.from(identifier, cmd: Command.kDocument) {
    // query with last document time
    if (lastTime != null) {
      setDateTime('last_time', lastTime);
    }
  }

  @override
  Document? get document {
    _doc ??= Document.parse(this['document']);
    return _doc;
  }

  @override
  DateTime? get lastTime => getDateTime('last_time', null);

}
