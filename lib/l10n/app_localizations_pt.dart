// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Zen';

  @override
  String get appNameFull => 'Zen Video Player';

  @override
  String get accessYourMedia => 'Acesse suas mídias';

  @override
  String mediaAccessDescription(String appName) {
    return 'O $appName precisa de acesso aos seus arquivos de mídia para encontrar e reproduzir vídeos e músicas no seu dispositivo.';
  }

  @override
  String get featurePlayLocal => 'Reproduzir vídeos e áudio locais';

  @override
  String get featureBrowseFiles => 'Navegar arquivos com facilidade';

  @override
  String get featureLockPrivate => 'Bloquear pastas privadas';

  @override
  String get allowAccess => 'Permitir acesso';

  @override
  String get allFilesAccessRequired =>
      'Please turn on Allow permission for All files access in Settings to continue.';

  @override
  String get notNow => 'Agora não';

  @override
  String get permissionRequired =>
      'O acesso à mídia é necessário para navegar na biblioteca. Você pode permitir nas Configurações.';

  @override
  String get openSettings => 'Abrir Configurações';

  @override
  String get tabVideo => 'Vídeo';

  @override
  String get tabAudio => 'Áudio';

  @override
  String get tabSettings => 'Configurações';

  @override
  String get pillPlaylist => 'PLAYLIST';

  @override
  String get pillMediaServer => 'SERVIDOR';

  @override
  String get pillNetworkStream => 'STREAM';

  @override
  String get comingSoon => 'Em breve';

  @override
  String get audioTabHint =>
      'A navegação de áudio estará disponível em uma atualização futura.';

  @override
  String get settingsTabHint =>
      'As configurações estarão disponíveis em uma atualização futura.';

  @override
  String get folderRecentlyAdded => 'Adicionados recentemente';

  @override
  String videoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vídeos',
      one: '1 vídeo',
    );
    return '$_temp0';
  }

  @override
  String folderSizeSummary(String count, String size) {
    return '$count • $size';
  }

  @override
  String get badgeNew => 'NOVO';

  @override
  String get noVideosFound => 'Nenhum vídeo encontrado neste dispositivo';

  @override
  String get grantAccessToBrowse =>
      'Permita o acesso à mídia para navegar nas pastas.';

  @override
  String get pickVideoFile => 'Escolher um vídeo';

  @override
  String get playFromUrl => 'Reproduzir por URL';

  @override
  String get pasteVideoUrl => 'Cole a URL do vídeo aqui';

  @override
  String get playVideo => 'Reproduzir';

  @override
  String get searchFolders => 'Buscar pastas';

  @override
  String get clearSearch => 'Limpar';

  @override
  String searchResultsFor(String query) {
    return 'Resultados de \"$query\"';
  }

  @override
  String get cast => 'Transmitir';

  @override
  String get moreOptions => 'Mais';

  @override
  String get loadingLibrary => 'Carregando biblioteca…';

  @override
  String get calculatingSize => 'Calculando…';

  @override
  String videosInFolder(String folder) {
    return 'Vídeos em $folder';
  }

  @override
  String get permissionWhyTitle => 'Por que o app precisa de permissão';

  @override
  String permissionWhyBody1(String appName) {
    return 'O $appName precisa de acesso a vídeos, músicas e legendas no seu dispositivo para funcionar corretamente.';
  }

  @override
  String get permissionWhyBody2 =>
      'O acesso a arquivos é usado para descobrir e reproduzir mídia no seu telefone. Após permitir, você verá pastas com seus vídeos no app.';

  @override
  String permissionWhyPrivacy(String appName) {
    return 'O $appName promete não usar essas permissões para acessar seus dados privados.';
  }

  @override
  String get permissionWhyMoreInfo => 'Para mais informações';

  @override
  String get permissionWhySupportUrl =>
      'https://support.google.com/googleplay/android-developer/answer/10467955';

  @override
  String get ok => 'OK';

  @override
  String get skip => 'Pular';

  @override
  String get next => 'Próximo';

  @override
  String get getStarted => 'Começar';

  @override
  String get onboardingTitle1 => 'Player de mídia completo';

  @override
  String get onboardingPictureModes => 'Modos de imagem';

  @override
  String get pictureModeStandard => 'Padrão';

  @override
  String get pictureModeVivid => 'Vívido';

  @override
  String get pictureModeGame => 'Jogo';

  @override
  String get pictureModeMovie => 'Filme';

  @override
  String get pictureModeCozy => 'Aconchego';

  @override
  String get pictureModeDynamic => 'Dinâmico';

  @override
  String get onboardingSubtitle1 =>
      'Player HDR para todos os arquivos. Player de música poderoso para toda a biblioteca.';

  @override
  String get onboardingTitle2 => 'Experiência de áudio premium';

  @override
  String get onboardingSubtitle2 =>
      'Equalizador cristalino com graves reais. Visualizadores de música elegantes.';

  @override
  String get onboardingTitle3 => 'Visualizadores impressionantes';

  @override
  String get onboardingSubtitle3 =>
      'Equalizador nítido. Graves profundos. Visualizadores elegantes.';

  @override
  String get onboardingTitle4 => 'Recursos avançados';

  @override
  String get onboardingSubtitle4 =>
      'Baixe legendas para qualquer vídeo. Pasta segura para privacidade.';

  @override
  String get chooseLanguage => 'Escolher idioma';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageTamil => 'Tâmil';

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
  String get languageTutorialTitle => 'Escolha seu idioma';

  @override
  String get languageTutorialBody =>
      'Toque no botão de idioma para alternar entre tâmil, inglês, hindi e telugu.';

  @override
  String get gotIt => 'Entendi';

  @override
  String get colorTutorialTitle => 'Color filters';

  @override
  String get colorTutorialBody =>
      'Choose a look for your video — tap a preset or open Custom to adjust contrast, brightness, and more.';

  @override
  String get audioSubAlbum => 'ÁLBUM';

  @override
  String get audioSubSongs => 'MÚSICAS';

  @override
  String get audioSubArtist => 'ARTISTA';

  @override
  String get audioSubFolder => 'PASTA';

  @override
  String get audioSubPlaylist => 'PLAYLIST';

  @override
  String get noAudioFound => 'Nenhum áudio encontrado neste dispositivo';

  @override
  String get searchAudio => 'Buscar áudio';

  @override
  String get unknownArtist => '<desconhecido>';

  @override
  String songCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count músicas',
      one: '1 música',
    );
    return '$_temp0';
  }

  @override
  String get audioPlaylistHint =>
      'Playlists estarão disponíveis em uma atualização futura.';

  @override
  String get backgroundPlaybackTitle =>
      'Permitir reprodução contínua em segundo plano';

  @override
  String get backgroundPlaybackBody =>
      'Para evitar que o sistema interrompa a reprodução, conceda a permissão necessária.';

  @override
  String get queue => 'Fila';

  @override
  String get shuffleAll => 'EMBARALHAR TUDO';

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
  String get proBadge => 'PRO';

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
}
