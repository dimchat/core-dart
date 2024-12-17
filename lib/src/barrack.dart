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
import 'mkm/user.dart';
import 'mkm/group.dart';

import 'archivist.dart';


///  Entity Factory
///  ~~~~~~~~~~~~~~
///  Entity pool to manage User/Contact/Group/Member instances
abstract class Barrack implements EntityDelegate {

  // memory caches
  final Map<ID, User>   _userMap = {};
  final Map<ID, Group> _groupMap = {};

  // protected
  void cacheUser(User user) => _userMap[user.identifier] = user;
  // protected
  void cacheGroup(Group group) => _groupMap[group.identifier] = group;

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

  /// Thanos
  /// ~~~~~~
  /// Thanos can kill half lives of a world with a snap of the finger
  static int thanos(Map planet, int finger) {
    // if ++finger is odd, remove it,
    // else, let it go
    planet.removeWhere((key, value) => (++finger & 1) == 1);
    return finger;
  }

  Archivist get archivist;

  //
  //  Entity Delegate
  //

  @override
  Future<User?> getUser(ID identifier) async {
    assert(identifier.isUser, 'user ID error: $identifier');
    // 1. get from user cache
    User? user = _userMap[identifier];
    if (user == null) {
      // 2. create user and cache it
      user = await archivist.createUser(identifier);
      if (user != null) {
        cacheUser(user);
      }
    }
    return user;
  }

  @override
  Future<Group?> getGroup(ID identifier) async {
    assert(identifier.isGroup, 'group ID error: $identifier');
    // 1. get from group cache
    Group? group = _groupMap[identifier];
    if (group == null) {
      // 2. create group and cache it
      group = await archivist.createGroup(identifier);
      if (group != null) {
        cacheGroup(group);
      }
    }
    return group;
  }

}
