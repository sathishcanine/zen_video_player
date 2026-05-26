// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appName => 'Zen Player';

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
  String get allFilesAccessRequired =>
      'Please allow access to videos and music to browse your library. You can change this anytime in Settings.';

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
  String get limitedVideoAccessTitle => 'Allow access to all videos';

  @override
  String get limitedVideoAccessBody =>
      'You allowed only selected videos. Zen needs access to all videos on your device to show folders like Camera and Downloads. Tap below, then choose Allow all on the system screen.';

  @override
  String get allowAllVideos => 'Allow all videos';

  @override
  String get limitedAudioAccessTitle => 'Allow access to all music';

  @override
  String get limitedAudioAccessBody =>
      'You allowed only selected music. Tap below, then choose Allow all on the system screen to browse your full library.';

  @override
  String get allowAllMusic => 'Allow all music';

  @override
  String get limitedAccessPreviewHint =>
      'Folders on your device — allow all videos to open and play them.';

  @override
  String get limitedPartialLibraryHint =>
      'You only allowed selected videos, so Zen can show a few folders. Allow all videos to browse Downloads and your full library.';

  @override
  String get limitedPartialFolderNote => 'allow all to browse';

  @override
  String get limitedAccessAlternatives => 'Or play without full library access';

  @override
  String get lockedFolderUnlock => 'Allow all videos to view';

  @override
  String get limitedAccessSettingsSnackbar =>
      'In Settings, open Videos (or Photos and videos) and choose Allow all — not Select photos.';

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
  String get moreLanguages => 'More languages';

  @override
  String get languageEnglish => 'ఆంగ్లం';

  @override
  String get languageTamil => 'తమిళం';

  @override
  String get languageHindi => 'హిందీ';

  @override
  String get languageTelugu => 'తెలుగు';

  @override
  String get languageSpanishPicker => 'స్పానిష్ (Español)';

  @override
  String get languageArabicPicker => 'అరబిక్ (العربية)';

  @override
  String get languageFrenchPicker => 'ఫ్రెంచ్ (Français)';

  @override
  String get languageBengaliPicker => 'బెంగాలీ (বাংলা)';

  @override
  String get languagePortuguesePicker => 'పోర్చుగీస్ (Português)';

  @override
  String get languageRussianPicker => 'రష్యన్ (Русский)';

  @override
  String get languageUrduPicker => 'ఉర్దూ (اردو)';

  @override
  String get languageMandarinPicker => 'చైనీస్ (中文)';

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
      'ఎప్పుడైనా యాప్ భాష మార్చడానికి భాష బటన్‌ను నొక్కండి.';

  @override
  String get gotIt => 'అర్థమైంది';

  @override
  String get colorTutorialTitle => 'Color filters';

  @override
  String get colorTutorialBody =>
      'Choose a look for your video — tap a preset or open Custom to adjust contrast, brightness, and more.';

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

  @override
  String get settingsNetworkStream => 'Network stream';

  @override
  String get settingsNetworkStreamSubtitle => 'Play media from network URL';

  @override
  String get settingsFindDuplicate => 'Find duplicate';

  @override
  String get settingsFindDuplicateSubtitle =>
      'Find duplicate audio or video files';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsDarkTheme => 'Dark theme';

  @override
  String get settingsDarkThemeSubtitle =>
      'Switch between light and dark appearance';

  @override
  String get settingsPrimaryColor => 'Primary color';

  @override
  String get settingsPrimaryColorSubtitle => 'Choose your accent color';

  @override
  String get settingsVersion => 'Version';

  @override
  String get duplicateChooseTitle => 'Choose';

  @override
  String get duplicateChooseCancel => 'CANCEL';

  @override
  String get duplicateScanning => 'Scanning storage';

  @override
  String get duplicateScanFailed => 'Scan failed. Please try again.';

  @override
  String get duplicateResultsTitle => 'Duplicates';

  @override
  String get duplicateNoneFound => 'No duplicate files found.';

  @override
  String duplicateGroupTitle(int count, String name) {
    return '$count copies · $name';
  }

  @override
  String get duplicateKeep => 'Keep';

  @override
  String get duplicateDeleteTitle => 'Delete file?';

  @override
  String duplicateDeleteBody(String name) {
    return 'Remove \"$name\" from this device? This cannot be undone.';
  }

  @override
  String get duplicateDeleteConfirm => 'Delete';

  @override
  String get duplicateDeleteAll => 'Delete all';

  @override
  String get duplicateDeleteAllTitle => 'Delete all duplicates?';

  @override
  String duplicateDeleteAllBody(int count) {
    return 'Remove $count duplicate files? The oldest copy in each group is kept.';
  }

  @override
  String duplicateDeleted(int count) {
    return 'Deleted $count file(s)';
  }

  @override
  String get duplicateDeleteFailed =>
      'Could not delete. Check permissions and try again.';

  @override
  String get optionPlay => 'Play';

  @override
  String get optionDelete => 'Delete';

  @override
  String get optionSend => 'Send';

  @override
  String get optionRename => 'Rename';

  @override
  String get optionAddToPlaylist => 'Add to playlist';

  @override
  String get optionHideFromList => 'Hide from list';

  @override
  String get optionDetails => 'Details';

  @override
  String get optionRemoveFromPlaylist => 'Remove from playlist';

  @override
  String get createPlaylist => 'Create Playlist';

  @override
  String get playlistNameHint => 'Playlist name';

  @override
  String get playlistEmpty => 'No playlists yet. Tap + Create Playlist.';

  @override
  String playlistVideoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Videos',
      one: '1 Video',
    );
    return '$_temp0';
  }

  @override
  String get renamePlaylist => 'Rename playlist';

  @override
  String get deletePlaylistTitle => 'Delete playlist?';

  @override
  String deletePlaylistBody(String name) {
    return 'Remove \"$name\"? Videos on your device are not deleted.';
  }

  @override
  String get deleteFolderTitle => 'Delete all videos?';

  @override
  String deleteFolderBody(int count, String name) {
    return 'Remove all $count videos in \"$name\" from this device? This cannot be undone.';
  }

  @override
  String get hideFolderTitle => 'Hide folder?';

  @override
  String hideFolderBody(String name) {
    return '\"$name\" will be hidden from the video list. You can restore it later in settings.';
  }

  @override
  String get renameNotSupported =>
      'Renaming device folders and videos is not supported.';

  @override
  String get shareFailed => 'Could not share files.';

  @override
  String get sharePreparing => 'Preparing files to share…';

  @override
  String addedToPlaylist(String name) {
    return 'Added to $name';
  }

  @override
  String get detailsTitle => 'Details';

  @override
  String get detailsName => 'Name';

  @override
  String get detailsPath => 'Path';

  @override
  String get detailsSize => 'Size';

  @override
  String get detailsDuration => 'Duration';

  @override
  String get detailsResolution => 'Resolution';

  @override
  String get detailsDate => 'Date added';

  @override
  String get detailsCount => 'Items';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get hide => 'Hide';

  @override
  String get proBadge => 'FREE PRO';

  @override
  String proUnlockTitleFeature(String feature) {
    return 'Unlock $feature';
  }

  @override
  String proUnlockBodyFeature(String feature) {
    return 'Watch one short ad to unlock $feature on this device.';
  }

  @override
  String get proUnlockWatchAd => 'Watch ad & unlock';

  @override
  String get proUnlockNotNow => 'Not now';

  @override
  String proUnlockSuccess(String feature) {
    return '$feature unlocked!';
  }

  @override
  String get proUnlockAdFailed =>
      'Ad not available. Please try again in a moment.';
}
