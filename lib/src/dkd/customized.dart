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
import '../protocol/types.dart';
import '../protocol/customized.dart';

import 'base.dart';


/// CustomizedContent
class AppCustomizedContent extends BaseContent implements CustomizedContent {
  AppCustomizedContent(super.dict);

  AppCustomizedContent.fromType(String msgType, {
    required String app, required String mod, required String act
  }) : super.fromType(msgType) {
    this['app'] = app;
    this['mod'] = mod;
    this['act'] = act;
  }
  AppCustomizedContent.from({
    required String app, required String mod, required String act
  }) : this.fromType(ContentType.CUSTOMIZED, app: app, mod: mod, act: act);

  @override
  String get application => getString('app') ?? '';

  @override
  String get module => getString('mod') ?? '';

  @override
  String get action => getString('act') ?? '';

}
