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
import 'package:dkd/dkd.dart';
import 'package:mkm/mkm.dart';

import '../protocol/commands.dart';

class CommandFactoryManager {
  factory CommandFactoryManager() => _instance;
  static final CommandFactoryManager _instance = CommandFactoryManager._internal();
  CommandFactoryManager._internal();

  CommandGeneralFactory generalFactory = CommandGeneralFactory();

}

class CommandGeneralFactory {

  final Map<String, CommandFactory> _commandFactories = {};

  //
  //  Command
  //

  void setCommandFactory(String cmd, CommandFactory? factory) {
    if (factory == null) {
      _commandFactories.remove(cmd);
    } else {
      _commandFactories[cmd] = factory;
    }
  }
  CommandFactory? getCommandFactory(String cmd) {
    return _commandFactories[cmd];
  }

  String? getCmd(Map content) {
    return content['command'];
  }

  Command? parseCommand(Object? content) {
    if (content == null) {
      return null;
    } else if (content is Command) {
      return content;
    }
    Map? info = Wrapper.getMap(content);
    if (info == null) {
      assert(false, 'content error: $content');
      return null;
    }
    // get factory by command name
    String? cmd = getCmd(info);
    // assert(cmd != null, 'command name not found: $info');
    CommandFactory? factory = cmd == null ? null : getCommandFactory(cmd);
    if (factory == null) {
      // unknown command name, get base command factory
      MessageFactoryManager man = MessageFactoryManager();
      MessageGeneralFactory gf = man.generalFactory;
      int? type = gf.getContentType(info);
      if (type == null) {
        assert(false, 'message type not found: $info');
      } else {
        ContentFactory? fact = gf.getContentFactory(type);
        if (fact is CommandFactory) {
          factory = fact as CommandFactory;
        } else {
          assert(false, 'cannot parse command: $info');
        }
      }
    }
    return factory?.parseCommand(info);
  }
}
