import 'package:flutter/material.dart';

const Color BleuFonce = Color.fromARGB(255, 7, 63, 166);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const PopUpTest(),
    );
  }
}

class PopUpTest extends StatefulWidget {
  const PopUpTest({super.key});

  @override
  _PopUpTestState createState() => _PopUpTestState();
}

class _PopUpTestState extends State<PopUpTest> {
  // Liste complète des parcs
  final List<Parc> parcs = [
    Parc(designation: "Parc 1", nserie: "12345"),
    Parc(designation: "Parc 2", nserie: "67890"),
    Parc(designation: "Parc 3", nserie: "11223"),
    Parc(designation: "Parc 4", nserie: "44556"),
  ];

  // Liste des parcs sélectionnés
  List<Parc> selectedParcs = [];

  /// Affiche un popup avec une liste de parcs à sélectionner
  void _showPopup(BuildContext context) {
    // Liste temporaire pour suivre les sélections dans le popup
    List<Parc> tempSelectedParcs = List.from(selectedParcs);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Sélectionner les parcs',
                style: TextStyle(color: BleuFonce),
              ),
              content: SizedBox(
                height: 300,
                width: 300,
                child: ListView.builder(
                  itemCount: parcs.length,
                  itemBuilder: (context, index) {
                    final parc = parcs[index];
                    final isSelected = tempSelectedParcs.contains(parc);

                    return CheckboxListTile(
                      title: Text(parc.designation),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelectedParcs.add(parc);
                          } else {
                            tempSelectedParcs.remove(parc);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Mettre à jour la liste des parcs sélectionnés
                    setState(() {
                      this.setState(() {
                        selectedParcs = List.from(tempSelectedParcs);
                      });
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Valider'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélection de parcs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => _showPopup(context),
              child: const Text('Afficher Popup'),
            ),
            const SizedBox(height: 16),
            // Afficher les parcs sélectionnés ou un message par défaut
            if (selectedParcs.isEmpty)
              const Text(
                'Aucun parc sélectionné.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Parcs sélectionnés:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: BleuFonce,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...selectedParcs.map((parc) => Text(
                        parc.designation,
                        style: const TextStyle(fontSize: 16),
                      )),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Modèle de parc
class Parc {
  final String designation;
  final String nserie;

  const Parc({
    required this.designation,
    required this.nserie,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Parc &&
          runtimeType == other.runtimeType &&
          designation == other.designation &&
          nserie == other.nserie;

  @override
  int get hashCode => designation.hashCode ^ nserie.hashCode;
}
