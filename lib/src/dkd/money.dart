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

import '../protocol/money.dart';
import 'base.dart';


/// MoneyContent
class BaseMoneyContent extends BaseContent implements MoneyContent {
  BaseMoneyContent(super.dict);

  BaseMoneyContent.fromType(int msgType, {required String currency, required double amount})
      : super.fromType(msgType) {
    this['currency'] = currency;
    this['amount'] = amount;
  }
  BaseMoneyContent.from({required String currency, required double amount})
      : this.fromType(ContentType.kMoney, currency: currency, amount: amount);

  @override
  String get currency => getString('currency', '')!;

  @override
  double get amount => getDouble('amount', 0)!;

  @override
  set amount(double value) => this['amount'] = value;
}


/// TransferContent
class TransferMoneyContent extends BaseMoneyContent implements TransferContent {
  TransferMoneyContent(super.dict);

  TransferMoneyContent.from({required String currency, required double amount})
      : super.fromType(ContentType.kTransfer, currency: currency, amount: amount);

  @override
  ID? get remitter => ID.parse(this['remitter']);

  @override
  set remitter(ID? sender) => setString('remitter', sender);

  @override
  ID? get remittee => ID.parse(this['remittee']);

  @override
  set remittee(ID? receiver) => setString('remittee', receiver);
}
