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

import '../dkd/money.dart';


///  Money message: {
///      type : 0x40,
///      sn   : 123,
///
///      currency : "RMB", // USD, USDT, ...
///      amount   : 100.00
///  }
abstract class MoneyContent implements Content {

  String get currency;

  double get amount;
  set amount(double value);

  //
  //  Factory
  //

  static MoneyContent create(int? msgType, {required String currency, required double amount}) {
    if (msgType == null) {
      return BaseMoneyContent.from(currency: currency, amount: amount);
    } else {
      return BaseMoneyContent.fromType(msgType, currency: currency, amount: amount);
    }
  }
}


///  Transfer money message: {
///      type : 0x41,
///      sn   : 123,
///
///      currency : "RMB",    // USD, USDT, ...
///      amount   : 100.00,
///      remitter : "{FROM}", // sender ID
///      remittee : "{TO}"    // receiver ID
///  }
abstract class TransferContent implements MoneyContent {

  /// sender
  ID get remitter;
  set remitter(ID sender);

  /// receiver
  ID get remittee;
  set remittee(ID receiver);

  //
  //  Factory
  //

  static TransferContent create({required String currency, required double amount}) =>
      TransferMoneyContent.from(currency: currency, amount: amount);
}
