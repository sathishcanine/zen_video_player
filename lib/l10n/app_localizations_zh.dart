// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Zen';

  @override
  String get appNameFull => 'Zen 视频播放器';

  @override
  String get accessYourMedia => '访问您的媒体';

  @override
  String mediaAccessDescription(String appName) {
    return '$appName 需要访问您的媒体文件，以便查找并播放设备上存储的视频和音乐。';
  }

  @override
  String get featurePlayLocal => '播放本地视频和音频';

  @override
  String get featureBrowseFiles => '轻松浏览文件';

  @override
  String get featureLockPrivate => '锁定私人文件夹';

  @override
  String get allowAccess => '允许访问';

  @override
  String get notNow => '暂不';

  @override
  String get permissionRequired => '浏览媒体库需要媒体访问权限。您可以在设置中允许访问。';

  @override
  String get openSettings => '打开设置';

  @override
  String get tabVideo => '视频';

  @override
  String get tabAudio => '音频';

  @override
  String get tabSettings => '设置';

  @override
  String get pillPlaylist => '播放列表';

  @override
  String get pillMediaServer => '媒体服务器';

  @override
  String get pillNetworkStream => '网络流';

  @override
  String get comingSoon => '即将推出';

  @override
  String get audioTabHint => '音频浏览将在未来更新中提供。';

  @override
  String get settingsTabHint => '设置将在未来更新中提供。';

  @override
  String get folderRecentlyAdded => '最近添加';

  @override
  String videoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个视频',
      one: '1 个视频',
    );
    return '$_temp0';
  }

  @override
  String folderSizeSummary(String count, String size) {
    return '$count • $size';
  }

  @override
  String get badgeNew => '新';

  @override
  String get noVideosFound => '此设备上未找到视频';

  @override
  String get grantAccessToBrowse => '允许媒体访问以浏览设备上的文件夹。';

  @override
  String get pickVideoFile => '选择视频文件';

  @override
  String get playFromUrl => '从 URL 播放';

  @override
  String get pasteVideoUrl => '在此粘贴视频 URL';

  @override
  String get playVideo => '播放';

  @override
  String get searchFolders => '搜索文件夹';

  @override
  String get clearSearch => '清除';

  @override
  String searchResultsFor(String query) {
    return '“$query”的搜索结果';
  }

  @override
  String get cast => '投屏';

  @override
  String get moreOptions => '更多';

  @override
  String get loadingLibrary => '正在加载媒体库…';

  @override
  String get calculatingSize => '计算中…';

  @override
  String videosInFolder(String folder) {
    return '$folder 中的视频';
  }

  @override
  String get permissionWhyTitle => '应用为何需要权限';

  @override
  String permissionWhyBody1(String appName) {
    return '$appName 需要访问您设备上的视频、歌曲和字幕才能正常运行。';
  }

  @override
  String get permissionWhyBody2 => '文件访问用于发现并播放手机上的媒体。允许访问后，您将在应用中看到视频文件夹。';

  @override
  String permissionWhyPrivacy(String appName) {
    return '$appName 承诺不会使用这些权限访问您的私人数据。';
  }

  @override
  String get permissionWhyMoreInfo => '更多信息';

  @override
  String get permissionWhySupportUrl =>
      'https://support.google.com/googleplay/android-developer/answer/10467955';

  @override
  String get ok => '确定';

  @override
  String get skip => '跳过';

  @override
  String get next => '下一步';

  @override
  String get getStarted => '开始使用';

  @override
  String get onboardingTitle1 => '一体化媒体播放器';

  @override
  String get onboardingPictureModes => '画面模式';

  @override
  String get pictureModeStandard => '标准';

  @override
  String get pictureModeVivid => '鲜艳';

  @override
  String get pictureModeGame => '游戏';

  @override
  String get pictureModeMovie => '电影';

  @override
  String get pictureModeCozy => '舒适';

  @override
  String get pictureModeDynamic => '动态';

  @override
  String get onboardingSubtitle1 => 'HDR 视频播放器支持所有文件。强大的音乐播放器管理整个曲库。';

  @override
  String get onboardingTitle2 => '高品质音频体验';

  @override
  String get onboardingSubtitle2 => '清澈均衡器与真实低音。优雅的音乐可视化。';

  @override
  String get onboardingTitle3 => '惊艳可视化';

  @override
  String get onboardingSubtitle3 => '清澈均衡器。深沉低音。优雅可视化效果。';

  @override
  String get onboardingTitle4 => '高级功能';

  @override
  String get onboardingSubtitle4 => '为任何视频下载字幕。安全文件夹保护隐私。';

  @override
  String get chooseLanguage => '选择语言';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageTamil => '泰米尔语';

  @override
  String get languageHindi => '印地语';

  @override
  String get languageTelugu => '泰卢固语';

  @override
  String get languageTamilPicker => 'Tamil (தமிழ்)';

  @override
  String get languageHindiPicker => 'Hindi (हिन्दी)';

  @override
  String get languageTeluguPicker => 'Telugu (తెలుగు)';

  @override
  String get languageTutorialTitle => '选择您的语言';

  @override
  String get languageTutorialBody => '点击语言按钮可在泰米尔语、英语、印地语和泰卢固语之间切换。';

  @override
  String get gotIt => '知道了';

  @override
  String get audioSubAlbum => '专辑';

  @override
  String get audioSubSongs => '歌曲';

  @override
  String get audioSubArtist => '艺术家';

  @override
  String get audioSubFolder => '文件夹';

  @override
  String get audioSubPlaylist => '播放列表';

  @override
  String get noAudioFound => '此设备上未找到音频';

  @override
  String get searchAudio => '搜索音频';

  @override
  String get unknownArtist => '<未知>';

  @override
  String songCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 首',
      one: '1 首',
    );
    return '$_temp0';
  }

  @override
  String get audioPlaylistHint => '播放列表将在未来更新中提供。';

  @override
  String get backgroundPlaybackTitle => '允许持续后台播放';

  @override
  String get backgroundPlaybackBody => '为防止系统停止播放，请授予必要权限。';

  @override
  String get queue => '播放队列';

  @override
  String get shuffleAll => '全部随机';

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
}
