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
  String get allFilesAccessRequired =>
      'Please allow access to videos and music to browse your library. You can change this anytime in Settings.';

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
  String get moreLanguages => 'More languages';

  @override
  String get languageEnglish => 'अंग्रेज़ी';

  @override
  String get languageTamil => 'तमिल';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageTelugu => 'तेलुगु';

  @override
  String get languageSpanishPicker => 'स्पेनिश (Español)';

  @override
  String get languageArabicPicker => 'अरबी (العربية)';

  @override
  String get languageFrenchPicker => 'फ़्रेंच (Français)';

  @override
  String get languageBengaliPicker => 'बंगाली (বাংলা)';

  @override
  String get languagePortuguesePicker => 'पुर्तगाली (Português)';

  @override
  String get languageRussianPicker => 'रूसी (Русский)';

  @override
  String get languageUrduPicker => 'उर्दू (اردو)';

  @override
  String get languageMandarinPicker => 'चीनी (中文)';

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
      'किसी भी समय ऐप की भाषा बदलने के लिए भाषा बटन पर टैप करें।';

  @override
  String get gotIt => 'समझ गया';

  @override
  String get colorTutorialTitle => 'Color filters';

  @override
  String get colorTutorialBody =>
      'Choose a look for your video — tap a preset or open Custom to adjust contrast, brightness, and more.';

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
