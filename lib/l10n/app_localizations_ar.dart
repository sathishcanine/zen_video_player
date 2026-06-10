// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Zen Player';

  @override
  String get appNameFull => 'Zen مشغل الفيديو';

  @override
  String get accessYourMedia => 'الوصول إلى الوسائط';

  @override
  String mediaAccessDescription(String appName) {
    return 'يحتاج $appName إلى الوصول إلى ملفات الوسائط للعثور على مقاطع الفيديو والموسيقى وتشغيلها على جهازك.';
  }

  @override
  String get featurePlayLocal => 'تشغيل الفيديو والصوت المحلي';

  @override
  String get featureBrowseFiles => 'تصفح الملفات بسهولة';

  @override
  String get featureLockPrivate => 'قفل المجلدات الخاصة';

  @override
  String get allowAccess => 'السماح بالوصول';

  @override
  String get allFilesAccessRequired =>
      'Please allow access to videos and music to browse your library. You can change this anytime in Settings.';

  @override
  String get notNow => 'ليس الآن';

  @override
  String get permissionRequired =>
      'يلزم الوصول إلى الوسائط لتصفح المكتبة. يمكنك السماح في الإعدادات.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get tabVideo => 'فيديو';

  @override
  String get tabAudio => 'صوت';

  @override
  String get tabSettings => 'إعدادات';

  @override
  String get pillPlaylist => 'قائمة التشغيل';

  @override
  String get pillMediaServer => 'خادم الوسائط';

  @override
  String get pillNetworkStream => 'بث الشبكة';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get audioTabHint => 'تصفح الصوت سيكون متاحاً في تحديث لاحق.';

  @override
  String get settingsTabHint => 'الإعدادات ستكون متاحة في تحديث لاحق.';

  @override
  String get folderRecentlyAdded => 'أُضيف مؤخراً';

  @override
  String videoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فيديو',
      one: 'فيديو واحد',
    );
    return '$_temp0';
  }

  @override
  String folderSizeSummary(String count, String size) {
    return '$count • $size';
  }

  @override
  String get badgeNew => 'جديد';

  @override
  String get noVideosFound => 'لم يتم العثور على فيديوهات على هذا الجهاز';

  @override
  String get grantAccessToBrowse => 'اسمح بالوصول إلى الوسائط لتصفح المجلدات.';

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
  String get pickVideoFile => 'اختر ملف فيديو';

  @override
  String get playFromUrl => 'تشغيل من رابط';

  @override
  String get pasteVideoUrl => 'الصق رابط الفيديو هنا';

  @override
  String get playVideo => 'تشغيل';

  @override
  String get searchFolders => 'بحث في المجلدات';

  @override
  String get clearSearch => 'مسح';

  @override
  String searchResultsFor(String query) {
    return 'نتائج \"$query\"';
  }

  @override
  String get cast => 'بث';

  @override
  String get moreOptions => 'المزيد';

  @override
  String get loadingLibrary => 'جاري تحميل المكتبة…';

  @override
  String get calculatingSize => 'جاري الحساب…';

  @override
  String videosInFolder(String folder) {
    return 'فيديوهات في $folder';
  }

  @override
  String get permissionWhyTitle => 'لماذا يحتاج التطبيق إلى إذن';

  @override
  String permissionWhyBody1(String appName) {
    return 'يحتاج $appName إلى الوصول إلى مقاطع الفيديو والأغاني والترجمات على جهازك ليعمل بشكل صحيح.';
  }

  @override
  String get permissionWhyBody2 =>
      'يُستخدم الوصول إلى الملفات لاكتشاف الوسائط وتشغيلها على هاتفك. بعد السماح، ستظهر مجلدات الفيديو في التطبيق.';

  @override
  String permissionWhyPrivacy(String appName) {
    return 'يعد $appName بعدم استخدام هذه الأذونات للوصول إلى بياناتك الخاصة.';
  }

  @override
  String get permissionWhyMoreInfo => 'لمزيد من المعلومات';

  @override
  String get permissionWhySupportUrl =>
      'https://support.google.com/googleplay/android-developer/answer/10467955';

  @override
  String get ok => 'موافق';

  @override
  String get skip => 'تخطي';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get onboardingTitle1 => 'مشغل وسائط شامل';

  @override
  String get onboardingPictureModes => 'أوضاع الصورة';

  @override
  String get pictureModeStandard => 'قياسي';

  @override
  String get pictureModeVivid => 'حيوي';

  @override
  String get pictureModeGame => 'لعبة';

  @override
  String get pictureModeMovie => 'فيلم';

  @override
  String get pictureModeCozy => 'مريح';

  @override
  String get pictureModeDynamic => 'ديناميكي';

  @override
  String get onboardingSubtitle1 =>
      'مشغل فيديو HDR يتعامل مع جميع الملفات. مشغل موسيقى قوي لمكتبتك بالكامل.';

  @override
  String get onboardingTitle2 => 'تجربة صوت مميزة';

  @override
  String get onboardingSubtitle2 =>
      'معادل صوت واضح مع باس حقيقي. مُصوّرات موسيقية أنيقة.';

  @override
  String get onboardingTitle3 => 'مُصوّرات مذهلة';

  @override
  String get onboardingSubtitle3 => 'معادل صوت واضح. باس عميق. مُصوّرات أنيقة.';

  @override
  String get onboardingTitle4 => 'ميزات متقدمة';

  @override
  String get onboardingSubtitle4 =>
      'تنزيل ترجمات لأي فيديو. مجلد آمن لخصوصيتك.';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get moreLanguages => 'More languages';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageTamil => 'التاميلية';

  @override
  String get languageHindi => 'الهندية';

  @override
  String get languageTelugu => 'التيلوجو';

  @override
  String get languageSpanishPicker => 'الإسبانية (Español)';

  @override
  String get languageArabicPicker => 'العربية (العربية)';

  @override
  String get languageFrenchPicker => 'الفرنسية (Français)';

  @override
  String get languageBengaliPicker => 'البنغالية (বাংলা)';

  @override
  String get languagePortuguesePicker => 'البرتغالية (Português)';

  @override
  String get languageRussianPicker => 'الروسية (Русский)';

  @override
  String get languageUrduPicker => 'الأردية (اردو)';

  @override
  String get languageMandarinPicker => 'الصينية (中文)';

  @override
  String get languageTamilPicker => 'Tamil (தமிழ்)';

  @override
  String get languageHindiPicker => 'Hindi (हिन्दी)';

  @override
  String get languageTeluguPicker => 'Telugu (తెలుగు)';

  @override
  String get languageTutorialTitle => 'اختر لغتك';

  @override
  String get languageTutorialBody =>
      'اضغط زر اللغة لتغيير لغة التطبيق في أي وقت.';

  @override
  String get gotIt => 'حسناً';

  @override
  String get colorTutorialTitle => 'Color filters';

  @override
  String get colorTutorialBody =>
      'Choose a look for your video — tap a preset or open Custom to adjust contrast, brightness, and more.';

  @override
  String get audioSubAlbum => 'الألبوم';

  @override
  String get audioSubSongs => 'الأغاني';

  @override
  String get audioSubArtist => 'الفنان';

  @override
  String get audioSubFolder => 'المجلد';

  @override
  String get audioSubPlaylist => 'قائمة';

  @override
  String get noAudioFound => 'لم يتم العثور على صوت على هذا الجهاز';

  @override
  String get searchAudio => 'بحث الصوت';

  @override
  String get unknownArtist => '<غير معروف>';

  @override
  String songCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أغاني',
      one: 'أغنية واحدة',
    );
    return '$_temp0';
  }

  @override
  String get audioPlaylistHint => 'قوائم التشغيل ستكون متاحة في تحديث لاحق.';

  @override
  String get backgroundPlaybackTitle => 'السماح بالتشغيل المستمر في الخلفية';

  @override
  String get backgroundPlaybackBody =>
      'لمنع النظام من إيقاف التشغيل، يرجى منح الإذن اللازم.';

  @override
  String get queue => 'قائمة الانتظار';

  @override
  String get shuffleAll => 'خلط الكل';

  @override
  String get equalizerTitle => 'Equalizer';

  @override
  String get eqZenPlayer => 'Zen Player';

  @override
  String get eqAudioSpectrum => 'Audio Spectrum';

  @override
  String get eqEnabled => 'Enable equalizer';

  @override
  String get eqReset => 'Reset';

  @override
  String get eqApply => 'Apply';

  @override
  String get eqApplied => 'Applied';

  @override
  String get eqOff => 'EQ Off';

  @override
  String get eqBassBoost => 'Bass Boost';

  @override
  String get eqPresets => 'Presets';

  @override
  String get eq3dSurround => '3D Surround';

  @override
  String get eqLoudness => 'Loudness';

  @override
  String get eqUnsupported =>
      'System equalizer is available on Android. Presets are saved for when you use an Android device.';

  @override
  String get eqPresetNormal => 'Flat';

  @override
  String get eqPresetRock => 'Rock';

  @override
  String get eqPresetPop => 'Pop';

  @override
  String get eqPresetJazz => 'Jazz';

  @override
  String get eqPresetClassical => 'Classical';

  @override
  String get eqPresetBass => 'Bass';

  @override
  String get eqPresetBassTreble => 'Bass+Treble';

  @override
  String get eqPresetTreble => 'Treble';

  @override
  String get eqPresetVocal => 'Vocal';

  @override
  String get eqPresetHipHop => 'Hip-Hop';

  @override
  String get eqPresetElectronic => 'Electronic';

  @override
  String get eqPresetNightMode => 'Night Mode';

  @override
  String get eqPresetCustom => 'Custom';

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
  String get playlistAddVideos => 'Add videos';

  @override
  String get playlistEmptyTitle => 'This playlist is empty';

  @override
  String get playlistEmptySubtitle =>
      'Add videos from your device to get started';

  @override
  String playlistAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count videos',
      one: '1 video',
    );
    return 'Add $_temp0';
  }

  @override
  String playlistVideosAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count videos added',
      one: '1 video added',
    );
    return '$_temp0';
  }

  @override
  String get playlistAlreadyAdded => 'Added';

  @override
  String get playlistAddSongs => 'Add songs';

  @override
  String get playlistEmptyAudioSubtitle =>
      'Add songs from your device to get started';

  @override
  String playlistAddSongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs',
      one: '1 song',
    );
    return 'Add $_temp0';
  }

  @override
  String playlistSongsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs added',
      one: '1 song added',
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

  @override
  String get playStoreRatingTitle => 'Help us to Grow';

  @override
  String get playStoreRatingBody =>
      'A quick rating on Google Play helps us grow and keep Zen free for everyone.';

  @override
  String get playStoreRatingRateNow => 'Rate now';

  @override
  String get playStoreRatingMaybe => 'Maybe';
}
