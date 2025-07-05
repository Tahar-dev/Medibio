//Finalisation HIVE+INDICATION ENVOI (ECHEC-SUCCES)+Ajout RESUM ET OBSERVATION
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_intervention_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_parc_model.dart';
import 'package:srasav_vf_v1/features/user/domain/usecases/get_interventions_by_id_usecase.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/intervention/intervention_bloc.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/intervention/intervention_event.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/intervention/intervention_state.dart';
import 'package:srasav_vf_v1/features/user/data/models/intervention_model.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/general_tools/theme_tools.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/home_page.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/intervention_deatils_page.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

class InterventionCalendarPage extends StatefulWidget {



  
  const InterventionCalendarPage({super.key,


   });
   static const route = '/notification-screen';
  
  @override
  _InterventionCalendarPageState createState() => _InterventionCalendarPageState();
}

class _InterventionCalendarPageState extends State<InterventionCalendarPage> {
  late InterventionBloc _bloc;
  String? savedName; 
   bool _hasSyncedInterventions = false;

  
  //final interventionsRef = Hive.box('interventions_locales');
  List<Map<String, dynamic>> interventionsData = [];

  List<InterventionModel> interventionsDataRealModel =[] ;


    Future<void> deleteSignatureImages() async {
  try {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory imagesDir = Directory('${appDocDir.path}/images');
    final String techSignaturePath = '${imagesDir.path}/signatureTechnicien.png';
    final String clientSignaturePath = '${imagesDir.path}/signatureClient.png';

    final File techFile = File(techSignaturePath);
    final File clientFile = File(clientSignaturePath);

    if (await techFile.exists()) {
      await techFile.delete();
      debugPrint('Signature du technicien supprimée.');
    }

    if (await clientFile.exists()) {
      await clientFile.delete();
      debugPrint('Signature du client supprimée.');
    }
  } catch (e) {
    debugPrint('Erreur lors de la suppression des signatures : $e');
  }
  }

//late StreamSubscription<List<ConnectivityResult>> connectivitySubscription;

@override
void initState() {
  super.initState();

  _bloc = InterventionBloc(context.read<GetInterventionsById>());

  // Vérifier les informations de connexion sauvegardées
  _checkSavedLogin().then((_) {
    // Appeler _initializeApp avec savedName
  initializeOrRefreshITVs(savedName);
  });

  deleteSignatureImages();
}

Future<void> initializeOrRefreshITVs(String? savedName) async {
  // Vérifier l'état de la connectivité
  var connectivityResult = await Connectivity().checkConnectivity();

  // Afficher l'état de la connectivité dans la console
  print("WIFI STATE:");
  if (connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile) {
    print("Connecté au Internet");
    print("SAVED NAME ISSSSSS");
    print(savedName);
    // Afficher un SnackBar pour indiquer que le chargement est en cours
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Actualisation de données 🔁'),
          backgroundColor: Color.fromARGB(255, 24, 113, 172),
          duration: Duration(milliseconds: 3000),
        ),
      );
    }

    // Effacer la boîte Hive
    await Hive.box<LocalIntervention>('interventions').clear();
    await Future.delayed(const Duration(milliseconds: 500));

    // Rafraîchir les interventions si savedName est disponible
    if (savedName != null && mounted) {
      setState(() {
        _bloc.add(GetInterventionsByIdEvent(savedName));
      });
    }

    await Future.delayed(const Duration(milliseconds: 500));


    if (mounted) {
      setState(() {});
    }

  } else if (connectivityResult == ConnectivityResult.none) {
    print("Pas de connexion Internet – Utilisation des données locales (mode hors ligne) 🌐🚫");

    // Afficher un SnackBar pour indiquer l'absence de connexion
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pas de connexion Internet – Utilisation des données locales (mode hors ligne) 🌐🚫'),
          backgroundColor: ThemeColors.burgundy,
          duration: Duration(milliseconds: 3000),
        ),
      );
    }

  } else {
    print("État de connectivité inconnu");
  }
}
 Future<void> _checkSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    savedName = prefs.getString('name');
  }

@override
Widget build(BuildContext context) {
  final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage?;
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  print("TEST NOTIF IN CALENDARRRRRRRRRRRRRRRRRRRRRRRRRR");
            print(message?.notification?.title ?? "Aucune notification");
            print(message?.notification?.body?? "Aucune notification");
            print(message?.data.toString() ?? "Aucune notification");

  return WillPopScope(
    onWillPop: () async {
      
      return false;
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendrier',
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
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          },
        ),

actions: [

IconButton(
  icon: const Icon(Icons.refresh),
  color: Colors.white,
  onPressed: () async {
    await initializeOrRefreshITVs(savedName);
  },
),

        ],
      ),


body: BlocBuilder<InterventionBloc, InterventionState>(
  bloc: _bloc,
  builder: (context, state) {
    // Charger les interventions locales depuis Hive
    final interventionBox = Hive.box<LocalIntervention>('interventions');
    final appointments = interventionBox.values.map((intervention) {
      return Appointment(
        startTime: combineDateAndTime(
            intervention.date ?? '', intervention.debuteHour ?? ''),
        endTime: combineDateAndTime(
            intervention.enddate ?? '', intervention.finishHour ?? ''),
        id: intervention.id ?? 'No ID',
        subject: intervention.description ?? 'No Subject',
        color: _getColorBasedOnStatus(intervention.state),
        notes: intervention.state,
        location: intervention.lieu ?? 'No Location',
      );
    }).toList();

   

// Traiter les données si l'état est InterventionLoaded
if (state is InterventionLoaded) {
  final interventions = state.interventions.cast<InterventionModel>();

  for (var intervention in interventions) {
    // Vérifier si l'ID de l'intervention n'existe pas dans la boîte
    if (!interventionBox.containsKey(intervention.id)) {
      final List<LocalParc> parcs = (intervention.parcs!)
          .map((parc) {
            final articles = parc.articles?.map((article) {
              return article.toLocalArticle();
            }).toList();

            return LocalParc(
              id: parc.id??"",
              designation: parc.designation,
              numserie: parc.numserie,
              marque: parc.marque,
              localisation: parc.localisation,
              firmware: parc.firmware,
              software: parc.software,
              articles: articles,
              resume: parc.resume,
              observation: parc.observation,

              attitudeApparence: parc.attitudeApparence,
              qualityPrestation: parc.qualityPrestation,
              communication: parc.communication,
              globlement: parc.globlement,

              problemType: parc.problemType,
              problemTypeList: parc.problemTypeList,
              
              interventions: parc.interventions,
              datesInterventions: parc.datesInterventions,
              techniciens: parc.techniciens,
              commentaires: parc.commentaires,

              intitule: parc.intitule,
              codeRapport: parc.codeRapport



            );
          })
          .toList();

      // Ajouter l'intervention uniquement si elle n'existe pas
      interventionBox.put(
        intervention.id,
        LocalIntervention(
          id: intervention.id!,
          isSaved: intervention.isSaved??false,
          BL:intervention.BL??'',
          description: intervention.description ?? '',
          duration: intervention.duration ?? '',
          technicienRealName: intervention.technicienRealName ?? '',
          technicienname: intervention.technicienname??'',
          couvertureglobale: intervention.couvertureglobale ?? '',
          type: intervention.type ?? '',
          email: intervention.email ?? '',
          tel: intervention.tel ?? '',
          date: intervention.date ?? '',
          debuteHour: intervention.debuteHour,
          enddate: intervention.enddate,
          finishHour: intervention.finishHour,
          state: intervention.state,
          client: intervention.client,
          lieu: intervention.lieu,

          ressources: intervention.ressources,

          parcs: parcs,

          attitudeApparenceItv: intervention.attitudeApparenceItv,
          qualityPrestationItv: intervention.qualityPrestationItv,
          communicationItv: intervention.communicationItv,
          globlementItv: intervention.globlementItv,

          realstarttimelist: intervention.realstarttimelist??[],
          realendtimelist:intervention.realendtimelist??[],
          realstartdaylist: intervention.realstartdaylist??[],
          
          realduration: intervention.realduration??"00:00:00",

        ),
      );
    }
  }
}

    // Toujours afficher le calendrier
    return SfCalendar(
      view: CalendarView.month,
      dataSource: InterventionDataSource(appointments),
      monthViewSettings: MonthViewSettings(
        showAgenda: true,
        agendaItemHeight: screenHeight * 0.24,
      ),
      appointmentBuilder: (context, details) {
        final appointment = details.appointments.first;

        return GestureDetector(
onTap: () {
  final selectedIntervention = interventionBox.values.firstWhere(
    (i) =>
        i.date == DateFormat('yyyyMMdd').format(appointment.startTime) &&
        i.enddate == DateFormat('yyyyMMdd').format(appointment.endTime) &&
        i.id == appointment.id &&
        i.description == appointment.subject &&
        i.state == appointment.notes,
    orElse: () => LocalIntervention(),
  );

  final interventionModel = InterventionModel.fromLocalIntervention(selectedIntervention);
  final interventionBloc = BlocProvider.of<InterventionBloc>(context);
  interventionBloc.add(SelectIntervention(interventionModel));

    print("------------------------------------------------------------------------------");

    print("Détails de l'intervention sélectionnée:");
    print("ID de l'intervention : ${selectedIntervention.id ?? 'Non spécifié'}");
    print("Date de l'intervention : ${selectedIntervention.date ?? 'Non spécifiée'}");
    print("Email : ${selectedIntervention.email ?? 'Non rempli'}");
    print("Téléphone : ${selectedIntervention.tel ?? 'Non rempli'}");

    final parcs = selectedIntervention.parcs!;
    if (parcs.isNotEmpty) {
      print("Parcs associés à l'intervention :");
      for (var parc in parcs) {
        print("  - Parc ID: ${parc.id}, Désignation: ${parc.designation ?? 'Non spécifiée'} \n Problèmes :${parc.problemTypeList ?? 'Non spécifiée'} ");

        // Charger les articles associés au parc
        final articles = parc.articles ?? [];
        if (articles.isNotEmpty) {
          print("    Articles associés au parc :");
          for (var article in articles) {
            print(
              "      * Article ID: ${article.id}, Désignation: ${article.designation ?? 'Non spécifiée'}, "
              "Quantité: ${article.quantity ?? 'Non spécifiée'}, Type: ${article.type ?? 'Non spécifié'}"
            );
          }
        } else {
          print("    Aucun article associé au parc.");
        }
      }
    } 
 


  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: interventionBloc,
        child: InterventionDetailsPage(adressFromMap: ''),
      ),
    ),
  );
},

          child: Card(
            elevation: 4,
            color: appointment.color,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow(Icons.numbers, 'ITV ID : ${appointment.id}', screenWidth),
                  _buildRow(Icons.event, 'Description : ${appointment.subject}', screenWidth),
                  _buildRow(
                    Icons.access_time,
                    'Heure de départ : ${DateFormat('yyyy-MM-dd HH:mm').format(appointment.startTime)}',
                    screenWidth,
                  ),
                  _buildRow(
                    Icons.access_time,
                    'Heure de fin : ${DateFormat('yyyy-MM-dd HH:mm').format(appointment.endTime)}',
                    screenWidth,
                  ),
                  _buildRow(Icons.info, 'État: ${appointment.notes ?? "Non défini"}', screenWidth),
                ],
              ),
            ),
          ),
        );
      },
    );
  },
),



    ),
  );
}

}


//Non  Commencée : Vert ; 
//Terminée : Rouge ;
//En pause : Bleu ; 
//En cours : Orange

  Color _getColorBasedOnStatus(String? status) {
    switch (status) {
      case "non commencé":
        return Colors.green;
      case "en cours":
        return Colors.orange;
      case "en pause":
        return Color.fromARGB(255, 21, 116, 194);
      case "terminé":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSpacing(double screenHeight) {
    return SizedBox(height: screenHeight * 0.01);
  }


class InterventionDataSource extends CalendarDataSource {
  InterventionDataSource(List<Appointment> appointments) {
    this.appointments = appointments;
  }
}

Widget _buildRow(IconData icon, String text, double screenWidth) {
  return Row(
    children: [
      Icon(icon, color: Colors.white, size: screenWidth * 0.05),
      SizedBox(width: screenWidth * 0.02),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
          fontSize:screenWidth*0.0296,
          color: Colors.white,
          fontFamily: 'Courier',
          fontWeight: FontWeight.bold,),
        ),
      ),
    ],
  );
}

DateTime combineDateAndTime(String dateString, String timeString) {
  DateTime date = parseDate(dateString);
  TimeOfDay time = parseTime(timeString);

  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

DateTime parseDate(String dateString) {
  if (dateString.length != 8) {
    throw const FormatException("La chaîne de date doit comporter 8 caractères au format yyyyMMdd");
  }

  int year = int.parse(dateString.substring(0, 4));
  int month = int.parse(dateString.substring(4, 6));
  int day = int.parse(dateString.substring(6, 8));

  return DateTime(year, month, day);
}

TimeOfDay parseTime(String timeString) {
  if (timeString.length != 4) {
    throw const FormatException("La chaîne de temps doit comporter 4 caractères au format HHmm");
  }

  int hour = int.parse(timeString.substring(0, 2));
  int minute = int.parse(timeString.substring(2, 4));

  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
    throw const FormatException("Les heures doivent être entre 00 et 23, et les minutes entre 00 et 59");
  }

  return TimeOfDay(hour: hour, minute: minute);
}
