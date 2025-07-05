//commit 29-05-2025 17:00
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_article_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_intervention_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_listarticle_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_listpiece_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_parc2_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_parc_model.dart';
import 'package:srasav_vf_v1/features/user/domain/repositories/user_repository.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/calendar_page.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/firebase_api.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/loading_screen.dart';
import 'features/user/data/data_sources/user_remote_data_source.dart';
import 'features/user/data/repositories/parc_repository_impl.dart';
import 'features/user/data/repositories/user_repository_impl.dart';
import 'features/user/domain/usecases/fetch_article_list_usecase.dart';
import 'features/user/domain/usecases/fetch_parc_list_usecase.dart';
import 'features/user/domain/usecases/fetch_parc_usecase.dart';
import 'features/user/domain/usecases/get_interventions_by_id_usecase.dart';
import 'features/user/domain/usecases/get_user_by_id_usecase.dart';
import 'features/user/domain/usecases/login_usecase.dart';
import 'features/user/domain/usecases/update_intervention_usecase.dart';
import 'features/user/presentation/blocs/login/login_bloc.dart';
import 'features/user/presentation/blocs/parc/parc_bloc.dart';
import 'features/user/presentation/blocs/parc/parc_event.dart';
import 'features/user/presentation/blocs/timer/timer_bloc.dart';
import 'features/user/presentation/blocs/intervention/intervention_bloc.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';

final navigatorKey = GlobalKey<NavigatorState>();



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuration pour afficher la barre de statut
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.top, // Affiche la barre de statut en haut
    SystemUiOverlay.bottom, // Affiche la barre de navigation en bas (optionnel)
  ]);
  await deleteSignatureImages();

  final userRepository = UserRepositoryImpl();
  final remoteDataSource = UserRemoteDataSource();
  final parcRepository = ParcRepositoryImpl(remoteDataSource: remoteDataSource);

  final updateInterventionUsecase = UpdateInterventionUseCase(userRepository);
  final getUserByIdUsecase = GetUserById(userRepository);
  final getInterventionsByIdUsecase = GetInterventionsById(userRepository);
  final fetchParcsUsecase = FetchParcs(repository: parcRepository);
  final fetchParcsListUsecase = FetchParcsList(repository: parcRepository);
  final fetchArticlesListUsecase = FetchArticleList(repository: parcRepository);
  WidgetsFlutterBinding.ensureInitialized();

// Initialiser Hive
  await Hive.initFlutter();

// Enregistrer les adaptateurs
  Hive.registerAdapter(LocalInterventionAdapter());
  Hive.registerAdapter(LocalParcAdapter());
  Hive.registerAdapter(LocalArticleAdapter());

  Hive.registerAdapter(LocalListArticleAdapter());

  Hive.registerAdapter(LocalPieceArticleAdapter());

  Hive.registerAdapter(LocalParc2Adapter());

// Ouvrir les boîtes de données sauvgardées en local
  await Hive.openBox<LocalIntervention>('interventions');
  await Hive.openBox<LocalParc>('parcs');
  await Hive.openBox<LocalArticle>('articles');

//LocalListArticle == le model local (HIVE) des element de liste de choix de Main d'oeuvre
  await Hive.openBox<LocalListArticle>('BoxMainOeuvreList');

//LocalPieceArticle == le model local (HIVE) des element de liste de choix de Piece
  await Hive.openBox<LocalPieceArticle>('BoxPieceList');

//LocalParc2 == le model local (HIVE) des element de liste de choix de Parc
  await Hive.openBox<LocalParc2>('parcs2');

  

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => getUserByIdUsecase),
        Provider(create: (_) => getInterventionsByIdUsecase),
        Provider(create: (_) => fetchParcsUsecase),
        Provider(create: (_) => fetchParcsListUsecase),
        Provider(create: (_) => fetchArticlesListUsecase),
        Provider(create: (_) => updateInterventionUsecase),
        Provider<UserRepository>(create: (_) => userRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => TimerBloc()),
          BlocProvider(
            create: (context) {
              final parcBloc = ParcBloc(
                context.read<FetchParcsList>(),
                context.read<FetchArticleList>(),
                fetchParcs: context.read<FetchParcs>(),
              );
              parcBloc.add(LoadAllParcs());
              return parcBloc;
            },
          ),
          BlocProvider(
              create: (context) =>
                  InterventionBloc(context.read<GetInterventionsById>())),
        ],
        child: const MyApp(),
      ),
    ),
  );

  await Firebase.initializeApp();

  // Initialiser App Check avec Play Integrity
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity, // Ou SafetyNet
  );

  // Définir la langue de l'utilisateur (optionnel)
  await FirebaseAuth.instance.setLanguageCode('fr');

    // Initialiser App Check en mode débogage
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, // Mode débogage
  );

 await FirebaseApi().initNotifications();
}

Future<void> deleteSignatureImages() async {
  try {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory imagesDir = Directory('${appDocDir.path}/images');
    final String techSignaturePath =
        '${imagesDir.path}/signatureTechnicien.png';
    final String clientSignaturePath = '${imagesDir.path}/signatureClient.png';

    final File techFile = File(techSignaturePath);
    final File clientFile = File(clientSignaturePath);

    if (await techFile.exists()) {
      await techFile.delete();
    }

    if (await clientFile.exists()) {
      await clientFile.delete();
    }
  } catch (e) {
    debugPrint('Erreur lors de la suppression des signatures : $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  String? email;
  String? password;
  String? name;
  String? pdffirebaselink;


  @override
  void initState() {
    super.initState();
    _loadSharedPreferences();
    _loadFireBasePdflink();
  }

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'fr';

    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', '')],
      locale: const Locale('fr', ''),
      title: 'SRASAV V1',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorKey: navigatorKey,
      home: (email != null && password != null && name != null)
          ? const InterventionCalendarPage()
          : BlocProvider(
              create: (context) =>
                  LoginBloc(LoginUseCase(UserRepositoryImpl())),
              child: const LoadingScreen(),
            ),
    routes: {
    InterventionCalendarPage.route:(context)=> InterventionCalendarPage()
    //NotificationScreen.route:(context)=> InterventionCalendarPage();;;;;;
    },
    );
  }

  Future<void> _loadSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email');
    password = prefs.getString('password');
    name = prefs.getString('name');

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFireBasePdflink() async {
    final prefs = await SharedPreferences.getInstance();
    pdffirebaselink = prefs.getString('pdffirebaselink');

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
