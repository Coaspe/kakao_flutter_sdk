/// @nodoc
class PlatformSupport {
  late final PlatformSupportValues android;
  late final PlatformSupportValues ios;
  late final PlatformSupportValues web;

  PlatformSupport({
    PlatformSupportValues? android,
    PlatformSupportValues? ios,
    PlatformSupportValues? web,
  }) {
    this.android = android ?? DefaultAndroid();
    this.ios = ios ?? DefaultiOS();
    this.web = web ?? DefaultWeb();
  }
}

/// @nodoc
class PlatformSupportValues {
  final String talkPackage = '';
  final String talkLoginScheme = '';
  final String talkSharingScheme = '';
  final String kakaoNaviScheme = '';
  final String kakaoNaviInstallPage = '';
  final String kakaoNaviOrigin = '';
  final String iosLoginUniversalLink = '';
  final String iosInAppLoginScheme = '';
}

/// @nodoc
class DefaultAndroid extends PlatformSupportValues {
  @override
  String get talkPackage => 'com.kakao.talk';

  @override
  String get talkSharingScheme => 'kakaolink';

  @override
  String get kakaoNaviScheme => 'kakaonavi-sdk://navigate';

  @override
  String get kakaoNaviInstallPage =>
      'https://kakaonavi.kakao.com/launch/index.do';

  @override
  String get kakaoNaviOrigin => 'com.locnall.KimGiSa';
}

/// @nodoc
class DefaultiOS extends PlatformSupportValues {
  @override
  String get talkLoginScheme => 'kakaokompassauth://authorize';

  @override
  String get talkSharingScheme => 'kakaolink';

  @override
  String get kakaoNaviScheme => 'kakaonavi-sdk://navigate';

  @override
  String get kakaoNaviInstallPage =>
      'https://kakaonavi.kakao.com/launch/index.do';
}

/// @nodoc
class DefaultWeb extends PlatformSupportValues {
  // for android
  @override
  String get talkPackage => 'com.kakao.talk';

  @override
  String get talkSharingScheme => 'kakaolink';

  @override
  String get kakaoNaviScheme => 'kakaonavi-sdk://navigate';

  // for android
  @override
  String get kakaoNaviOrigin => 'com.locnall.KimGiSa';

  @override
  String get kakaoNaviInstallPage =>
      'https://kakaonavi.kakao.com/launch/index.do';

  // for ios
  @override
  String get iosLoginUniversalLink => 'https://talk-apps.kakao.com/scheme/';

  // for ios
  @override
  String get talkLoginScheme => 'kakaokompassauth://authorize';

  // for ios
  @override
  String get iosInAppLoginScheme => 'kakaotalk://inappbrowser';
}
