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

import 'group.dart';
import 'user.dart';

///  Entity (User/Group)
///  ~~~~~~~~~~~~~~~~~~~
///  Base class of User and Group, ...
///
///  properties:
///      identifier - entity ID
///      type       - entity type
///      meta       - meta for generate ID
///      document   - visa for user, or bulletin for group
abstract class Entity {

  ID get identifier;

  /// EntityType
  int get type;

  EntityDataSource? get dataSource;
  set dataSource(EntityDataSource? delegate);

  Future<Meta> get meta;
  Future<List<Document>> get documents;
}

/// This interface is for getting information for entity(user/group)
///
/// 1. meta for user, which is generated by the user's private key
/// 2. meta for group, which is generated by the founder's private key
/// 3. meta key, which can verify message sent by this user(or group founder)
/// 4. visa key, which can encrypt message for the receiver(user)
abstract class EntityDataSource {

  ///  Get meta for entity ID
  ///
  /// @param identifier - entity ID
  /// @return meta object
  Future<Meta?> getMeta(ID identifier);

  ///  Get document for entity ID
  ///
  /// @param identifier - entity ID
  /// @return Document
  Future<List<Document>> getDocuments(ID identifier);
}

abstract class EntityDelegate {

  ///  Create user with ID
  ///
  /// @param identifier - user ID
  /// @return user
  Future<User?> getUser(ID identifier);

  ///  Create group with ID
  ///
  /// @param identifier - group ID
  /// @return group
  Future<Group?> getGroup(ID identifier);
}

//
//  Base Entity
//

class BaseEntity implements Entity {
  BaseEntity(ID id) : _id = id, _barrack = null;

  // entity ID
  final ID _id;

  // barrack
  WeakReference<EntityDataSource>? _barrack;

  @override
  bool operator ==(Object other) {
    if (other is Entity) {
      if (identical(this, other)) {
        // same object
        return true;
      }
      // check with ID
      other = other.identifier;
    }
    return _id == other;
  }

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() {
    Type clazz = runtimeType;
    int network = _id.address.type;
    return '<$clazz id="$_id" network=$network />';
  }

  @override
  ID get identifier => _id;

  @override
  int get type => _id.type;

  @override
  EntityDataSource? get dataSource => _barrack?.target;

  @override
  set dataSource(EntityDataSource? facebook) =>
      _barrack = facebook == null ? null : WeakReference(facebook);

  @override
  Future<Meta> get meta async =>
      (await dataSource!.getMeta(_id))!;

  @override
  Future<List<Document>> get documents async =>
      await dataSource!.getDocuments(_id);

}
