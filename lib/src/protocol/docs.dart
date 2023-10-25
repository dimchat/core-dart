/* license: https://mit-license.org
 *
 *  Ming-Ke-Ming : Decentralized User Identity Authentication
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
import 'package:mkm/crypto.dart';
import 'package:mkm/mkm.dart';

///  User Document
///  ~~~~~~~~~~~~~
///  This interface is defined for authorizing other apps to login,
///  which can generate a temporary asymmetric key pair for messaging.
abstract class Visa implements Document {

  ///  Get public key to encrypt message for user
  ///
  /// @return public key as visa.key
  EncryptKey? get publicKey;

  ///  Set public key for other user to encrypt message
  ///
  /// @param pKey - public key as visa.key
  set publicKey(EncryptKey? pKey);

  ///  Get avatar URL
  ///
  /// @return PNF(URL)
  PortableNetworkFile? get avatar;

  ///  Set avatar URL
  ///
  /// @param url - PNF(URL)
  set avatar(PortableNetworkFile? url);
}

abstract class Bulletin implements Document {

  ///  Get group founder
  ///
  ///  @return user ID
  ID? get founder;

  ///  Get group assistants
  ///
  /// @return group bot ID list
  List<ID>? get assistants;

  ///  Set group assistants
  ///
  /// @param bots - group bot ID list
  set assistants(List<ID>? bots);
}
