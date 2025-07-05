import 'package:flutter/material.dart';
import 'package:srasav_vf_v1/features/user/data/models/parc_model.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/general_tools/theme_tools.dart';

class ParcHistoryPage extends StatelessWidget {
  final ParcModel parc;

  const ParcHistoryPage({super.key, required this.parc});

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

  // Nouvelle méthode pour filtrer les doublons
  List<Map<String, dynamic>> _getUniqueInterventions() {
    if (parc.interventions == null) return [];

    Map<String, Map<String, dynamic>> uniqueInterventions = {};
    
    for (int i = 0; i < parc.interventions!.length; i++) {
      final interventionId = parc.interventions![i];
      final tech = (parc.techniciens != null && i < parc.techniciens!.length) 
          ? parc.techniciens![i] : '';
      final comment = (parc.commentaires != null && i < parc.commentaires!.length) 
          ? parc.commentaires![i] : '';
      final date = (parc.datesInterventions != null && i < parc.datesInterventions!.length) 
          ? parc.datesInterventions![i] : '';

      uniqueInterventions[interventionId] = {
        'id': interventionId,
        'tech': tech,
        'comment': comment,
        'date': date,
        'originalIndex': i, // Conserve l'index original pour l'ordre
      };
    }

    // Convertir en liste et trier par index original pour conserver l'ordre chronologique
    return uniqueInterventions.values.toList()
      ..sort((a, b) => a['originalIndex'].compareTo(b['originalIndex']));
  }

  @override
  Widget build(BuildContext context) {
    final uniqueInterventions = _getUniqueInterventions();

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
      ),
      body: SafeArea(
        child: uniqueInterventions.isNotEmpty
            ? AnimatedList(
                initialItemCount: uniqueInterventions.length,
                itemBuilder: (context, index, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    )),
                    child: _buildInterventionCard(context, index, uniqueInterventions),
                  );
                },
              )
            : const Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 48, color: Colors.blueGrey),
                        SizedBox(height: 16),
                        Text(
                          'Aucune intervention enregistrée',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInterventionCard(BuildContext context, int index, List<Map<String, dynamic>> interventions) {
    final intervention = interventions[index];
    
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, const Color(0xFFF5F7FA)],
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
                    topRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),)
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Parc ID : ${parc.id!}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                       // const SizedBox(width: 12),
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
                                offset: const Offset(0, 1),)
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
                      intervention['id'],
                      Icons.numbers,
                      Colors.blueGrey.shade700,
                    ),
                    if (intervention['date'].isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailSection(
                        'Date:',
                        _formatDate(intervention['date']),
                        Icons.date_range,
                        Colors.indigo.shade700,
                      ),
                    ],
                    if (intervention['tech'].isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailSection(
                        'Technicien :',
                        intervention['tech'],
                        Icons.person,
                        Colors.indigo.shade700,
                      ),
                    ],
                    if (intervention['comment'].isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailSection(
                        'Commentaire :',
                        intervention['comment'],
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