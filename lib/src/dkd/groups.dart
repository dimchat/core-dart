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

import '../protocol/types.dart';
import '../protocol/groups.dart';
import 'commands.dart';


///
/// HistoryCommand
///
class BaseHistoryCommand extends BaseCommand implements HistoryCommand {
  BaseHistoryCommand(super.dict);

  BaseHistoryCommand.fromName(String cmd)
      : super.fromType(ContentType.HISTORY, cmd);
}


///
/// GroupCommand
///
class BaseGroupCommand extends BaseHistoryCommand implements GroupCommand {
  BaseGroupCommand(super.dict);

  BaseGroupCommand.from(String cmd, ID group, {ID? member, List<ID>? members})
      : super.fromName(cmd) {
    this.group = group;
    if (member != null) {
      assert(members == null, 'parameters error');
      this.member == member;
    } else if (members != null) {
      this.members = members;
    }
  }

  @override
  ID? get member => ID.parse(this['member']);

  @override
  set member(ID? user) {
    setString('member', user);
    remove('members');
  }

  @override
  List<ID>? get members {
    var array = this['members'];
    if (array is List) {
      // convert all items to ID objects
      return ID.convert(array);
    }
    // get from 'member'
    ID? single = member;
    return single == null ? [] : [single];
  }

  @override
  set members(List<ID>? users) {
    if (users == null) {
      remove('members');
    } else {
      this['members'] = ID.revert(users);
    }
    remove('member');
  }
}


///
/// InviteCommand
///
class InviteGroupCommand extends BaseGroupCommand implements InviteCommand {
  InviteGroupCommand(super.dict);

  InviteGroupCommand.from(ID group, {ID? member, List<ID>? members})
      : super.from(GroupCommand.INVITE, group, member: member, members: members);
}


///
/// ExpelCommand (Deprecated, use 'reset' instead)
///
class ExpelGroupCommand extends BaseGroupCommand implements ExpelCommand {
  ExpelGroupCommand(super.dict);

  ExpelGroupCommand.from(ID group, {ID? member, List<ID>? members})
      : super.from(GroupCommand.EXPEL, group, member: member, members: members);
}


///
/// JoinCommand
///
class JoinGroupCommand extends BaseGroupCommand implements JoinCommand {
  JoinGroupCommand(super.dict);

  JoinGroupCommand.from(ID group) : super.from(GroupCommand.JOIN, group);
}


///
/// QuitCommand
///
class QuitGroupCommand extends BaseGroupCommand implements QuitCommand {
  QuitGroupCommand(super.dict);

  QuitGroupCommand.from(ID group) : super.from(GroupCommand.QUIT, group);
}


///
/// QueryCommand
///
class QueryGroupCommand extends BaseGroupCommand implements QueryCommand {
  QueryGroupCommand(super.dict);

  @override
  DateTime? get lastTime => getDateTime('last_time', null);

  QueryGroupCommand.from(ID group, DateTime? lastTime)
      : super.from(GroupCommand.QUERY, group) {
    if (lastTime != null) {
      setDateTime('last_time', lastTime);
    }
  }

}


///
/// ResetCommand
///
class ResetGroupCommand extends BaseGroupCommand implements ResetCommand {
  ResetGroupCommand(super.dict);

  ResetGroupCommand.from(ID group, {required List<ID> members})
      : super.from(GroupCommand.RESET, group, members: members);
}
