import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SelectedPlaceInfoPage extends StatefulWidget {
  final String? placeName;
  final String address;
  final List<String> nearbyPlaces;
  final double latitude;
  final double longitude;
  final String? plusCode;

  const SelectedPlaceInfoPage({
    super.key,
    this.placeName,
    required this.address,
    required this.nearbyPlaces,
    required this.latitude,
    required this.longitude,
    this.plusCode,
  });

  @override
  State<SelectedPlaceInfoPage> createState() => _SelectedPlaceInfoPageState();
}

class _SelectedPlaceInfoPageState extends State<SelectedPlaceInfoPage> {
  final String _apiKey = "AIzaSyASDVNe0KfqmQnMHAF4ODiIycXIx7SxiPc";
  Map<String, String> _detailedAddresses = {}; // Stockage des adresses récupérées
  bool _isSearching = false;
  String? _selectedDetailedAddress;

  @override
  Widget build(BuildContext context) {
    // Extraire le Plus Code s'il est disponible dans l'adresse
    String? extractedPlusCode = widget.plusCode;
    if (extractedPlusCode == null && widget.address.contains("Plus Code:")) {
      extractedPlusCode = widget.address.split("Plus Code: ").last.trim();
    }

    // Préparer l'adresse sans le Plus Code pour l'affichage
    String cleanAddress = widget.address.contains("Plus Code:")
        ? widget.address.split("Plus Code:").first.trim()
        : widget.address;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du lieu'),
  
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        
            
            const SizedBox(height: 24),
            
            // Nom principal du lieu
            if (widget.placeName != null && widget.placeName!.isNotEmpty)
              Card(
                elevation: 2,
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.place, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Lieu sélectionné',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.placeName!,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Coordonnées et Plus Code
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Localisation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Adresse
                    const Text(
                      'Adresse:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cleanAddress,
                      style: const TextStyle(fontSize: 16),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Coordonnées
                    const Text(
                      'Coordonnées GPS:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                      const SizedBox(height: 12),
                      const Text(
                        'Plus Code:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
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
            
            const SizedBox(height: 16),
            
            // Afficher l'adresse détaillée sélectionnée si disponible
            if (_selectedDetailedAddress != null)
              Card(
                elevation: 2,
                color: Colors.amber[50],
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_city, color: Colors.amber),
                          SizedBox(width: 8),
                          Text(
                            'Adresse Exacte Détaillée',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedDetailedAddress!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
  OutlinedButton.icon(
    onPressed: () async {
      if (_selectedDetailedAddress != null) {
        await Clipboard.setData(ClipboardData(text: _selectedDetailedAddress!));

        final overlay = Overlay.of(context);
        final entry = OverlayEntry(
          builder: (context) => Positioned(
            top: MediaQuery.of(context).viewInsets.top + 50,
            left: MediaQuery.of(context).size.width * 0.2,
            width: MediaQuery.of(context).size.width * 0.6,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Adresse copiée dans le presse-papiers',
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        );

        overlay.insert(entry);
        await Future.delayed(const Duration(seconds: 2));
        entry.remove();
      }
    },
    
    label: const Text('Copier Adresse'),
    icon: const Icon(Icons.copy),
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.green,
    ),
  ),
  IconButton(
    onPressed: () {
      setState(() {
        _selectedDetailedAddress = null;
      });
    },
    icon: const Icon(Icons.close),
    color: Colors.red,
  ),
],

                      ),
                    ],
                  ),
                ),
              ),
            
            // Overlay de chargement
            if (_isSearching)
              Card(
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
                      const SizedBox(width: 16),
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
                            const SizedBox(height: 4),
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
              ),
            
            // Lieux à proximité
            if (widget.nearbyPlaces.isNotEmpty)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.business, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            "Places, rues et avenues à proximité de la zone sélectionnée :",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.nearbyPlaces.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              _getDetailedAddressForPlace(widget.nearbyPlaces[index], context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${index + 1}.',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.nearbyPlaces[index],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 16,
                                              color: Colors.blue[700],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Adresse Exacte',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.blue[700],
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _openInGoogleMaps();
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('Ouvrir Google Maps'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  void _shareLocation(BuildContext context) {
    // Créer un texte à partager
    
    if (widget.placeName != null && widget.placeName!.isNotEmpty) {
    }
    
    
    // Logique pour partager l'emplacement (vous devrez implémenter cela)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de partage à implémenter'),
      ),
    );
  }

  void _openInGoogleMaps() async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}';
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  // Nouvelle méthode pour rechercher l'adresse détaillée d'un lieu à proximité
  Future<void> _getDetailedAddressForPlace(String placeName, BuildContext context) async {
    // Vérifier si nous avons déjà l'adresse en cache
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
      // 1. Rechercher le lieu par son nom pour obtenir son ID
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
          
          // Si l'API retourne directement l'adresse formatée
          if (candidate['formatted_address'] != null && candidate['formatted_address'].toString().isNotEmpty) {
            final String formattedAddress = candidate['formatted_address'];
            
            // Mettre en cache et afficher
            setState(() {
              _detailedAddresses[placeName] = formattedAddress;
              _selectedDetailedAddress = formattedAddress;
              _isSearching = false;
            });
          } 
          // Sinon, obtenir plus de détails avec l'ID du lieu
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
        _handleSearchError('Erreur de connexion');
      }
    } catch (e) {
      _handleSearchError('Erreur: $e');
    }
  }

  // Obtenir les détails d'un lieu à partir de son ID
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
            
            // Exemple de formatage spécifique comme demandé:
            // "7ème étage, Promed Building, Bloc B, Tunis 1082"
            String detailedAddress = formattedAddress;
            
            // Si on a des composants d'adresse, on peut créer un format personnalisé
            if (result['address_components'] != null) {
              
              // Ici, on pourrait construire une adresse personnalisée
              // selon les composants disponibles
            }
            
            // Mettre en cache et afficher
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

  // Gérer les erreurs de recherche
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