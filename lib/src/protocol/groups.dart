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


///  Group command: {
///      type : 0x89,
///      sn   : 123,
///
///      command : "invite",         // "expel", "quit"
///      time    : 0,                // timestamp
///      group   : "{GROUP_ID}",     // group ID
///      member  : "{MEMBER_ID}",    // member ID
///      members : ["{MEMBER_ID}",]  // member ID list
///  }
abstract class GroupCommand implements HistoryCommand {

  //-------- group command names begin --------
  // founder/owner
  static const String kFound    = "found";
  static const String kAbdicate = "abdicate";
  // member
  static const String kInvite   = "invite";
  static const String kExpel    = "expel";  // Deprecated (use 'reset' instead)
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

  static GroupCommand create(String cmd, ID group, {ID? member, List<ID>? members}) =>
      BaseGroupCommand.from(cmd, group, member: member, members: members);

  static InviteCommand invite(ID group, {ID? member, List<ID>? members}) =>
      InviteGroupCommand.from(group, member: member, members: members);
  /// Deprecated (use 'reset' instead)
  static ExpelCommand expel(ID group, {ID? member, List<ID>? members}) =>
      ExpelGroupCommand.from(group, member: member, members: members);

  static JoinCommand join(ID group) => JoinGroupCommand.from(group);
  static QuitCommand quit(ID group) => QuitGroupCommand.from(group);

  static QueryCommand query(ID group) => QueryGroupCommand.from(group);
  static ResetCommand reset(ID group, {required List<ID> members}) =>
      ResetGroupCommand.from(group, members: members);

  ///  Administrators, Assistants

  static HireCommand hire(ID group, {List<ID>? administrators, List<ID>? assistants}) =>
      HireGroupCommand.from(group, administrators: administrators, assistants: assistants);
  static FireCommand fire(ID group, {List<ID>? administrators, List<ID>? assistants}) =>
      FireGroupCommand.from(group, administrators: administrators, assistants: assistants);
  static ResignCommand resign(ID group) => ResignGroupCommand.from(group);
}


abstract class InviteCommand implements GroupCommand {
}


abstract class ExpelCommand implements GroupCommand {
  /// Deprecated (use 'reset' instead)
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


//  Administrators, Assistants


abstract class HireCommand implements GroupCommand {

  /// Administrators
  List<ID>? get administrators;
  set administrators(List<ID>? members);

  /// Assistants (Bots)
  List<ID>? get assistants;
  set assistants(List<ID>? bots);

}


abstract class FireCommand implements GroupCommand {

  /// Administrators
  List<ID>? get administrators;
  set administrators(List<ID>? members);

  /// Assistants (Bots)
  List<ID>? get assistants;
  set assistants(List<ID>? bots);

}


abstract class ResignCommand implements GroupCommand {
}
