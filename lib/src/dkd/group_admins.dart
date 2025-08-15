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

import '../protocol/groups.dart';

import 'groups.dart';


///
/// HireCommand
///
class HireGroupCommand extends BaseGroupCommand implements HireCommand {
  HireGroupCommand([super.dict]);

  HireGroupCommand.from(ID group, {List<ID>? administrators, List<ID>? assistants})
      : super.from(GroupCommand.HIRE, group) {
    if (administrators != null) {
      this['administrators'] = ID.revert(administrators);
    }
    if (assistants != null) {
      this['assistants'] = ID.revert(assistants);
    }
  }

  @override
  List<ID>? get administrators {
    var array = this['administrators'];
    if (array is List) {
      // convert all items to ID objects
      return ID.convert(array);
    }
    assert(array == null, 'ID list error: $array');
    return null;
  }

  @override
  set administrators(List<ID>? members) {
    if (members == null) {
      remove('administrators');
    } else {
      this['administrators'] = ID.revert(members);
    }
  }

  @override
  List<ID>? get assistants {
    var array = this['assistants'];
    if (array is List) {
      // convert all items to ID objects
      return ID.convert(array);
    }
    assert(array == null, 'ID list error: $array');
    return null;
  }

  @override
  set assistants(List<ID>? bots) {
    if (bots == null) {
      remove('assistants');
    } else {
      this['assistants'] = ID.revert(bots);
    }
  }

}


///
/// FireCommand
///
class FireGroupCommand extends BaseGroupCommand implements FireCommand {
  FireGroupCommand([super.dict]);

  FireGroupCommand.from(ID group, {List<ID>? administrators, List<ID>? assistants})
      : super.from(GroupCommand.FIRE, group) {
    if (administrators != null) {
      this['administrators'] = ID.revert(administrators);
    }
    if (assistants != null) {
      this['assistants'] = ID.revert(assistants);
    }
  }

  @override
  List<ID>? get administrators {
    var array = this['administrators'];
    if (array is List) {
      // convert all items to ID objects
      return ID.convert(array);
    }
    assert(array == null, 'ID list error: $array');
    return null;
  }

  @override
  set administrators(List<ID>? members) {
    if (members == null) {
      remove('administrators');
    } else {
      this['administrators'] = ID.revert(members);
    }
  }

  @override
  List<ID>? get assistants {
    var array = this['assistants'];
    if (array is List) {
      // convert all items to ID objects
      return ID.convert(array);
    }
    assert(array == null, 'ID list error: $array');
    return null;
  }

  @override
  set assistants(List<ID>? bots) {
    if (bots == null) {
      remove('assistants');
    } else {
      this['assistants'] = ID.revert(bots);
    }
  }

}


///
/// ResignCommand
///
class ResignGroupCommand extends BaseGroupCommand implements ResignCommand {
  ResignGroupCommand([super.dict]);

  ResignGroupCommand.from(ID group) : super.from(GroupCommand.RESIGN, group);
}
