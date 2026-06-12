// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Zen Player';

  @override
  String get appNameFull => 'Zen Reproductor de Video';

  @override
  String get accessYourMedia => 'Accede a tus medios';

  @override
  String mediaAccessDescription(String appName) {
    return '$appName necesita acceso a tus archivos multimedia para encontrar y reproducir videos y música en tu dispositivo.';
  }

  @override
  String get featurePlayLocal => 'Reproduce videos y audio locales';

  @override
  String get featureBrowseFiles => 'Explora archivos fácilmente';

  @override
  String get featureLockPrivate => 'Bloquea carpetas privadas';

  @override
  String get allowAccess => 'Permitir acceso';

  @override
  String get allFilesAccessRequired =>
      'Please allow access to videos and music to browse your library. You can change this anytime in Settings.';

  @override
  String get notNow => 'Ahora no';

  @override
  String get permissionRequired =>
      'Se requiere acceso a medios para explorar tu biblioteca. Puedes permitirlo en Ajustes.';

  @override
  String get openSettings => 'Abrir Ajustes';

  @override
  String get tabVideo => 'Video';

  @override
  String get tabAudio => 'Audio';

  @override
  String get tabSettings => 'Ajustes';

  @override
  String get pillPlaylist => 'LISTA';

  @override
  String get pillMediaServer => 'SERVIDOR';

  @override
  String get pillNetworkStream => 'STREAM';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get audioTabHint =>
      'La exploración de audio estará disponible en una actualización futura.';

  @override
  String get settingsTabHint =>
      'Los ajustes estarán disponibles en una actualización futura.';

  @override
  String get folderRecentlyAdded => 'Añadidos recientemente';

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
  String get badgeNew => 'NUEVO';

  @override
  String get noVideosFound => 'No se encontraron videos en este dispositivo';

  @override
  String get grantAccessToBrowse =>
      'Permite el acceso a medios para explorar carpetas.';

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
  String get pickVideoFile => 'Elegir un video';

  @override
  String get playFromUrl => 'Reproducir desde URL';

  @override
  String get pasteVideoUrl => 'Pega la URL del video aquí';

  @override
  String get playVideo => 'Reproducir';

  @override
  String get searchFolders => 'Buscar carpetas';

  @override
  String get clearSearch => 'Borrar';

  @override
  String searchResultsFor(String query) {
    return 'Resultados de \"$query\"';
  }

  @override
  String get cast => 'Transmitir';

  @override
  String get moreOptions => 'Más';

  @override
  String get loadingLibrary => 'Cargando biblioteca…';

  @override
  String get calculatingSize => 'Calculando…';

  @override
  String videosInFolder(String folder) {
    return 'Videos en $folder';
  }

  @override
  String get permissionWhyTitle => 'Por qué la app necesita permiso';

  @override
  String permissionWhyBody1(String appName) {
    return '$appName necesita acceso a videos, canciones y subtítulos en tu dispositivo para funcionar correctamente.';
  }

  @override
  String get permissionWhyBody2 =>
      'El acceso a archivos se usa para descubrir y reproducir medios en tu teléfono. Después de permitirlo, verás carpetas con tus videos en la app.';

  @override
  String permissionWhyPrivacy(String appName) {
    return '$appName promete no usar estos permisos para acceder a tus datos privados.';
  }

  @override
  String get permissionWhyMoreInfo => 'Para más información';

  @override
  String get permissionWhySupportUrl =>
      'https://support.google.com/googleplay/android-developer/answer/10467955';

  @override
  String get ok => 'Aceptar';

  @override
  String get skip => 'Omitir';

  @override
  String get next => 'Siguiente';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get onboardingTitle1 => 'Reproductor multimedia todo en uno';

  @override
  String get onboardingPictureModes => 'Modos de imagen';

  @override
  String get pictureModeStandard => 'Estándar';

  @override
  String get pictureModeVivid => 'Vívido';

  @override
  String get pictureModeGame => 'Juego';

  @override
  String get pictureModeMovie => 'Película';

  @override
  String get pictureModeCozy => 'Acogedor';

  @override
  String get pictureModeDynamic => 'Dinámico';

  @override
  String get onboardingSubtitle1 =>
      'Reproductor HDR para todos los archivos. Potente reproductor de música para toda tu biblioteca.';

  @override
  String get onboardingTitle2 => 'Experiencia de audio premium';

  @override
  String get onboardingSubtitle2 =>
      'Ecualizador nítido con graves reales. Visualizadores de música elegantes.';

  @override
  String get onboardingTitle3 => 'Visualizadores impresionantes';

  @override
  String get onboardingSubtitle3 =>
      'Ecualizador cristalino. Graves profundos. Visualizadores elegantes.';

  @override
  String get onboardingTitle4 => 'Funciones avanzadas';

  @override
  String get onboardingSubtitle4 =>
      'Descarga subtítulos para cualquier video. Carpeta segura para tu privacidad.';

  @override
  String get chooseLanguage => 'Elegir idioma';

  @override
  String get moreLanguages => 'More languages';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageTamil => 'Tamil';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageTelugu => 'Telugu';

  @override
  String get languageSpanishPicker => 'Español (Español)';

  @override
  String get languageArabicPicker => 'Árabe (العربية)';

  @override
  String get languageFrenchPicker => 'Francés (Français)';

  @override
  String get languageBengaliPicker => 'Bengalí (বাংলা)';

  @override
  String get languagePortuguesePicker => 'Portugués (Português)';

  @override
  String get languageRussianPicker => 'Ruso (Русский)';

  @override
  String get languageUrduPicker => 'Urdu (اردو)';

  @override
  String get languageMandarinPicker => 'Chino (中文)';

  @override
  String get languageTamilPicker => 'Tamil (தமிழ்)';

  @override
  String get languageHindiPicker => 'Hindi (हिन्दी)';

  @override
  String get languageTeluguPicker => 'Telugu (తెలుగు)';

  @override
  String get languageTutorialTitle => 'Elige tu idioma';

  @override
  String get languageTutorialBody =>
      'Toca el botón de idioma para cambiar el idioma de la app en cualquier momento.';

  @override
  String get gotIt => 'Entendido';

  @override
  String get colorTutorialTitle => 'Color filters';

  @override
  String get colorTutorialBody =>
      'Choose a look for your video — tap a preset or open Custom to adjust contrast, brightness, and more.';

  @override
  String get audioSubAlbum => 'ÁLBUM';

  @override
  String get audioSubSongs => 'CANCIONES';

  @override
  String get audioSubArtist => 'ARTISTA';

  @override
  String get audioSubFolder => 'CARPETA';

  @override
  String get audioSubPlaylist => 'LISTA';

  @override
  String get noAudioFound => 'No se encontró audio en este dispositivo';

  @override
  String get searchAudio => 'Buscar audio';

  @override
  String get unknownArtist => '<desconocido>';

  @override
  String songCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count canciones',
      one: '1 canción',
    );
    return '$_temp0';
  }

  @override
  String get audioPlaylistHint =>
      'Las listas de reproducción llegarán en una actualización futura.';

  @override
  String get backgroundPlaybackTitle =>
      'Permitir reproducción continua en segundo plano';

  @override
  String get backgroundPlaybackBody =>
      'Para evitar que el sistema detenga la reproducción, conceda el permiso necesario.';

  @override
  String get queue => 'Cola';

  @override
  String get shuffleAll => 'MEZCLAR TODO';

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
