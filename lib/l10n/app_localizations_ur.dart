// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appName => 'Zen Player';

  @override
  String get appNameFull => 'Zen Video Player';

  @override
  String get accessYourMedia => 'Access Your Media';

  @override
  String mediaAccessDescription(String appName) {
    return '$appName needs access to your media files to find and play videos and music stored on your device.';
  }

  @override
  String get featurePlayLocal => 'Play local videos & audio';

  @override
  String get featureBrowseFiles => 'Browse files easily';

  @override
  String get featureLockPrivate => 'Lock private folders';

  @override
  String get allowAccess => 'Allow Access';

  @override
  String get allFilesAccessRequired =>
      'Please allow access to videos and music to browse your library. You can change this anytime in Settings.';

  @override
  String get notNow => 'Not now';

  @override
  String get permissionRequired =>
      'Media access is required to browse your library. You can allow access in Settings.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get tabVideo => 'Video';

  @override
  String get tabAudio => 'Audio';

  @override
  String get tabSettings => 'Settings';

  @override
  String get pillPlaylist => 'PLAYLIST';

  @override
  String get pillMediaServer => 'MEDIA SERVER';

  @override
  String get pillNetworkStream => 'NETWORK STREAM';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get audioTabHint =>
      'Audio browsing will be available in a future update.';

  @override
  String get settingsTabHint =>
      'Settings will be available in a future update.';

  @override
  String get folderRecentlyAdded => 'Recently added';

  @override
  String videoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count videos',
      one: '1 video',
    );
    return '$_temp0';
  }

  @override
  String folderSizeSummary(String count, String size) {
    return '$count • $size';
  }

  @override
  String get badgeNew => 'NEW';

  @override
  String get noVideosFound => 'No videos found on this device';

  @override
  String get grantAccessToBrowse =>
      'Allow media access to browse folders on your device.';

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
  String get pickVideoFile => 'Pick a video file';

  @override
  String get playFromUrl => 'Play from URL';

  @override
  String get pasteVideoUrl => 'Paste video URL here';

  @override
  String get playVideo => 'Play Video';

  @override
  String get searchFolders => 'Search folders';

  @override
  String get clearSearch => 'Clear';

  @override
  String searchResultsFor(String query) {
    return 'Results for \"$query\"';
  }

  @override
  String get cast => 'Cast';

  @override
  String get moreOptions => 'More';

  @override
  String get loadingLibrary => 'Loading your library…';

  @override
  String get calculatingSize => 'Calculating…';

  @override
  String videosInFolder(String folder) {
    return 'Videos in $folder';
  }

  @override
  String get permissionWhyTitle => 'Why the app needs permission';

  @override
  String permissionWhyBody1(String appName) {
    return '$appName needs access to videos, songs, and subtitles on your device to function properly.';
  }

  @override
  String get permissionWhyBody2 =>
      'File access is used so you can discover and play media stored on your phone. After you allow access, you will see folders with your videos in the app.';

  @override
  String permissionWhyPrivacy(String appName) {
    return '$appName promises that it will not use these permissions to access your private data.';
  }

  @override
  String get permissionWhyMoreInfo => 'For more information';

  @override
  String get permissionWhySupportUrl =>
      'https://support.google.com/googleplay/android-developer/answer/10467955';

  @override
  String get ok => 'OK';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get onboardingTitle1 => 'All-in-One Media Player';

  @override
  String get onboardingPictureModes => 'Picture Modes';

  @override
  String get pictureModeStandard => 'Standard';

  @override
  String get pictureModeVivid => 'Vivid';

  @override
  String get pictureModeGame => 'Game';

  @override
  String get pictureModeMovie => 'Movie';

  @override
  String get pictureModeCozy => 'Cozy';

  @override
  String get pictureModeDynamic => 'Dynamic';

  @override
  String get onboardingSubtitle1 =>
      'HDR video player handles all files. Powerful music player for your entire library.';

  @override
  String get onboardingTitle2 => 'Premium Audio Experience';

  @override
  String get onboardingSubtitle2 =>
      'Crystal clear equalizer with true bass. Elegant music visualizers.';

  @override
  String get onboardingTitle3 => 'Stunning Visualizers';

  @override
  String get onboardingSubtitle3 =>
      'Crystal-clear equalizer. Deep bass. Elegant visualizers.';

  @override
  String get onboardingTitle4 => 'Advanced Features';

  @override
  String get onboardingSubtitle4 =>
      'Download subtitles for any video. Secure folder locker for privacy.';

  @override
  String get chooseLanguage => 'زبان منتخب کریں';

  @override
  String get moreLanguages => 'More languages';

  @override
  String get languageEnglish => 'انگریزی';

  @override
  String get languageTamil => 'Tamil';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageTelugu => 'Telugu';

  @override
  String get languageSpanishPicker => 'ہسپانوی (Español)';

  @override
  String get languageArabicPicker => 'عربی (العربية)';

  @override
  String get languageFrenchPicker => 'فرانسیسی (Français)';

  @override
  String get languageBengaliPicker => 'بنگالی (বাংলা)';

  @override
  String get languagePortuguesePicker => 'پرتگالی (Português)';

  @override
  String get languageRussianPicker => 'روسی (Русский)';

  @override
  String get languageUrduPicker => 'اردو (اردو)';

  @override
  String get languageMandarinPicker => 'چینی (中文)';

  @override
  String get languageTamilPicker => 'تامل (தமிழ்)';

  @override
  String get languageHindiPicker => 'ہندی (हिन्दी)';

  @override
  String get languageTeluguPicker => 'تیلگو (తెలుగు)';

  @override
  String get languageTutorialTitle => 'اپنی زبان منتخب کریں';

  @override
  String get languageTutorialBody =>
      'کسی بھی وقت ایپ کی زبان بدلنے کے لیے زبان کے بٹن پر ٹیپ کریں۔';

  @override
  String get gotIt => 'سمجھ گیا';

  @override
  String get colorTutorialTitle => 'Color filters';

  @override
  String get colorTutorialBody =>
      'Choose a look for your video — tap a preset or open Custom to adjust contrast, brightness, and more.';

  @override
  String get audioSubAlbum => 'ALBUM';

  @override
  String get audioSubSongs => 'SONGS';

  @override
  String get audioSubArtist => 'ARTIST';

  @override
  String get audioSubFolder => 'FOLDER';

  @override
  String get audioSubPlaylist => 'PLAYLIST';

  @override
  String get noAudioFound => 'No audio found on this device';

  @override
  String get searchAudio => 'Search audio';

  @override
  String get unknownArtist => '<unknown>';

  @override
  String songCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs',
      one: '1 song',
    );
    return '$_temp0';
  }

  @override
  String get audioPlaylistHint =>
      'Create and manage playlists in a future update.';

  @override
  String get backgroundPlaybackTitle => 'Allow continuous background playback';

  @override
  String get backgroundPlaybackBody =>
      'To prevent playback from being stopped by the system, please give the necessary permission.';

  @override
  String get queue => 'Queue';

  @override
  String get shuffleAll => 'SHUFFLE ALL';

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
