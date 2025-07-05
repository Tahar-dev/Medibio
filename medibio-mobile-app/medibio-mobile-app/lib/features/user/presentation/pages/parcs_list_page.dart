import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_article_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_parc2_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/parc_model.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/parc/parc_bloc.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/parc/parc_event.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/parc/parc_state.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/Parc_history_page.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/details_parcs_intervention.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/general_tools/theme_tools.dart';

class ParcsListPage extends StatefulWidget {
  const ParcsListPage({Key? key}) : super(key: key);

  @override
  State<ParcsListPage> createState() => _ParcsListPageState();
}

class _ParcsListPageState extends State<ParcsListPage> {
  late List<ParcModel> staticParcs;
  bool _isLoading = true;
  bool _isRefreshing = false; // Nouvelle variable pour le rafraîchissement

  List<LocalParc2> savedParcs = [];

  Future<void> _handleRefresh(BuildContext context) async {
    if (_isRefreshing) return; // Empêcher les rafraîchissements multiples
    
    setState(() {
      _isRefreshing = true;
    });

    try {
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
      
      // Recharger les données dans staticParcs et rafraîchir l'interface
      await _loadParcs();
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _handleRefresh2(BuildContext context) async {
  if (_isRefreshing) return; // Empêcher les rafraîchissements multiples
  
  setState(() {
    _isRefreshing = true;
  });

  try {
    // 🔍 Étape 1 : Vérifier la connexion Internet
    var connectivityResult = await Connectivity().checkConnectivity();
    bool hasConnection = connectivityResult != ConnectivityResult.none;

    if (!hasConnection) {
      // ❌ Pas de connexion : afficher un SnackBar mais continuer
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
    
    // Recharger les données dans staticParcs et rafraîchir l'interface
    await _loadParcs();
  } catch (e) {
    print('❌ Erreur lors du rafraîchissement: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur lors de la mise à jour: $e'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  } finally {
    setState(() {
      _isRefreshing = false;
    });
  }
}

  @override
  void initState() {
    super.initState();
    // Ajoutez ceci pour le rafraîchissement initial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleRefresh(context);
    });
  }

  Future<void> _loadParcs() async {
    try {
      final parcs = Hive.box<LocalParc2>('parcs2')
          .values
          .map((localParc2) => localParc2.toParcModel())
          .toList();
      setState(() {
        staticParcs = parcs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors du chargement des PARCs"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        leadingWidth: 56,
        title: const Text(
          "Parcs",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: ThemeColors.buildCardBlue,
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,

                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isRefreshing
                ? null
                : () async {
                    await _handleRefresh(context);
                  },
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : staticParcs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warning_amber, size: 50, color: Colors.orange),
                          const SizedBox(height: 16),
                          const Text(
                            "Aucun PARC trouvé",
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadParcs,
                            child: const Text("Réessayer"),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: staticParcs.length,
                        itemBuilder: (context, index) {
                          final parc = staticParcs[index];
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 12.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey[700],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12.0),
                                      topRight: Radius.circular(12.0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'PARC : ${parc.id}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.history,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                    onPressed: () async {
  // Navigation immédiate vers la page d'historique
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ParcHistoryPage(parc: parc),
    ),
  );

  // Exécuter le rafraîchissement en arrière-plan si possible
  await _handleRefresh(context);
},

                                        splashColor: Colors.blueAccent,
                                        splashRadius: 28,
                                        highlightColor: Colors.blue.withOpacity(0.3),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoRow("N° série", parc.numserie??''),
                                      const SizedBox(height: 8),
                                      _buildInfoRow("Marque", parc.marque??''),
                                      const SizedBox(height: 8),
                                      _buildInfoRow("Localisation", parc.localisation??''),
                                      const SizedBox(height: 8),
                                      _buildInfoRow("Software", parc.software??''),
                                      const SizedBox(height: 8),
                                      _buildInfoRow("Firmware", parc.firmware??''),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
     if (_isRefreshing)
  const Center(
    child: CircularProgressIndicator(),
  ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}