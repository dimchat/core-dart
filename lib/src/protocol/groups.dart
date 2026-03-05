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
import 'package:mkm/protocol.dart';

import '../dkd/groups.dart';

import 'base.dart';


/// History command interface for recording operational history.
///
/// Base interface for all history-tracking commands, which record the timestamp
/// and parameters of system operations (e.g., group member changes).
///
/// All group-related commands implement this interface to form the group's change history.
///
/// JSON format:
/// ```json
/// {
///   "type" : i2s(0x89),
///   "sn"   : 123,
///
///   "command" : "...",   // Unique history command name
///   "time"    : 123.45,  // Timestamp when the command was executed
///
///   "extra"   : info     // Optional command-specific parameters
/// }
/// ```
abstract interface class HistoryCommand implements Command {

  //-------- history command names begin --------
  // account
  static const String REGISTER = "register";
  static const String SUICIDE  = "suicide";
//-------- history command names end --------
}
// ignore_for_file: constant_identifier_names


/// Group command interface for tracking group member/role changes.
///
/// Extends [HistoryCommand] to define group-specific operations, which collectively
/// form the complete change history of a group's member information (members, admins, owner).
///
/// JSON format:
/// ```json
/// {
///   "type" : i2s(0x89),
///   "sn"   : 123,
///
///   "command" : "reset",          // "invite", "quit", "query", ...
///   "time"    : 123.45,           // Timestamp of the group operation
///
///   "group"   : "{GROUP_ID}",     // Target group ID
///   "members" : ["{MEMBER_ID}",]  // List of affected member IDs
/// }
/// ```
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
  //static const String QUERY  = "query";  // Deprecated
  static const String RESET    = "reset";
  // administrator/assistant
  static const String HIRE     = "hire";
  static const String FIRE     = "fire";
  static const String RESIGN   = "resign";
  //-------- group command names end --------

  /// List of member IDs affected by this group command.
  List<ID>? get members;
  set members(List<ID>? users);

  //
  //  Factories
  //

  static GroupCommand create(String cmd, ID group, {List<ID>? members}) =>
      BaseGroupCommand.fromCmd(cmd, group, members: members);

  static InviteCommand invite(ID group, {required List<ID> members}) =>
      InviteGroupCommand.from(group, members: members);
  /// Deprecated (use 'reset' instead)
  static ExpelCommand expel(ID group, {required List<ID> members}) =>
      ExpelGroupCommand.from(group, members: members);

  static JoinCommand join(ID group) => JoinGroupCommand.from(group);
  static QuitCommand quit(ID group) => QuitGroupCommand.from(group);

  static ResetCommand reset(ID group, {required List<ID> members}) =>
      ResetGroupCommand.from(group, members: members);

}


/// Group invite command interface.
///
/// Used to record the history of inviting users to join a group.
/// The [members] field contains the IDs of users being invited.
abstract interface class InviteCommand implements GroupCommand {
}


/// Group expel command interface (DEPRECATED).
///
/// Originally used to record the history of expelling members from a group.
/// This command is deprecated - use [ResetCommand] (RESET) instead for member removal.
abstract interface class ExpelCommand implements GroupCommand {
  /// Deprecated (use 'reset' instead)
}


/// Group join command interface.
///
/// Used to record the history of users voluntarily joining a group.
/// The [members] field contains the ID of the user joining the group.
abstract interface class JoinCommand implements GroupCommand {
}


/// Group quit command interface.
///
/// Used to record the history of members voluntarily leaving a group.
/// The [members] field contains the ID of the member quitting the group.
abstract interface class QuitCommand implements GroupCommand {
}

/// Group reset command interface.
///
/// Used to record the history of resetting the full list of group members,
/// replacing deprecated commands like EXPEL and QUERY. This command is the
/// standard way to update the complete member list (add/remove multiple members).
///
/// JSON format:
/// ```json
/// {
///   "type" : i2s(0x89),
///   "sn"   : 123,
///
///   "command" : "reset",
///   "time"    : 123.45,        // Timestamp of the reset operation
///
///   "group"   : "{GROUP_ID}",  // Target group ID
///   "members" : [...]          // Full list of current group members after reset
/// }
/// ```
abstract interface class ResetCommand implements GroupCommand {
}
