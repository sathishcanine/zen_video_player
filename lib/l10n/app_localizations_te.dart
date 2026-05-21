// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appName => 'Zen';

  @override
  String get appNameFull => 'Zen వీడియో ప్లేయర్';

  @override
  String get accessYourMedia => 'మీ మీడియాను యాక్సెస్ చేయండి';

  @override
  String mediaAccessDescription(String appName) {
    return 'మీ పరికరంలో వీడియోలు మరియు సంగీతాన్ని కనుగొని ప్లే చేయడానికి $appName కు మీడియా యాక్సెస్ అవసరం.';
  }

  @override
  String get featurePlayLocal => 'లోకల్ వీడియో & ఆడియో ప్లే';

  @override
  String get featureBrowseFiles => 'ఫైళ్లను సులభంగా బ్రౌజ్ చేయండి';

  @override
  String get featureLockPrivate => 'ప్రైవేట్ ఫోల్డర్లను లాక్ చేయండి';

  @override
  String get allowAccess => 'యాక్సెస్ అనుమతించు';

  @override
  String get notNow => 'ఇప్పుడు కాదు';

  @override
  String get permissionRequired =>
      'లైబ్రరీ బ్రౌజ్ చేయడానికి మీడియా యాక్సెస్ అవసరం. సెట్టింగ్‌లలో అనుమతించవచ్చు.';

  @override
  String get openSettings => 'సెట్టింగ్‌లు తెరువు';

  @override
  String get tabVideo => 'వీడియో';

  @override
  String get tabAudio => 'ఆడియో';

  @override
  String get tabSettings => 'సెట్టింగ్‌లు';

  @override
  String get pillPlaylist => 'ప్లేలిస్ట్';

  @override
  String get pillMediaServer => 'మీడియా సర్వర్';

  @override
  String get pillNetworkStream => 'నెట్‌వర్క్ స్ట్రీమ్';

  @override
  String get comingSoon => 'త్వరలో';

  @override
  String get audioTabHint => 'ఆడియో బ్రౌజింగ్ తదుపరి అప్‌డేట్‌లో వస్తుంది.';

  @override
  String get settingsTabHint => 'సెట్టింగ్‌లు తదుపరి అప్‌డేట్‌లో వస్తాయి.';

  @override
  String get folderRecentlyAdded => 'ఇటీవల జోడించినవి';

  @override
  String videoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count వీడియోలు',
      one: '1 వీడియో',
    );
    return '$_temp0';
  }

  @override
  String folderSizeSummary(String count, String size) {
    return '$count • $size';
  }

  @override
  String get badgeNew => 'కొత్త';

  @override
  String get noVideosFound => 'ఈ పరికరంలో వీడియోలు లేవు';

  @override
  String get grantAccessToBrowse =>
      'ఫోల్డర్లను బ్రౌజ్ చేయడానికి మీడియా యాక్సెస్ అనుమతించండి.';

  @override
  String get pickVideoFile => 'వీడియో ఫైల్ ఎంచుకోండి';

  @override
  String get playFromUrl => 'URL నుండి ప్లే';

  @override
  String get pasteVideoUrl => 'వీడియో URL ఇక్కడ అతకండి';

  @override
  String get playVideo => 'వీడియో ప్లే';

  @override
  String get searchFolders => 'ఫోల్డర్లు వెతకండి';

  @override
  String get clearSearch => 'తొలగించు';

  @override
  String searchResultsFor(String query) {
    return '\"$query\" ఫలితాలు';
  }

  @override
  String get cast => 'కాస్ట్';

  @override
  String get moreOptions => 'మరిన్ని';

  @override
  String get loadingLibrary => 'లైబ్రరీ లోడ్ అవుతోంది…';

  @override
  String get calculatingSize => 'లెక్కిస్తోంది…';

  @override
  String videosInFolder(String folder) {
    return '$folder లో వీడియోలు';
  }

  @override
  String get permissionWhyTitle => 'అనుమతి ఎందుకు అవసరం';

  @override
  String permissionWhyBody1(String appName) {
    return 'సరిగ్గా పని చేయడానికి $appName కు వీడియోలు, పాటలు, సబ్‌టైటిల్స్ యాక్సెస్ అవసరం.';
  }

  @override
  String get permissionWhyBody2 =>
      'మీ ఫోన్‌లో మీడియాను కనుగొని ప్లే చేయడానికి ఫైల్ యాక్సెస్ ఉపయోగించబడుతుంది.';

  @override
  String permissionWhyPrivacy(String appName) {
    return '$appName మీ ప్రైవేట్ డేటాను యాక్సెస్ చేయదని హామీ ఇస్తుంది.';
  }

  @override
  String get permissionWhyMoreInfo => 'మరింత సమాచారం';

  @override
  String get permissionWhySupportUrl =>
      'https://support.google.com/googleplay/android-developer/answer/10467955';

  @override
  String get ok => 'సరే';

  @override
  String get skip => 'దాటవేయి';

  @override
  String get next => 'తదుపరి';

  @override
  String get getStarted => 'ప్రారంభించు';

  @override
  String get onboardingTitle1 => 'ఆల్-ఇన్-వన్ మీడియా ప్లేయర్';

  @override
  String get onboardingPictureModes => 'పిక్చర్ మోడ్స్';

  @override
  String get pictureModeStandard => 'స్టాండర్డ్';

  @override
  String get pictureModeVivid => 'వివిడ్';

  @override
  String get pictureModeGame => 'గేమ్';

  @override
  String get pictureModeMovie => 'మూవీ';

  @override
  String get pictureModeCozy => 'కోజీ';

  @override
  String get pictureModeDynamic => 'డైనమిక్';

  @override
  String get onboardingSubtitle1 =>
      'HDR వీడియో ప్లేయర్ అన్ని ఫైళ్లను నిర్వహిస్తుంది. మీ మొత్తం లైబ్రరీకి శక్తివంతమైన మ్యూజిక్ ప్లేయర్.';

  @override
  String get onboardingTitle2 => 'ప్రీమియం ఆడియో అనుభవం';

  @override
  String get onboardingSubtitle2 =>
      'స్పష్టమైన ఈక్వలైజర్ నిజమైన బాస్. అందమైన మ్యూజిక్ విజువలైజర్లు.';

  @override
  String get onboardingTitle3 => 'అద్భుత విజువలైజర్లు';

  @override
  String get onboardingSubtitle3 =>
      'క్రిస్టల్-క్లియర్ ఈక్వలైజర్. లోతైన బాస్. అందమైన విజువలైజర్లు.';

  @override
  String get onboardingTitle4 => 'అధునాతన ఫీచర్లు';

  @override
  String get onboardingSubtitle4 =>
      'ఏ వీడియోకైనా సబ్‌టైటిల్స్ డౌన్‌లోడ్. ప్రైవసీ కోసం సురక్షిత ఫోల్డర్.';

  @override
  String get chooseLanguage => 'భాష ఎంచుకోండి';

  @override
  String get languageEnglish => 'ఆంగ్లం';

  @override
  String get languageTamil => 'తమిళం';

  @override
  String get languageHindi => 'హిందీ';

  @override
  String get languageTelugu => 'తెలుగు';

  @override
  String get languageTamilPicker => 'Tamil (தமிழ்)';

  @override
  String get languageHindiPicker => 'Hindi (हिन्दी)';

  @override
  String get languageTeluguPicker => 'Telugu (తెలుగు)';

  @override
  String get languageTutorialTitle => 'మీ భాష ఎంచుకోండి';

  @override
  String get languageTutorialBody =>
      'తమిళం, ఆంగ్లం, హిందీ, తెలుగు మార్చడానికి ఇక్కడ భాష బటన్‌ను నొక్కండి.';

  @override
  String get gotIt => 'అర్థమైంది';

  @override
  String get audioSubAlbum => 'ఆల్బమ్';

  @override
  String get audioSubSongs => 'పాటలు';

  @override
  String get audioSubArtist => 'కళాకారుడు';

  @override
  String get audioSubFolder => 'ఫోల్డర్';

  @override
  String get audioSubPlaylist => 'ప్లేలిస్ట్';

  @override
  String get noAudioFound => 'ఈ పరికరంలో ఆడియో లేదు';

  @override
  String get searchAudio => 'ఆడియో వెతకండి';

  @override
  String get unknownArtist => '<తెలియదు>';

  @override
  String songCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count పాటలు',
      one: '1 పాట',
    );
    return '$_temp0';
  }

  @override
  String get audioPlaylistHint => 'ప్లేలిస్ట్‌లు తదుపరి అప్‌డేట్‌లో వస్తాయి.';

  @override
  String get backgroundPlaybackTitle =>
      'నిరంతర నేపథ్య ప్లేబ్యాక్‌ను అనుమతించండి';

  @override
  String get backgroundPlaybackBody =>
      'సిస్టమ్ ప్లేబ్యాక్‌ను ఆపకుండా ఉండడానికి, అవసరమైన అనుమతిని ఇవ్వండి.';

  @override
  String get queue => 'క్యూయు';

  @override
  String get shuffleAll => 'అన్నీ షఫుల్ చేయి';

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
