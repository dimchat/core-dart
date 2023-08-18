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

import '../dkd/groups.dart';
import 'commands.dart';


///  History command: {
///      type : 0x89,
///      sn   : 123,
///
///      command : "...", // command name
///      time    : 0,     // command timestamp
///      extra   : info   // command parameters
///  }
abstract class HistoryCommand implements Command {

  //-------- history command names begin --------
  // account
  static const String kRegister = "register";
  static const String kSuicide  = "suicide";
//-------- history command names end --------
}


abstract class GroupCommand implements HistoryCommand {

  //-------- group command names begin --------
  // founder/owner
  static const String kFound    = "found";
  static const String kAbdicate = "abdicate";
  // member
  static const String kInvite   = "invite";
  static const String kExpel    = "expel";
  static const String kJoin     = "join";
  static const String kQuit     = "quit";
  static const String kQuery    = "query";
  static const String kReset    = "reset";
  // administrator/assistant
  static const String kHire     = "hire";
  static const String kFire     = "fire";
  static const String kResign   = "resign";
  //-------- group command names end --------


  ID? get member;
  set member(ID? user);

  List<ID>? get members;
  set members(List<ID>? users);

  //
  //  Factories
  //

  static InviteCommand invite(ID group, {ID? member, List<ID>? members}) {
    return InviteGroupCommand.from(group, member: member, members: members);
  }
  static ExpelCommand expel(ID group, {ID? member, List<ID>? members}) {
    return ExpelGroupCommand.from(group, member: member, members: members);
  }

  static JoinCommand join(ID group) {
    return JoinGroupCommand.from(group);
  }
  static QuitCommand quit(ID group) {
    return QuitGroupCommand.from(group);
  }

  static QueryCommand query(ID group) {
    return QueryGroupCommand.from(group);
  }
  static ResetCommand reset(ID group, {required List<ID> members}) {
    return ResetGroupCommand.from(group, members: members);
  }
}


abstract class InviteCommand implements GroupCommand {
}


abstract class ExpelCommand implements GroupCommand {
}


abstract class JoinCommand implements GroupCommand {
}


abstract class QuitCommand implements GroupCommand {
}


///  NOTICE:
///      This command is just for querying group info,
///      should not be saved in group history
abstract class QueryCommand implements GroupCommand {
}


abstract class ResetCommand implements GroupCommand {
}
