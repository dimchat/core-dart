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

import '../dkd/group_admins.dart';
import '../dkd/groups.dart';

import 'base.dart';


///  History command: {
///      type : i2s(0x89),
///      sn   : 123,
///
///      command : "...", // command name
///      time    : 0,     // command timestamp
///      extra   : info   // command parameters
///  }
abstract interface class HistoryCommand implements Command {

  //-------- history command names begin --------
  // account
  static const String REGISTER = "register";
  static const String SUICIDE  = "suicide";
//-------- history command names end --------
}
// ignore_for_file: constant_identifier_names


///  Group command: {
///      type : i2s(0x89),
///      sn   : 123,
///
///      command : "reset",   // "invite", "quit", "query", ...
///      time    : 123.456,   // command timestamp
///
///      group   : "{GROUP_ID}",
///      member  : "{MEMBER_ID}",
///      members : ["{MEMBER_ID}",]
///  }
abstract interface class GroupCommand implements HistoryCommand {

  //-------- group command names begin --------
  // founder/owner
  static const String FOUND    = "found";
  static const String ABDICATE = "abdicate";
  // member
  static const String INVITE   = "invite";
  static const String EXPEL    = "expel";  // Deprecated (use 'reset' instead)
  static const String JOIN     = "join";
  static const String QUIT     = "quit";
  static const String QUERY    = "query";
  static const String RESET    = "reset";
  // administrator/assistant
  static const String HIRE     = "hire";
  static const String FIRE     = "fire";
  static const String RESIGN   = "resign";
  //-------- group command names end --------


  ID? get member;
  set member(ID? user);

  List<ID>? get members;
  set members(List<ID>? users);

  //
  //  Factories
  //

  static GroupCommand create(String cmd, ID group, {ID? member, List<ID>? members}) =>
      BaseGroupCommand.from(cmd, group, member: member, members: members);

  static InviteCommand invite(ID group, {ID? member, List<ID>? members}) =>
      InviteGroupCommand.from(group, member: member, members: members);
  /// Deprecated (use 'reset' instead)
  static ExpelCommand expel(ID group, {ID? member, List<ID>? members}) =>
      ExpelGroupCommand.from(group, member: member, members: members);

  static JoinCommand join(ID group) => JoinGroupCommand.from(group);
  static QuitCommand quit(ID group) => QuitGroupCommand.from(group);

  static QueryCommand query(ID group, [DateTime? lastTime]) =>
      QueryGroupCommand.from(group, lastTime);
  static ResetCommand reset(ID group, {required List<ID> members}) =>
      ResetGroupCommand.from(group, members: members);

  ///  Administrators, Assistants

  static HireCommand hire(ID group, {List<ID>? administrators, List<ID>? assistants}) =>
      HireGroupCommand.from(group, administrators: administrators, assistants: assistants);
  static FireCommand fire(ID group, {List<ID>? administrators, List<ID>? assistants}) =>
      FireGroupCommand.from(group, administrators: administrators, assistants: assistants);
  static ResignCommand resign(ID group) => ResignGroupCommand.from(group);
}


abstract interface class InviteCommand implements GroupCommand {
}


abstract interface class ExpelCommand implements GroupCommand {
  /// Deprecated (use 'reset' instead)
}


abstract interface class JoinCommand implements GroupCommand {
}


abstract interface class QuitCommand implements GroupCommand {
}


///  History command: {
///      type : i2s(0x88),
///      sn   : 123,
///
///      command : "query",
///      time    : 123.456,
///
///      group     : "{GROUP_ID}",
///      last_time : 0
///  }
abstract interface class QueryCommand implements GroupCommand {
  // NOTICE:
  //     This command is just for querying group info,
  //     should not be saved in group history

  /// Last group history time for querying
  DateTime? get lastTime;
}


///  History command: {
///      type : i2s(0x89),
///      sn   : 123,
///
///      command : "reset",
///      time    : 123.456,
///
///      group   : "{GROUP_ID}",
///      members : []
///  }
abstract interface class ResetCommand implements GroupCommand {
}


//  Administrators, Assistants


abstract interface class HireCommand implements GroupCommand {

  /// Administrators
  List<ID>? get administrators;
  set administrators(List<ID>? members);

  /// Assistants (Bots)
  List<ID>? get assistants;
  set assistants(List<ID>? bots);

}


abstract interface class FireCommand implements GroupCommand {

  /// Administrators
  List<ID>? get administrators;
  set administrators(List<ID>? members);

  /// Assistants (Bots)
  List<ID>? get assistants;
  set assistants(List<ID>? bots);

}


abstract interface class ResignCommand implements GroupCommand {
}
