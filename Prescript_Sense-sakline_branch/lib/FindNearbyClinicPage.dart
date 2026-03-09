import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;
import 'app_colors.dart';

class FindNearbyClinicPage extends StatefulWidget {
  const FindNearbyClinicPage({super.key});

  @override
  State<FindNearbyClinicPage> createState() => _FindNearbyClinicPageState();
}

class _FindNearbyClinicPageState extends State<FindNearbyClinicPage> {
  // TODO: Replace with your actual Mapbox PUBLIC Key (Starts with pk.)
  static const String _mapboxPublicKey =
      'pk.eyJ1Ijoiam9obi1kb2UtOTA4IiwiYSI6ImNtbWk1N3dxeDEyeWsycHM1M3IzeXAzM3oifQ.CBTtvxYvxvXqWeVa3nG9_Q';

  final TextEditingController _searchController = TextEditingController();
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _annotationManager;
  CircleAnnotationManager? _circleManager;

  geo.Position? _currentPosition;
  String _selectedFilter = 'All';
  bool _isLoadingMap = true;

  final List<String> _filterOptions = ['All', 'Clinic', 'Hospital', 'Pharmacy'];

  @override
  void initState() {
    super.initState();
    MapboxOptions.setAccessToken(_mapboxPublicKey);
    _initializeLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 1. Get location with robust error handling
  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services are disabled.');

      geo.LocationPermission permission =
          await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          throw Exception('Location permissions denied.');
        }
      }
      if (permission == geo.LocationPermission.deniedForever) {
        throw Exception('Location permanently denied.');
      }

      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingMap = false; // This triggers the MapWidget to build
        });
        // We DO NOT fetch places here anymore. We wait for the map to finish building first!
      }
    } catch (e) {
      debugPrint("Location Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not get live location. Error: ${e.toString().split(':').last}',
            ),
            backgroundColor: AppColors.cautionAmber,
          ),
        );
      }
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    // Initialize both managers
    _annotationManager = await _mapboxMap!.annotations
        .createPointAnnotationManager();
    _circleManager = await _mapboxMap!.annotations
        .createCircleAnnotationManager();

    _fetchNearbyPlacesMapbox();
  }


  /// FIXED: Use Mapbox Search Box Category API for real POI discovery
  Future<void> _fetchNearbyPlacesMapbox() async {
    if (_currentPosition == null) return;

    // Map filter to Mapbox Search Box category IDs
    final Map<String, String> categoryMap = {
      'All': 'hospital,clinic_and_praxis,pharmacy',
      'Clinic': 'clinic_and_praxis',
      'Hospital': 'hospital',
      'Pharmacy': 'pharmacy',
    };

    final category = categoryMap[_selectedFilter] ?? 'hospital';

    // Use Mapbox Search Box API (category endpoint) — correct API for POI search
    final url = Uri.parse(
      'https://api.mapbox.com/search/searchbox/v1/category/$category?'
      'proximity=${_currentPosition!.longitude},${_currentPosition!.latitude}'
      '&limit=25'
      '&access_token=$_mapboxPublicKey',
    );

    try {
      final response = await http.get(url);
      debugPrint('Search Box Status: ${response.statusCode}');
      debugPrint('Search Box Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Search Box API returns 'features' just like Geocoding
        final features = data['features'] as List;

        if (features.isEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No $_selectedFilter found nearby.'),
              backgroundColor: AppColors.cautionAmber,
            ),
          );
        }

        _buildMarkersFromSearchBox(features);
      } else {
        debugPrint('API Error: ${response.body}');
      }
    } catch (e) {
      debugPrint('Mapbox Search Box Error: $e');
    }
  }

  /// Parses Search Box API response (different shape from Geocoding API)
Future<void> _buildMarkersFromSearchBox(List<dynamic> features) async {
  if (_annotationManager == null || _circleManager == null) return;

  await _annotationManager?.deleteAll();
  await _circleManager?.deleteAll();

  final points = <PointAnnotationOptions>[];
  final circles = <CircleAnnotationOptions>[];

  for (var feature in features) {
    // Search Box uses geometry.coordinates just like Geocoding
    final coords = feature['geometry']['coordinates'] as List;
    final lng = (coords[0] as num).toDouble();
    final lat = (coords[1] as num).toDouble();

    // Search Box API puts the name in properties.name (not feature['text'])
    final name = feature['properties']?['name'] ?? 'Location';

    String prefix = "📍";
    int dotColor = 0xFF0D6E6E;

    if (_selectedFilter == 'Hospital') {
      prefix = "🏥";
      dotColor = 0xFFDC2626;
    } else if (_selectedFilter == 'Pharmacy') {
      prefix = "💊";
      dotColor = 0xFF059669;
    } else if (_selectedFilter == 'Clinic') {
      prefix = "🩺";
      dotColor = 0xFF1A9C9C;
    } else {
      // For 'All', auto-detect from category
      final cats = (feature['properties']?['poi_category'] as List?)
              ?.map((c) => c.toString().toLowerCase())
              .toList() ??
          [];
      if (cats.any((c) => c.contains('hospital'))) {
        prefix = "🏥";
        dotColor = 0xFFDC2626;
      } else if (cats.any((c) => c.contains('pharmacy'))) {
        prefix = "💊";
        dotColor = 0xFF059669;
      } else {
        prefix = "🩺";
        dotColor = 0xFF1A9C9C;
      }
    }

    circles.add(
      CircleAnnotationOptions(
        geometry: Point(coordinates: Position(lng, lat)),
        circleColor: dotColor,
        circleRadius: 10.0,
      ),
    );

    points.add(
      PointAnnotationOptions(
        geometry: Point(coordinates: Position(lng, lat)),
        textField: "$prefix $name",
        textColor: 0xFF000000,
        textSize: 14.0,
        textOffset: [0.0, 1.2],
      ),
    );
  }

  if (circles.isNotEmpty) await _circleManager?.createMulti(circles);
  if (points.isNotEmpty) await _annotationManager?.createMulti(points);

  _mapboxMap?.flyTo(
    CameraOptions(
      center: Point(
        coordinates: Position(
          _currentPosition!.longitude,
          _currentPosition!.latitude,
        ),
      ),
      zoom: 13.5,
    ),
    MapAnimationOptions(duration: 1000),
  );
}

  /// Converts a typed location into coordinates, moves the map, and fetches clinics there.
  Future<void> _searchAndMoveToLocation(String query) async {
    if (query.trim().isEmpty) return;

    setState(() => _isLoadingMap = true);

    final geocodeUrl = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(query)}.json?'
      'access_token=$_mapboxPublicKey',
    );

    try {
      final response = await http.get(geocodeUrl);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;

        if (features.isNotEmpty) {
          final coords = features[0]['geometry']['coordinates'] as List;
          final lng = coords[0];
          final lat = coords[1];

          setState(() {
            _currentPosition = geo.Position(
              longitude: lng,
              latitude: lat,
              timestamp: DateTime.now(),
              accuracy: 0.0,
              altitude: 0.0,
              altitudeAccuracy: 0.0,
              heading: 0.0,
              headingAccuracy: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0,
            );
            _isLoadingMap = false;
          });

          _mapboxMap?.flyTo(
            CameraOptions(
              center: Point(coordinates: Position(lng, lat)),
              zoom: 13.5,
            ),
            MapAnimationOptions(duration: 1200),
          );

          _fetchNearbyPlacesMapbox();
        } else {
          setState(() => _isLoadingMap = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location not found.'),
                backgroundColor: AppColors.cautionAmber,
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() => _isLoadingMap = false);
      debugPrint('Geocoding Error: $e');
    }
  }

  /// Parses JSON into Mapbox Markers (Emulator-Safe Version)
  Future<void> _buildMarkersFromJson(List<dynamic> features) async {
    if (_annotationManager == null || _circleManager == null) return;

    // Clear existing markers
    await _annotationManager?.deleteAll();
    await _circleManager?.deleteAll();

    final points = <PointAnnotationOptions>[];
    final circles = <CircleAnnotationOptions>[];

    for (var feature in features) {
      final coords = feature['geometry']['coordinates'] as List;
      final lng = (coords[0] as num).toDouble();
      final lat = (coords[1] as num).toDouble();
      final name = feature['text'] ?? 'Location';

      // Define semantics based on category
      String prefix = "📍";
      int dotColor = 0xFF0D6E6E; // Deep Teal (Default)

      if (_selectedFilter == 'Hospital') {
        prefix = "🏥";
        dotColor = 0xFFDC2626; // Alert Red
      } else if (_selectedFilter == 'Pharmacy') {
        prefix = "💊";
        dotColor = 0xFF059669; // Safe Green
      } else if (_selectedFilter == 'Clinic') {
        prefix = "🩺";
        dotColor = 0xFF1A9C9C; // Teal
      }

      // 1. Draw the basic colored dot (Removed Stroke/Outline to prevent shader crash)
      circles.add(
        CircleAnnotationOptions(
          geometry: Point(coordinates: Position(lng, lat)),
          circleColor: dotColor,
          circleRadius: 10.0,
        ),
      );

      // 2. Draw the text (Removed Halo to prevent shader crash)
      points.add(
        PointAnnotationOptions(
          geometry: Point(coordinates: Position(lng, lat)),
          textField: "$prefix $name",
          textColor: 0xFF000000, // Explicit Solid Black
          textSize: 14.0,
          textOffset: [0.0, 1.2],
        ),
      );
    }

    if (circles.isNotEmpty) await _circleManager?.createMulti(circles);
    if (points.isNotEmpty) await _annotationManager?.createMulti(points);

    // Re-center camera gently
    _mapboxMap?.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(
            _currentPosition!.longitude,
            _currentPosition!.latitude,
          ),
        ),
        zoom: 13.5,
      ),
      MapAnimationOptions(duration: 1000),
    );
  }

  Future<void> _callAmbulance() async {
    const tel = 'tel:999';
    if (await canLaunchUrl(Uri.parse(tel))) {
      await launchUrl(Uri.parse(tel));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot make a call from this device'),
          backgroundColor: AppColors.alertRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.ink : AppColors.cloud;
    final cardBg = isDark ? AppColors.slate : AppColors.white;
    final textMain = isDark ? AppColors.white : AppColors.ink;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Find Care Nearby'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? AppColors.teal : AppColors.deepTeal,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.teal : AppColors.deepTeal,
          letterSpacing: -0.5,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),

          // --- SEARCH & AMBULANCE ROW ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: textMain),
                    decoration: InputDecoration(
                      hintText: 'Search areas (e.g. Uttara)...',
                      hintStyle: const TextStyle(color: AppColors.ash),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.teal,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: cardBg,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onSubmitted: (value) {
                      FocusScope.of(context).unfocus();
                      _searchAndMoveToLocation(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _callAmbulance,
                  icon: const Icon(Icons.emergency_rounded, size: 18),
                  label: const Text(
                    'SOS',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softRed,
                    foregroundColor: AppColors.alertRed,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // --- FILTER CHIPS ROW ---
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final type = _filterOptions[index];
                final isSelected = _selectedFilter == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedFilter = type);
                        _fetchNearbyPlacesMapbox();
                      }
                    },
                    selectedColor: AppColors.deepTeal,
                    backgroundColor: cardBg,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.white : textMain,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.deepTeal
                            : (isDark
                                  ? AppColors.ash.withOpacity(0.2)
                                  : AppColors.mist),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // --- MAPBOX WIDGET ---
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: _isLoadingMap || _currentPosition == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.deepTeal,
                      ),
                    )
                  : MapWidget(
                      key: const ValueKey("mapWidget"),
                      onMapCreated: _onMapCreated,
                      cameraOptions: CameraOptions(
                        center: Point(
                          coordinates: Position(
                            _currentPosition!.longitude,
                            _currentPosition!.latitude,
                          ),
                        ),
                        zoom: 14.0,
                      ),
                      styleUri: isDark
                          ? MapboxStyles.DARK
                          : MapboxStyles.MAPBOX_STREETS,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
