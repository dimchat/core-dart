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
import 'package:mkm/crypto.dart';
import 'package:mkm/protocol.dart';

import '../format/file.dart';


/// User Visa document interface (user-specific authorization document).
///
/// Defines a user's public-facing information and authorization keys, used for:
/// - Generating temporary asymmetric keys for secure messaging
/// - Authorizing third-party apps to log in
abstract interface class Visa implements Document {

  /// Gets the user's display name/nickname.
  String? get name;

  /// Sets the user's display name/nickname.
  ///
  /// @param nickname - New display name for the user
  set name(String? nickname);

  /// Gets the user's public encryption key.
  ///
  /// This key is used by other users to encrypt messages sent to this user.
  EncryptKey? get publicKey;

  /// Sets the user's public encryption key.
  ///
  /// @param pKey - New public key for message encryption
  set publicKey(EncryptKey? pKey);

  /// Gets the user's avatar image (URL/Base64).
  ///
  /// Returns a [TransportableFile] containing the avatar's URL or Base64 data.
  TransportableFile? get avatar;

  /// Sets the user's avatar image (URL/Base64).
  ///
  /// @param img - New avatar image (URL/Base64)
  set avatar(TransportableFile? img);

}


/// Group Bulletin document interface (group-specific announcement document).
///
/// Defines a group's public-facing information and core attributes.
abstract interface class Bulletin implements Document {

  /// Gets the group's display name/title.
  String? get name;

  /// Sets the group's display name/title.
  ///
  /// @param title - New title for the group
  set name(String? title);

  /// Gets the group founder's user ID.
  ///
  /// Identifies the original creator of the group.
  ID? get founder;

}
