// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'Zen';

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
  String get languageEnglish => 'ஆங்கிலம்';

  @override
  String get languageTamil => 'தமிழ்';

  @override
  String get languageHindi => 'இந்தி';

  @override
  String get languageTelugu => 'தெலுங்கு';

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
      'தமிழ், ஆங்கிலம், இந்தி, தெலுங்கு மாற்ற இங்கே மொழி பொத்தானைத் தட்டவும்.';

  @override
  String get gotIt => 'புரிந்தது';

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
}
