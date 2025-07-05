import 'package:flutter/material.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/general_tools/theme_tools.dart';

class CardUtils {
  static Widget buildCard({
    required Widget child,
    required BuildContext context,
    required String interventionIdLabel,
    required String interventionIdValue,
    required String datedebutplanfieeValue,
    required String datefinplanfieeValue,
  }) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      elevation: 15,
      shadowColor: Colors.black.withOpacity(0.8),
      color: ThemeColors.buildCardBlue,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar with the ID
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.assignment, color: Colors.black, size: 28),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: interventionIdLabel,
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.032,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Courier',
                            ),
                          ),
                          TextSpan(
                            text: interventionIdValue,
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.032,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                              fontFamily: 'Courier',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Row containing dates and additional widget
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.white, size: 24),
                            const SizedBox(width: 8),
                            const Text(
                              "Date début planifiée:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'RobotoMono',
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          datedebutplanfieeValue,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 24),
                            const SizedBox(width: 8),
                            const Text(
                              "Date fin planifiée:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'RobotoMono',
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          datefinplanfieeValue,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16), // Réduction de la taille du SizedBox
                  Expanded(
                    flex: 1,
                    child: child,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
