// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Zen';

  @override
  String get appNameFull => 'Zen वीडियो प्लेयर';

  @override
  String get accessYourMedia => 'अपने मीडिया तक पहुँचें';

  @override
  String mediaAccessDescription(String appName) {
    return '$appName को आपके डिवाइस पर संगीतित वीडियो और संगीत खोजने और चलाने के लिए आपकी मीडिया फ़ाइलों की अनुमति चाहिए।';
  }

  @override
  String get featurePlayLocal => 'स्थानीय वीडियो और ऑडियो चलाएँ';

  @override
  String get featureBrowseFiles => 'फ़ाइलें आसानी से ब्राउज़ करें';

  @override
  String get featureLockPrivate => 'निजी फ़ोल्डर लॉक करें';

  @override
  String get allowAccess => 'अनुमति दें';

  @override
  String get notNow => 'अभी नहीं';

  @override
  String get permissionRequired =>
      'लाइब्रेरी ब्राउज़ करने के लिए मीडिया एक्सेस ज़रूरी है। आप सेटिंग्स में अनुमति दे सकते हैं।';

  @override
  String get openSettings => 'सेटिंग्स खोलें';

  @override
  String get tabVideo => 'वीडियो';

  @override
  String get tabAudio => 'ऑडियो';

  @override
  String get tabSettings => 'सेटिंग्स';

  @override
  String get pillPlaylist => 'प्लेलिस्ट';

  @override
  String get pillMediaServer => 'मीडिया सर्वर';

  @override
  String get pillNetworkStream => 'नेटवर्क स्ट्रीम';

  @override
  String get comingSoon => 'जल्द आ रहा है';

  @override
  String get audioTabHint =>
      'ऑडियो ब्राउज़िंग भविष्य के अपडेट में उपलब्ध होगी।';

  @override
  String get settingsTabHint => 'सेटिंग्स भविष्य के अपडेट में उपलब्ध होंगी।';

  @override
  String get folderRecentlyAdded => 'हाल में जोड़े गए';

  @override
  String videoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वीडियो',
      one: '1 वीडियो',
    );
    return '$_temp0';
  }

  @override
  String folderSizeSummary(String count, String size) {
    return '$count • $size';
  }

  @override
  String get badgeNew => 'नया';

  @override
  String get noVideosFound => 'इस डिवाइस पर कोई वीडियो नहीं मिला';

  @override
  String get grantAccessToBrowse =>
      'फ़ोल्डर ब्राउज़ करने के लिए मीडिया एक्सेस की अनुमति दें।';

  @override
  String get pickVideoFile => 'वीडियो फ़ाइल चुनें';

  @override
  String get playFromUrl => 'URL से चलाएँ';

  @override
  String get pasteVideoUrl => 'वीडियो URL यहाँ पेस्ट करें';

  @override
  String get playVideo => 'वीडियो चलाएँ';

  @override
  String get searchFolders => 'फ़ोल्डर खोजें';

  @override
  String get clearSearch => 'साफ़ करें';

  @override
  String searchResultsFor(String query) {
    return '\"$query\" के परिणाम';
  }

  @override
  String get cast => 'कास्ट';

  @override
  String get moreOptions => 'अधिक';

  @override
  String get loadingLibrary => 'लाइब्रेरी लोड हो रही है…';

  @override
  String get calculatingSize => 'गणना हो रही है…';

  @override
  String videosInFolder(String folder) {
    return '$folder में वीडियो';
  }

  @override
  String get permissionWhyTitle => 'ऐप को अनुमति क्यों चाहिए';

  @override
  String permissionWhyBody1(String appName) {
    return '$appName को सही तरह काम करने के लिए आपके डिवाइस पर वीडियो, गाने और उपशीर्षक की अनुमति चाहिए।';
  }

  @override
  String get permissionWhyBody2 =>
      'फ़ाइल एक्सेस से आप फ़ोन पर संग्रहित मीडिया खोज और चला सकते हैं। अनुमति देने के बाद ऐप में वीडियो फ़ोल्डर दिखेंगे।';

  @override
  String permissionWhyPrivacy(String appName) {
    return '$appName वादा करता है कि ये अनुमतियाँ आपके निजी डेटा तक पहुँचने के लिए उपयोग नहीं होंगी।';
  }

  @override
  String get permissionWhyMoreInfo => 'अधिक जानकारी के लिए';

  @override
  String get permissionWhySupportUrl =>
      'https://support.google.com/googleplay/android-developer/answer/10467955';

  @override
  String get ok => 'ठीक है';

  @override
  String get skip => 'छोड़ें';

  @override
  String get next => 'आगे';

  @override
  String get getStarted => 'शुरू करें';

  @override
  String get onboardingTitle1 => 'ऑल-इन-वन मीडिया प्लेयर';

  @override
  String get onboardingPictureModes => 'पिक्चर मोड';

  @override
  String get pictureModeStandard => 'स्टैंडर्ड';

  @override
  String get pictureModeVivid => 'विविड';

  @override
  String get pictureModeGame => 'गेम';

  @override
  String get pictureModeMovie => 'मूवी';

  @override
  String get pictureModeCozy => 'आरामदायक';

  @override
  String get pictureModeDynamic => 'डायनामिक';

  @override
  String get onboardingSubtitle1 =>
      'HDR वीडियो प्लेयर सभी फ़ाइलें चलाता है। पूरी लाइब्रेरी के लिए शक्तिशाली संगीत प्लेयर।';

  @override
  String get onboardingTitle2 => 'प्रीमियम ऑडियो अनुभव';

  @override
  String get onboardingSubtitle2 =>
      'स्पष्ट इक्वलाइज़र और गहरे बास। सुंदर संगीत विज़ुअलाइज़र।';

  @override
  String get onboardingTitle3 => 'शानदार विज़ुअलाइज़र';

  @override
  String get onboardingSubtitle3 =>
      'क्रिस्टल-क्लियर इक्वलाइज़र। गहरा बास। सुंदर विज़ुअलाइज़र।';

  @override
  String get onboardingTitle4 => 'उन्नत सुविधाएँ';

  @override
  String get onboardingSubtitle4 =>
      'किसी भी वीडियो के लिए उपशीर्षक डाउनलोड। गोपनीयता के लिए सुरक्षित फ़ोल्डर।';

  @override
  String get chooseLanguage => 'भाषा चुनें';

  @override
  String get languageEnglish => 'अंग्रेज़ी';

  @override
  String get languageTamil => 'तमिल';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageTelugu => 'तेलुगु';

  @override
  String get languageTamilPicker => 'Tamil (தமிழ்)';

  @override
  String get languageHindiPicker => 'Hindi (हिन्दी)';

  @override
  String get languageTeluguPicker => 'Telugu (తెలుగు)';

  @override
  String get languageTutorialTitle => 'अपनी भाषा चुनें';

  @override
  String get languageTutorialBody =>
      'तमिल, अंग्रेज़ी, हिन्दी और तेलुगु के बीच बदलने के लिए यहाँ भाषा बटन पर टैप करें।';

  @override
  String get gotIt => 'समझ गया';

  @override
  String get audioSubAlbum => 'एल्बम';

  @override
  String get audioSubSongs => 'गाने';

  @override
  String get audioSubArtist => 'कलाकार';

  @override
  String get audioSubFolder => 'फ़ोल्डर';

  @override
  String get audioSubPlaylist => 'प्लेलिस्ट';

  @override
  String get noAudioFound => 'इस डिवाइस पर कोई ऑडियो नहीं मिला';

  @override
  String get searchAudio => 'ऑडियो खोजें';

  @override
  String get unknownArtist => '<अज्ञात>';

  @override
  String songCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count गाने',
      one: '1 गाना',
    );
    return '$_temp0';
  }

  @override
  String get audioPlaylistHint => 'प्लेलिस्ट भविष्य के अपडेट में उपलब्ध होंगी।';

  @override
  String get backgroundPlaybackTitle =>
      'निरंतर पृष्ठभूमि प्लेबैक की अनुमति दें';

  @override
  String get backgroundPlaybackBody =>
      'सिस्टम द्वारा प्लेबैक रोकने से बचने के लिए, कृपया आवश्यक अनुमति दें।';

  @override
  String get queue => 'कतार';

  @override
  String get shuffleAll => 'सभी शफ़ल करें';

  @override
  String get castSelectDevice => 'Cast to device';

  @override
  String get castSearching => 'Looking for Cast devices…';

  @override
  String get castWifiHint => 'Phone and TV must be on the same Wi‑Fi network.';

  @override
  String get castDisconnect => 'Disconnect';

  @override
  String get castDisconnected => 'Disconnected from Cast';

  @override
  String castConnectedTo(String device) {
    return 'Connected to $device';
  }

  @override
  String castPlayingOn(String device) {
    return 'Playing on $device';
  }

  @override
  String get castFailed => 'Could not cast this video. Try again.';

  @override
  String get castUnsupportedPlatform =>
      'Cast is not available on this platform.';

  @override
  String get castUnsupportedContentUri =>
      'Cast is not supported for videos opened from other apps.';

  @override
  String get castLocalWifiRequired =>
      'Connect to Wi‑Fi to cast local videos from this phone.';

  @override
  String get castPlayVideoToCast =>
      'Open a video and tap Cast to play it on your TV.';
}
