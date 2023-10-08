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
import 'package:mkm/crypto.dart';
import 'package:mkm/mkm.dart';

import 'mkm/entity.dart';
import 'mkm/group.dart';
import 'mkm/user.dart';

///  Entity Database
///  ~~~~~~~~~~~~~~~
///  Entity pool to manage User/Contact/Group/Member instances
///  Manage meta/document for all entities
///
///     1st, get instance here to avoid create same instance,
///     2nd, if they were updated, we can refresh them immediately here
abstract class Barrack implements EntityDelegate, UserDataSource, GroupDataSource {

  // memory caches
  final Map<ID, User>   _userMap = {};
  final Map<ID, Group> _groupMap = {};

  // protected
  void cacheUser(User user) {
    user.dataSource ??= this;
    _userMap[user.identifier] = user;
  }
  // protected
  void cacheGroup(Group group) {
    group.dataSource ??= this;
    _groupMap[group.identifier] = group;
  }

  /// Call it when received 'UIApplicationDidReceiveMemoryWarningNotification',
  /// this will remove 50% of cached objects
  ///
  /// @return number of survivors
  int reduceMemory() {
    int finger = 0;
    finger = thanos(_userMap, finger);
    finger = thanos(_groupMap, finger);
    return finger >> 1;
  }

  ///  Create user when visa.key exists
  ///
  /// @param identifier - user ID
  /// @return user, null on not ready
  // protected
  Future<User?> createUser(ID identifier);

  ///  Create group when members exist
  ///
  /// @param identifier - group ID
  /// @return group, null on not ready
  // protected
  Future<Group?> createGroup(ID identifier);

  // protected
  Future<EncryptKey?> getVisaKey(ID user) async {
    Document? doc = await getDocument(user, Document.kVisa);
    if (doc is Visa/* && doc.isValid*/) {
      return doc.publicKey;
    }
    return null;
  }

  // protected
  Future<VerifyKey?> getMetaKey(ID user) async {
    Meta? meta = await getMeta(user);
    // assert(meta != null, 'failed to get meta for: $entity');
    return meta?.publicKey;
  }

  //
  //  Entity Delegate
  //

  @override
  Future<User?> getUser(ID identifier) async {
    // 1. get from user cache
    User? user = _userMap[identifier];
    if (user == null) {
      // 2. create user and cache it
      user = await createUser(identifier);
      if (user != null) {
        cacheUser(user);
      }
    }
    return user;
  }

  @override
  Future<Group?> getGroup(ID identifier) async {
    // 1. get from group cache
    Group? group = _groupMap[identifier];
    if (group == null) {
      // 2. create group and cache it
      group = await createGroup(identifier);
      if (group != null) {
        cacheGroup(group);
      }
    }
    return group;
  }

  //
  //  User Data Source
  //

  @override
  Future<EncryptKey?> getPublicKeyForEncryption(ID user) async {
    // 1. get key from visa
    EncryptKey? visaKey = await getVisaKey(user);
    if (visaKey != null) {
      // if visa.key exists, use it for encryption
      return visaKey;
    }
    // 2. get key from meta
    VerifyKey? metaKey = await getMetaKey(user);
    if (metaKey is EncryptKey) {
      // if visa.key not exists and meta.key is encrypt key,
      // use it for encryption
      return metaKey as EncryptKey;
    }
    // assert(false, 'failed to get encrypt key for user: $user');
    return null;
  }

  @override
  Future<List<VerifyKey>> getPublicKeysForVerification(ID user) async {
    List<VerifyKey> keys = [];
    // 1. get key from visa
    EncryptKey? visaKey = await getVisaKey(user);
    if (visaKey is VerifyKey) {
      // the sender may use communication key to sign message.data,
      // so try to verify it with visa.key here
      keys.add(visaKey as VerifyKey);
    }
    // 2. get key from meta
    VerifyKey? metaKey = await getMetaKey(user);
    if (metaKey != null) {
      // the sender may use identity key to sign message.data,
      // try to verify it with meta.key
      keys.add(metaKey);
    }
    assert(keys.isNotEmpty, 'failed to get verify key for user: $user');
    return keys;
  }

  //
  //  Group Data Source
  //

  @override
  Future<ID?> getFounder(ID group) async {
    // check broadcast group
    if (group.isBroadcast) {
      // founder of broadcast group
      return getBroadcastFounder(group);
    }
    // get from document
    Document? doc = await getDocument(group, '*');
    if (doc is Bulletin/* && doc.isValid*/) {
      return doc.founder;
    }
    // TODO: load founder from database
    return null;
  }

  @override
  Future<ID?> getOwner(ID group) async {
    // check broadcast group
    if (group.isBroadcast) {
      // owner of broadcast group
      return getBroadcastOwner(group);
    }
    // check group type
    if (group.type == EntityType.kGroup) {
      // Polylogue's owner is its founder
      return await getFounder(group);
    }
    // TODO: load owner from database
    return null;
  }

  @override
  Future<List<ID>> getMembers(ID group) async {
    // check broadcast group
    if (group.isBroadcast) {
      // members of broadcast group
      return getBroadcastMembers(group);
    }
    // TODO: load members from database
    return [];
  }

  @override
  Future<List<ID>> getAssistants(ID group) async {
    Document? doc = await getDocument(group, Document.kBulletin);
    if (doc is Bulletin/* && doc.isValid*/) {
      List<ID>? bots = doc.assistants;
      if (bots != null) {
        return bots;
      }
    }
    // TODO: get group bots from SP configuration
    return [];
  }

  //
  //  Broadcast Group
  //

  // private
  static String? getGroupSeed(ID group) {
    String? name = group.name;
    if (name != null) {
      int len = name.length;
      if (len == 0 || (len == 8 && name.toLowerCase() == "everyone")) {
        name = null;
      }
    }
    return name;
  }

  // protected
  static ID getBroadcastFounder(ID group) {
    String? name = getGroupSeed(group);
    if (name == null) {
      // Consensus: the founder of group 'everyone@everywhere'
      //            'Albert Moky'
      return ID.kFounder;
    } else {
      // DISCUSS: who should be the founder of group 'xxx@everywhere'?
      //          'anyone@anywhere', or 'xxx.founder@anywhere'
      return ID.parse('$name.founder@anywhere')!;
    }
  }

  // protected
  static ID getBroadcastOwner(ID group) {
    String? name = getGroupSeed(group);
    if (name == null) {
      // Consensus: the owner of group 'everyone@everywhere'
      //            'anyone@anywhere'
      return ID.kAnyone;
    } else {
      // DISCUSS: who should be the owner of group 'xxx@everywhere'?
      //          'anyone@anywhere', or 'xxx.owner@anywhere'
      return ID.parse('$name.owner@anywhere')!;
    }
  }

  // protected
  static List<ID> getBroadcastMembers(ID group) {
    String? name = getGroupSeed(group);
    if (name == null) {
      // Consensus: the member of group 'everyone@everywhere'
      //            'anyone@anywhere'
      return [ID.kAnyone];
    } else {
      // DISCUSS: who should be the member of group 'xxx@everywhere'?
      //          'anyone@anywhere', or 'xxx.member@anywhere'
      ID owner = ID.parse('$name.owner@anywhere')!;
      ID member = ID.parse('$name.member@anywhere')!;
      return [owner, member];
    }
  }

}

/// Thanos
/// ~~~~~~
/// Thanos can kill half lives of a world with a snap of the finger
int thanos(Map planet, int finger) {
  // if ++finger is odd, remove it,
  // else, let it go
  planet.removeWhere((key, value) => (++finger & 1) == 1);
  return finger;
}
