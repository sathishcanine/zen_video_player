import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
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
    Locale('en'),
    Locale('es'),
    Locale('hi'),
    Locale('pt'),
    Locale('ta'),
    Locale('te'),
    Locale('zh')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Zen'**
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
  /// **'Tap the language button here to switch the app between Tamil, English, Hindi, and Telugu.'**
  String get languageTutorialBody;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

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
        'en',
        'es',
        'hi',
        'pt',
        'ta',
        'te',
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
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'hi':
      return AppLocalizationsHi();
    case 'pt':
      return AppLocalizationsPt();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
