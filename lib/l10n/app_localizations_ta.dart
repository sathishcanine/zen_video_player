// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'Zen Player';

  @override
  String get appNameFull => 'Zen வீடியோ பிளேயர்';

  @override
  String get accessYourMedia => 'உங்கள் மீடியாவை அணுகுங்கள்';

  @override
  String mediaAccessDescription(String appName) {
    return 'உங்கள் சாதனத்தில் உள்ள வீடியோ மற்றும் இசையை கண்டறிந்து இயக்க $appName க்கு மீடியா அணுகல் தேவை.';
  }

  @override
  String get featurePlayLocal => 'உள்ளூர் வீடியோ & ஆடியோ இயக்கு';

  @override
  String get featureBrowseFiles => 'கோப்புகளை எளிதாக உலாவு';

  @override
  String get featureLockPrivate => 'தனிப்பட்ட கோப்புறைகளை பூட்டு';

  @override
  String get allowAccess => 'அணுகலை அனுமதி';

  @override
  String get allFilesAccessRequired =>
      'Please allow access to videos and music to browse your library. You can change this anytime in Settings.';

  @override
  String get notNow => 'இப்போது வேண்டாம்';

  @override
  String get permissionRequired =>
      'நூலகத்தை உலாவ மீடியா அணுகல் தேவை. அமைப்புகளில் அனுமதிக்கலாம்.';

  @override
  String get openSettings => 'அமைப்புகளை திற';

  @override
  String get tabVideo => 'வீடியோ';

  @override
  String get tabAudio => 'ஆடியோ';

  @override
  String get tabSettings => 'அமைப்புகள்';

  @override
  String get pillPlaylist => 'பிளேலிஸ்ட்';

  @override
  String get pillMediaServer => 'மீடியா சர்வர்';

  @override
  String get pillNetworkStream => 'நெட்வொர்க் ஸ்ட்ரீம்';

  @override
  String get comingSoon => 'விரைவில்';

  @override
  String get audioTabHint => 'ஆடியோ உலாவல் வரும் புதுப்பிப்பில் கிடைக்கும்.';

  @override
  String get settingsTabHint => 'அமைப்புகள் வரும் புதுப்பிப்பில் கிடைக்கும்.';

  @override
  String get folderRecentlyAdded => 'சமீபத்தில் சேர்க்கப்பட்டது';

  @override
  String videoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count வீடியோக்கள்',
      one: '1 வீடியோ',
    );
    return '$_temp0';
  }

  @override
  String folderSizeSummary(String count, String size) {
    return '$count • $size';
  }

  @override
  String get badgeNew => 'புதிய';

  @override
  String get noVideosFound => 'இந்த சாதனத்தில் வீடியோ இல்லை';

  @override
  String get grantAccessToBrowse =>
      'கோப்புறைகளை உலாவ மீடியா அணுகலை அனுமதிக்கவும்.';

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
  String get pickVideoFile => 'வீடியோ கோப்பை தேர்வு';

  @override
  String get playFromUrl => 'URL இலிருந்து இயக்கு';

  @override
  String get pasteVideoUrl => 'வீடியோ URL ஐ இங்கே ஒட்டு';

  @override
  String get playVideo => 'வீடியோ இயக்கு';

  @override
  String get searchFolders => 'கோப்புறை தேடு';

  @override
  String get clearSearch => 'அழி';

  @override
  String searchResultsFor(String query) {
    return '\"$query\" முடிவுகள்';
  }

  @override
  String get cast => 'காஸ்ட்';

  @override
  String get moreOptions => 'மேலும்';

  @override
  String get loadingLibrary => 'நூலகம் ஏற்றப்படுகிறது…';

  @override
  String get calculatingSize => 'கணக்கிடப்படுகிறது…';

  @override
  String videosInFolder(String folder) {
    return '$folder இல் வீடியோக்கள்';
  }

  @override
  String get permissionWhyTitle => 'ஏன் அனுமதி தேவை';

  @override
  String permissionWhyBody1(String appName) {
    return 'சரியாக வேலை செய்ய $appName க்கு வீடியோ, பாடல், உபதலைப்பு அணுகல் தேவை.';
  }

  @override
  String get permissionWhyBody2 =>
      'உங்கள் தொலைபேசியில் உள்ள மீடியாவை கண்டறியவும் இயக்கவும் கோப்பு அணுகல் பயன்படுத்தப்படுகிறது.';

  @override
  String permissionWhyPrivacy(String appName) {
    return '$appName உங்கள் தனிப்பட்ட தரவை அணுகாது என்று உறுதி அளிக்கிறது.';
  }

  @override
  String get permissionWhyMoreInfo => 'மேலும் தகவலுக்கு';

  @override
  String get permissionWhySupportUrl =>
      'https://support.google.com/googleplay/android-developer/answer/10467955';

  @override
  String get ok => 'சரி';

  @override
  String get skip => 'தவிர்';

  @override
  String get next => 'அடுத்து';

  @override
  String get getStarted => 'தொடங்கு';

  @override
  String get onboardingTitle1 => 'ஆல்-இன்-ஒன் மீடியா பிளேயர்';

  @override
  String get onboardingPictureModes => 'பிக்ச்சர் மோட்கள்';

  @override
  String get pictureModeStandard => 'ஸ்டாண்டர்ட்';

  @override
  String get pictureModeVivid => 'விவிட்';

  @override
  String get pictureModeGame => 'கேம்';

  @override
  String get pictureModeMovie => 'மூவி';

  @override
  String get pictureModeCozy => 'கோஸி';

  @override
  String get pictureModeDynamic => 'டைனமிக்';

  @override
  String get onboardingSubtitle1 =>
      'HDR வீடியோ பிளேயர் அனைத்து கோப்புகளையும் கையாளும். முழு நூலகத்திற்கும் சக்திவாய்ந்த இசை பிளேயர்.';

  @override
  String get onboardingTitle2 => 'பிரீமியம் ஆடியோ அனுபவம்';

  @override
  String get onboardingSubtitle2 =>
      'தெளிவான ஈக்வலைசர் உண்மை பாஸ். அழகான இசை விசுவலைசர்கள்.';

  @override
  String get onboardingTitle3 => 'அற்புத விசுவலைசர்கள்';

  @override
  String get onboardingSubtitle3 =>
      'தெளிவான ஈக்வலைசர். ஆழமான பாஸ். அழகான விசுவலைசர்கள்.';

  @override
  String get onboardingTitle4 => 'மேம்பட்ட அம்சங்கள்';

  @override
  String get onboardingSubtitle4 =>
      'எந்த வீடியோவிற்கும் உபதலைப்பு பதிவிறக்கம். தனியுரிமைக்கு பாதுகாப்பு கோப்புறை.';

  @override
  String get chooseLanguage => 'மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get moreLanguages => 'More languages';

  @override
  String get languageEnglish => 'ஆங்கிலம்';

  @override
  String get languageTamil => 'தமிழ்';

  @override
  String get languageHindi => 'இந்தி';

  @override
  String get languageTelugu => 'தெலுங்கு';

  @override
  String get languageSpanishPicker => 'ஸ்பானிஷ் (Español)';

  @override
  String get languageArabicPicker => 'அரபு (العربية)';

  @override
  String get languageFrenchPicker => 'பிரெஞ்சு (Français)';

  @override
  String get languageBengaliPicker => 'வங்காளி (বাংলা)';

  @override
  String get languagePortuguesePicker => 'போர்த்துகீசு (Português)';

  @override
  String get languageRussianPicker => 'ரஷியன் (Русский)';

  @override
  String get languageUrduPicker => 'உருது (اردو)';

  @override
  String get languageMandarinPicker => 'சீனம் (中文)';

  @override
  String get languageTamilPicker => 'Tamil (தமிழ்)';

  @override
  String get languageHindiPicker => 'Hindi (हिन्दी)';

  @override
  String get languageTeluguPicker => 'Telugu (తెలుగు)';

  @override
  String get languageTutorialTitle => 'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get languageTutorialBody =>
      'எப்போது வேண்டுமானாலும் ஆப் மொழியை மாற்ற மொழி பொத்தானைத் தட்டவும்.';

  @override
  String get gotIt => 'புரிந்தது';

  @override
  String get colorTutorialTitle => 'Color filters';

  @override
  String get colorTutorialBody =>
      'Choose a look for your video — tap a preset or open Custom to adjust contrast, brightness, and more.';

  @override
  String get audioSubAlbum => 'ஆல்பம்';

  @override
  String get audioSubSongs => 'பாடல்கள்';

  @override
  String get audioSubArtist => 'கலைஞர்';

  @override
  String get audioSubFolder => 'கோப்புறை';

  @override
  String get audioSubPlaylist => 'பிளேலிஸ்ட்';

  @override
  String get noAudioFound => 'இந்த சாதனத்தில் ஆடியோ இல்லை';

  @override
  String get searchAudio => 'ஆடியோ தேடு';

  @override
  String get unknownArtist => '<தெரியவில்லை>';

  @override
  String songCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பாடல்கள்',
      one: '1 பாடல்',
    );
    return '$_temp0';
  }

  @override
  String get audioPlaylistHint => 'பிளேலிஸ்ட் வரும் புதுப்பிப்பில் கிடைக்கும்.';

  @override
  String get backgroundPlaybackTitle =>
      'தொடர்ச்சியான பின்னணி பிளேபேக்கை அனுமதி';

  @override
  String get backgroundPlaybackBody =>
      'சிஸ்டம் பிளேபேக்கை நிறுத்துவதைத் தடுக்க, தேவையான அனுமதியை வழங்கவும்.';

  @override
  String get queue => 'வரிசை';

  @override
  String get shuffleAll => 'அனைத்தையும் கலக்கு';

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
