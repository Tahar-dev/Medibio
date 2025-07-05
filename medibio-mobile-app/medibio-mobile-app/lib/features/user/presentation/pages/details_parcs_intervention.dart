//save list parcs 2 in local 
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srasav_vf_v1/features/user/data/models/article_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_article_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_parc2_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/parc_model.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/intervention/intervention_bloc.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/intervention/intervention_event.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/intervention/intervention_state.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/parc/parc_bloc.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/parc/parc_event.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/parc/parc_state.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/Parc_history_page2.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/components/build_card_widget.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/general_tools/theme_tools.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/intervention_deatils_page.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/parc_card2.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/ParcHistoryPopup.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/rapport_intervention_parc.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/timer/timer_bloc.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/timer/timer_event.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/timer/timer_state.dart';

List<ArticleModel> _savedOptionsIntervenants = [];

//Box<LocalParc2> box = Hive.box<LocalParc2>('parcs2');

bool doesExist(String parcId, Box<LocalParc2> box) {
  return box.values.any((localParc2) => localParc2.id == parcId);
}

List<ParcModel> staticParcs = [];

List<ParcModel> staticParcs2 = [];

List<LocalParc2> savedParcs = [];

List<InterventionHistory> _historyList = [];

var parcIdSf;

bool isChronoArrowBackState = false;
  // Sauvegarder isReset dans SharedPreferences
  // ignore: non_constant_identifier_names
  Future<void> setShp_chronoArrowBackState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('chronoArrowBackState', true);
  }



class DetailsParcsIntervention extends StatefulWidget {


  const DetailsParcsIntervention({
    super.key,


 

  });

  @override
  _DetailsParcsInterventionState createState() => _DetailsParcsInterventionState();
}

class _DetailsParcsInterventionState extends State<DetailsParcsIntervention> {
  late  InterventionBloc ? interventionBloc;
  

  

  late InterventionState currentState;

  var counterText ;



String ? loacalDuration ;



  late TextEditingController SoftWareController;
  late TextEditingController FirmWareController ;
 
@override
void initState() {
  super.initState();

  interventionBloc = context.read<InterventionBloc>();

  currentState = interventionBloc!.state;

  if (currentState is InterventionSelected) {
    final interventionId = (currentState as InterventionSelected).selecteditv.id;

    // Charger les parcs spécifiques à l'intervention
    Future.microtask(() => context.read<ParcBloc>().add(LoadParcs(interventionId!)));
  }


print("📦 Contenu de la box 'parcs2' :");

for (var parc in Hive.box<LocalParc2>('parcs2').values) {
  print(parc.toJson()); // Si LocalParc2 a une méthode toJson(), sinon afficher ses attributs manuellement.

}

isTerminated = (currentState as InterventionSelected).selecteditv.state == 'terminé';
print("GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG");
print((currentState as InterventionSelected).selecteditv.isSaved.toString());
SoftWareController = TextEditingController(
  text: (currentState as InterventionSelected).selecteditv.parcs!.isNotEmpty 
      ? (currentState as InterventionSelected).selecteditv.parcs!.first.software 
      : '',
);

FirmWareController = TextEditingController(
  text: (currentState as InterventionSelected).selecteditv.parcs!.isNotEmpty 
      ? (currentState as InterventionSelected).selecteditv.parcs!.first.firmware
      : '',
);

loacalDuration = calcDuration((currentState as InterventionSelected).selecteditv.realstarttimelist, (currentState as InterventionSelected).selecteditv.realendtimelist);

print("DURATION $loacalDuration");


  // Ajoutez ceci pour le rafraîchissement initial
 /* WidgetsBinding.instance.addPostFrameCallback((_) {
    _handleRefresh(context);
  });*/

}

  Future<void> _loadParcs() async {
    try {
      final parcs = Hive.box<LocalParc2>('parcs2')
          .values
          .map((localParc2) => localParc2.toParcModel())
          .toList();
      setState(() {
        staticParcs = parcs;
      });
    } catch (e) {
      setState(() {
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors du chargement des PARCs"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

/*Future<void> _handleRefresh(BuildContext context) async {
    
 

  

    final box = Hive.box<LocalParc2>('parcs2');

    // 🧹 Étape 2 : Vider Hive
    await box.clear();
    print("✅ Hive Box vidée.");

    setState(() {
      savedParcs.clear();
    });

    // ⏬ Étape 3 : Récupérer les nouveaux parcs via le Bloc
    context.read<ParcBloc>().add(LoadAllParcs());

    await Future.delayed(const Duration(milliseconds: 1000));

    final parcState = context.read<ParcBloc>().state;

    // 💾 Étape 4 : Enregistrer les nouveaux parcs dans Hive
    if (parcState is ParcListLoaded) {
      if (parcState.parcsList.isEmpty) {
        print('❌ Aucun parc récupéré.');
      } else {
        for (var parc in parcState.parcsList) {
          if (!doesExist(parc.id ?? '', box)) {
            await box.add(LocalParc2(
              id: parc.id ?? '',
              marque: parc.marque,
              numserie: parc.numserie,
              interventions: parc.interventions,
              datesInterventions: parc.datesInterventions,  
              techniciens: parc.techniciens,
              commentaires: parc.commentaires,
              localisation: parc.localisation,
              firmware: parc.firmware,
              software: parc.software,
              articles: parc.articles?.map((article) => LocalArticle(
                id: article.id,
                designation: article.designation,
                us: article.us,
                quantity: article.quantity,
                type: article.type,
                ref: article.ref,
                commentaire: article.commentaire,
              )).toList(),
              addressSite: parc.addressSite,
              article: parc.article,
              designation: parc.designation,
              designationSite: parc.designationSite,
              forced: parc.forced,
              isSelected: parc.isSelected,
              marqueDesignation: parc.marqueDesignation,
              resume: parc.resume,
              observation: parc.observation,
              attitudeApparence: parc.attitudeApparence,
              qualityPrestation: parc.qualityPrestation,
              communication: parc.communication,
              globlement: parc.globlement,
              problemType: parc.problemType,
            ));
          }
        }

        setState(() {
          savedParcs = box.values.toList();
        });

        print("✅ Parcs mis à jour localement !");
      }
    } else if (parcState is ParcListError) {
      print('❌ Erreur de récupération : ${parcState.messageList}');
    }


    
    // Recharger les données dans staticParcs et rafraîchir l'interface
    setState(() {
// Montrer l'indicateur de chargement
    });
    
    // Recharger les parcs depuis Hive pour mettre à jour staticParcs
  //  await _loadParcs();
}*/



  /*void _onIconPressed() {
    setState(() {
      _isIconClicked = !_isIconClicked;
    });

  }*/


  Timer? _timer;
  bool isRunning = false;
  bool isTerminated = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

  /// Convertit une chaîne 'HH:MM'
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

  String combineDateAndTime(String dateString, String timeString) {
    DateTime date = parseDate(dateString);
    TimeOfDay time = parseTime(timeString);

    DateTime dateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }


   String formatTime(int totalSeconds) {
  final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
  final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}



int calculateTotalSeconds(String ? stringDuration) {
  if (stringDuration!.length != 5) {
    throw ArgumentError("La chaîne doit contenir exactement 5 caractères.");
  }

  // Extraire les heures, minutes et secondes
  int hours = int.parse(stringDuration.substring(0, 1));   // 1er caractère
  int minutes = int.parse(stringDuration.substring(1, 3)); // 2e et 3e caractères
  int seconds = int.parse(stringDuration.substring(3, 5)); // 4e et 5e caractères

  // Calculer la durée totale en secondes
  int totalSeconds = (hours * 3600) + (minutes * 60) + seconds;

  return totalSeconds;
}


String calcDuration(List<String>? realstarttimelist, List<String>? realendtimelist) {
  if (realstarttimelist == null || realendtimelist == null || realstarttimelist.isEmpty || realendtimelist.isEmpty) {
    return "00000"; // Gérer le cas des listes vides ou nulles
  }

  // Vérifier que les listes ont la même longueur
  if (realstarttimelist.length != realendtimelist.length) {
    return "00000"; // Gérer le cas où les listes n'ont pas la même longueur
  }

  // Initialiser la durée totale en secondes
  int totalDurationInSeconds = 0;

  // Itérer sur les paires d'éléments des deux listes
  for (int i = 0; i < realstarttimelist.length; i++) {
    // Extraire l'heure, les minutes et les secondes du startTime
    String start = realstarttimelist[i];
    String end = realendtimelist[i];

    // Convertir le startTime en secondes depuis minuit
    int startHours = int.parse(start.substring(0, 2));   // 1ere 2eme caractères : heures
    int startMinutes = int.parse(start.substring(2, 4)); // 3eme et 4eme caractères : minutes
    int startSeconds = int.parse(start.substring(4, 6)); // 5eme et 6eme caractères : secondes
    int startTotalSeconds = (startHours * 3600) + (startMinutes * 60) + startSeconds;

    // Convertir le endTime en secondes depuis minuit
    int endHours = int.parse(end.substring(0, 2));   // 1er caractère : heures
    int endMinutes = int.parse(end.substring(2, 4)); // 2e et 3e caractères : minutes
    int endSeconds = int.parse(end.substring(4, 6)); // 4e et 5e caractères : secondes
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
  String formattedHours = hours.toString();
  String formattedMinutes = minutes.toString().padLeft(2, '0');
  String formattedSeconds = seconds.toString().padLeft(2, '0');

  return '$formattedHours$formattedMinutes$formattedSeconds';
}



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    
                  
    

           return WillPopScope(
      onWillPop: () async {
        // Empêche le retour à la page précédente (page login)
        return false;
      },
    child  :Scaffold(
appBar: PreferredSize(
  preferredSize: const Size.fromHeight(60), // Hauteur totale de l'AppBar
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      AppBar(
        title: const Text(
          'Détails des Parcs de l\'intervention',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: ThemeColors.buildCardBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () async{
            String realname = (currentState as InterventionSelected).selecteditv.technicienname.toString();
            final regex = RegExp(r'[A-Za-z]');
            realname = realname.split('').where((char) => regex.hasMatch(char)).join('');

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const InterventionDetailsPage(adressFromMap: '',),
              ),
            );

             print("COUNTER TEXT ");
             print(counterText.toString());

             WidgetsBinding.instance.addPostFrameCallback((_) {
  final blocState = context.read<TimerBloc>().state;
  final initialTime = blocState.counter; // Utilisation directe du compteur actuel
  
 
    print('Initializing timer with current counter value: $initialTime');
  
  
 // context.read<TimerBloc>().add(TimerSetInitial(initialTime));
});


final prefs = await SharedPreferences.getInstance();

print("shp_countertext shp_countertext shp_countertext from PARC PAGE from PARC PAGE");
print(counterText.toString());


print("--------------------------------------------------------------------------------------");
//setShp_chronoArrowBackState();
await prefs.setBool('chronoArrowBackState', true);
print(isChronoArrowBackState);
isChronoArrowBackState=prefs.getBool('chronoArrowBackState')!;
print("*******************************************************************************");
print(isChronoArrowBackState);
          },
        ),
        actions: [

IconButton(
  icon: const Icon(Icons.refresh),
  color: Colors.white,
  onPressed: () async {
    
    //await _handleRefresh(context);
    // 🔍 Étape 1 : Vérifier la connexion Internet
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

    print("🔄 Rafraîchissement en cours...");

    final box = Hive.box<LocalParc2>('parcs2');

    // 🧹 Étape 2 : Vider Hive
    await box.clear();
    print("✅ Hive Box vidée.");

    setState(() {
      savedParcs.clear();
    });

    // ⏬ Étape 3 : Récupérer les nouveaux parcs via le Bloc
    context.read<ParcBloc>().add(LoadAllParcs());

    await Future.delayed(const Duration(milliseconds: 1000));

    final parcState = context.read<ParcBloc>().state;

    // 💾 Étape 4 : Enregistrer les nouveaux parcs dans Hive
    if (parcState is ParcListLoaded) {
      if (parcState.parcsList.isEmpty) {
        print('❌ Aucun parc récupéré.');
      } else {
        for (var parc in parcState.parcsList) {
          if (!doesExist(parc.id ?? '', box)) {
            await box.add(LocalParc2(
              id: parc.id ?? '',
              marque: parc.marque,
              numserie: parc.numserie,
              interventions: parc.interventions,
              datesInterventions: parc.datesInterventions,  
              techniciens: parc.techniciens,
              commentaires: parc.commentaires,
              localisation: parc.localisation,
              firmware: parc.firmware,
              software: parc.software,
              articles: parc.articles?.map((article) => LocalArticle(
                id: article.id,
                designation: article.designation,
                us: article.us,
                quantity: article.quantity,
                type: article.type,
                ref: article.ref,
                commentaire: article.commentaire,
              )).toList(),
              addressSite: parc.addressSite,
              article: parc.article,
              designation: parc.designation,
              designationSite: parc.designationSite,
              forced: parc.forced,
              isSelected: parc.isSelected,
              marqueDesignation: parc.marqueDesignation,
              resume: parc.resume,
              observation: parc.observation,
              attitudeApparence: parc.attitudeApparence,
              qualityPrestation: parc.qualityPrestation,
              communication: parc.communication,
              globlement: parc.globlement,
              problemType: parc.problemType,
            ));
          }
        }

        setState(() {
          savedParcs = box.values.toList();
        });

        print("✅ Parcs mis à jour localement !");
      }
    } else if (parcState is ParcListError) {
      print('❌ Erreur de récupération : ${parcState.messageList}');
    }

    // ✅ Notification finale
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
            children: [
  CardUtils.buildCard(
  context:context,
  interventionIdLabel: 'Intervention ID : ',
  interventionIdValue: (currentState as InterventionSelected).selecteditv.id.toString(),
  datedebutplanfieeValue:  combineDateAndTime(
                      (currentState as InterventionSelected).selecteditv.date??'20250101',
                      (currentState as InterventionSelected).selecteditv.debuteHour??'0000',
                    ).toString(),
  datefinplanfieeValue:  combineDateAndTime(
                      (currentState as InterventionSelected).selecteditv.enddate??'20250101',
                      (currentState as InterventionSelected).selecteditv.finishHour??'0000',
                    ).toString(),
 child:BlocBuilder<TimerBloc, TimerState>(
  builder: (context, state) {
    
     counterText = (state is TimerRunning || state is TimerPausing)
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
              (currentState as InterventionSelected).selecteditv.duration ?? "00000",
            ),
          ),
        ),

        
        const SizedBox(height: 8),

        
        Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            
Container(
      decoration: BoxDecoration(
        color: isTerminated ? Colors.grey :ThemeColors.bleuCiel,
        borderRadius: BorderRadius.circular(8.0),
      ),
      width: MediaQuery.of(context).size.width * 0.08,
      height: MediaQuery.of(context).size.width * 0.08,
      child: BlocBuilder<TimerBloc, TimerState>(
        builder: (context, state) {
          isRunning = state is TimerRunning; 

 
          return IconButton(
            icon: Icon(
              isRunning ? Icons.pause : Icons.play_arrow,
              size: MediaQuery.of(context).size.width * 0.04,
              color: Colors.white,
            ),
           onPressed: isTerminated ? null :() {
              if (isRunning) {
                context.read<TimerBloc>().add(TimerPaused());

                (currentState as InterventionSelected).selecteditv.realendtimelist?.add(DateTime.now().toString().substring(11, 19).replaceAll(':', ''));


              print("REAL START LIST NOWWW*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-");
              print( (currentState as InterventionSelected).selecteditv.realstarttimelist.toString());

              print("REAL END LIST NOWWW*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-");
              print( (currentState as InterventionSelected).selecteditv.realendtimelist.toString());


             print("DAY OF WORKS LIST DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
             print( (currentState as InterventionSelected).selecteditv.realstartdaylist.toString());

              } else {
                context.read<TimerBloc>().add(TimerStarted());
                 (currentState as InterventionSelected).selecteditv.realstarttimelist?.add(DateTime.now().toString().substring(11, 19).replaceAll(':', ''));

              print("REAL START LIST NOWWW*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-");
              print( (currentState as InterventionSelected).selecteditv.realstarttimelist.toString());

              print("REAL END LIST NOWWW*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-*+-");
              print( (currentState as InterventionSelected).selecteditv.realendtimelist.toString());



              (currentState as InterventionSelected).selecteditv.realstartdaylist?.add(DateTime.now().toString().substring(0, 10).replaceAll('-', ''));
              print("DAY OF WORKS LIST DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
              print( (currentState as InterventionSelected).selecteditv.realstartdaylist.toString());

              

              }
            },
          );
        },
      ),
    ),

          
const SizedBox(width: 12),

            
Container(
  decoration: BoxDecoration(
    color: isTerminated ? Colors.grey : ThemeColors.bleuCiel, // Fond gris si terminé
    borderRadius: BorderRadius.circular(8.0),
  ),
  width: MediaQuery.of(context).size.width * 0.08,
  height: MediaQuery.of(context).size.width * 0.08,
  child: IconButton(
    icon: Icon(
      Icons.refresh, // Icône pour le bouton reset
      size: MediaQuery.of(context).size.width * 0.04,
      color: Colors.white, // Icône reste blanche
    ),
    onPressed: isTerminated ? null : () {context.read<TimerBloc>().add(TimerReset());
    print("DURATIONNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN");
    loacalDuration = calcDuration((currentState as InterventionSelected).selecteditv.realstarttimelist, (currentState as InterventionSelected).selecteditv.realendtimelist);
    print(loacalDuration); 
    } 
  ),
),
          ],
        ),
      ],
    );
  },
)
    ),

BlocBuilder<InterventionBloc, InterventionState>(
  builder: (context, state) {
    if (state is InterventionSelected) {
      final List<ParcModel> parcs = state.selecteditv.parcs ?? [];
      final Set<String> uniqueIds = {};
      final List<ParcModel> uniqueParcs = parcs.where((parc) => uniqueIds.add(parc.id!)).toList();

      if (uniqueParcs.isNotEmpty) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${uniqueParcs.length} PARC(S) CRÉÉ(S)",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            ...uniqueParcs.map((parc) {
              // Utilisation d'un StatefulBuilder pour gérer l'état local
              return StatefulBuilder(
                builder: (context, setLocalState) {
                  return ParcCard2(
                    key: ValueKey(parc.id), // Clé unique pour chaque parc
                    parccardd22: parc,
                    isTerminatedcardd22: isTerminated,
                    parcCardPicked: parcs,
                    onDelete: () {
                      setState(() {
                        state.selecteditv.parcs?.removeWhere((p) => p.id == parc.id);
                      });
                    },
onHistoryPress: () async {
  // Add your logic here for handling history press
  print("History button pressed for parc: ${parc.id}");

  // Navigation immédiate vers la page d'historique
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ParcHistoryPage2(parcId: parc.id!),
    ),
  );

  // Vérification de la connexion uniquement pour le rafraîchissement des données
  var connectivityResult = await Connectivity().checkConnectivity();
  bool hasConnection = connectivityResult != ConnectivityResult.none;

  if (!hasConnection) {
    // Pas de connexion : on ne fait pas le rafraîchissement mais on laisse la navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pas de connexion Internet – Utilisation des données locales (mode hors ligne) 🌐🚫'),
        backgroundColor: ThemeColors.burgundy,
        duration: Duration(milliseconds: 3000),
      ),
    );
    return;
  }

  // Si on arrive ici, il y a une connexion Internet
  print("🔄 Rafraîchissement en cours...");

  try {
    final box = Hive.box<LocalParc2>('parcs2');

    // 🧹 Étape 2 : Vider Hive
    await box.clear();
    print("✅ Hive Box vidée.");

    setState(() {
      savedParcs.clear();
    });

    // ⏬ Étape 3 : Récupérer les nouveaux parcs via le Bloc
    context.read<ParcBloc>().add(LoadAllParcs());

    await Future.delayed(const Duration(milliseconds: 1000));

    final parcState = context.read<ParcBloc>().state;

    // 💾 Étape 4 : Enregistrer les nouveaux parcs dans Hive
    if (parcState is ParcListLoaded) {
      if (parcState.parcsList.isEmpty) {
        print('❌ Aucun parc récupéré.');
      } else {
        for (var parc in parcState.parcsList) {
          if (!doesExist(parc.id ?? '', box)) {
            await box.add(LocalParc2(
              id: parc.id ?? '',
              marque: parc.marque,
              numserie: parc.numserie,
              interventions: parc.interventions,
              datesInterventions: parc.datesInterventions,  
              techniciens: parc.techniciens,
              commentaires: parc.commentaires,
              localisation: parc.localisation,
              firmware: parc.firmware,
              software: parc.software,
              articles: parc.articles?.map((article) => LocalArticle(
                id: article.id,
                designation: article.designation,
                us: article.us,
                quantity: article.quantity,
                type: article.type,
                ref: article.ref,
                commentaire: article.commentaire,
              )).toList(),
              addressSite: parc.addressSite,
              article: parc.article,
              designation: parc.designation,
              designationSite: parc.designationSite,
              forced: parc.forced,
              isSelected: parc.isSelected,
              marqueDesignation: parc.marqueDesignation,
              resume: parc.resume,
              observation: parc.observation,
              attitudeApparence: parc.attitudeApparence,
              qualityPrestation: parc.qualityPrestation,
              communication: parc.communication,
              globlement: parc.globlement,
              problemType: parc.problemType,
            ));
          }
        }

        setState(() {
          savedParcs = box.values.toList();
        });

        print("✅ Parcs mis à jour localement !");
      }
    } else if (parcState is ParcListError) {
      print('❌ Erreur de récupération : ${parcState.messageList}');
    }

    // Notification de succès
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Actualisation de données 🔁'),
        backgroundColor: Color.fromARGB(255, 24, 113, 172),
        duration: Duration(seconds: 2),
      ),
    );
  } catch (e) {
    print('❌ Erreur lors du rafraîchissement: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur lors de la mise à jour: $e'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
},
                    onReportPress: () {
                      if (isRunning || isTerminated) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RapportInterventionParc(parcid: parc.id),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Row(
                              children: [
                                Icon(Icons.warning, color: ThemeColors.buildCardBlue),
                                SizedBox(width: 8),
                                Text("Alerte", style: TextStyle(
                                  color: ThemeColors.buildCardBlue,
                                  fontWeight: FontWeight.bold,
                                )),
                              ],
                            ),
                            content: const Text(
                              "\nMerci d'activer le chronomètre avant de poursuivre.",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK", style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ThemeColors.buildCardBlue,
                                )),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  );
                },
              );
            }).toList(),
          ],
        );
      } else {
        return const Center(child: Text(""));
      }
    } else {
      return const Center(child: Text("État invalide", style: TextStyle(color: Colors.red)));
    }
  },
)


            ],
          ),
        )
      ),),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: GestureDetector(

onTap: () async {
  if ((currentState as InterventionSelected).selecteditv.state != 'terminé' ){ 
  print("🕒 Préparation de staticParcs...");

  // Petit délai avant la mise à jour
  await Future.delayed(const Duration(milliseconds: 200));

  print("📋 staticParcs AVANT mise à jour: ${staticParcs.map((parc) => parc.toJson()).toList()}");

  print("📋 savedParcs AVANT mise à jour: ${savedParcs.map((parc) => parc.toJson()).toList()}");

  staticParcs = savedParcs.map((localParc2) => localParc2.toParcModel()).toList();

  // Petit délai après la mise à jour
  await Future.delayed(const Duration(milliseconds: 200));

  print("✅ staticParcs APRÈS mise à jour: ${staticParcs.map((parc) => parc.toJson()).toList()}");
  print("📋 savedParcs  APRÈS mise à jour: ${savedParcs.map((parc) => parc.toJson()).toList()}");

  _showPopup2(context, selectedParcs);
}},


 


          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isTerminated ? Colors.grey :ThemeColors.buildCardBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    ),
  );
}



  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value?.isNotEmpty == true ? value! : "",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }


Widget _buildFieldInfoRow(
  String label,
  String? value,
  TextEditingController controller, {
  required Function(String) onChanged, // Callback pour la mise à jour
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 0.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: TextField(
            controller: controller,
            enabled: false,
            onChanged: onChanged, // Appeler le callback ici
            decoration: const InputDecoration(
              hintText: "________",
              contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}


Widget _buildInfoColumn({
  required IconData icon,
  required String text1,
  required String text2,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center, 
    children: [

      Text(
        text1,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.04, 
          fontWeight: FontWeight.bold,
          fontFamily: 'Courier',
          color: Colors.white,
        ),
      ),

      
      const SizedBox(height: 8),

      // Icône
      Icon(
        icon,
        size: MediaQuery.of(context).size.width * 0.07, 
        color: Colors.white,
      ),

   
      const SizedBox(height: 8),

     
      Text(
        text2,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.04,
          fontWeight: FontWeight.bold,
          color: Colors.green,
          fontFamily: 'Courier',
        ),
      ),
    ],
  );
}

List<ParcModel> selectedParcs = [];

void _showPopup2(BuildContext context, List<ParcModel> selectedParcs) {
  List<ParcModel> tempSelectedParcs = List.from(selectedParcs);


  staticParcs= Hive.box<LocalParc2>('parcs2')
    .values
    .map((localParc2) => localParc2.toParcModel())
    .toList();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PARCs',
                    style: TextStyle(
                      color: ThemeColors.buildCardBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
Expanded(
  child: ListView.builder(
    itemCount: staticParcs.length,
    itemBuilder: (context, index) {
      final parc = staticParcs[index];
      return Card(
    
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
              ),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PARC : ${parc.id}',
                    style:  TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.032,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Checkbox(
                    value: tempSelectedParcs.contains(parc),
                    onChanged: (bool? selected) {
                      // Imprimer avant l'ajout ou la suppression
                      print("Avant l'ajout/suppression: ${tempSelectedParcs.map((e) => e.id).toList()}");

                      setState(() {
                        if (selected == true) {
                          tempSelectedParcs.add(parc);
                        } else {
                          tempSelectedParcs.remove(parc);
                        }
                      });

                      // Imprimer après l'ajout ou la suppression
                      print("Après l'ajout/suppression: ${tempSelectedParcs.map((e) => e.id).toList()}");
                    },
                    checkColor: Colors.white,
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Text("Interventions: ${parc.interventions}"),
                  Text("N° série: ${parc.numserie}"),
                  Text("Marque: ${parc.marque}"),
                  Text("Localisation: ${parc.localisation}"),
                  Text("Software: ${parc.software}"),
                  Text("Firmware: ${parc.firmware}"),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      );
    },
  ),
),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Annuler', style: TextStyle(
                      color: ThemeColors.buildCardBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,)
),
                      ),
ElevatedButton(
  onPressed: () {
    if (tempSelectedParcs.isNotEmpty) {
      // Ajouter les parcs sélectionnés à l'événement
      for (var parc in tempSelectedParcs) {
        context.read<InterventionBloc>().add(AddParcIdEvent(parcId: parc));
      }
      
      print('BAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAASSAAAAAAAAAAAAAAAAAAAAAAAAAAAAZZ');
      // Imprimer la liste complète des parc.id ajoutés
      print("Parcs sélectionnés : ${tempSelectedParcs.map((e) => e.id).toList()}");
      print("Parcs sélectionnés : ${staticParcs.map((e) => e.id).toList()}");

      Navigator.pop(context);
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BlocProvider<InterventionBloc>.value(
      value: interventionBloc!,
      child: DetailsParcsIntervention(),
    ),
  ),
);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Aucun parc sélectionné !"),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  },
  child: const Text(
    'Valider',
    style: TextStyle(
      color: ThemeColors.buildCardBlue,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
)



                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}



}
