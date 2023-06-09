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
import 'package:mkm/mkm.dart';

import 'entity.dart';

abstract class Group extends Entity {

  /// group document
  Future<Bulletin?> get bulletin;

  Future<ID> get founder;
  Future<ID> get owner;

  // NOTICE: the owner must be a member
  //         (usually the first one)
  Future<List<ID>> get members;
  Future<List<ID>> get assistants;
}

abstract class GroupDataSource implements EntityDataSource {

  ///  Get group founder
  ///
  /// @param group - group ID
  /// @return fonder ID
  Future<ID?> getFounder(ID group);

  ///  Get group owner
  ///
  /// @param group - group ID
  /// @return owner ID
  Future<ID?> getOwner(ID group);

  ///  Get group members list
  ///
  /// @param group - group ID
  /// @return members list (ID)
  Future<List<ID>> getMembers(ID group);

  ///  Get assistants for this group
  ///
  /// @param group - group ID
  /// @return bot ID list
  Future<List<ID>> getAssistants(ID group);
}

//
//  Base Group
//

class BaseGroup extends BaseEntity implements Group {
  BaseGroup(super.id) : _founder = null;

  /// once the group founder is set, it will never change
  ID? _founder;

  @override
  GroupDataSource? get dataSource {
    EntityDataSource? barrack = super.dataSource;
    if (barrack == null) {
      return null;
    }
    assert(barrack is GroupDataSource, 'group data source error: $barrack');
    return barrack as GroupDataSource;
  }

  @override
  Future<Bulletin?> get bulletin async {
    Document? doc = await getDocument(Document.kBulletin);
    return doc is Bulletin ? doc : null;
  }

  @override
  Future<ID> get founder async {
    _founder ??= await dataSource!.getFounder(identifier);
    return _founder!;
  }

  @override
  Future<ID> get owner async => (await dataSource!.getOwner(identifier))!;

  @override
  Future<List<ID>> get members async => await dataSource!.getMembers(identifier);

  @override
  Future<List<ID>> get assistants async => await dataSource!.getAssistants(identifier);
}
