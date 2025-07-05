//HIVE + SOAP DONE
// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:srasav_vf_v1/features/user/data/models/local_intervention_model.dart';
import 'package:srasav_vf_v1/features/user/domain/repositories/user_repository.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/intervention/intervention_bloc.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/intervention/intervention_event.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/intervention/intervention_state.dart';

import 'package:srasav_vf_v1/features/user/presentation/blocs/timer/timer_bloc.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/timer/timer_event.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/timer/timer_state.dart';

import 'package:srasav_vf_v1/features/user/presentation/pages/calendar_page.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/components/build_card_widget.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/details_parcs_intervention.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/general_tools/theme_tools.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/map_page.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/site_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class InterventionDetailsPage extends StatefulWidget {
  final String adressFromMap;
  const InterventionDetailsPage({
    required this.adressFromMap,
    super.key,
  });

  @override
  _InterventionDetailsPageState createState() =>
      _InterventionDetailsPageState();
}

class _InterventionDetailsPageState extends State<InterventionDetailsPage> {
  late InterventionBloc interventionBloc;
  late InterventionState currentState;

  var selectedIntervention;

  var parcs;

  String name = '';

  var counterText;

  var stableDuration;

  String? loacalDuration;

  var pickedRealTime;

  var updateData;

  var var1;
  var var2;
  var var3;
  var var4;
  var var5;
  var var6;
  var var7;

  bool saveState = false;

  bool isReset = false;

  late String? firstStartDay;

  late String? lastStartDay;

  late String? firstTime;

  late String? lastTime;

  var _isLoading = true;

  bool _isEmailValid(String email) {
    final emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return email.isEmpty || emailRegExp.hasMatch(email);
  }

// Fonction de validation du numéro de téléphone à ajouter dans votre classe
  bool _isValidPhoneNumber(String phone) {
    // Vérifie que le numéro contient entre 8 et 15 chiffres
    // La plupart des numéros internationaux sont dans cette plage
    return phone.isEmpty || (phone.length >= 8 && phone.length <= 15);
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController tellController = TextEditingController();

  late TextEditingController _siteController = TextEditingController();

  bool isTerminated = false;
  var shp_countertext;

  @override
  void initState() {
    super.initState();

    interventionBloc = BlocProvider.of<InterventionBloc>(context);
    currentState = interventionBloc.state;

    if (currentState is InterventionSelected) {
      selectedIntervention = (currentState as InterventionSelected).selecteditv;
      print(
          "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR");

      print(
          "ID de l'intervention : ${selectedIntervention.technicienname ?? 'CODE NAME'}");
      // Afficher les détails de l'intervention sélectionnée
      print("Détails de l'intervention sélectionnée:");
      print("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF");
      print(
          "Is Sent : ${selectedIntervention.isSaved.toString()?? 'J C PAS'}");
      print(
          "ID de l'intervention : ${selectedIntervention.id ?? 'Non spécifié'}");
      print(
          "Date de l'intervention : ${selectedIntervention.date ?? 'Non spécifiée'}");
      print("Email : ${selectedIntervention.email ?? 'Non rempli'}");
      print("Téléphone : ${selectedIntervention.tel ?? 'Non rempli'}");
      print(
          "ATITSAT: ${selectedIntervention.attitudeApparenceItv ?? 'Non rempli'}");
      print(
          "ATITSAT: ${selectedIntervention.attitudeApparenceItv ?? 'Non rempli'}");
      print(
          "REAL DURATION: ${selectedIntervention.realduration ?? '00:00:00'}");

      final parcs = selectedIntervention.parcs ?? [];
      if (parcs.isNotEmpty) {
        print("Parcs associés à l'intervention :");
        for (var parc in parcs) {
          print(
              "  - Parc ID: ${parc.id}, Désignation: ${parc.designation ?? 'Non spécifiée'}");

          // Charger les articles associés au parc
          final articles = parc.articles ?? [];
          if (articles.isNotEmpty) {
            print("    Articles associés au parc :");
            for (var article in articles) {
              print(
                  "      * Article ID: ${article.id}, Désignation: ${article.designation ?? 'Non spécifiée'}, "
                  "Quantité: ${article.quantity ?? 'Non spécifiée'}, Type: ${article.type ?? 'Non spécifié'}");
            }
          } else {
            print("    Aucun article associé au parc.");
          }
        }
      } else {
        print("Aucun parc associé à l'intervention sélectionnée.");
      }
    } else {
      print(
          "Erreur : L'état actuel n'est pas InterventionSelected. État : $currentState");
    }

    // Initialisation des champs texte
    pickedRealTime =
        DateTime.now().toString().substring(11, 16).replaceAll(':', '');
    emailController.text =
        (currentState as InterventionSelected).selecteditv.email ??
            'E-mail non rempli';
    tellController.text =
        (currentState as InterventionSelected).selecteditv.tel ??
            'Téléphone non rempli';

    isTerminated =
        (currentState as InterventionSelected).selecteditv.state == 'terminé';

    loacalDuration = calcDuration(
        (currentState as InterventionSelected).selecteditv.realstarttimelist,
        (currentState as InterventionSelected).selecteditv.realendtimelist);

    print("DATE - TIME - DURATION : FROM INIT STATE");

    firstStartDay = (currentState as InterventionSelected)
            .selecteditv
            .realstartdaylist!
            .isNotEmpty
        ? (currentState as InterventionSelected)
            .selecteditv
            .realstartdaylist!
            .first
        : "00000000";

    print("FIRST DAY $firstStartDay");

    lastStartDay = (currentState as InterventionSelected)
            .selecteditv
            .realstartdaylist!
            .isNotEmpty
        ? (currentState as InterventionSelected)
            .selecteditv
            .realstartdaylist!
            .last
        : "00000000";

    print("LAST  DAY $lastStartDay");

    firstTime = (currentState as InterventionSelected)
            .selecteditv
            .realstarttimelist!
            .isNotEmpty
        ? (currentState as InterventionSelected)
            .selecteditv
            .realstarttimelist!
            .first
        : "000000";

    print("FIRST TIME $firstTime");
    print("FIRST TIME ${firstTime!.substring(0, 4)}");

    lastTime = (currentState as InterventionSelected)
            .selecteditv
            .realendtimelist!
            .isNotEmpty
        ? (currentState as InterventionSelected)
            .selecteditv
            .realendtimelist!
            .last
        : "000000";

    print("LAST  TIME $lastTime  ");
    print("LAST  TIME ${lastTime!.substring(0, 4)}");

    print("DURATION $loacalDuration");

    print(
        "DURATION **${(currentState as InterventionSelected).selecteditv.realduration!.replaceAll(':', '')}");

//stableDuration =  calculateTotalSeconds(loacalDuration);
    print("**counterText**");
    print(counterText);

    print(
        "shp_countertext shp_countertext shp_countertext shp_countertext shp_countertext shp_countertext");
    print(shp_countertext);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final isArrowBack = prefs.getBool('chronoArrowBackState') ?? false;

      if (!isArrowBack) {
        // Si ouverture normale
        final durationString =
            (currentState as InterventionSelected).selecteditv.realduration;

        if (durationString != null && durationString.isNotEmpty) {
          try {
            final totalSeconds =
                calculateTotalSeconds(durationString.replaceAll(':', ''));
            context.read<TimerBloc>().add(TimerSetInitial(totalSeconds));
            if (kDebugMode) print('Timer initialisé à: $totalSeconds secondes');
          } catch (e) {
            context.read<TimerBloc>().add(TimerSetInitial(0));
            if (kDebugMode) print('Erreur d\'initialisation: $e');
          }
        } else {
          context.read<TimerBloc>().add(TimerSetInitial(0));
        }
      } else {
        if (kDebugMode) print('Mode retour arrière - pas d\'initialisation');
      }
    });
  }

  String getCurrentDate() {
    return DateTime.now().toString().substring(0, 10).replaceAll('-', '');
  }

  String formatDuration(String? durationString) {
    // Extraire les parties : heures, minutes et secondes
    String hours = durationString!.substring(0, 2); // 1er et 2eme caractère
    String minutes = durationString.substring(2, 4); // 3e et 4e caractères
    String seconds = durationString.substring(4, 6); // 5e et 6e caractères

    // Combiner avec ':'
    return "$hours:$minutes:$seconds";
  }

  Timer? _timer;

  List<String> localStartTimelist = ["10:00", "12:12"];

  List<String> localEndTimelist = [];

  String? varStart;

  String? varEnd;

  bool isRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String calcDuration(
      List<String>? realstarttimelist, List<String>? realendtimelist) {
    if (realstarttimelist == null ||
        realendtimelist == null ||
        realstarttimelist.isEmpty ||
        realendtimelist.isEmpty) {
      return "000000"; // Gérer le cas des listes vides ou nulles
    }

    // Vérifier que les listes ont la même longueur
    if (realstarttimelist.length != realendtimelist.length) {
      return "000000"; // Gérer le cas où les listes n'ont pas la même longueur
    }

    // Initialiser la durée totale en secondes
    int totalDurationInSeconds = 0;

    // Itérer sur les paires d'éléments des deux listes
    for (int i = 0; i < realstarttimelist.length; i++) {
      // Extraire l'heure, les minutes et les secondes du startTime
      String start = realstarttimelist[i];
      String end = realendtimelist[i];

      // Convertir le startTime en secondes depuis minuit
      int startHours =
          int.parse(start.substring(0, 2)); // 1ere 2eme caractères : heures
      int startMinutes =
          int.parse(start.substring(2, 4)); // 3eme et 4eme caractères : minutes
      int startSeconds = int.parse(
          start.substring(4, 6)); // 5eme et 6eme caractères : secondes
      int startTotalSeconds =
          (startHours * 3600) + (startMinutes * 60) + startSeconds;

      // Convertir le endTime en secondes depuis minuit
      int endHours = int.parse(end.substring(0, 2)); // 1er caractère : heures
      int endMinutes =
          int.parse(end.substring(2, 4)); // 2e et 3e caractères : minutes
      int endSeconds =
          int.parse(end.substring(4, 6)); // 4e et 5e caractères : secondes
      int endTotalSeconds = (endHours * 3600) + (endMinutes * 60) + endSeconds;

      // Ajouter la différence des secondes de cette paire à la durée totale
      totalDurationInSeconds += (endTotalSeconds - startTotalSeconds);
    }

    // Vérifier si la durée totale est négative (cela signifie que l'heure de fin est avant l'heure de début)
    if (totalDurationInSeconds < 0) {
      return "00000"; // Retourner 00000 si la durée est négative
    }

    // Convertir la durée totale en heures, minutes et secondes
    int hours = totalDurationInSeconds ~/ 3600;
    int minutes = (totalDurationInSeconds % 3600) ~/ 60;
    int seconds = totalDurationInSeconds % 60;

    // Formater la durée en "HHMMSS" avec 5 caractères
    String formattedHours = hours.toString().padLeft(2, '0');
    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = seconds.toString().padLeft(2, '0');

    return '$formattedHours$formattedMinutes$formattedSeconds';
  }

  int calculateTotalSeconds(String? stringDuration) {
    if (stringDuration!.length != 6) {
      print("La chaîne doit contenir exactement 6 caractères.");
    }

    // Extraire les heures, minutes et secondes
    int hours = int.parse(stringDuration.substring(0, 2)); // 1er caractère
    int minutes =
        int.parse(stringDuration.substring(2, 4)); // 2e et 3e caractères
    int seconds =
        int.parse(stringDuration.substring(4, 6)); // 4e et 5e caractères

    // Calculer la durée totale en secondes
    int totalSeconds = (hours * 3600) + (minutes * 60) + seconds;

    return totalSeconds;
  }

  String formatTime(int totalSeconds) {
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String getCurrentTime() {
    return DateTime.now().toString().substring(11, 16).replaceAll(':', '');
  }

  DateTime parseDate(String dateString) {
    if (dateString.length != 8) {
      throw const FormatException(
          "La chaîne de date doit comporter 8 caractères au format yyyyMMdd");
    }
    int year = int.parse(dateString.substring(0, 4));
    int month = int.parse(dateString.substring(4, 6));
    int day = int.parse(dateString.substring(6, 8));
    return DateTime(year, month, day);
  }

  TimeOfDay parseDuration(String durationString) {
    if (durationString.length != 5) {
      throw const FormatException(
          "La chaîne de durée doit comporter 5 caractères au format xHHMM");
    }
    String relevantPart = durationString.substring(1);
    int hours = int.parse(relevantPart.substring(0, 2));
    int minutes = int.parse(relevantPart.substring(2, 4));
    return TimeOfDay(hour: hours, minute: minutes);
  }

  String timeOfDayToString(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return "$hours H $minutes M";
  }

  TimeOfDay parseTime(String timeString) {
    if (timeString.length != 4) {
      throw const FormatException(
          "La chaîne de temps doit comporter 4 caractères au format HHmm");
    }

    int hour = int.parse(timeString.substring(0, 2));
    int minute = int.parse(timeString.substring(2, 4));

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw const FormatException(
          "Les heures doivent être entre 00 et 23, et les minutes entre 00 et 59");
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Combine une date et un temps pour retourner un DateTime formaté
  String combineDateAndTime(String dateString, String timeString) {
    DateTime date = parseDate(dateString);
    TimeOfDay time = parseTime(timeString);

    DateTime dateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    // Retourne la date et l'heure au format 'yyyy-MM-dd HH:mm'
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  int convertAndRoundTime(String timeStr) {
    // Vérifie si la chaîne est valide (exactement 5 caractères)
    if (timeStr.length != 5 || !RegExp(r'^\d+$').hasMatch(timeStr)) {
      throw ArgumentError('La chaîne doit être de 5 chiffres.');
    }

    // Extraire les 4 derniers caractères et les convertir en minutes et secondes
    String durationStr = timeStr.substring(1); // Ignore le premier caractère
    int minutes = int.parse(durationStr.substring(
        0, 2)); // Les 2 premiers chiffres pour les minutes
    int seconds = int.parse(
        durationStr.substring(2)); // Les 2 derniers chiffres pour les secondes

    // Conversion totale en minutes (float)
    double totalMinutes = minutes + (seconds / 60);

    // Retourner la valeur arrondie en entier
    return totalMinutes.round();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    String name = (currentState as InterventionSelected)
        .selecteditv
        .technicienname
        .toString();
    final regex = RegExp(r'[A-Za-z]');
    name = name.split('').where((char) => regex.hasMatch(char)).join('');

    return WillPopScope(
        onWillPop: () async {
          // Empêche le retour à la page précédente (page login)
          return false;
        },
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize:
                const Size.fromHeight(60), // Hauteur totale de l'AppBar
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: const Text(
                    'Détails de l\'intervention',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontFamily: 'RobotoMono',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: ThemeColors.buildCardBlue,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () async {
                      if ((currentState as InterventionSelected)
                                  .selecteditv
                                  .state !=
                              'terminé' &&
                          saveState == false) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Row(
                              children: [
                                Icon(Icons.save,
                                    size: 24,
                                    color: ThemeColors
                                        .buildCardBlue), // Icône de sauvegarde
                                SizedBox(
                                    width:
                                        8), // Espacement entre l'icône et le texte
                                Text(
                                  "Rappel de sauvegarde",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: ThemeColors.buildCardBlue,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            content: const Text(
                              "Merci de sauvegarder localement afin d'assurer une conservation optimale du traitement de l'intervention.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            actions: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "Annuler",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeColors.buildCardBlue,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const InterventionCalendarPage(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Continuer",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeColors.buildCardBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const InterventionCalendarPage(),
                          ),
                        );
                      }
                      context.read<TimerBloc>().add(TimerPaused());
                      if ((currentState as InterventionSelected)
                              .selecteditv
                              .realendtimelist!
                              .length !=
                          (currentState as InterventionSelected)
                              .selecteditv
                              .realstarttimelist!
                              .length) {
                        (currentState as InterventionSelected)
                            .selecteditv
                            .realendtimelist
                            ?.add(DateTime.now()
                                .toString()
                                .substring(11, 19)
                                .replaceAll(':', ''));

                        print(
                            "REAL START LIST NOWWW*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-");
                        print((currentState as InterventionSelected)
                            .selecteditv
                            .realstarttimelist
                            .toString());

                        print(
                            "REAL END LIST NOWWW*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-");
                        print((currentState as InterventionSelected)
                            .selecteditv
                            .realendtimelist
                            .toString());

                        print(
                            "DAY OF WORKS LIST DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
                        print((currentState as InterventionSelected)
                            .selecteditv
                            .realstartdaylist
                            .toString());
                      } else {
                        print(
                            "REAL START LIST NOWWW*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-");
                        print((currentState as InterventionSelected)
                            .selecteditv
                            .realstarttimelist
                            .toString());

                        print(
                            "REAL END LIST NOWWW*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-");
                        print((currentState as InterventionSelected)
                            .selecteditv
                            .realendtimelist
                            .toString());

                        print(
                            "DAY OF WORKS LIST DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
                        print((currentState as InterventionSelected)
                            .selecteditv
                            .realstartdaylist
                            .toString());
                      }
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('chronoArrowBackState', false);
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      color: Colors.white,
                      onPressed: () async{
                           var connectivityResult = await Connectivity().checkConnectivity();
    bool hasConnection = connectivityResult != ConnectivityResult.none;

    if (!hasConnection) {
      // ❌ Pas de connexion : afficher un SnackBar et annuler le refresh
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pas de connexion Internet – Utilisation des données locales (mode hors ligne) 🌐🚫'),
          backgroundColor: ThemeColors.burgundy,
          duration: Duration(milliseconds: 3000),
        ),
      );
      return;
    }
                        print('refresh button clicked');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Actualisation de données 🔁'),
                            backgroundColor: Color.fromARGB(255, 24, 113, 172),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  height: 3,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CardUtils.buildCard(
                        context: context,
                        interventionIdLabel: 'Intervention ID : ',
                        interventionIdValue:
                            (currentState as InterventionSelected)
                                .selecteditv
                                .id
                                .toString(),
                        datedebutplanfieeValue: combineDateAndTime(
                          (currentState as InterventionSelected)
                                  .selecteditv
                                  .date ??
                              '00000000',
                          (currentState as InterventionSelected)
                                  .selecteditv
                                  .debuteHour ??
                              '0000',
                        ).toString(),
                        datefinplanfieeValue: combineDateAndTime(
                          (currentState as InterventionSelected)
                                  .selecteditv
                                  .enddate ??
                              '00000000',
                          (currentState as InterventionSelected)
                                  .selecteditv
                                  .finishHour ??
                              '0000',
                        ).toString(),
                        child: BlocBuilder<TimerBloc, TimerState>(
                          builder: (context, state) {
                            // print(state.counter);
                            counterText =
                                (state is TimerRunning || state is TimerPausing)
                                    ? formatTime(state.counter)
                                    : formatTime(state.counter);

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildInfoColumn(
                                  icon: FontAwesomeIcons.solidClock,
                                  text1: counterText,
                                  text2: timeOfDayToString(
                                    parseDuration(
                                      (currentState as InterventionSelected)
                                              .selecteditv
                                              .duration ??
                                          "00000",
                                    ),
                                  ),
                                ),

                                // Espacement réduit entre les colonnes et la ligne
                                const SizedBox(height: 8),
// Ligne pour les boutons de contrôle (play/pause et reset)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // Centrer les boutons horizontalement
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isTerminated
                                            ? Colors.grey
                                            : ThemeColors.bleuCiel,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      width: MediaQuery.of(context).size.width *
                                          0.08,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.08,
                                      child: BlocBuilder<TimerBloc, TimerState>(
                                        builder: (context, state) {
                                          isRunning = state
                                              is TimerRunning; // Détermine si le timer est en cours

                                          // Affectation de pickedRealTime lors de la première activation de isRunning
                                          if (!isRunning! &&
                                              pickedRealTime == null) {
                                            pickedRealTime = DateTime.now()
                                                .toString()
                                                .substring(11, 16)
                                                .replaceAll(':', '');
                                            print(
                                                'Picked real time: $pickedRealTime'); // Debug
                                          }

                                          return IconButton(
                                            icon: Icon(
                                              isRunning
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              color: Colors.white,
                                            ),
                                            onPressed: isTerminated
                                                ? null
                                                : () {
                                                    if (isRunning) {
                                                      context
                                                          .read<TimerBloc>()
                                                          .add(TimerPaused());

                                                      (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realendtimelist
                                                          ?.add(DateTime.now()
                                                              .toString()
                                                              .substring(11, 19)
                                                              .replaceAll(
                                                                  ':', ''));

                                                      print(
                                                          "REAL START LIST NOWWW*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-");
                                                      print((currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realstarttimelist
                                                          .toString());

                                                      print(
                                                          "REAL END LIST NOWWW*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-");
                                                      print((currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realendtimelist
                                                          .toString());

                                                      print(
                                                          "DAY OF WORKS LIST DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
                                                      print((currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realstartdaylist
                                                          .toString());
                                                    } else {
                                                      context
                                                          .read<TimerBloc>()
                                                          .add(TimerStarted());

                                                      (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realstarttimelist
                                                          ?.add(DateTime.now()
                                                              .toString()
                                                              .substring(11, 19)
                                                              .replaceAll(
                                                                  ':', ''));

                                                      print(
                                                          "REAL START LIST NOWWW*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-");
                                                      print((currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realstarttimelist
                                                          .toString());

                                                      print(
                                                          "REAL END LIST NOWWW*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-");
                                                      print((currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realendtimelist
                                                          .toString());

                                                      (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realstartdaylist
                                                          ?.add(DateTime.now()
                                                              .toString()
                                                              .substring(0, 10)
                                                              .replaceAll(
                                                                  '-', ''));
                                                      print(
                                                          "DAY OF WORKS LIST DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
                                                      print((currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realstartdaylist
                                                          .toString());
                                                    }
                                                  },
                                          );
                                        },
                                      ),
                                    ),
                                    // Espacement horizontal réduit
                                    const SizedBox(width: 12),

                                    Container(
                                      decoration: BoxDecoration(
                                        color: isTerminated
                                            ? Colors.grey
                                            : ThemeColors
                                                .bleuCiel, // Fond gris si terminé
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      width: MediaQuery.of(context).size.width *
                                          0.08,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.08,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons
                                              .refresh, // Icône pour le bouton reset
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                          color: Colors
                                              .white, // Icône reste blanche
                                        ),
                                        onPressed: isTerminated
                                            ? null
                                            : () {
                                                context
                                                    .read<TimerBloc>()
                                                    .add(TimerReset());

                                                print(
                                                    "DURATIONNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN");
                                                loacalDuration = calcDuration(
                                                    (currentState
                                                            as InterventionSelected)
                                                        .selecteditv
                                                        .realstarttimelist,
                                                    (currentState
                                                            as InterventionSelected)
                                                        .selecteditv
                                                        .realendtimelist);
                                                print(loacalDuration);
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                  context.read<TimerBloc>().add(
                                                      TimerSetInitial((0)));
                                                });
                                                isReset = true;
                                              },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        )),

                    SizedBox(height: screenHeight * 0.02), // Taille dynamique
                    Column(
                      children: [
                        _textViewItem(
                            Icons.description,
                            'Description',
                            (currentState as InterventionSelected)
                                    .selecteditv
                                    .description ??
                                'Non défini'),
                        _textViewItem(
                            Icons.person,
                            'Technicien',
                            (currentState as InterventionSelected)
                                    .selecteditv
                                    .technicienRealName ??
                                'Non défin i'),
                        _textViewItem(
                            Icons.wifi,
                            'Couverture Globale',
                            (currentState as InterventionSelected)
                                    .selecteditv
                                    .couvertureglobale ??
                                'Non défini'),
                        _textViewItem(
                            Icons.type_specimen,
                            'Type',
                            (currentState as InterventionSelected)
                                    .selecteditv
                                    .type ??
                                'Non défini'),

                        _textViewItemAdr(
                            Icons.people,
                            'Client',
                            (currentState as InterventionSelected)
                                    .selecteditv
                                    .client ??
                                'Non défini'),
                        _textViewItemSite(
                          Icons.location_city,
                          'Site Client',
                           widget.adressFromMap??'Non défini',
                              
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            //color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8.0),
                            border:
                                Border.all(color: ThemeColors.buildCardBlue),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Contact Client',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeColors.buildCardBlue,
                                  decoration: TextDecoration
                                      .underline, // Ajout du soulignement
                                ),
                              ),
                              SizedBox(height: 8.0),
                              _mailtextField(
                                  Icons.mail,
                                  'E-mail',
                                  emailController,
                                  currentState as InterventionSelected),
                              _phoneNumberTextField(
                                  Icons.phone_android_rounded,
                                  'Téléphone',
                                  tellController,
                                  currentState as InterventionSelected),
                            ],
                          ),
                        ),
                        //_mailtextField(Icons.mail,'E-mail',emailController),

                        //  _phoneNumberTextField(Icons.phone_android_rounded, 'Téléphone', tellController),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                        _buildNavigateButton(
                          label: 'Parcs',
                          onPressed: () {
                            // Condition pour la navigation autorisée
                            //bool canNavigate = isRunning || isTerminated;

                            // Condition pour le blocage
                            //  bool shouldBlock = !isRunning ;

                            if (isRunning == false || isTerminated == false) {
                              // Blocage si le timer est inactif ET l'intervention n'est pas terminée
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Row(
                                      children: [
                                        Icon(Icons.warning,
                                            size: 24,
                                            color: ThemeColors
                                                .buildCardBlue), // Icône de sauvegarde
                                        SizedBox(
                                            width:
                                                8), // Espacement entre l'icône et le texte
                                        Text(
                                          "Alerte",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: ThemeColors.buildCardBlue,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    content: const Text(
                                      "\nMerci d’activer le chronomètre avant de poursuivre.",
                                      style: TextStyle(
                                        //fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(
                                            0xFF000000), // Couleur noire pour le texte
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text(
                                          "OK",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: ThemeColors.buildCardBlue),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }

                            Future.delayed(const Duration(milliseconds: 100));

                            if (isRunning == true || isTerminated == true) {
                              // Navigation autorisée si le timer est actif OU l'intervention est terminée
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: interventionBloc,
                                    child: const DetailsParcsIntervention(),
                                  ),
                                ),
                              );
                            }
                            // context.read<TimerBloc>().add(TimerPaused());
                          },
                        ),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.005),
                        _buildNavigateButton2(
                          label: 'Sauvegarder Intervention',
                          colorButton: isTerminated
                              ? Colors.grey
                              : const Color.fromARGB(255, 21, 116, 194),
                          isterminatedstate: isTerminated,
                          onPressed: () async {
                            // Récupération de l'état actuel et de l'ID de l'intervention
                            final selectedItv =
                                (currentState as InterventionSelected)
                                    .selecteditv;
                            final id = selectedItv.id;

                            // Vérification que l'ID n'est pas nul
                            if (id == null) {
                              print(
                                  'Erreur : ID de l\'intervention introuvable');
                              return;
                            }

                            // Vérification que la box contient une intervention avec cet ID
                            if (!Hive.box<LocalIntervention>('interventions')
                                .containsKey(id)) {
                              print(
                                  'Erreur : Aucune intervention trouvée avec l\'ID $id');
                              return;
                            }
                            print("new lieu adressssssss");
                            print((currentState as InterventionSelected)
                                .selecteditv
                                .lieu);
                            // Mise à jour directe dans la box Hive
                            Hive.box<LocalIntervention>('interventions').put(
                              id,
                              LocalIntervention(
                                id: id,
                                isSaved: selectedItv.isSaved??false,
                                BL:selectedItv.BL??'',
                                description: selectedItv.description ??
                                    'Description par défaut',
                                duration:
                                    selectedItv.duration ?? 'Durée par défaut',
                                technicienRealName:
                                    selectedItv.technicienRealName ??
                                        'Nom technicien par défaut',
                                couvertureglobale:
                                    selectedItv.couvertureglobale ??
                                        'Couverture par défaut',
                                type: selectedItv.type ?? 'Type par défaut',
                                email: selectedItv.email ?? 'email@exemple.com',
                                tel: selectedItv.tel ?? '0000000000',
                                date: selectedItv.date ?? '01012025',
                                calendardate:
                                    selectedItv.calendardate ?? '01012025',
                                debuteHour: selectedItv.debuteHour ?? '0000',
                                enddate: selectedItv.enddate ?? '01012025',
                                finishHour: selectedItv.finishHour ?? '0000',
                                state:  'en pause',
                                client:
                                    selectedItv.client ?? 'Client par défaut',
                                lieu: selectedItv.lieu ?? 'Lieu par défaut',
                                parcs: selectedItv.parcs
                                    ?.map((parc) => parc.toLocalParc())
                                    .toList(),
                                ressources: selectedItv.ressources,
                                attitudeApparenceItv:
                                    selectedItv.attitudeApparenceItv ?? '',
                                qualityPrestationItv:
                                    selectedItv.qualityPrestationItv ?? '',
                                communicationItv:
                                    selectedItv.communicationItv ?? '',
                                globlementItv: selectedItv.globlementItv ?? '',
                                realstarttimelist:
                                    selectedItv.realstarttimelist,
                                realendtimelist: selectedItv.realendtimelist,
                                realstartdaylist: selectedItv.realstartdaylist,
                              ),
                            );

                            // Affichage du dialogue de succès de sauvegarde locale
                            await Future.delayed(Duration(milliseconds: 500));
                            AwesomeDialog(
                              context: context,
                              animType: AnimType.scale,
                              headerAnimationLoop: false,
                              dialogType: DialogType.success,
                              showCloseIcon: true,
                              title: 'Succès',
                              body: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text:
                                          'Confirmez-vous la sauvegarde du traitement d\'intervention ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF000000),
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${selectedItv.id} ',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeColors.bleuCiel,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: ' ?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF000000),
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              btnOkOnPress: () async {
                                final selectedState =
                                    currentState as InterventionSelected;

// Mise à jour des informations de l'intervention sélectionnée
                                selectedState.selecteditv.tel =
                                    tellController.text;
                                selectedState.selecteditv.email =
                                    emailController.text;
                                final parcsTest =
                                    (currentState as InterventionSelected)
                                            .selecteditv
                                            .parcs ??
                                        [];
                                for (var parc in parcsTest) {
                                  var1 = List.from(parc.problemTypeList ?? [])
                                              .length >
                                          0
                                      ? List.from(parc.problemTypeList ?? [])[0]
                                      : '1';
                                  var2 = List.from(parc.problemTypeList ?? [])
                                              .length >
                                          1
                                      ? List.from(parc.problemTypeList ?? [])[1]
                                      : '1';
                                  var3 = List.from(parc.problemTypeList ?? [])
                                              .length >
                                          2
                                      ? List.from(parc.problemTypeList ?? [])[2]
                                      : '1';
                                  var4 = List.from(parc.problemTypeList ?? [])
                                              .length >
                                          3
                                      ? List.from(parc.problemTypeList ?? [])[3]
                                      : '1';
                                  var5 = List.from(parc.problemTypeList ?? [])
                                              .length >
                                          4
                                      ? List.from(parc.problemTypeList ?? [])[4]
                                      : '1';
                                  var6 = List.from(parc.problemTypeList ?? [])
                                              .length >
                                          5
                                      ? List.from(parc.problemTypeList ?? [])[5]
                                      : '1';
                                  var7 = List.from(parc.problemTypeList ?? [])
                                              .length >
                                          6
                                      ? List.from(parc.problemTypeList ?? [])[6]
                                      : '1';

                                  print(
                                      'VARRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR');
                                  print(var1 + 'n1 \n');
                                  print(var2 + 'n2 \n');
                                  print(var3 + 'n3 \n');
                                  print(var4 + 'n4 \n');
                                  print(var5 + 'n5 \n');
                                  print(var6 + 'n6 \n');
                                  print(var7 + 'n7 \n');
                                }

                                // Préparation des données de l'intervention à envoyer
                                List<Map<String, dynamic>> parcList = [];

// Parcourir chaque parc
                                for (var parc
                                    in selectedState.selecteditv.parcs!) {
                                  // Liste pour stocker les articles du parc courant
                                  List<Map<String, dynamic>> articlesList = [];

                                  // Parcourir chaque article du parc
                                  for (var article in parc.articles!) {
                                    // Vérifier si la quantité est différente de "0"
                                    if (article.quantity?.toString() != "0") {
                                      // Ajouter l'article à la liste uniquement si la quantité n'est pas "0"
                                      articlesList.add({
                                        "id": article.id,
                                        "parcid": parc.id,
                                        "us": "UN",
                                        "designation": article.designation,
                                        "quantity":
                                            article.quantity?.toString(),
                                        "type": article.type,
                                        "ref": article.ref,
                                        "commentaire": article.commentaire
                                      });
                                    } else {
                                      // Optionnel : Afficher un message de débogage pour indiquer que l'article est ignoré
                                      print(
                                          "Article ignoré : la quantité est égale à 0 (ID: ${article.id})");
                                    }
                                  }
                                  // Ajouter le parc avec tous ses articles à parcList
                                  parcList.add({
                                    //  "article": parc.articles!.isNotEmpty ? parc.articles!.first.designation ?? "" : "", // Premier article comme valeur par défaut
                                    "articles":
                                        articlesList, // Liste de tous les articles
                                    "intitulé": parc.intitule ?? "",
                                    "codeRapport": parc.codeRapport ?? "",
                                    "id": parc.id!,
                                    "texte":
                                        "Texte de parc bien envoyé from Mobile APP",
                                    "software": parc.software ?? "",
                                    "firmware": parc.firmware ?? "",
                                    "resume": parc.resume ?? "",
                                    "observation": parc.observation ?? "",
                                    "problemTypeList": parc.problemTypeList ??
                                        ["1", "1", "1", "1", "1", "1", "1"],
                                    "problemOtherType": parc.problemType ?? "",
                                  });
                                }

                                // Préparation des données de mise à jour pour l'intervention
                                Map<String, Object> updateData = {
                                  "id": selectedItv.id!,
                                  "_id": selectedItv.id!,
                                  "interventionId": selectedItv.id!,
                                  "calendardate":
                                      selectedItv.calendardate ?? "AAAAMMJJ",
                                  "date": selectedItv.date ?? "AAAAMMJJ",
                                  "tel": selectedItv.tel ?? "",
                                  "email": selectedItv.email ?? "",
                                  "state": "en pause",
                                  "lieu": selectedItv.lieu ?? "Lieu par défaut",
                                  "technicienname":
                                      selectedItv.technicienname ?? "",
                                  "parcs": parcList,
                                  "attitudeApparenceItv":
                                      selectedItv.attitudeApparenceItv ?? "",
                                  "qualityPrestationItv":
                                      selectedItv.qualityPrestationItv ?? "",
                                  "communicationItv":
                                      selectedItv.communicationItv ?? "",
                                  "globlementItv":
                                      selectedItv.globlementItv ?? "",
                                  "realstarttimelist":
                                      selectedItv.realstarttimelist ?? [],
                                  "realendtimelist":
                                      selectedItv.realendtimelist ?? [],
                                  "realstartdaylist":
                                      selectedItv.realstartdaylist ?? [],
                                  "realduration": counterText,
                                  "realenddate":
                                      selectedItv.realstartdaylist!.isNotEmpty
                                          ? selectedItv.realstartdaylist!.last
                                          : "00000000",
                                  "realendtime":
                                      selectedItv.realendtimelist!.isNotEmpty
                                          ? selectedItv.realendtimelist!.last
                                              .substring(0, 4)
                                          : "000000",
                                  "realstartdate":
                                      selectedItv.realstartdaylist!.isNotEmpty
                                          ? selectedItv.realstartdaylist!.first
                                          : "00000000",
                                  "realstarttime":
                                      selectedItv.realstarttimelist!.isNotEmpty
                                          ? selectedItv.realstarttimelist!.first
                                              .substring(0, 4)
                                          : "000000",
                                };

                                // Encodage des données en JSON
                                String dataIntervention =
                                    jsonEncode(updateData);
                                print(
                                    "DEBUG JSON ----------------------------- : $dataIntervention");

                                // Affichage de la boîte de dialogue de chargement
                                AwesomeDialog(
                                  context: context,
                                  animType: AnimType.scale,
                                  headerAnimationLoop: false,
                                  dialogType: DialogType.info,
                                  title: 'Envoi en cours',
                                  body: const Center(
                                      child: CircularProgressIndicator()),
                                ).show();

                                // Appel de l'événement d'envoi dans le bloc
                                final repository =
                                    context.read<UserRepository>();
                                context.read<InterventionBloc>().add(
                                      UpdateIntervention2Event(
                                        id: selectedItv.id!,
                                        updateData: updateData,
                                        repository: repository,
                                      ),
                                    );

                                await Future.delayed(
                                    const Duration(seconds: 3));

                                // Vérification de l'état après l'envoi
                                var state =
                                    BlocProvider.of<InterventionBloc>(context)
                                        .state;
                                if (state is InterventionSelected) {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  AwesomeDialog(
                                    context: context,
                                    animType: AnimType.scale,
                                    headerAnimationLoop: false,
                                    dialogType: DialogType.success,
                                    title: 'Succès',
                                    body: const Text(
                                      'Intervention synchronisé avec les autres appareils avec\n succès.',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF000000),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    alignment: Alignment.center,
                                    btnOkOnPress: () {},
                                    btnOkColor: Colors.green,
                                  ).show();
                                  print(
                                      "SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS");
                                  print(
                                      'SUCCES d\'envoi, état actuel : $state');
                                } else {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  AwesomeDialog(
                                    context: context,
                                    animType: AnimType.scale,
                                    headerAnimationLoop: false,
                                    dialogType: DialogType.error,
                                    title: 'ECHEC',
                                    body: const Text(
                                      "Intervention sauvegardé localement, mais non synchronisée avec les autres appareils en raison d'un problème de serveur ou d'une absence de connexion Internet.",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                    ),
                                    btnOkOnPress: () {},
                                    btnOkColor: Colors.red,
                                  ).show();
                                  print(
                                      "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW");
                                  print(
                                      'Erreur d\'envoi, état actuel : ${BlocProvider.of<InterventionBloc>(context).state}');

                                  BlocProvider.of<InterventionBloc>(context)
                                      .add(SelectIntervention(
                                          selectedIntervention!));

                                  await Future.delayed(
                                      Duration(milliseconds: 100));

                                  print(
                                      "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR");
                                  print(
                                      'Erreur d\'envoi, état actuel après mise à jour 111111 : ${BlocProvider.of<InterventionBloc>(context).state}');

                                  await Future.delayed(
                                      Duration(milliseconds: 100));

                                  print(
                                      "R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2");
                                  print(
                                      'Erreur d\'envoi, état actuel après mise à jour 222222: ${BlocProvider.of<InterventionBloc>(context).state}');
                                }

                                print(
                                    'Intervention avec ID $id mise à jour avec succès.');
                                print('Tel mis à jour : ${selectedItv.tel}');
                                print(
                                    'Email mis à jour : ${selectedItv.email}');

                                loacalDuration = calcDuration(
                                    selectedItv.realstarttimelist,
                                    selectedItv.realendtimelist);
                                print('Duration IS');
                                print(loacalDuration);
                                print('Duration IN SECONDE IS');
                                print(formatDuration(loacalDuration));
                                print("CounterText ISISIS");
                                print(counterText);

                                saveState = true;
                              },
                        
                             
                           
                              btnOkText: 'Oui',

                              btnOkColor: const Color(0xFFFF9800),
                              customHeader: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFFF9800),
                                  shape: BoxShape.circle,
                                ),
                                padding: EdgeInsets.all(30),
                                child: Icon(
                                  Icons.save,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                             // btnCancelOnPress: () async {print("rien");},
                              /*btnCancel: Container(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(50),
    ),
    alignment: Alignment.center,
    child: const Text(
      'Non',
      style: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    ),
  ),*/
  btnCancelColor: Colors.transparent,
 /*  btnCancelOnPress: () {
    debugPrint('Cancel pressed'); // Vérifiez dans la console
    Navigator.of(context, rootNavigator: true).pop('dialog'); // Force le pop
  },*/
btnCancel: SizedBox(
  width: 100, // Largeur fixe
  height: 40,  // Hauteur fixe
  child: GestureDetector(
    onTap: () => Navigator.of(context, rootNavigator: true).pop(),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(50),
      ),
      alignment: Alignment.center,
      child: const Text(
        'Non',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),
),

                            ).show();

                            // await Future.delayed(const Duration(seconds: 1));

                            // Préparation des données de l'intervention à envoyer
                          },
                        ),

                        SizedBox(
                            height: MediaQuery.of(context).size.height *
                                0.005), // Taille dynamique

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isTerminated
                                ? () => print("session terminated")
                                : () async {
                                    // Vérifier si l'état actuel est 'InterventionSelected'
                                    if (currentState is! InterventionSelected) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Une opération est déjà en cours ou une erreur est survenue.'),
                                          backgroundColor: ThemeColors.burgundy,
                                        ),
                                      );
                                      return;
                                    }

                                    // Boîte de dialogue de confirmation avant d'envoyer l'intervention
                                    AwesomeDialog(
                                      context: context,
                                      animType: AnimType.scale,
                                      headerAnimationLoop: true,
                                      dialogType: DialogType.question,
                                      // dialogBackgroundColor: Color(0xFF9B4D96) ,// Violet
                                      customHeader: Container(
                                        decoration: BoxDecoration(
                                          //     color: ThemeColors.buildCardBlue,
                                          shape: BoxShape.circle,
                                        ),
                                        // padding: EdgeInsets.all(30),
                                        child: Icon(
                                          Icons.help,
                                          color: ThemeColors.buildCardBlue,
                                          size: 110,
                                        ),
                                      ),

                                      showCloseIcon: false,
                                      titleTextStyle: TextStyle(
                                          fontSize: 18,
                                          color: ThemeColors.buildCardBlue,
                                          fontWeight: FontWeight.bold),

                                      title: 'Confirmer l\'envoi',
                                      desc:
                                          'Voulez-vous envoyer l\'intervention au Sage X3 ❓',
                                      descTextStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),

                                      btnCancelColor: Color(0xFF808080),
                                      btnOkOnPress: () async {


                                        final selectedState = currentState
                                            as InterventionSelected;

                                  
                                        selectedState.selecteditv.tel =
                                            tellController.text;


                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        String? storedPdfUrl =
                                            prefs.getString('pdffirebaselink');
                                        List<Map<String, Object>> parcList = [];

                                        final parcsTest = (currentState
                                                    as InterventionSelected)
                                                .selecteditv
                                                .parcs ??
                                            [];
                                        for (var parc in parcsTest) {
                                          var1 =
                                              List.from(parc.problemTypeList ??
                                                              [])
                                                          .length >
                                                      0
                                                  ? List.from(
                                                      parc.problemTypeList ??
                                                          [])[0]
                                                  : '1';
                                          var2 =
                                              List.from(parc.problemTypeList ??
                                                              [])
                                                          .length >
                                                      1
                                                  ? List.from(
                                                      parc.problemTypeList ??
                                                          [])[1]
                                                  : '1';
                                          var3 =
                                              List.from(parc.problemTypeList ??
                                                              [])
                                                          .length >
                                                      2
                                                  ? List.from(
                                                      parc.problemTypeList ??
                                                          [])[2]
                                                  : '1';
                                          var4 =
                                              List.from(parc.problemTypeList ??
                                                              [])
                                                          .length >
                                                      3
                                                  ? List.from(
                                                      parc.problemTypeList ??
                                                          [])[3]
                                                  : '1';
                                          var5 =
                                              List.from(parc.problemTypeList ??
                                                              [])
                                                          .length >
                                                      4
                                                  ? List.from(
                                                      parc.problemTypeList ??
                                                          [])[4]
                                                  : '1';
                                          var6 =
                                              List.from(parc.problemTypeList ??
                                                              [])
                                                          .length >
                                                      5
                                                  ? List.from(
                                                      parc.problemTypeList ??
                                                          [])[5]
                                                  : '1';
                                          var7 =
                                              List.from(parc.problemTypeList ??
                                                              [])
                                                          .length >
                                                      6
                                                  ? List.from(
                                                      parc.problemTypeList ??
                                                          [])[6]
                                                  : '1';

                                          print(
                                              'VARRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR');
                                          print(var1 + 'n1 \n');
                                          print(var2 + 'n2 \n');
                                          print(var3 + 'n3 \n');
                                          print(var4 + 'n4 \n');
                                          print(var5 + 'n5 \n');
                                          print(var6 + 'n6 \n');
                                          print(var7 + 'n7 \n');
                                        }
                                        // ignore: unused_local_variable
                                        for (var parc in selectedState
                                            .selecteditv.parcs!) {
                                          for (var parc in selectedState
                                              .selecteditv.parcs!) {
                                            for (var article
                                                in parc.articles!) {
                                              // Vérifier si la quantité est différente de "0"
                                              if (article.quantity
                                                      ?.toString() !=
                                                  "0") {
                                                // Ajouter l'article à parcList uniquement si la quantité n'est pas "0"
                                                parcList.add({
                                                  "article": article.id ?? '',
                                                  "articles": [
                                                    {
                                                      "id": article.id,
                                                      "parcid": parc.id,
                                                      "us": "UN",
                                                      "designation":
                                                          article.designation,
                                                      "quantity": article
                                                          .quantity
                                                          ?.toString(),
                                                      "ref": article.ref,
                                                      "commentaire":
                                                          article.commentaire
                                                    }
                                                  ],
                                                  "descResumTrv":
                                                      parc.resume ?? '',
                                                  "problemTypeList":
                                                      parc.problemTypeList ??
                                                          [
                                                            "1",
                                                            "1",
                                                            "1",
                                                            "1",
                                                            "1",
                                                            "1",
                                                            "1"
                                                          ],
                                                  "problemOtherType":
                                                      parc.problemType ?? "",
                                                  "clientComment": "",
                                                  "techComment":
                                                      parc.observation ?? '',
                                                  "intitulé":
                                                      parc.intitule ?? "",
                                                  "id": parc.id!,
                                                  "texte":
                                                      "Texte de parc bien envoyé from Mobile APP"
                                                });
                                              } else {
                                                // Optionnel : Afficher un message de débogage pour indiquer que l'article est ignoré
                                                print(
                                                    "Article ignoré : la quantité est égale à 0 (ID: ${article.id})");
                                              }
                                            }
                                          }
                                        }

                                        loacalDuration = calcDuration(
                                            (currentState
                                                    as InterventionSelected)
                                                .selecteditv
                                                .realstarttimelist,
                                            (currentState
                                                    as InterventionSelected)
                                                .selecteditv
                                                .realendtimelist);
                                        await Future.delayed(
                                            Duration(milliseconds: 100));
                                        Map<String, Object> updateData = {
                                          "intervention": {
                                            "id": selectedState.selecteditv.id!,
                                            "parcs": parcList,
                                            "realdepartureDate": (currentState
                                                        as InterventionSelected)
                                                    .selecteditv
                                                    .realstartdaylist!
                                                    .isNotEmpty
                                                ? (currentState
                                                        as InterventionSelected)
                                                    .selecteditv
                                                    .realstartdaylist!
                                                    .first
                                                : "00000000",
                                            "realdepartureTime": (currentState
                                                        as InterventionSelected)
                                                    .selecteditv
                                                    .realstarttimelist!
                                                    .isNotEmpty
                                                ? (currentState
                                                        as InterventionSelected)
                                                    .selecteditv
                                                    .realstarttimelist!
                                                    .first
                                                    .substring(0, 4)
                                                : "000000",
                                            "realduration": counterText,
                                            "realenddate": (currentState
                                                        as InterventionSelected)
                                                    .selecteditv
                                                    .realstartdaylist!
                                                    .isNotEmpty
                                                ? (currentState
                                                        as InterventionSelected)
                                                    .selecteditv
                                                    .realstartdaylist!
                                                    .last
                                                : "00000000",
                                            "realendtime": (currentState
                                                        as InterventionSelected)
                                                    .selecteditv
                                                    .realendtimelist!
                                                    .isNotEmpty
                                                ? (currentState
                                                        as InterventionSelected)
                                                    .selecteditv
                                                    .realendtimelist!
                                                    .last
                                                    .substring(0, 4)
                                                : "000000",
                                            "realstartdate": (currentState
                                                        as InterventionSelected)
                                                    .selecteditv
                                                    .realstartdaylist!
                                                    .isNotEmpty
                                                ? (currentState
                                                        as InterventionSelected)
                                                    .selecteditv
                                                    .realstartdaylist!
                                                    .first
                                                : "00000000",
                                            "realstarttime": (currentState
                                                        as InterventionSelected)
                                                    .selecteditv
                                                    .realstarttimelist!
                                                    .isNotEmpty
                                                ? (currentState
                                                        as InterventionSelected)
                                                    .selecteditv
                                                    .realstarttimelist!
                                                    .first
                                                    .substring(0, 4)
                                                : "000000",
                                            "attitudeApparenceItv": (() {
                                              switch ((currentState
                                                          as InterventionSelected)
                                                      .selecteditv
                                                      .attitudeApparenceItv ??
                                                  "") {
                                                case "Très satisfait":
                                                  return 'A1';
                                                case "Satisfait":
                                                  return 'B1';
                                                case "Insatisfait":
                                                  return 'C1';
                                                case "Très insatisfait":
                                                  return 'D1';
                                                default:
                                                  return ''; // Valeur par défaut si jamais la satisfaction n'est pas reconnue
                                              }
                                            })(),
                                            "qualityPrestationItv": (() {
                                              switch ((currentState
                                                          as InterventionSelected)
                                                      .selecteditv
                                                      .qualityPrestationItv ??
                                                  "") {
                                                case "Très satisfait":
                                                  return 'A1';
                                                case "Satisfait":
                                                  return 'B1';
                                                case "Insatisfait":
                                                  return 'C1';
                                                case "Très insatisfait":
                                                  return 'D1';
                                                default:
                                                  return '';
                                              }
                                            })(),
                                            "communicationItv": (() {
                                              switch ((currentState
                                                          as InterventionSelected)
                                                      .selecteditv
                                                      .communicationItv ??
                                                  "") {
                                                case "Très satisfait":
                                                  return 'A1';
                                                case "Satisfait":
                                                  return 'B1';
                                                case "Insatisfait":
                                                  return 'C1';
                                                case "Très insatisfait":
                                                  return 'D1';
                                                default:
                                                  return ''; // Valeur par défaut si jamais la satisfaction n'est pas reconnue
                                              }
                                            })(),
                                            "globlementItv": (() {
                                              switch ((currentState
                                                          as InterventionSelected)
                                                      .selecteditv
                                                      .globlementItv ??
                                                  "") {
                                                case "Très satisfait":
                                                  return 'A1';
                                                case "Satisfait":
                                                  return 'B1';
                                                case "Insatisfait":
                                                  return 'C1';
                                                case "Très insatisfait":
                                                  return 'D1';
                                                default:
                                                  return ''; // Valeur par défaut si jamais la satisfaction n'est pas reconnue
                                              }
                                            })(),
                                          },
                                          "pdfData": {
                                            "interventionId":
                                                selectedState.selecteditv.id!,
                                            "fileUrl": storedPdfUrl ?? ""
                                          }
                                        };

                                        // Encodage des données en JSON
                                        String dataIntervention =
                                            jsonEncode(updateData);
                                        print(
                                            "DEBUG JSON ----------------------------- : $dataIntervention");

                                        // Préparation des données de mise à jour pour l'intervention
                                        Map<String, Object> updateDataState = {
                                          "_id": (currentState
                                                  as InterventionSelected)
                                              .selecteditv
                                              .id!,
                                          "id": (currentState
                                                  as InterventionSelected)
                                              .selecteditv
                                              .id!,
                                             "technicienname": (currentState
                                                  as InterventionSelected)
                                              .selecteditv
                                              .technicienname!,
                                              "interventionId": (currentState
                                                  as InterventionSelected)
                                              .selecteditv
                                              .id!,
                                          "state": "terminé",
                                       
                                        };

                                        // Encodage des données en JSON
                                        String dataInterventionState =
                                            jsonEncode(updateDataState);
                                        print(
                                            "DEBUG JSON State----------------------------- : $dataInterventionState");
                                        // Affichage de la boîte de dialogue de chargement
                                        AwesomeDialog(
                                          context: context,
                                          animType: AnimType.scale,
                                          headerAnimationLoop: false,
                                          dialogType: DialogType.info,
                                          title: 'Envoi en cours',
                                          body: const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        ).show();

                                        // Appel de l'événement d'envoi dans le bloc
                                        final repository =
                                            context.read<UserRepository>();
                                        context.read<InterventionBloc>().add(
                                              UpdateInterventionEvent(
                                                id: selectedState
                                                    .selecteditv.id!,
                                                updateData: updateData,
                                                repository: repository,
                                              ),
                                            );
                                        await Future.delayed(
                                            const Duration(milliseconds: 500));
                                        final repository2 =
                                            context.read<UserRepository>();
                                        context.read<InterventionBloc>().add(
                                              UpdateIntervention2Event(
                                                id: selectedState
                                                    .selecteditv.id!,
                                                updateData: updateDataState,
                                                repository: repository2,
                                              ),
                                            );
                                        // await Future.delayed(const Duration(milliseconds: 500));
                                        // _isLoading ? null : _updateIntervention;
                                        await Future.delayed(
                                            const Duration(seconds: 60));

                                        // Vérification de l'état après l'envoi
                                        var state =
                                            BlocProvider.of<InterventionBloc>(
                                                    context)
                                                .state;
                                        if (state is InterventionSelected) {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop();
                                          AwesomeDialog(
                                            context: context,
                                            animType: AnimType.scale,
                                            headerAnimationLoop: false,
                                            dialogType: DialogType.success,
                                            title: 'Succès',
                                            body: const Text(
                                              'Intervention envoyée avec\n succès.',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                            btnOkOnPress: () {
//await Future.delayed(const Duration(milliseconds: 500));
//_isLoading ? null : _updateIntervention;
                                              print('last pop clicked');
                                              (currentState
                                                      as InterventionSelected)
                                                  .selecteditv
                                                  .state = "terminé";
                                              // Mise à jour directe dans la box Hive
                                              Hive.box<LocalIntervention>(
                                                      'interventions')
                                                  .put(
                                                (currentState
                                                        as InterventionSelected)
                                                    .selecteditv
                                                    .id,
                                                LocalIntervention(
                                                  id: (currentState
                                                          as InterventionSelected)
                                                      .selecteditv
                                                      .id,
                                                  description: (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .description ??
                                                      'Description par défaut',
                                                  duration: (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .duration ??
                                                      'Durée par défaut',
                                                  technicienRealName: (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .technicienRealName ??
                                                      'Nom technicien par défaut',
                                                  couvertureglobale: (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .couvertureglobale ??
                                                      'Couverture par défaut',
                                                  type: (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .type ??
                                                      'Type par défaut',
                                                  email: (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .email ??
                                                      'email@exemple.com',
                                                  tel: (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .tel ??
                                                      '0000000000',
                                                  date: (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .date ??
                                                      '01012025',
                                                  debuteHour: (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .debuteHour ??
                                                      '0000',
                                                  enddate: (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .enddate ??
                                                      '01012025',
                                                  finishHour: (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .finishHour ??
                                                      '0000',
                                                  state: 'terminé',
                                                  client: (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .client ??
                                                      'Client par défaut',
                                                  lieu: (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .lieu ??
                                                      'Lieu par défaut',
                                                  parcs: (currentState
                                                          as InterventionSelected)
                                                      .selecteditv
                                                      .parcs
                                                      ?.map((parc) =>
                                                          parc.toLocalParc())
                                                      .toList(),
                                                  ressources: (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .ressources ??
                                                      [],
                                                  attitudeApparenceItv: (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .attitudeApparenceItv ??
                                                      "",
                                                  qualityPrestationItv: (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .qualityPrestationItv ??
                                                      "",
                                                  communicationItv: (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .communicationItv ??
                                                      "",
                                                  globlementItv: (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .globlementItv ??
                                                      "",
                                                  realstarttimelist: (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realstarttimelist ??
                                                      [],
                                                  realendtimelist: (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realendtimelist ??
                                                      [],
                                                  realstartdaylist: (currentState
                                                              as InterventionSelected)
                                                          .selecteditv
                                                          .realstartdaylist ??
                                                      [],
                                                ),
                                              );

                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const InterventionCalendarPage(),
                                                ),
                                              );
                                            },
                                          ).show();

                                          print(
                                              "SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS");

                                          print(
                                              'SUCCES d\'envoi, état actuel : $state');

                                        } else {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop();
                                          AwesomeDialog(
                                            context: context,
                                            animType: AnimType.scale,
                                            headerAnimationLoop: false,
                                            dialogType: DialogType.error,
                                            title: 'ECHEC',
                                            body: const Text(
                                              'Echec de l\'envoi !',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            btnOkOnPress: () {},
                                            btnOkColor: Colors.red,
                                          ).show();
                                          print(
                                              "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW");
                                          print(
                                              'Erreur d\'envoi, état actuel : ${BlocProvider.of<InterventionBloc>(context).state}');

                                          BlocProvider.of<InterventionBloc>(
                                                  context)
                                              .add(SelectIntervention(
                                                  selectedIntervention!));

                                          await Future.delayed(
                                              Duration(milliseconds: 100));

                                          print(
                                              "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR");
                                          print(
                                              'Erreur d\'envoi, état actuel après mise à jour 111111 : ${BlocProvider.of<InterventionBloc>(context).state}');

                                          await Future.delayed(
                                              Duration(milliseconds: 100));

                                          print(
                                              "R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2R2");
                                          print(
                                              'Erreur d\'envoi, état actuel après mise à jour 222222: ${BlocProvider.of<InterventionBloc>(context).state}');
                                        }
                                      },
                                      btnCancelOnPress: () {},
                                      btnOkText: 'Oui',

                                      btnCancelText: 'Non',
                                    ).show();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isTerminated
                                  ? Colors.grey
                                  : const Color.fromARGB(255, 11, 105, 182),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.1,
                                vertical:
                                    MediaQuery.of(context).size.height * 0.01,
                              ),
                            ),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Envoyer Intervention',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.034,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
     
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  void showConfirmationPopupSaveItv(BuildContext context) {
    AwesomeDialog(
      context: context,
      animType: AnimType.scale,
      headerAnimationLoop: true,
      dialogType: DialogType.question,
      showCloseIcon: false,
      title: 'Confirmation',
      body: const Text(
        'Voulez-vous envoyer l\'intervention ?',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF000000),
        ),
      ),
      btnOkOnPress: () {},
      btnCancelOnPress: () {},
      btnOkText: 'Oui',
      btnCancelText: 'Non',
      btnOkColor: ThemeColors.vertClaire,
      btnCancelColor: ThemeColors.rougeClaire,
    ).show();
  }

  Widget _buildInfoColumn({
    required IconData icon,
    required String text1,
    required String text2,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment:
          MainAxisAlignment.center, // Centre verticalement les éléments
      children: [
        // Texte principal
        Text(
          text1,
          style: TextStyle(
            fontSize:
                MediaQuery.of(context).size.width * 0.04, // Taille dynamique
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier',
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 8),
        Icon(
          icon,
          size: MediaQuery.of(context).size.width * 0.07,
          color: Colors.white,
        ),

        const SizedBox(height: 8),

        Text(
          text2,
          style: TextStyle(
            fontSize:
                MediaQuery.of(context).size.width * 0.04, // Taille dynamique
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4CAF50),
            fontFamily: 'Courier',
          ),
        ),
      ],
    );
  }

  Widget _textViewItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: const Color.fromARGB(255, 7, 63, 166).withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: ThemeColors.buildCardBlue),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            color: ThemeColors.buildCardBlue,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 17,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _textViewItemAdr(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: const Color.fromARGB(255, 7, 63, 166).withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: ThemeColors.buildCardBlue),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            color: ThemeColors.buildCardBlue,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 17,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _textViewItemSite(IconData icon, String title, String initialValue) {
    // Initialiser le controller
    if (_siteController.text.isEmpty && initialValue != 'Non défini') {
      _siteController.text = initialValue;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: const Color.fromARGB(255, 7, 63, 166).withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: ThemeColors.buildCardBlue),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            color: ThemeColors.buildCardBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _siteController,
                  enabled: !isTerminated,
                  decoration: InputDecoration(
                    labelText: 'Adresse',
                    hintText: 'Entrez le site client',
                    labelStyle: const TextStyle(
                      fontSize: 17,
                      color: ThemeColors.buildCardBlue,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.blueGrey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: ThemeColors.buildCardBlue),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: ThemeColors.buildCardBlue),
                    ),
                    suffixIcon: isTerminated
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.check,
                                color: ThemeColors.buildCardBlue),
                            onPressed: () {
                              if (_siteController.text.isNotEmpty) {
                                setState(() {
                                  (currentState as InterventionSelected)
                                      .selecteditv
                                      .lieu = _siteController.text;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Site client enregistré ✅'),
                                    duration: Duration(milliseconds: 2000),
                                    backgroundColor: ThemeColors.buildCardBlue,
                                  ),
                                );
                              }
                            },
                          ),
                  ),
                  onChanged: (value) {
                    if (!isTerminated) {
                      setState(() {
                        (currentState as InterventionSelected)
                            .selecteditv
                            .lieu = value;
                      });
                    }
                  },
                ),
              ),
              if (!isTerminated)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.my_location,
                        color: ThemeColors.buildCardBlue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapPage(),
                        ),
                      ).then((selectedLocation) {
                        if (selectedLocation != null) {
                          setState(() {
                            _siteController.text = selectedLocation;
                            (currentState as InterventionSelected)
                                .selecteditv
                                .lieu = selectedLocation;
                          });
                        }
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mailtextField(IconData icon, String subtitle,
      TextEditingController controller, InterventionSelected currentState) {
    bool isTerminated = currentState.selecteditv.state == 'terminé';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: const Color.fromARGB(255, 7, 63, 166).withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: ThemeColors.buildCardBlue),
        subtitle: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: TextField(
            controller: controller,
            enabled: !isTerminated, // Désactiver si l'état est "terminé"
            decoration: InputDecoration(
              labelText: subtitle,
              hintText: 'Entrez votre $subtitle',
              labelStyle: const TextStyle(
                fontSize: 17,
                color: ThemeColors.buildCardBlue,
                fontWeight: FontWeight.bold,
              ),
              hintStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: ThemeColors.buildCardBlue),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: ThemeColors.buildCardBlue),
              ),
              errorText: _isEmailValid(controller.text)
                  ? null
                  : 'Format d\'email invalide',
              suffixIcon: isTerminated
                  ? null // Supprimer l'icône si désactivé
                  : IconButton(
                      icon: const Icon(Icons.check,
                          color: ThemeColors.buildCardBlue),
                      onPressed: () {
                        if (_isEmailValid(controller.text)) {
                          (currentState as InterventionSelected)
                              .selecteditv
                              .email = controller.text;
                          // Optionnel: montrer un feedback de succès
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('E-mail enregistré ✅'),
                              duration: Duration(
                                  milliseconds: 2000), // Durée d'affichage
                              backgroundColor:
                                  ThemeColors.buildCardBlue, // Couleur de fond
                            ),
                          );
                        } else {
                          // Feedback d'erreur
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Veuillez entrer un email valide'),
                              duration: Duration(
                                  milliseconds: 2000), // Durée d'affichage
                              backgroundColor:
                                  ThemeColors.buildCardBlue, // Couleur de fond
                            ),
                          );
                        }
                      },
                    ),
            ),
            keyboardType:
                TextInputType.emailAddress, // Utiliser le clavier email
            onChanged: (value) {
              // Optionnel: valider à chaque changement
              setState(() {
                // Pour forcer la mise à jour de errorText
              });
            },
          ),

// Fonction de validation d'email à ajouter dans votre classe
        ),
      ),
    );
  }

  Widget _phoneNumberTextField(IconData icon, String subtitle,
      TextEditingController controller, InterventionSelected currentState) {
    bool isTerminated = currentState.selecteditv.state == 'terminé';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: const Color.fromARGB(255, 7, 63, 166).withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: ThemeColors.buildCardBlue),
        subtitle: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: TextField(
            controller: controller,
            enabled: !isTerminated, // Désactiver si l'état est "terminé"
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              labelText: subtitle,
              hintText: 'Entrez votre numéro de $subtitle',
              labelStyle: const TextStyle(
                fontSize: 17,
                color: ThemeColors.buildCardBlue,
                fontWeight: FontWeight.bold,
              ),
              hintStyle: const TextStyle(
                color: Colors.blueGrey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: ThemeColors.buildCardBlue),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: ThemeColors.buildCardBlue),
              ),
              errorText: _isValidPhoneNumber(controller.text)
                  ? null
                  : 'Numéro invalide (8-15 chiffres)',
              suffixIcon: isTerminated
                  ? null // Supprimer l'icône si le champ est désactivé
                  : IconButton(
                      icon: const Icon(Icons.check,
                          color: ThemeColors.buildCardBlue),
                      onPressed: () {
                        if (_isValidPhoneNumber(controller.text)) {
                          currentState.selecteditv.tel = controller.text;
                          // Feedback de succès
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Numéro de téléphone enregistré ✅'),
                              duration: Duration(
                                  milliseconds: 1500), // Durée d'affichage
                              backgroundColor:
                                  ThemeColors.buildCardBlue, // Couleur de fond
                            ),
                          );
                        } else {
                          // Feedback d'erreur
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Veuillez entrer un numéro valide (8-15 chiffres)'),
                              duration: Duration(
                                  milliseconds: 1500), // Durée d'affichage
                              backgroundColor:
                                  ThemeColors.buildCardBlue, // Couleur de fond
                            ),
                          );
                        }
                      },
                    ),
            ),
            onChanged: (value) {
              // Pour forcer la mise à jour de errorText à chaque changement
              setState(() {});
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavigateButton(
      {required String label, required VoidCallback onPressed}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 21, 116, 194),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.1,
            vertical: screenHeight * 0.01,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.034,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigateButton2(
      {required String label,
      Color? colorButton,
      bool? isterminatedstate,
      required VoidCallback onPressed}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (isterminatedstate! == false) {
            onPressed();
          } else {
            null;
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.1,
            vertical: screenHeight * 0.01,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.034,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
