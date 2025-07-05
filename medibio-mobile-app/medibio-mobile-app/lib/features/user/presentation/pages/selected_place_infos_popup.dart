import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/intervention_deatils_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';




// 1. Nouvelle méthode pour afficher la popup
Future<void> showPlaceDetailsPopup({
  required BuildContext context,
  required String? placeName,
  required String? adresseNameFromMap,
  required String address,
  required List<String> nearbyPlaces,
  required double latitude,
  required double longitude,
  required String? plusCode,
}) async {
  // Copie automatique de l'adresse dans le presse-papiers dès l'ouverture
  await Clipboard.setData(ClipboardData(text: address));
  
  
  await showDialog(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: _PlaceDetailsPopup(
        placeName: placeName,
        address: address,
        nearbyPlaces: nearbyPlaces,
        latitude: latitude,
        longitude: longitude,
        plusCode: plusCode,
      ),
    ),
  );
}

// 2. Widget pour le contenu de la popup
class _PlaceDetailsPopup extends StatefulWidget {
  final String? placeName;
  final String address;
  final List<String> nearbyPlaces;
  final double latitude;
  final double longitude;
  final String? plusCode;

  const _PlaceDetailsPopup({
    required this.placeName,
    required this.address,
    required this.nearbyPlaces,
    required this.latitude,
    required this.longitude,
    required this.plusCode,
  });

  @override
  State<_PlaceDetailsPopup> createState() => _PlaceDetailsPopupState();
}

class _PlaceDetailsPopupState extends State<_PlaceDetailsPopup> {
  final String _apiKey = "AIzaSyASDVNe0KfqmQnMHAF4ODiIycXIx7SxiPc";
  Map<String, String> _detailedAddresses = {};
  bool _isSearching = false;
  String? _selectedDetailedAddress;

String _getValidNearbyPlace() {
  if (widget.nearbyPlaces.isEmpty) return '';

  debugPrint('Lieux à proximité originaux: ${widget.nearbyPlaces}');

  List<String> processedNames = [];
  List<String> arabicBuffer = [];

  for (int i = 0; i < widget.nearbyPlaces.length; i++) {
    String name = widget.nearbyPlaces[i];
    
    if (_containsArabic(name)) {
      arabicBuffer.add(name);
    } else {
      // Quand on trouve un nom non-arabe, traiter le buffer arabe
      if (arabicBuffer.isNotEmpty) {
        processedNames.addAll(arabicBuffer.reversed.toList());
        arabicBuffer.clear();
      }
      processedNames.add(name);
    }
  }

  // Traiter les derniers éléments arabes restants
  if (arabicBuffer.isNotEmpty) {
    processedNames.addAll(arabicBuffer.reversed.toList());
  }

  debugPrint('Lieux après inversion des blocs arabes: $processedNames');

  // Logique de sélection inchangée
  if (processedNames.length == 1) return processedNames[0];
  
  // Priorité à l'index 1 si valide
  if (processedNames.length > 1 && processedNames[1].isNotEmpty) {
    return processedNames[1];
  }

  // Fallback: premier élément valide
  for (String name in processedNames) {
    if (name.isNotEmpty && name != '.') {
      return name;
    }
  }

  return '';
}

bool _containsArabic(String text) {
  final arabicRegex = RegExp(r'[\u0600-\u06FF]');
  return arabicRegex.hasMatch(text);
}

  @override
  void initState() {
    super.initState();
    
    // Charger automatiquement l'adresse du deuxième point d'intérêt (indice 1) s'il existe
    WidgetsBinding.instance.addPostFrameCallback((_) async {
     // Vérifie d'abord si la liste contient au moins 1 élément
if (widget.nearbyPlaces.isNotEmpty) {
  // Sélectionne l'index selon la même logique (0 si length=1, 1 sinon)
  
  // Récupère l'adresse détaillée pour l'élément sélectionné
  await _getDetailedAddressForPlace(widget.address, context);
  print("DFDFDFDFDFDFDFDFDFDFD");
  print("lieu adresse lieu Real:: $_selectedDetailedAddress")   ;
  
  
  
  // Copie automatiquement l'adresse détaillée si disponible
  if (_selectedDetailedAddress != null && mounted) {
    await Clipboard.setData(ClipboardData(text: _selectedDetailedAddress!));
  }
}
    }); 
    print("sssssssssssssssssssssssssssssssssssssssssssss");
    print("lieu adresse lieu Real:: $_selectedDetailedAddress")   ;
    
    print("lieu adresse lieu Name from API map:: ${widget.address}")   ;
    
  }

  @override
  Widget build(BuildContext context) {
    String? extractedPlusCode = widget.plusCode;
    if (extractedPlusCode == null && widget.address.contains("Plus Code:")) {
      extractedPlusCode = widget.address.split("Plus Code: ").last.trim();
    }


    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header de la popup
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                //const Icon(Icons.location_city, color: Colors.green, size: 24),
                //const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Adresse Détaillée',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

Card(
  elevation: 2,
  color: Colors.amber[50],
  margin: const EdgeInsets.only(bottom: 16),
  child: SingleChildScrollView( // Ajout d'un ScrollView parent
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row pour l'établissement
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_city, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: widget.nearbyPlaces.isEmpty
                  ? const Text(
                      "Aucun établissement à proximité",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : FutureBuilder<String>(
                      future: Future.value(_getValidNearbyPlace()),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text(
                            "Chargement...",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text(
                            "Erreur de chargement",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[400],
                            ),
                          );
                        }
                        return Text(
                          "Établissement : ${snapshot.data ?? 'Non disponible'}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                        ); // Retrait de maxLines et overflow
                      },
                    ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Row pour l'adresse
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Adresse : ${_selectedDetailedAddress ?? ' Adresse exacte non trouvée. Essayez avec la barre de recherche'}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                softWrap: true,
              ), // Retrait de maxLines et overflow
            ),
          ],
        ),
      ],
    ),
  ),
),              
                 
FutureBuilder<bool>(
  future: Future.delayed(Duration(seconds: 2), () => false),
  initialData: true,
  builder: (context, snapshot) {
    if (_isSearching && snapshot.data == true) {
      return Card(
        elevation: 2,
        color: Colors.blue[50],
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recherche en cours...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Récupération de l\'adresse détaillée',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  },
),
                    SizedBox(height: 12),
                                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.my_location, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Coordonnées géographiques',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          
    
                          const Text(
                            'Position',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                           SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Latitude: ${widget.latitude.toStringAsFixed(6)}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Longitude: ${widget.longitude.toStringAsFixed(6)}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          
                          // Plus Code
                          if (extractedPlusCode != null && extractedPlusCode.isNotEmpty) ...[
                            SizedBox(height: 12),
                            const Text(
                              'Plus Code:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Text(
                                extractedPlusCode,
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
     
              
                ],
              ),
            ),
          ),

   
          Padding(
            padding: const EdgeInsets.all(16),
            child:Row(
  children: [
    // Bouton Annuler
    Expanded(
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context); // Retour sans valeur
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300], // Couleur grise claire
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: Colors.grey.shade500), // Bordure
        ),
        child: Text('Annuler',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800, // Texte gris foncé
          ),
        ),
      ),
    ),
    
    const SizedBox(width: 10), // Espacement entre les boutons
    
    // Bouton Confirmer (existant)
    Expanded(
      child: ElevatedButton(
        onPressed: () {

          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InterventionDetailsPage( adressFromMap: _selectedDetailedAddress ?? widget.address ,),
                              ),
                            );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text('Confirmer',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),
  ],
)
          ),
        ],
      ),
    );
  }

  // Méthodes existantes conservées...
  void _openInGoogleMaps() async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}';
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir Google Maps'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _getDetailedAddressForPlace(String placeName, BuildContext context) async {
    if (_detailedAddresses.containsKey(placeName)) {
      setState(() {
        _selectedDetailedAddress = _detailedAddresses[placeName];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final searchUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json'
        '?input=${Uri.encodeComponent(placeName)}'
        '&inputtype=textquery'
        '&fields=place_id,formatted_address'
        '&language=fr'
        '&locationbias=circle:100@${widget.latitude},${widget.longitude}'
        '&key=$_apiKey'
      );

      final searchResponse = await http.get(searchUrl);
      
      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        
        if (searchData['status'] == 'OK' && searchData['candidates'] != null && searchData['candidates'].isNotEmpty) {
          final candidate = searchData['candidates'][0];
          
          if (candidate['formatted_address'] != null && candidate['formatted_address'].toString().isNotEmpty) {
            final String formattedAddress = candidate['formatted_address'];
            
            setState(() {
              _detailedAddresses[placeName] = formattedAddress;
              _selectedDetailedAddress = formattedAddress;
              _isSearching = false;
            });
          } 
          else if (candidate['place_id'] != null) {
            final String placeId = candidate['place_id'];
            await _getPlaceDetails(placeId, placeName);
          } else {
            print('Aucune adresse trouvée pour ce lieu');
          }
        } else {
          print('Lieu non trouvé dans Google Maps');
        }
      } else {
        print('Erreur de connexion');
      }
    } catch (e) {
      _handleSearchError('Erreur: $e');
    }
  }

  Future<void> _getPlaceDetails(String placeId, String placeName) async {
    try {
      final detailUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=formatted_address,name,address_component'
        '&language=fr'
        '&key=$_apiKey'
      );

      final detailResponse = await http.get(detailUrl);
      
      if (detailResponse.statusCode == 200) {
        final detailData = json.decode(detailResponse.body);
        
        if (detailData['status'] == 'OK' && detailData['result'] != null) {
          final result = detailData['result'];
          
          if (result['formatted_address'] != null) {
            final String formattedAddress = result['formatted_address'];
            String detailedAddress = formattedAddress;
            
            if (result['address_components'] != null) {
              // Formatage personnalisé possible ici
            }
            
            setState(() {
              _detailedAddresses[placeName] = detailedAddress;
              _selectedDetailedAddress = detailedAddress;
              _isSearching = false;
            });
          } else {
            _handleSearchError('Détails d\'adresse non disponibles');
          }
        } else {
          _handleSearchError('Impossible d\'obtenir les détails du lieu');
        }
      } else {
        _handleSearchError('Erreur de connexion');
      }
    } catch (e) {
      _handleSearchError('Erreur lors de la récupération des détails: $e');
    }
  }

  void _handleSearchError(String message) {
    setState(() {
      _isSearching = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}