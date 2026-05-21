// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Zen';

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
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageTamil => 'التاميلية';

  @override
  String get languageHindi => 'الهندية';

  @override
  String get languageTelugu => 'التيلوجو';

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
      'اضغط زر اللغة للتبديل بين التاميلية والإنجليزية والهندية والتيلوجو.';

  @override
  String get gotIt => 'حسناً';

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
}
