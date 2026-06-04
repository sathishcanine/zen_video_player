import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('pt'),
    Locale('ru'),
    Locale('ta'),
    Locale('te'),
    Locale('ur'),
    Locale('zh')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Zen Player'**
  String get appName;

  /// No description provided for @appNameFull.
  ///
  /// In en, this message translates to:
  /// **'Zen Video Player'**
  String get appNameFull;

  /// No description provided for @accessYourMedia.
  ///
  /// In en, this message translates to:
  /// **'Access Your Media'**
  String get accessYourMedia;

  /// No description provided for @mediaAccessDescription.
  ///
  /// In en, this message translates to:
  /// **'{appName} needs access to your media files to find and play videos and music stored on your device.'**
  String mediaAccessDescription(String appName);

  /// No description provided for @featurePlayLocal.
  ///
  /// In en, this message translates to:
  /// **'Play local videos & audio'**
  String get featurePlayLocal;

  /// No description provided for @featureBrowseFiles.
  ///
  /// In en, this message translates to:
  /// **'Browse files easily'**
  String get featureBrowseFiles;

  /// No description provided for @featureLockPrivate.
  ///
  /// In en, this message translates to:
  /// **'Lock private folders'**
  String get featureLockPrivate;

  /// No description provided for @allowAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow Access'**
  String get allowAccess;

  /// No description provided for @allFilesAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Please allow access to videos and music to browse your library. You can change this anytime in Settings.'**
  String get allFilesAccessRequired;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Media access is required to browse your library. You can allow access in Settings.'**
  String get permissionRequired;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @tabVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get tabVideo;

  /// No description provided for @tabAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get tabAudio;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @pillPlaylist.
  ///
  /// In en, this message translates to:
  /// **'PLAYLIST'**
  String get pillPlaylist;

  /// No description provided for @pillMediaServer.
  ///
  /// In en, this message translates to:
  /// **'MEDIA SERVER'**
  String get pillMediaServer;

  /// No description provided for @pillNetworkStream.
  ///
  /// In en, this message translates to:
  /// **'NETWORK STREAM'**
  String get pillNetworkStream;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @audioTabHint.
  ///
  /// In en, this message translates to:
  /// **'Audio browsing will be available in a future update.'**
  String get audioTabHint;

  /// No description provided for @settingsTabHint.
  ///
  /// In en, this message translates to:
  /// **'Settings will be available in a future update.'**
  String get settingsTabHint;

  /// No description provided for @folderRecentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get folderRecentlyAdded;

  /// No description provided for @videoCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 video} other{{count} videos}}'**
  String videoCount(int count);

  /// No description provided for @folderSizeSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} • {size}'**
  String folderSizeSummary(String count, String size);

  /// No description provided for @badgeNew.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get badgeNew;

  /// No description provided for @noVideosFound.
  ///
  /// In en, this message translates to:
  /// **'No videos found on this device'**
  String get noVideosFound;

  /// No description provided for @grantAccessToBrowse.
  ///
  /// In en, this message translates to:
  /// **'Allow media access to browse folders on your device.'**
  String get grantAccessToBrowse;

  /// No description provided for @limitedVideoAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow access to all videos'**
  String get limitedVideoAccessTitle;

  /// No description provided for @limitedVideoAccessBody.
  ///
  /// In en, this message translates to:
  /// **'You allowed only selected videos. Zen needs access to all videos on your device to show folders like Camera and Downloads. Tap below, then choose Allow all on the system screen.'**
  String get limitedVideoAccessBody;

  /// No description provided for @allowAllVideos.
  ///
  /// In en, this message translates to:
  /// **'Allow all videos'**
  String get allowAllVideos;

  /// No description provided for @limitedAudioAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow access to all music'**
  String get limitedAudioAccessTitle;

  /// No description provided for @limitedAudioAccessBody.
  ///
  /// In en, this message translates to:
  /// **'You allowed only selected music. Tap below, then choose Allow all on the system screen to browse your full library.'**
  String get limitedAudioAccessBody;

  /// No description provided for @allowAllMusic.
  ///
  /// In en, this message translates to:
  /// **'Allow all music'**
  String get allowAllMusic;

  /// No description provided for @limitedAccessPreviewHint.
  ///
  /// In en, this message translates to:
  /// **'Folders on your device — allow all videos to open and play them.'**
  String get limitedAccessPreviewHint;

  /// No description provided for @limitedPartialLibraryHint.
  ///
  /// In en, this message translates to:
  /// **'You only allowed selected videos, so Zen can show a few folders. Allow all videos to browse Downloads and your full library.'**
  String get limitedPartialLibraryHint;

  /// No description provided for @limitedPartialFolderNote.
  ///
  /// In en, this message translates to:
  /// **'allow all to browse'**
  String get limitedPartialFolderNote;

  /// No description provided for @limitedAccessAlternatives.
  ///
  /// In en, this message translates to:
  /// **'Or play without full library access'**
  String get limitedAccessAlternatives;

  /// No description provided for @lockedFolderUnlock.
  ///
  /// In en, this message translates to:
  /// **'Allow all videos to view'**
  String get lockedFolderUnlock;

  /// No description provided for @limitedAccessSettingsSnackbar.
  ///
  /// In en, this message translates to:
  /// **'In Settings, open Videos (or Photos and videos) and choose Allow all — not Select photos.'**
  String get limitedAccessSettingsSnackbar;

  /// No description provided for @pickVideoFile.
  ///
  /// In en, this message translates to:
  /// **'Pick a video file'**
  String get pickVideoFile;

  /// No description provided for @playFromUrl.
  ///
  /// In en, this message translates to:
  /// **'Play from URL'**
  String get playFromUrl;

  /// No description provided for @pasteVideoUrl.
  ///
  /// In en, this message translates to:
  /// **'Paste video URL here'**
  String get pasteVideoUrl;

  /// No description provided for @playVideo.
  ///
  /// In en, this message translates to:
  /// **'Play Video'**
  String get playVideo;

  /// No description provided for @searchFolders.
  ///
  /// In en, this message translates to:
  /// **'Search folders'**
  String get searchFolders;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearSearch;

  /// No description provided for @searchResultsFor.
  ///
  /// In en, this message translates to:
  /// **'Results for \"{query}\"'**
  String searchResultsFor(String query);

  /// No description provided for @cast.
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get cast;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreOptions;

  /// No description provided for @loadingLibrary.
  ///
  /// In en, this message translates to:
  /// **'Loading your library…'**
  String get loadingLibrary;

  /// No description provided for @calculatingSize.
  ///
  /// In en, this message translates to:
  /// **'Calculating…'**
  String get calculatingSize;

  /// No description provided for @videosInFolder.
  ///
  /// In en, this message translates to:
  /// **'Videos in {folder}'**
  String videosInFolder(String folder);

  /// No description provided for @permissionWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why the app needs permission'**
  String get permissionWhyTitle;

  /// No description provided for @permissionWhyBody1.
  ///
  /// In en, this message translates to:
  /// **'{appName} needs access to videos, songs, and subtitles on your device to function properly.'**
  String permissionWhyBody1(String appName);

  /// No description provided for @permissionWhyBody2.
  ///
  /// In en, this message translates to:
  /// **'File access is used so you can discover and play media stored on your phone. After you allow access, you will see folders with your videos in the app.'**
  String get permissionWhyBody2;

  /// No description provided for @permissionWhyPrivacy.
  ///
  /// In en, this message translates to:
  /// **'{appName} promises that it will not use these permissions to access your private data.'**
  String permissionWhyPrivacy(String appName);

  /// No description provided for @permissionWhyMoreInfo.
  ///
  /// In en, this message translates to:
  /// **'For more information'**
  String get permissionWhyMoreInfo;

  /// No description provided for @permissionWhySupportUrl.
  ///
  /// In en, this message translates to:
  /// **'https://support.google.com/googleplay/android-developer/answer/10467955'**
  String get permissionWhySupportUrl;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'All-in-One Media Player'**
  String get onboardingTitle1;

  /// No description provided for @onboardingPictureModes.
  ///
  /// In en, this message translates to:
  /// **'Picture Modes'**
  String get onboardingPictureModes;

  /// No description provided for @pictureModeStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get pictureModeStandard;

  /// No description provided for @pictureModeVivid.
  ///
  /// In en, this message translates to:
  /// **'Vivid'**
  String get pictureModeVivid;

  /// No description provided for @pictureModeGame.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get pictureModeGame;

  /// No description provided for @pictureModeMovie.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get pictureModeMovie;

  /// No description provided for @pictureModeCozy.
  ///
  /// In en, this message translates to:
  /// **'Cozy'**
  String get pictureModeCozy;

  /// No description provided for @pictureModeDynamic.
  ///
  /// In en, this message translates to:
  /// **'Dynamic'**
  String get pictureModeDynamic;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'HDR video player handles all files. Powerful music player for your entire library.'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Premium Audio Experience'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Crystal clear equalizer with true bass. Elegant music visualizers.'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Stunning Visualizers'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Crystal-clear equalizer. Deep bass. Elegant visualizers.'**
  String get onboardingSubtitle3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In en, this message translates to:
  /// **'Advanced Features'**
  String get onboardingTitle4;

  /// No description provided for @onboardingSubtitle4.
  ///
  /// In en, this message translates to:
  /// **'Download subtitles for any video. Secure folder locker for privacy.'**
  String get onboardingSubtitle4;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @moreLanguages.
  ///
  /// In en, this message translates to:
  /// **'More languages'**
  String get moreLanguages;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageTamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get languageTamil;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get languageHindi;

  /// No description provided for @languageTelugu.
  ///
  /// In en, this message translates to:
  /// **'Telugu'**
  String get languageTelugu;

  /// No description provided for @languageSpanishPicker.
  ///
  /// In en, this message translates to:
  /// **'Spanish (Español)'**
  String get languageSpanishPicker;

  /// No description provided for @languageArabicPicker.
  ///
  /// In en, this message translates to:
  /// **'Arabic (العربية)'**
  String get languageArabicPicker;

  /// No description provided for @languageFrenchPicker.
  ///
  /// In en, this message translates to:
  /// **'French (Français)'**
  String get languageFrenchPicker;

  /// No description provided for @languageBengaliPicker.
  ///
  /// In en, this message translates to:
  /// **'Bengali (বাংলা)'**
  String get languageBengaliPicker;

  /// No description provided for @languagePortuguesePicker.
  ///
  /// In en, this message translates to:
  /// **'Portuguese (Português)'**
  String get languagePortuguesePicker;

  /// No description provided for @languageRussianPicker.
  ///
  /// In en, this message translates to:
  /// **'Russian (Русский)'**
  String get languageRussianPicker;

  /// No description provided for @languageUrduPicker.
  ///
  /// In en, this message translates to:
  /// **'Urdu (اردو)'**
  String get languageUrduPicker;

  /// No description provided for @languageMandarinPicker.
  ///
  /// In en, this message translates to:
  /// **'Chinese (中文)'**
  String get languageMandarinPicker;

  /// No description provided for @languageTamilPicker.
  ///
  /// In en, this message translates to:
  /// **'Tamil (தமிழ்)'**
  String get languageTamilPicker;

  /// No description provided for @languageHindiPicker.
  ///
  /// In en, this message translates to:
  /// **'Hindi (हिन्दी)'**
  String get languageHindiPicker;

  /// No description provided for @languageTeluguPicker.
  ///
  /// In en, this message translates to:
  /// **'Telugu (తెలుగు)'**
  String get languageTeluguPicker;

  /// No description provided for @languageTutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageTutorialTitle;

  /// No description provided for @languageTutorialBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the language button here to switch the app language anytime.'**
  String get languageTutorialBody;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @colorTutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Color filters'**
  String get colorTutorialTitle;

  /// No description provided for @colorTutorialBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a look for your video — tap a preset or open Custom to adjust contrast, brightness, and more.'**
  String get colorTutorialBody;

  /// No description provided for @audioSubAlbum.
  ///
  /// In en, this message translates to:
  /// **'ALBUM'**
  String get audioSubAlbum;

  /// No description provided for @audioSubSongs.
  ///
  /// In en, this message translates to:
  /// **'SONGS'**
  String get audioSubSongs;

  /// No description provided for @audioSubArtist.
  ///
  /// In en, this message translates to:
  /// **'ARTIST'**
  String get audioSubArtist;

  /// No description provided for @audioSubFolder.
  ///
  /// In en, this message translates to:
  /// **'FOLDER'**
  String get audioSubFolder;

  /// No description provided for @audioSubPlaylist.
  ///
  /// In en, this message translates to:
  /// **'PLAYLIST'**
  String get audioSubPlaylist;

  /// No description provided for @noAudioFound.
  ///
  /// In en, this message translates to:
  /// **'No audio found on this device'**
  String get noAudioFound;

  /// No description provided for @searchAudio.
  ///
  /// In en, this message translates to:
  /// **'Search audio'**
  String get searchAudio;

  /// No description provided for @unknownArtist.
  ///
  /// In en, this message translates to:
  /// **'<unknown>'**
  String get unknownArtist;

  /// No description provided for @songCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 song} other{{count} songs}}'**
  String songCount(int count);

  /// No description provided for @audioPlaylistHint.
  ///
  /// In en, this message translates to:
  /// **'Create and manage playlists in a future update.'**
  String get audioPlaylistHint;

  /// No description provided for @backgroundPlaybackTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow continuous background playback'**
  String get backgroundPlaybackTitle;

  /// No description provided for @backgroundPlaybackBody.
  ///
  /// In en, this message translates to:
  /// **'To prevent playback from being stopped by the system, please give the necessary permission.'**
  String get backgroundPlaybackBody;

  /// No description provided for @queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queue;

  /// No description provided for @shuffleAll.
  ///
  /// In en, this message translates to:
  /// **'SHUFFLE ALL'**
  String get shuffleAll;

  /// No description provided for @castSelectDevice.
  ///
  /// In en, this message translates to:
  /// **'Cast to device'**
  String get castSelectDevice;

  /// No description provided for @castSearching.
  ///
  /// In en, this message translates to:
  /// **'Looking for Cast devices…'**
  String get castSearching;

  /// No description provided for @castWifiHint.
  ///
  /// In en, this message translates to:
  /// **'Phone and TV must be on the same Wi‑Fi network.'**
  String get castWifiHint;

  /// No description provided for @castDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get castDisconnect;

  /// No description provided for @castDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected from Cast'**
  String get castDisconnected;

  /// No description provided for @castConnectedTo.
  ///
  /// In en, this message translates to:
  /// **'Connected to {device}'**
  String castConnectedTo(String device);

  /// No description provided for @castPlayingOn.
  ///
  /// In en, this message translates to:
  /// **'Playing on {device}'**
  String castPlayingOn(String device);

  /// No description provided for @castFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not cast this video. Try again.'**
  String get castFailed;

  /// No description provided for @castUnsupportedPlatform.
  ///
  /// In en, this message translates to:
  /// **'Cast is not available on this platform.'**
  String get castUnsupportedPlatform;

  /// No description provided for @castUnsupportedContentUri.
  ///
  /// In en, this message translates to:
  /// **'Cast is not supported for videos opened from other apps.'**
  String get castUnsupportedContentUri;

  /// No description provided for @castLocalWifiRequired.
  ///
  /// In en, this message translates to:
  /// **'Connect to Wi‑Fi to cast local videos from this phone.'**
  String get castLocalWifiRequired;

  /// No description provided for @castPlayVideoToCast.
  ///
  /// In en, this message translates to:
  /// **'Open a video and tap Cast to play it on your TV.'**
  String get castPlayVideoToCast;

  /// No description provided for @settingsNetworkStream.
  ///
  /// In en, this message translates to:
  /// **'Network stream'**
  String get settingsNetworkStream;

  /// No description provided for @settingsNetworkStreamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play media from network URL'**
  String get settingsNetworkStreamSubtitle;

  /// No description provided for @settingsFindDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Find duplicate'**
  String get settingsFindDuplicate;

  /// No description provided for @settingsFindDuplicateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find duplicate audio or video files'**
  String get settingsFindDuplicateSubtitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get settingsDarkTheme;

  /// No description provided for @settingsDarkThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch between light and dark appearance'**
  String get settingsDarkThemeSubtitle;

  /// No description provided for @settingsPrimaryColor.
  ///
  /// In en, this message translates to:
  /// **'Primary color'**
  String get settingsPrimaryColor;

  /// No description provided for @settingsPrimaryColorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your accent color'**
  String get settingsPrimaryColorSubtitle;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @duplicateChooseTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get duplicateChooseTitle;

  /// No description provided for @duplicateChooseCancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get duplicateChooseCancel;

  /// No description provided for @duplicateScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning storage'**
  String get duplicateScanning;

  /// No description provided for @duplicateScanFailed.
  ///
  /// In en, this message translates to:
  /// **'Scan failed. Please try again.'**
  String get duplicateScanFailed;

  /// No description provided for @duplicateResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicates'**
  String get duplicateResultsTitle;

  /// No description provided for @duplicateNoneFound.
  ///
  /// In en, this message translates to:
  /// **'No duplicate files found.'**
  String get duplicateNoneFound;

  /// No description provided for @duplicateGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} copies · {name}'**
  String duplicateGroupTitle(int count, String name);

  /// No description provided for @duplicateKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get duplicateKeep;

  /// No description provided for @duplicateDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete file?'**
  String get duplicateDeleteTitle;

  /// No description provided for @duplicateDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from this device? This cannot be undone.'**
  String duplicateDeleteBody(String name);

  /// No description provided for @duplicateDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get duplicateDeleteConfirm;

  /// No description provided for @duplicateDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get duplicateDeleteAll;

  /// No description provided for @duplicateDeleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all duplicates?'**
  String get duplicateDeleteAllTitle;

  /// No description provided for @duplicateDeleteAllBody.
  ///
  /// In en, this message translates to:
  /// **'Remove {count} duplicate files? The oldest copy in each group is kept.'**
  String duplicateDeleteAllBody(int count);

  /// No description provided for @duplicateDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {count} file(s)'**
  String duplicateDeleted(int count);

  /// No description provided for @duplicateDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete. Check permissions and try again.'**
  String get duplicateDeleteFailed;

  /// No description provided for @optionPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get optionPlay;

  /// No description provided for @optionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get optionDelete;

  /// No description provided for @optionSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get optionSend;

  /// No description provided for @optionRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get optionRename;

  /// No description provided for @optionAddToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to playlist'**
  String get optionAddToPlaylist;

  /// No description provided for @optionHideFromList.
  ///
  /// In en, this message translates to:
  /// **'Hide from list'**
  String get optionHideFromList;

  /// No description provided for @optionDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get optionDetails;

  /// No description provided for @optionRemoveFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Remove from playlist'**
  String get optionRemoveFromPlaylist;

  /// No description provided for @createPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Create Playlist'**
  String get createPlaylist;

  /// No description provided for @playlistNameHint.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get playlistNameHint;

  /// No description provided for @playlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'No playlists yet. Tap + Create Playlist.'**
  String get playlistEmpty;

  /// No description provided for @playlistVideoCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Video} other{{count} Videos}}'**
  String playlistVideoCount(int count);

  /// No description provided for @renamePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Rename playlist'**
  String get renamePlaylist;

  /// No description provided for @deletePlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete playlist?'**
  String get deletePlaylistTitle;

  /// No description provided for @deletePlaylistBody.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\"? Videos on your device are not deleted.'**
  String deletePlaylistBody(String name);

  /// No description provided for @deleteFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all videos?'**
  String get deleteFolderTitle;

  /// No description provided for @deleteFolderBody.
  ///
  /// In en, this message translates to:
  /// **'Remove all {count} videos in \"{name}\" from this device? This cannot be undone.'**
  String deleteFolderBody(int count, String name);

  /// No description provided for @hideFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Hide folder?'**
  String get hideFolderTitle;

  /// No description provided for @hideFolderBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be hidden from the video list. You can restore it later in settings.'**
  String hideFolderBody(String name);

  /// No description provided for @renameNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Renaming device folders and videos is not supported.'**
  String get renameNotSupported;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not share files.'**
  String get shareFailed;

  /// No description provided for @sharePreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing files to share…'**
  String get sharePreparing;

  /// No description provided for @addedToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Added to {name}'**
  String addedToPlaylist(String name);

  /// No description provided for @detailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsTitle;

  /// No description provided for @detailsName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get detailsName;

  /// No description provided for @detailsPath.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get detailsPath;

  /// No description provided for @detailsSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get detailsSize;

  /// No description provided for @detailsDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get detailsDuration;

  /// No description provided for @detailsResolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get detailsResolution;

  /// No description provided for @detailsDate.
  ///
  /// In en, this message translates to:
  /// **'Date added'**
  String get detailsDate;

  /// No description provided for @detailsCount.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get detailsCount;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @proBadge.
  ///
  /// In en, this message translates to:
  /// **'FREE PRO'**
  String get proBadge;

  /// No description provided for @proUnlockTitleFeature.
  ///
  /// In en, this message translates to:
  /// **'Unlock {feature}'**
  String proUnlockTitleFeature(String feature);

  /// No description provided for @proUnlockBodyFeature.
  ///
  /// In en, this message translates to:
  /// **'Watch one short ad to unlock {feature} on this device.'**
  String proUnlockBodyFeature(String feature);

  /// No description provided for @proUnlockWatchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch ad & unlock'**
  String get proUnlockWatchAd;

  /// No description provided for @proUnlockNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get proUnlockNotNow;

  /// No description provided for @proUnlockSuccess.
  ///
  /// In en, this message translates to:
  /// **'{feature} unlocked!'**
  String proUnlockSuccess(String feature);

  /// No description provided for @proUnlockAdFailed.
  ///
  /// In en, this message translates to:
  /// **'Ad not available. Please try again in a moment.'**
  String get proUnlockAdFailed;

  /// No description provided for @playStoreRatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Help us to Grow'**
  String get playStoreRatingTitle;

  /// No description provided for @playStoreRatingBody.
  ///
  /// In en, this message translates to:
  /// **'A quick rating on Google Play helps us grow and keep Zen free for everyone.'**
  String get playStoreRatingBody;

  /// No description provided for @playStoreRatingRateNow.
  ///
  /// In en, this message translates to:
  /// **'Rate now'**
  String get playStoreRatingRateNow;

  /// No description provided for @playStoreRatingMaybe.
  ///
  /// In en, this message translates to:
  /// **'Maybe'**
  String get playStoreRatingMaybe;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'bn',
        'en',
        'es',
        'fr',
        'hi',
        'pt',
        'ru',
        'ta',
        'te',
        'ur',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
    case 'ur':
      return AppLocalizationsUr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
