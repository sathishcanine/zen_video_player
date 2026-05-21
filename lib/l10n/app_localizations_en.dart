// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Zen';

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
  String get chooseLanguage => 'Choose language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTamil => 'Tamil';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageTelugu => 'Telugu';

  @override
  String get languageTamilPicker => 'Tamil (தமிழ்)';

  @override
  String get languageHindiPicker => 'Hindi (हिन्दी)';

  @override
  String get languageTeluguPicker => 'Telugu (తెలుగు)';

  @override
  String get languageTutorialTitle => 'Choose your language';

  @override
  String get languageTutorialBody =>
      'Tap the language button here to switch the app between Tamil, English, Hindi, and Telugu.';

  @override
  String get gotIt => 'Got it';

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
}
