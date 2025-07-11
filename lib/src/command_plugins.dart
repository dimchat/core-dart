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
import 'protocol/helpers.dart';

///  Command GeneralFactory
///  ~~~~~~~~~~~~~~~~~~~~~~
abstract interface class GeneralCommandHelper /*implements CommandHelper */{

  //
  //  CMD - Command, Method, Declaration
  //

  /// Get command name
  String? getCmd(Map content, [String? defaultValue]);

}

/// Command FactoryManager
/// ~~~~~~~~~~~~~~~~~~~~~~
class SharedCommandExtensions {
  factory SharedCommandExtensions() => _instance;
  static final SharedCommandExtensions _instance = SharedCommandExtensions._internal();
  SharedCommandExtensions._internal();

  /// Command
  CommandHelper? get cmdHelper =>
      CommandExtensions().cmdHelper;

  set cmdHelper(CommandHelper? helper) =>
      CommandExtensions().cmdHelper = helper;

  /// General Helper
  GeneralCommandHelper? helper;

}
