import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ParcHistoryPopup extends StatelessWidget {
  final List<InterventionHistory> historyList;

  const ParcHistoryPopup({super.key, required this.historyList});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Historique du parc",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final history = historyList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLine("intervention ID", history.interventionID),
                        const SizedBox(height: 6),
                        _buildLine("Date d'intervention", history.date),
                        const SizedBox(height: 6),
                        _buildLine("Technicien", history.technician),
                        const SizedBox(height: 6),
                        _buildLine("Commentaire", history.comment),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("ANNULER"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label : ",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}

class InterventionHistory {
   final String interventionID;
  final String date;
  final String technician;
  final String comment;

  InterventionHistory({
    required this.interventionID,
    required this.date,
    required this.technician,
    required this.comment,
  });
}
