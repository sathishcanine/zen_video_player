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
}
