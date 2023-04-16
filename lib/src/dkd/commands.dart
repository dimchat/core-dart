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
  String get cmd => getString('command') ?? '';
}


///
/// MetaCommand
///
class BaseMetaCommand extends BaseCommand implements MetaCommand {
  BaseMetaCommand(super.dict);

  BaseMetaCommand.from(String cmd, ID identifier, Meta? meta)
      : super.fromName(cmd) {
    // ID
    setString('ID', identifier);
    // meta
    if (meta != null) {
      setMap('meta', meta);
    }
  }

  @override
  ID get identifier => ID.parse(this['ID'])!;

  @override
  Meta? get meta => Meta.parse(this['meta']);
}

///
/// DocumentCommand
///
class BaseDocumentCommand extends BaseMetaCommand implements DocumentCommand {
  BaseDocumentCommand(super.dict);

  BaseDocumentCommand.from(String cmd, ID identifier,
      {Meta? meta, Document? document, String? signature})
      : super.from(cmd, identifier, meta) {
    // document
    if (document != null) {
      setMap('document', document);
    }
    // signature
    if (signature != null) {
      this['signature'] = signature;
    }
  }

  @override
  Document? get document => Document.parse(this['document']);

  @override
  String? get signature => getString('signature');
}


///
/// HistoryCommand
///
class BaseHistoryCommand extends BaseCommand implements HistoryCommand {
  BaseHistoryCommand(super.dict);

  BaseHistoryCommand.fromName(String cmd)
      : super.fromType(ContentType.kHistory, cmd);
}
