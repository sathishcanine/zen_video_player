// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Zen Player';

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
  String get allFilesAccessRequired =>
      'Please allow access to videos and music to browse your library. You can change this anytime in Settings.';

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
  String get moreLanguages => 'More languages';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageTamil => '泰米尔语';

  @override
  String get languageHindi => '印地语';

  @override
  String get languageTelugu => '泰卢固语';

  @override
  String get languageSpanishPicker => '西班牙语 (Español)';

  @override
  String get languageArabicPicker => '阿拉伯语 (العربية)';

  @override
  String get languageFrenchPicker => '法语 (Français)';

  @override
  String get languageBengaliPicker => '孟加拉语 (বাংলা)';

  @override
  String get languagePortuguesePicker => '葡萄牙语 (Português)';

  @override
  String get languageRussianPicker => '俄语 (Русский)';

  @override
  String get languageUrduPicker => '乌尔都语 (اردو)';

  @override
  String get languageMandarinPicker => '中文 (中文)';

  @override
  String get languageTamilPicker => 'Tamil (தமிழ்)';

  @override
  String get languageHindiPicker => 'Hindi (हिन्दी)';

  @override
  String get languageTeluguPicker => 'Telugu (తెలుగు)';

  @override
  String get languageTutorialTitle => '选择您的语言';

  @override
  String get languageTutorialBody => '点击语言按钮可随时切换应用语言。';

  @override
  String get gotIt => '知道了';

  @override
  String get colorTutorialTitle => 'Color filters';

  @override
  String get colorTutorialBody =>
      'Choose a look for your video — tap a preset or open Custom to adjust contrast, brightness, and more.';

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
  String get equalizerFeatureAnnounceTitle => 'New feature';

  @override
  String get equalizerFeatureAnnounceHeadline => 'Equalizer for Audio player';

  @override
  String get equalizerFeatureAnnounceBody =>
      'Fine-tune your music with presets, bass boost, 3D surround, and loudness — open any song and tap the equalizer icon.';

  @override
  String get equalizerFeatureAnnounceCta => 'Got it';

  @override
  String get whatsNewTitle => 'What\'s New';

  @override
  String get whatsNewHeadline => 'Your player just got better';

  @override
  String get whatsNewFeatureVisualizerTitle => 'Music Visualizer';

  @override
  String get whatsNewFeatureVisualizerBody =>
      'Watch your music come alive with Bars, Wave, and Circle styles wrapped around your album art.';

  @override
  String get whatsNewFeatureContinueTitle => 'Continue Watching';

  @override
  String get whatsNewFeatureContinueBody =>
      'Pick up right where you left off — your latest videos are ready on the home screen.';

  @override
  String get whatsNewFeatureSleepTimerTitle => 'Sleep Timer';

  @override
  String get whatsNewFeatureSleepTimerBody =>
      'Drift off peacefully. Set a timer or stop when the current song or video ends.';

  @override
  String get whatsNewCta => 'Got it';

  @override
  String get equalizerTitle => 'Equalizer';

  @override
  String get eqZenPlayer => 'Zen Player';

  @override
  String get eqAudioSpectrum => 'Audio Spectrum';

  @override
  String get visualizerModeBars => 'Bars';

  @override
  String get visualizerModeWave => 'Wave';

  @override
  String get visualizerModeCircle => 'Circle';

  @override
  String get visualizerStyle => 'Visualizer style';

  @override
  String get visualizer => 'Visualizer';

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
  String get pictureInPicture => 'Picture-in-picture';

  @override
  String get pictureInPictureUnavailable =>
      'Could not start Picture-in-picture. In system Settings, open Apps → Zen VideoPlayer → Picture-in-picture and allow it.';

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

  @override
  String get sleepTimerTitle => 'Sleep timer';

  @override
  String sleepTimerMinutes(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get sleepTimerCustom => 'Custom time';

  @override
  String get sleepTimerCustomHint => 'Minutes';

  @override
  String get sleepTimerSet => 'Set';

  @override
  String get sleepTimerCancel => 'Cancel sleep timer';

  @override
  String get sleepTimerEndOfMedia => 'When current ends';

  @override
  String get sleepTimerEndOfMediaSubtitle =>
      'Stop playback when this video or song finishes';

  @override
  String get sleepTimerEndOfMediaActive => 'Stops when current media ends';

  @override
  String sleepTimerRemaining(String time) {
    return 'Time left: $time';
  }

  @override
  String get settingsPlayback => 'Playback';

  @override
  String get settingsResumeAudio => 'Resume audio';

  @override
  String get settingsResumeAudioSubtitle => 'Continue songs where you left off';

  @override
  String get settingsResumeVideo => 'Resume video';

  @override
  String get settingsResumeVideoSubtitle =>
      'Continue videos where you left off';

  @override
  String get settingsKeepScreenOnVideo => 'Keep screen on';

  @override
  String get settingsKeepScreenOnVideoSubtitle =>
      'Prevent screen sleep during video playback';

  @override
  String get settingsLibrary => 'Library';

  @override
  String get settingsHiddenFolders => 'Hidden video folders';

  @override
  String get settingsHiddenFoldersSubtitle =>
      'Restore folders hidden from the video list';

  @override
  String get settingsHiddenFoldersSheetBody =>
      'Folders you hide from the video tab appear here. Tap Restore to show them in your library again.';

  @override
  String get hiddenFoldersEmpty => 'No hidden folders';

  @override
  String get hiddenFolderRestore => 'Restore';

  @override
  String hiddenFolderRestored(String name) {
    return '\"$name\" is visible in your library again';
  }

  @override
  String get hiddenFoldersRestoreAllTitle => 'Restore all folders?';

  @override
  String get hiddenFoldersRestoreAllBody =>
      'Every hidden video folder will appear in your library again.';

  @override
  String get hiddenFoldersRestoreAllConfirm => 'Restore all';

  @override
  String get hiddenFoldersRestoreAllDone => 'All folders restored';

  @override
  String get folderDownloads => 'Downloads';

  @override
  String get badgeToday => 'TODAY';

  @override
  String get backgroundPlayingAudio => 'Playing in background';

  @override
  String get backgroundPlayingVideo => 'Video playing';

  @override
  String get tapToReturnPlayer => 'Tap to return to player';

  @override
  String get continueWatching => 'Continue watching';

  @override
  String get resumePlaybackPrompt => 'Continue from where you stopped.';

  @override
  String get resumeStartOver => 'START OVER';
}
