import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_intervention_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_parc_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_article_model.dart';

class AddLocalInterventionPage extends StatefulWidget {
  @override
  _AddLocalInterventionPageState createState() => _AddLocalInterventionPageState();
}

class _AddLocalInterventionPageState extends State<AddLocalInterventionPage> {
  final _formKey = GlobalKey<FormState>();
  String? InterventionID;
  DateTime? date;
  final TextEditingController parcDesignationController = TextEditingController();
  final TextEditingController articleIdController = TextEditingController();
  final TextEditingController articleDesignationController = TextEditingController();
  final TextEditingController articleQuantityController = TextEditingController();
  final TextEditingController articleUnitController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajouter une Intervention')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Intervention ID TextField
                TextFormField(
                  decoration: InputDecoration(labelText: 'Intervention ID'),
                  onSaved: (value) => InterventionID = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Intervention ID';
                    }
                    return null;
                  },
                ),
                // Parc Designation TextField
                TextFormField(
                  controller: parcDesignationController,
                  decoration: InputDecoration(labelText: 'Parc Designation'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Parc Designation';
                    }
                    return null;
                  },
                ),
                // Article Marque TextField
                TextFormField(
                  controller: articleDesignationController,
                  decoration: InputDecoration(labelText: 'Article Designation'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Article Marque';
                    }
                    return null;
                  },
                ),
                // Save Button
                
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Save form data
                      _formKey.currentState!.save();

                      // Create a new intervention
                      final intervention = LocalIntervention(
                        id: InterventionID!,
                        client: 'LABM', // Example client name
                        date: '20250101',
                        parcs: [], // Empty list for now, we will add parcs later
                      );

                      // Open the interventions box and add the intervention
                      final interventionBox = await Hive.openBox<LocalIntervention>('interventions');
                      interventionBox.add(intervention);

                      // Save new parc to the box
                      final parcBox = await Hive.openBox<LocalParc>('parcs');
                      parcBox.add(LocalParc(
                        id: InterventionID!, // Using Intervention ID to link the parc
                        designation: parcDesignationController.text,
                        marque: 'Marque P', // Example marque, adjust as needed
                        articles: [], // Empty list for articles
                      ));

                      // Save new article to the box
                      final articleBox = await Hive.openBox<LocalArticle>('articles');
                      articleBox.add(LocalArticle(
                        id: InterventionID!,
                        designation: articleDesignationController.text,
                        quantity: articleQuantityController.text,
                        us: articleUnitController.text,
                        parcid: '',
                        type: '',
                        ref:'ref1111',
                        commentaire: 'commentt111'
                      ));

                      // Go back to the previous page
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
