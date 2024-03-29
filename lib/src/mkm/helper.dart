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
import 'dart:typed_data';

import 'package:mkm/crypto.dart';
import 'package:mkm/mkm.dart';

import '../protocol/docs.dart';


abstract interface class BroadcastHelper {

  // private
  static String? getGroupSeed(ID group) {
    String? name = group.name;
    if (name != null) {
      int len = name.length;
      if (len == 0 || (len == 8 && name.toLowerCase() == "everyone")) {
        name = null;
      }
    }
    return name;
  }

  // protected
  static ID getBroadcastFounder(ID group) {
    String? name = getGroupSeed(group);
    if (name == null) {
      // Consensus: the founder of group 'everyone@everywhere'
      //            'Albert Moky'
      return ID.kFounder;
    } else {
      // DISCUSS: who should be the founder of group 'xxx@everywhere'?
      //          'anyone@anywhere', or 'xxx.founder@anywhere'
      return ID.parse('$name.founder@anywhere')!;
    }
  }

  // protected
  static ID getBroadcastOwner(ID group) {
    String? name = getGroupSeed(group);
    if (name == null) {
      // Consensus: the owner of group 'everyone@everywhere'
      //            'anyone@anywhere'
      return ID.kAnyone;
    } else {
      // DISCUSS: who should be the owner of group 'xxx@everywhere'?
      //          'anyone@anywhere', or 'xxx.owner@anywhere'
      return ID.parse('$name.owner@anywhere')!;
    }
  }

  // protected
  static List<ID> getBroadcastMembers(ID group) {
    String? name = getGroupSeed(group);
    if (name == null) {
      // Consensus: the member of group 'everyone@everywhere'
      //            'anyone@anywhere'
      return [ID.kAnyone];
    } else {
      // DISCUSS: who should be the member of group 'xxx@everywhere'?
      //          'anyone@anywhere', or 'xxx.member@anywhere'
      ID owner = ID.parse('$name.owner@anywhere')!;
      ID member = ID.parse('$name.member@anywhere')!;
      return [owner, member];
    }
  }

}


abstract interface class MetaHelper {

  static bool checkMeta(Meta meta) {
    VerifyKey key = meta.publicKey;
    // assert(key != null, 'meta.key should not be empty: $meta');
    String? seed = meta.seed;
    Uint8List? fingerprint = meta.fingerprint;
    bool noSeed = seed == null || seed.isEmpty;
    bool noSig = fingerprint == null || fingerprint.isEmpty;
    // check meta version
    if (!MetaType.hasSeed(meta.type)) {
      // this meta has no seed, so no fingerprint too
      return noSeed && noSig;
    } else if (noSeed || noSig) {
      // seed and fingerprint should not be empty
      return false;
    }
    // verify fingerprint
    return key.verify(UTF8.encode(seed), fingerprint);
  }

  static bool matchIdentifier(ID identifier, Meta meta) {
    assert(meta.isValid, 'meta not valid: $meta');
    // check ID.name
    String? seed = meta.seed;
    String? name = identifier.name;
    if (name == null || name.isEmpty) {
      if (seed != null && seed.isNotEmpty) {
        return false;
      }
    } else if (name != seed) {
      return false;
    }
    // check ID.address
    Address old = identifier.address;
    Address gen = Address.generate(meta, old.type);
    return old == gen;
  }

  static bool matchPublicKey(VerifyKey pKey, Meta meta) {
    assert(meta.isValid, 'meta not valid: $meta');
    // check whether the public key equals to meta.key
    if (pKey == meta.publicKey) {
      return true;
    }
    // check with seed & fingerprint
    if (MetaType.hasSeed(meta.type)) {
      // check whether keys equal by verifying signature
      String? seed = meta.seed;
      Uint8List? fingerprint = meta.fingerprint;
      return pKey.verify(UTF8.encode(seed!), fingerprint!);
    } else {
      // NOTICE: ID with BTC/ETH address has no username, so
      //         just compare the key.data to check matching
      return false;
    }
  }

}


abstract interface class DocumentHelper {

  /// Check whether this time is before old time
  static bool isBefore(DateTime? oldTime, DateTime? thisTime) {
    if (oldTime == null || thisTime == null) {
      return false;
    }
    return thisTime.isBefore(oldTime);
  }

  /// Check whether this document's time is before old document's time
  static bool isExpired(Document thisDoc, Document oldDoc) {
    return isBefore(oldDoc.time, thisDoc.time);
  }

  /// Select last document matched the type
  static Document? lastDocument(List<Document> documents, [String? type]) {
    if (type == null || type == '*') {
      type = '';
    }
    bool checkType = type.isNotEmpty;

    Document? last;
    String? docType;
    bool matched;
    for (Document doc in documents) {
      // 1. check type
      if (checkType) {
        docType = doc.type;
        matched = docType == null || docType.isEmpty || docType == type;
        if (!matched) {
          // type not matched, skip it
          continue;
        }
      }
      // 2. check time
      if (last != null) {
        if (isExpired(doc, last)) {
          // skip expired document
          continue;
        }
      }
      // got it
      last = doc;
    }
    return last;
  }

  /// Select last visa document
  static Visa? lastVisa(List<Document> documents) {
    Visa? last;
    bool matched;
    for (Document doc in documents) {
      // 1. check type
      matched = doc is Visa;
      if (!matched) {
        // type not matched, skip it
        continue;
      }
      // 2. check time
      if (last != null) {
        if (isExpired(doc, last)) {
          // skip expired document
          continue;
        }
      }
      // got it
      last = doc;
    }
    return last;
  }

  /// Select last bulletin document
  static Bulletin? lastBulletin(List<Document> documents) {
    Bulletin? last;
    bool matched;
    for (Document doc in documents) {
      // 1. check type
      matched = doc is Bulletin;
      if (!matched) {
        // type not matched, skip it
        continue;
      }
      // 2. check time
      if (last != null) {
        if (isExpired(doc, last)) {
          // skip expired document
          continue;
        }
      }
      // got it
      last = doc;
    }
    return last;
  }

}
