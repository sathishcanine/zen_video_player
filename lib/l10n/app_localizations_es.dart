// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Zen';

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
  String get languageEnglish => 'Inglés';

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
  String get languageTutorialTitle => 'Elige tu idioma';

  @override
  String get languageTutorialBody =>
      'Toca el botón de idioma para cambiar entre tamil, inglés, hindi y telugu.';

  @override
  String get gotIt => 'Entendido';

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
