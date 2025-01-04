# Decentralized Instant Messaging Protocol (Dart)

[![License](https://img.shields.io/github/license/dimchat/core-dart)](https://github.com/dimchat/core-dart/blob/master/LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/dimchat/core-dart/pulls)
[![Platform](https://img.shields.io/badge/Platform-Dart%203-brightgreen.svg)](https://github.com/dimchat/core-dart/wiki)
[![Issues](https://img.shields.io/github/issues/dimchat/core-dart)](https://github.com/dimchat/core-dart/issues)
[![Repo Size](https://img.shields.io/github/repo-size/dimchat/core-dart)](https://github.com/dimchat/core-dart/archive/refs/heads/main.zip)
[![Tags](https://img.shields.io/github/tag/dimchat/core-dart)](https://github.com/dimchat/core-dart/tags)
[![Version](https://img.shields.io/pub/v/dimp)](https://pub.dev/packages/dimp)

[![Watchers](https://img.shields.io/github/watchers/dimchat/core-dart)](https://github.com/dimchat/core-dart/watchers)
[![Forks](https://img.shields.io/github/forks/dimchat/core-dart)](https://github.com/dimchat/core-dart/forks)
[![Stars](https://img.shields.io/github/stars/dimchat/core-dart)](https://github.com/dimchat/core-dart/stargazers)
[![Followers](https://img.shields.io/github/followers/dimchat)](https://github.com/orgs/dimchat/followers)

## Dependencies

| Name | Version | Description |
|------|---------|-------------|
| [Ming Ke Ming (名可名)](https://github.com/dimchat/mkm-dart) | [![Version](https://img.shields.io/pub/v/mkm)](https://pub.dev/packages/mkm) | Decentralized User Identity Authentication |
| [Dao Ke Dao (道可道)](https://github.com/dimchat/dkd-dart) | [![Version](https://img.shields.io/pub/v/dkd)](https://pub.dev/packages/dkd) | Universal Message Module |

## Examples

### extends Command

* _Handshake Command Protocol_
  0. (C-S) handshake start
  1. (S-C) handshake again with new session
  2. (C-S) handshake restart with new session
  3. (S-C) handshake success

```dart
import 'package:dimp/dimp.dart';


class HandshakeState {

  static const int START   = 0;  // C -> S, without session key(or session expired)
  static const int AGAIN   = 1;  // S -> C, with new session key
  static const int RESTART = 2;  // C -> S, with new session key
  static const int SUCCESS = 3;  // S -> C, handshake accepted

  static int checkState(String title, String? session) {
    if (title == 'DIM!'/* || title == 'OK!'*/) {
      return SUCCESS;
    } else if (title == 'DIM?') {
      return AGAIN;
    } else if (session == null) {
      return START;
    } else {
      return RESTART;
    }
  }
}


///  Handshake command: {
///      type : 0x88,
///      sn   : 123,
///
///      command : "handshake",    // command name
///      title   : "Hello world!", // "DIM?", "DIM!"
///      session : "{SESSION_KEY}" // session key
///  }
abstract interface class HandshakeCommand implements Command {

  static const String HANDSHAKE = 'handshake';

  String get title;
  String? get sessionKey;

  int get state;

  static HandshakeCommand start() =>
      BaseHandshakeCommand.from('Hello world!');

  static HandshakeCommand restart(String session) =>
      BaseHandshakeCommand.from('Hello world!', sessionKey: session);

  static HandshakeCommand again(String session) =>
      BaseHandshakeCommand.from('DIM?', sessionKey: session);

  static HandshakeCommand success(String? session) =>
      BaseHandshakeCommand.from('DIM!', sessionKey: session);

}


class BaseHandshakeCommand extends BaseCommand implements HandshakeCommand {
  BaseHandshakeCommand(super.dict);

  BaseHandshakeCommand.from(String title, {String? sessionKey})
      : super.fromName(HandshakeCommand.HANDSHAKE) {
    // text message
    this['title'] = title;
    // session key
    if (sessionKey != null) {
      this['session'] = sessionKey;
    }
  }

  @override
  String get title => getString('title', '')!;

  @override
  String? get sessionKey => getString('session', null);

  @override
  int get state => HandshakeState.checkState(title, sessionKey);

}
```

### extends Content

```dart
import 'package:dimp/dimp.dart';


///  Application Customized message: {
///      type : 0xCC,
///      sn   : 123,
///
///      app   : "{APP_ID}",  // application (e.g.: "chat.dim.sechat")
///      mod   : "{MODULE}",  // module name (e.g.: "drift_bottle")
///      act   : "{ACTION}",  // action name (3.g.: "throw")
///      extra : info         // action parameters
///  }
abstract interface class CustomizedContent implements Content {

  /// get App ID
  String get application;

  /// get Module name
  String get module;

  /// get Action name
  String get action;

  static CustomizedContent create({
    required String app, required String mod, required String act
  }) => AppCustomizedContent.from(app: app, mod: mod, act: act);

}


class AppCustomizedContent extends BaseContent implements CustomizedContent {
  AppCustomizedContent(super.dict);

  AppCustomizedContent.from({
    required String app, required String mod, required String act
  }) : super.fromType(ContentType.CUSTOMIZED) {
    this['app'] = app;
    this['mod'] = mod;
    this['act'] = act;
  }

  @override
  String get application => getString('app', '')!;

  @override
  String get module => getString('mod', '')!;

  @override
  String get action => getString('act', '')!;

}
```

### extends ID Address

* Examples in [dim_plugins](https://pub.dev/packages/dim_plugins)

----

Copyright &copy; 2023 Albert Moky
[![Followers](https://img.shields.io/github/followers/moky)](https://github.com/moky?tab=followers)
