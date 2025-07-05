/*import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_intervention_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_parc_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_article_model.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/add_intervention_page.dart';

class LocalInterventionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interventions')),
      body: Column(
        children: [
          // ValueListenable for Interventions
          ValueListenableBuilder<Box<LocalIntervention>>(
            valueListenable: Hive.box<LocalIntervention>('interventions').listenable(),
            builder: (context, Box<LocalIntervention> interventionsBox, _) {
              final interventions = interventionsBox.values.toList().cast<LocalIntervention>();

              return ListView.builder(
                shrinkWrap: true, // Ensures the ListView takes only necessary space
                itemCount: interventions.length,
                itemBuilder: (context, index) {
                  final intervention = interventions[index];

                  return ListTile(
                    title: Text(intervention.clientName),
                    subtitle: Text(intervention.date.toString()),
                    onTap: () {
                      // Navigate to intervention details page
                    },
                  );
                },
              );
            },
          ),

          // ValueListenable for Parcs
          ValueListenableBuilder<Box<LocalParc>>(
            valueListenable: Hive.box<LocalParc>('parcs').listenable(),
            builder: (context, Box<LocalParc> parcsBox, _) {
              final parcs = parcsBox.values.toList().cast<LocalParc>();

              // You can use the `parcs` data as needed
              return ListView.builder(
                shrinkWrap: true,
                itemCount: parcs.length,
                itemBuilder: (context, index) {
                  final parc = parcs[index];

                  return ListTile(
                    title: Text(parc.id), // Example field of LocalParc
                    subtitle: Text(parc.designation), // Example field of LocalParc
                    onTap: () {
                      // Handle parc selection
                    },
                  );
                },
              );
            },
          ),

          // ValueListenable for Articles
          ValueListenableBuilder<Box<LocalArticle>>(
            valueListenable: Hive.box<LocalArticle>('articles').listenable(),
            builder: (context, Box<LocalArticle> articlesBox, _) {
              final articles = articlesBox.values.toList().cast<LocalArticle>();

              // You can use the `articles` data as needed
              return ListView.builder(
                shrinkWrap: true,
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];

                  return ListTile(
                    title: Text(article.id), // Example field of LocalArticle
                    subtitle: Text(article.designation), // Example field of LocalArticle
                    onTap: () {
                      // Handle article selection
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddInterventionPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}*/
