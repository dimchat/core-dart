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

import 'mkm/entity.dart';
import 'mkm/group.dart';
import 'mkm/user.dart';

///  Entity Database
///  ~~~~~~~~~~~~~~~
///  Entity pool to manage User/Contact/Group/Member instances
///
///     1st, get instance here to avoid create same instance,
///     2nd, if they were updated, we can refresh them immediately here
abstract class Barrack implements EntityDelegate, UserDataSource, GroupDataSource {

  Future<EncryptKey?> _visaKey(ID user) async {
    Document? doc = await getDocument(user, Document.kVisa);
    if (doc is Visa) {
      if (doc.isValid) {
        return doc.key;
      }
    }
    return null;
  }

  Future<VerifyKey?> _metaKey(ID user) async {
    Meta? meta = await getMeta(user);
    // assert(meta != null, 'failed to get meta for: $entity');
    return meta?.key;
  }

  //
  //  User Data Source
  //

  @override
  Future<EncryptKey?> getPublicKeyForEncryption(ID user) async {
    // 1. get key from visa
    EncryptKey? visaKey = await _visaKey(user);
    if (visaKey != null) {
      // if visa.key exists, use it for encryption
      return visaKey;
    }
    // 2. get key from meta
    VerifyKey? metaKey = await _metaKey(user);
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
    EncryptKey? visaKey = await _visaKey(user);
    if (visaKey is VerifyKey) {
      // the sender may use communication key to sign message.data,
      // so try to verify it with visa.key here
      keys.add(visaKey as VerifyKey);
    }
    // 2. get key from meta
    VerifyKey? metaKey = await _metaKey(user);
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
    if (doc is Bulletin) {
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
    if (doc is Bulletin && doc.isValid) {
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

  static List<ID> getBroadcastMembers(ID group) {
    List<ID> members = [];
    String? name = getGroupSeed(group);
    if (name == null) {
      // Consensus: the member of group 'everyone@everywhere'
      //            'anyone@anywhere'
      members.add(ID.kAnyone);
    } else {
      // DISCUSS: who should be the member of group 'xxx@everywhere'?
      //          'anyone@anywhere', or 'xxx.member@anywhere'
      ID owner = ID.parse('$name.owner@anywhere')!;
      ID member = ID.parse('$name.member@anywhere')!;
      members.add(owner);
      members.add(member);
    }
    return members;
  }

}
