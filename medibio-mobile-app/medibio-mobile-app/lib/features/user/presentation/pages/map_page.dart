import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_webservice/places.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/general_tools/theme_tools.dart';
import 'package:srasav_vf_v1/features/user/presentation/pages/intervention_deatils_page.dart';
import 'selected_place_infos.dart';
import 'selected_place_infos_popup.dart';
import 'package:flutter/services.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _mapController;
  bool _isLoading = true;
  bool _isSearching = false;
  LatLng _myActualPosition = const LatLng(0, 0);
  final loc.Location _location = loc.Location();
  LatLng? _selectedPosition;
  String _selectedAddress = "Adresse en cours de détection...";
  bool _hasEstablishment = false;
  
  List<dynamic> _nearbyPlaces = [];
  List<String> _placeNames = [];
  
  final String _apiKey = "AIzaSyASDVNe0KfqmQnMHAF4ODiIycXIx7SxiPc";
  Set<Marker> _markers = {};
  bool _selectionActive = false;
  loc.LocationData? _locationData;
  String? _plusCode;
  
  // Nouveaux états pour la recherche
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchSuggestions = [];
  bool _showSuggestions = false;
  late GoogleMapsPlaces places;

  var nameofplace;

Future<String> _getFilteredPlaceName() async {
  if (_placeNames.isEmpty) return '';

  debugPrint('Liste originale: $_placeNames');

  List<String> processedNames = [];
  List<String> arabicBuffer = [];

  for (int i = 0; i < _placeNames.length; i++) {
    String name = _placeNames[i];
    
    if (_containsArabic(name)) {
      // Ajouter au buffer temporaire pour les éléments arabes
      arabicBuffer.add(name);
    } else {
      // Si on a des éléments arabes en buffer, les ajouter en ordre inverse
      if (arabicBuffer.isNotEmpty) {
        processedNames.addAll(arabicBuffer.reversed.toList());
        arabicBuffer.clear();
      }
      processedNames.add(name); // Ajouter l'élément non arabe
    }
  }

  // Traiter les derniers éléments arabes restants
  if (arabicBuffer.isNotEmpty) {
    processedNames.addAll(arabicBuffer.reversed.toList());
  }

  debugPrint('Liste après inversion des blocs arabes: $processedNames');

  // Logique de sélection
  if (processedNames.length == 1) return processedNames[0];
  if (processedNames.length > 1) return processedNames[1];
  return '';
}

bool _containsArabic(String text) {
  final arabicRegex = RegExp(r'[\u0600-\u06FF]');
  return arabicRegex.hasMatch(text);
}


  @override
  void initState() {
    super.initState();
    places = GoogleMapsPlaces(apiKey: _apiKey);
    _setupLocationTracking();
  }

  Future<void> _setupLocationTracking() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    _location.changeSettings(
      accuracy: loc.LocationAccuracy.high,
      interval: 1000,
      distanceFilter: 5,
    );
    
    try {
      _locationData = await _location.getLocation();
      if (mounted) {
        setState(() {
          _myActualPosition = LatLng(
            _locationData?.latitude ?? 0,
            _locationData?.longitude ?? 0,
          );
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération de la position: $e');
    }
    
    _location.onLocationChanged.listen((loc.LocationData currentLocation) {
      if (mounted) {
        setState(() {
          _locationData = currentLocation;
          _myActualPosition = LatLng(
            currentLocation.latitude ?? 0,
            currentLocation.longitude ?? 0,
          );
          
          if (!_isLoading && _mapController != null && _selectedPosition == null) {
            _mapController.animateCamera(
              CameraUpdate.newLatLng(_myActualPosition),
            );
          }
        });
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      _locationData = await _location.getLocation();
      if (mounted && _locationData != null) {
        setState(() {
          _myActualPosition = LatLng(
            _locationData!.latitude ?? 0,
            _locationData!.longitude ?? 0,
          );
        });
        
        if (_mapController != null) {
          _mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _myActualPosition,
                zoom: 17.0,
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération de la position: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
     return WillPopScope(
    onWillPop: () async {
      // Retourne false pour bloquer TOUS les retours système
      return false;
    },child :Scaffold(
  appBar: AppBar(
  title: Container(
    width: double.infinity,
    child: const Text(
      'Map',
      textAlign: TextAlign.left, // Alignement à droite
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  ),
  centerTitle: false, // Désactive le centrage par défaut
  backgroundColor: ThemeColors.buildCardBlue,
  elevation: 4,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () async {
      final clipboardData = await Clipboard.getData('text/plain');
      final addressFromClipboard = clipboardData?.text ?? '';
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InterventionDetailsPage(
            adressFromMap: addressFromClipboard,
          ),
        ),
      );
    },
  ),
),
      body: Stack(
        children: [
          GoogleMap(
            
            initialCameraPosition: CameraPosition(
              target: _myActualPosition,
              zoom: 17.0,
            ),
            mapType: MapType.normal,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                _mapController = controller;
                _isLoading = false;
              });
              
              if (_myActualPosition.latitude != 0 && _myActualPosition.longitude != 0) {
                controller.animateCamera(
                  CameraUpdate.newLatLng(_myActualPosition),
                );
              }
            },
            onTap: (LatLng position) {
              _updateSelectedPosition(position);
              
              setState(() {
                _selectionActive = true;
                _showSuggestions = false; // Cacher les suggestions quand on clique sur la carte
              });
              
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  setState(() {
                    _selectionActive = false;
                  });
                }
              });
            },
          ),
          
          // Barre de recherche en haut
          //SizedBox(height: 300,),
          Positioned(
            top: 20,
            left: 10,
            right: 10,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un lieu...',
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _searchController.clear();
                                _searchPlaces('');
                              },
                            )
                          : null,
                    ),
                    onChanged: _searchPlaces,
                    onTap: () {
                      setState(() {
                        _showSuggestions = _searchSuggestions.isNotEmpty;
                      });
                    },
                    onSubmitted: (value) {
                      if (_searchSuggestions.isNotEmpty) {
                        _selectPlace(_searchSuggestions.first);
                      }
                    },
                  ),
                ),
                
                // Suggestions d'auto-complétion
                if (_showSuggestions && _searchSuggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: _searchSuggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(_searchSuggestions[index]),
                          onTap: () {
                            _selectPlace(_searchSuggestions[index]);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          
          if (_isLoading || _isSearching) 
            Container(
              color: Colors.black26,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      _isSearching ? 'Détection de l\'adresse et établissements...' : 'Chargement de la carte...',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          
          if (!_isLoading && !_isSearching)
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 24.0,
                ),
              ),
            ),
          
          if (_selectionActive)
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.white,
                  size: 48.0,
                ),
              ),
            ),
        ],
      ),
      
      bottomSheet: _selectedPosition != null 
        ? Container(
  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
  decoration: BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 1,
        blurRadius: 5,
        offset: const Offset(0, -1),
      ),
    ],
  ),
  width: 340, // Largeur fixe
  height: 180, // Hauteur fixe
  child: LayoutBuilder( // Utilisation de LayoutBuilder pour des contraintes précises
    builder: (context, constraints) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Point Sélectionné :",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          
          SizedBox(
            height: 128, 
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(), 
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 10, 
                  maxWidth: constraints.maxWidth - 30, 
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_hasEstablishment && _placeNames.isNotEmpty) 
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth - 30,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          border: Border.all(color: Colors.green, width: 1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (kDebugMode ) ...[
                              Builder(
                                builder: (context) {
                                  debugPrint("Lieux à proximité: ${_placeNames.toString()}");
                                  return const SizedBox.shrink();
                                },
                              ),
                              const SizedBox(height: 4),
                            ],
                            
                          //  if (_placeNames.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4), // Réduit de 8 à 4
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
  const Icon(Icons.location_on, color: Colors.amber, size: 16),
  const SizedBox(width: 8),
  Flexible(
   child: FutureBuilder<String>(
  future: _getFilteredPlaceName(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator(); // Ou un placeholder
    }
    nameofplace=snapshot.data ;
    return Text(
      snapshot.data ?? '', // Valeur par défaut si null

      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.blue[800],
      ),
      softWrap: true,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  },
)
  ),
],
                                ),
                              ),
                          ],
                        ),
                      ),
                    
                    if (_selectedAddress.contains("Plus Code"))
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth - 30,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10), // Réduit de 8 à 6
                        margin: const EdgeInsets.only(top: 4), // Réduit de 8 à 4
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          border: Border.all(color: Colors.blue, width: 1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.map, color: Colors.blue, size: 16),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _selectedAddress.split("Plus Code: ").last,
                                style: const TextStyle(
                                  fontSize: 14, 
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  ),
)
        : null,
      
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'btnMyLocation',
            onPressed: () {
              _getCurrentLocation();
              if (_myActualPosition.latitude != 0 && _myActualPosition.longitude != 0) {
                _mapController.animateCamera(
                  CameraUpdate.newLatLng(_myActualPosition),
                );
              }
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
         const SizedBox(height: 10),
// 1. Modifiez le FloatingActionButton pour utiliser showDialog
SizedBox(
  width: 100,
  height: 100,
  child: FloatingActionButton(
    heroTag: 'btnConfirm',
    onPressed: () async {
      print("azazazazazazazaza");
      print("nameofplace : $nameofplace");
      if (_selectedPosition != null) {
        await showPlaceDetailsPopup(
          context: context,
          placeName: _hasEstablishment && _placeNames.isNotEmpty ? _placeNames.first : null,
          adresseNameFromMap:'',
          address: nameofplace,
          nearbyPlaces: _placeNames,
          latitude: _selectedPosition!.latitude,
          longitude: _selectedPosition!.longitude,
          plusCode: _selectedAddress.contains("Plus Code:") 
              ? _selectedAddress.split("Plus Code: ").last.trim() 
              : null,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une position sur la carte'),
            backgroundColor: Colors.red,
          ),
        );
      }
    },
    backgroundColor: Colors.green,
    child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), 
      child: Center( 
        child: Text(
          "Récupérer adresse et voir détails",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  ),
),
        ],
      ),
      ) );
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchSuggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
      _showSuggestions = true;
    });
    
    try {
      final response = await places.autocomplete(
        query,
        language: 'fr',
        components: [Component(Component.country, 'tn')]
      );
      
      if (response.isOkay) {
        setState(() {
          _searchSuggestions = response.predictions
              .map((prediction) => prediction.description ?? '')
              .toList();
        });
      }
    } catch (e) {
      print('Erreur lors de la recherche de lieux: $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  // Méthode pour sélectionner un lieu à partir des suggestions
  Future<void> _selectPlace(String placeDescription) async {
    setState(() {
      _isSearching = true;
      _showSuggestions = false;
      _searchController.text = placeDescription;
    });
    
    try {
      final response = await places.searchByText(placeDescription);
      
      if (response.isOkay && response.results.isNotEmpty) {
        final place = response.results.first;
        final location = LatLng(
          place.geometry?.location.lat ?? 0,
          place.geometry?.location.lng ?? 0,
        );
        
        // Mettre à jour la position sélectionnée
        _updateSelectedPosition(location);
        
        // Animer la caméra vers la position
        _mapController.animateCamera(CameraUpdate.newLatLngZoom(location, 17));
        
        // Créer un marqueur
        final Marker marker = Marker(
          markerId: MarkerId(place.placeId ?? "selected_place"),
          position: location,
          infoWindow: InfoWindow(title: place.name),
        );
        
        setState(() {
          _markers = {marker};
          _selectedAddress = place.formattedAddress ?? "Adresse non disponible";
          _placeNames = [place.name ?? "Lieu inconnu"];
          _hasEstablishment = true;
        });
      }
    } catch (e) {
      print('Erreur lors de la sélection du lieu: $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _navigateToDetailsPage() async {
    if (_selectedPosition == null) return;

    String? plusCode;
    if (_selectedAddress.contains("Plus Code:")) {
      plusCode = _selectedAddress.split("Plus Code: ").last.trim();
    }

    String? placeName;
    if (_hasEstablishment && _placeNames.isNotEmpty) {
      placeName = _placeNames.first;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectedPlaceInfoPage(
          placeName: placeName,
          address: _selectedAddress,
          nearbyPlaces: _placeNames,
          latitude: _selectedPosition!.latitude,
          longitude: _selectedPosition!.longitude,
          plusCode: plusCode,
        ),
      ),
    );

    if (result != null) {
      if (result is String) {
        Navigator.pop(context, result);
      } 
      else if (result == true) {
        String returnValue = _hasEstablishment && _placeNames.isNotEmpty
            ? "${_placeNames.first}\n$_selectedAddress" 
            : _selectedAddress;
        Navigator.pop(context, returnValue);
      }
    }
  }

  // 2. Ajoutez cette nouvelle méthode pour afficher le dialog
/*Future<void> _showPlaceDetailsDialog(BuildContext context) async {
  if (_selectedPosition == null) return;

  String? plusCode;
  if (_selectedAddress.contains("Plus Code:")) {
    plusCode = _selectedAddress.split("Plus Code: ").last.trim();
  }

  String? placeName;
  if (_hasEstablishment && _placeNames.isNotEmpty) {
    placeName = _placeNames.first;
  }

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      insetPadding: const EdgeInsets.all(20),
      contentPadding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: _PlaceDetailsPopup(
          placeName: placeName,
          address: _selectedAddress,
          nearbyPlaces: _placeNames,
          latitude: _selectedPosition!.latitude,
          longitude: _selectedPosition!.longitude,
          plusCode: plusCode,
          onConfirm: (selectedValue) {
            Navigator.pop(context, selectedValue);
          },
        ),
      ),
    ),
  );
}*/

  Future<void> _updateSelectedPosition(LatLng position) async {
    setState(() {
      _isSearching = true;
      _selectedPosition = position;
      _selectedAddress = "Détection de l'adresse en cours...";
      _hasEstablishment = false;
      _placeNames = [];
      _plusCode = null;
      
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selectedPosition'),
          position: position,
          infoWindow: const InfoWindow(title: 'Position sélectionnée'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    });

    await _searchNearbyPlaces(position);
    
    String? addressResult = await _getFormattedAddress(position);
    
    if (mounted) {
      setState(() {
        _isSearching = false;
        
        if (addressResult != null && addressResult.isNotEmpty) {
          _selectedAddress = addressResult;
          
          if (_plusCode != null && _plusCode!.isNotEmpty) {
            _selectedAddress += "\nPlus Code: $_plusCode";
          }
        } else {
          _selectedAddress = "Latitude: ${position.latitude.toStringAsFixed(6)}, Longitude: ${position.longitude.toStringAsFixed(6)}";
          
          if (_plusCode != null && _plusCode!.isNotEmpty) {
            _selectedAddress += "\nPlus Code: $_plusCode";
          }
        }
        
        if (_hasEstablishment && _placeNames.isNotEmpty) {
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('selectedPosition'),
              position: position,
              infoWindow: InfoWindow(
                title: _placeNames.first,
                snippet: _selectedAddress,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
          );
        }
      });
    }
  }

  Future<void> _searchNearbyPlaces(LatLng position) async {
    try {
      final url='https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
          'location=${position.latitude},${position.longitude}'
          '&radius=5'
          '&key=$_apiKey';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'] != null) {
          _nearbyPlaces = data['results'];
          
          _placeNames = [];
          for (var place in _nearbyPlaces) {
            if (place['name'] != null && place['name'].toString().isNotEmpty) {
              _placeNames.add(place['name'].toString());
            }
          }
          
          _hasEstablishment = _placeNames.isNotEmpty;
        }
      }
    } catch (e) {
      print('Erreur dans searchNearbyPlaces: $e');
    }
  }

  Future<String?> _getFormattedAddress(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        
        List<String> addressParts = [];
        
        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          addressParts.add(place.postalCode!);
        }
        
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }
        
        return addressParts.join(', ');
      }
      
      return null;
    } catch (e) {
      print('Erreur dans getFormattedAddress: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}