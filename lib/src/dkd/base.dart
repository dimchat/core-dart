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

class BaseContent extends Dictionary implements Content {
  BaseContent(super.dict) : _type = null, _sn = null, _time = null;

  BaseContent.fromType(int msgType) : super(null) {
    DateTime now = DateTime.now();
    _type = msgType;
    _sn = InstantMessage.generateSerialNumber(msgType, now);
    _time = now;
    this['type'] = _type;
    this['sn'] = _sn;
    setTime('time', _time);
  }

  /// message type: text, image, ...
  int? _type;

  /// serial number: random number to identify message content
  int? _sn;

  /// message time
  DateTime? _time;

  @override
  int get type {
    _type ??= getInt('type');
    return _type ?? 0;
  }

  @override
  int get sn {
    _sn ??= getInt('sn');
    assert(_sn! > 0, 'serial number error: $this');
    return _sn ?? 0;
  }

  @override
  DateTime? get time {
    _time ??= getTime('time');
    return _time;
  }

  @override
  ID? get group => ID.parse(this['group']);

  @override
  set group(ID? identifier) => setString('group', identifier);
}
