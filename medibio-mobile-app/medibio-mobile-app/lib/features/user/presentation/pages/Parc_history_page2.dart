import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_parc2_model.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/general_tools/theme_tools.dart';

class ParcHistoryPage2 extends StatefulWidget {
  final String parcId;

  const ParcHistoryPage2({super.key, required this.parcId});

  @override
  State<ParcHistoryPage2> createState() => _ParcHistoryPage2State();
}

class _ParcHistoryPage2State extends State<ParcHistoryPage2> {
  late Future<List<InterventionData>> _interventionsFuture;

  @override
  void initState() {
    super.initState();
    _loadInterventions();
  }

  String _formatDate(String aaaammjj) {
    try {
      if (aaaammjj.length == 8) {
        final year = aaaammjj.substring(0, 4);
        final month = aaaammjj.substring(4, 6);
        final day = aaaammjj.substring(6, 8);
        return '$day-$month-$year';
      }
    } catch (e) {
      debugPrint('Error formatting date: $e');
    }
    return 'Date invalide';
  }

  Future<void> _loadInterventions() async {
    setState(() {
      _interventionsFuture = Future.delayed(
        const Duration(seconds: 2),
      ).then((_) => _fetchInterventions());
    });
  }

  Future<List<InterventionData>> _fetchInterventions() async {
    try {
      final box = Hive.box<LocalParc2>('parcs2');
      final parc = box.values.firstWhere((parc) => parc.id == widget.parcId);
      return _getUniqueInterventions(parc);
    } catch (e) {
      debugPrint('Error loading interventions: $e');
      return [];
    }
  }

  List<InterventionData> _getUniqueInterventions(LocalParc2 parc) {
    final interventions = <InterventionData>[];
    final uniqueIds = <String, int>{};

    if (parc.interventions != null) {
      for (int i = 0; i < parc.interventions!.length; i++) {
        final interventionId = parc.interventions![i];
        // Garde seulement la dernière occurrence de chaque ID
        uniqueIds[interventionId] = i;
      }

      // Crée les interventions uniques en conservant l'ordre chronologique
      uniqueIds.forEach((id, index) {
        interventions.add(InterventionData(
          parc: parc,
          index: index,
        ));
      });
    }

    // Tri par index original pour conserver l'ordre chronologique
    interventions.sort((a, b) => a.index.compareTo(b.index));
    
    return interventions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        leadingWidth: 56,
        title: const Text(
          "Historique du Parc",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: ThemeColors.buildCardBlue,
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder<List<InterventionData>>(
          future: _interventionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorWidget();
            }

            final interventions = snapshot.data ?? [];

            if (interventions.isEmpty) {
              return _buildEmptyState();
            }

            return _buildInterventionsList(interventions);
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return const Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(
            color: Colors.red,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Erreur de chargement des interventions'),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(
            color: Colors.blueGrey,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.blueGrey),
              SizedBox(height: 16),
              Text(
                'Aucune intervention enregistrée pour ce parc',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterventionsList(List<InterventionData> interventions) {
    return ListView.builder(
      itemCount: interventions.length,
      itemBuilder: (context, index) {
        return _buildInterventionCard(context, interventions[index]);
      },
    );
  }

  Widget _buildInterventionCard(BuildContext context, InterventionData data) {
    final parc = data.parc;
    final index = data.index;
    final interventionTitle = parc.interventions![index];
    final hasTech = parc.techniciens != null && index < parc.techniciens!.length;
    final hasComment = parc.commentaires != null && index < parc.commentaires!.length;
    final hasDate = parc.datesInterventions != null && index < parc.datesInterventions!.length;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF5F7FA)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[700],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Parc ID : ${widget.parcId}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        //const SizedBox(width: 12),
                        /*Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1)),
                            ],
                          ),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.blueGrey.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),*/
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection(
                      'Intervention ID :',
                      interventionTitle,
                      Icons.numbers,
                      Colors.blueGrey.shade700,
                    ),
                    if (hasDate) ...[
                      const SizedBox(height: 12),
                      _buildDetailSection(
                        'Date:',
                        _formatDate(parc.datesInterventions![index]),
                        Icons.date_range,
                        Colors.indigo.shade700,
                      ),
                    ],
                    if (hasTech) ...[
                      const SizedBox(height: 12),
                      _buildDetailSection(
                        'Technicien:',
                        parc.techniciens![index],
                        Icons.person,
                        Colors.indigo.shade700,
                      ),
                    ],
                    if (hasComment) ...[
                      const SizedBox(height: 12),
                      _buildDetailSection(
                        'Commentaire:',
                        parc.commentaires![index],
                        Icons.comment,
                        Colors.teal.shade700,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content.isNotEmpty ? content : 'Aucun $title disponible',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class InterventionData {
  final LocalParc2 parc;
  final int index;

  InterventionData({required this.parc, required this.index});
}