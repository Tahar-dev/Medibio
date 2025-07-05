import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_article_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_intervention_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_parc_model.dart';
import 'package:srasav_vf_v1/features/user/domain/usecases/get_interventions_by_id_usecase.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/intervention/intervention_bloc.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/intervention/intervention_event.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/calendar_page.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/general_tools/theme_tools.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/home_page.dart';

class ListCardPage extends StatefulWidget {
  const ListCardPage({Key? key}) : super(key: key);

  @override
  _ListCardPageState createState() => _ListCardPageState();
}

class _ListCardPageState extends State<ListCardPage> {
  late InterventionBloc _bloc;
  String? savedName;
  String searchClient = '';
  String selectedState = 'all';
  DateTime? selectedDate;
  // Ajout du contrôleur pour le champ de recherche
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _bloc = InterventionBloc(context.read<GetInterventionsById>());
    _loadPreferences();
    Hive.openBox<LocalIntervention>('interventions');
    // Initialisation du contrôleur de recherche
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    // Libération des ressources du contrôleur
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    savedName = prefs.getString('name');
    if (savedName != null) {
      _bloc.add(GetInterventionsByIdEvent(savedName!));
    }
  }

  List<LocalIntervention> _filterInterventions(Box<LocalIntervention> box) {
    return box.values.where((intervention) {
      final matchesClient = searchClient.isEmpty ||
          intervention.client!.toLowerCase().contains(searchClient.toLowerCase());
      final matchesState = selectedState == 'all' || intervention.state == selectedState;
      final matchesDate = selectedDate == null || (intervention.date != null && parseDate(intervention.date!).isAtSameMomentAs(selectedDate!));
      return matchesClient && matchesState && matchesDate;
    }).toList();
  }

  void _resetAllFilters() {
    setState(() {
      searchClient = '';
      selectedState = 'all';
      selectedDate = null;
      // Vider le texte du champ de recherche
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Interventions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: ThemeColors.buildCardBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetAllFilters,
            tooltip: 'Réinitialiser tous les filtres',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,  // Utilisation du contrôleur
                      decoration: const InputDecoration(
                        labelText: 'Recherche par client :',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchClient = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Filtre par état - première ligne
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          'Filtrer par état :',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedState,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedState = newValue!;
                                });
                              },
                              items: <String>['all', 'non commencé', 'en pause', 'terminé']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      value == 'all' ? 'Tous les états' : value,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Filtre par date - deuxième ligne
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          'Filtrer par date :',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextButton.icon(
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  selectedDate = pickedDate;
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              selectedDate == null
                                  ? 'Sélectionner une date'
                                  : DateFormat('yyyy-MM-dd').format(selectedDate!),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.restore, size: 20),
                          onPressed: () {
                            setState(() {
                              selectedDate = null;
                            });
                          },
                          tooltip: 'Réinitialiser la date',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<LocalIntervention>('interventions').listenable(),
              builder: (context, Box<LocalIntervention> box, _) {
                final filteredInterventions = _filterInterventions(box);
                if (filteredInterventions.isEmpty) {
                  return const Center(child: Text('Aucune intervention sauvegardée.'));
                }
                return ListView.builder(
                  itemCount: filteredInterventions.length,
                  itemBuilder: (context, index) {
                    final intervention = filteredInterventions[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: intervention.state == 'en pause'
                              ? Color.fromARGB(255, 21, 116, 194)
                              : intervention.state == 'terminé'
                                  ? Colors.red
                                  : Colors.green,
                          width: 1.5,
                        ),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  intervention.state == 'en pause'
                                      ? Icons.settings
                                      : intervention.state == 'terminé'
                                          ? Icons.check_circle
                                          : Icons.pending_actions,
                                  color: intervention.state == 'en pause'
                                      ? Color.fromARGB(255, 21, 116, 194)
                                      : intervention.state == 'terminé'
                                          ? Colors.red
                                          : Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  intervention.state == 'en pause'
                                      ? 'en pause'
                                      : intervention.state == 'terminé'
                                          ? 'Terminé'
                                          : 'Non commencé',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: intervention.state == 'en pause'
                                        ? Color.fromARGB(255, 21, 116, 194)
                                        : intervention.state == 'terminé'
                                            ? Colors.red
                                            : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.person, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  'Intervention ID: ${intervention.id ?? 'Non spécifié'}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.person, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  'Client: ${intervention.client ?? 'Non spécifié'}',
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.description, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Description: ${intervention.description ?? 'Non spécifié'}',
                                    style: const TextStyle(color: Colors.black87),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.place, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  'Lieu: ${intervention.lieu ?? 'Non spécifié'}',
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.date_range, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  'Daté de début : ${combineDateAndTime(intervention.date!, intervention.debuteHour!)}',
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.event_available, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  'Date de fin : ${combineDateAndTime(intervention.enddate!, intervention.finishHour!)}',
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}