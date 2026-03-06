import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class FindNearbyClinicPage extends StatefulWidget {
  const FindNearbyClinicPage({super.key});

  @override
  State<FindNearbyClinicPage> createState() => _FindNearbyClinicPageState();
}

class _FindNearbyClinicPageState extends State<FindNearbyClinicPage> {
  final TextEditingController _searchController = TextEditingController();
  late GoogleMapController _mapController;

  // Sample initial location (can be updated with Geolocator)
  final LatLng _initialPosition = const LatLng(23.8103, 90.4125); // Dhaka

  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('clinic1'),
      position: LatLng(23.8110, 90.4120),
      infoWindow: InfoWindow(title: 'City Health Clinic'),
    ),
    Marker(
      markerId: MarkerId('clinic2'),
      position: LatLng(23.8090, 90.4140),
      infoWindow: InfoWindow(title: 'Downtown Medical Center'),
    ),
  };

  // Launch a phone call to ambulance
  Future<void> _callAmbulance() async {
    const tel = 'tel:999'; // Replace with local ambulance number
    if (await canLaunchUrl(Uri.parse(tel))) {
      await launchUrl(Uri.parse(tel));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot make a call')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _searchClinic() {
    // Mock search: just show snackbar
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for "$query"...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Nearby Clinic'),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search clinics or specialties',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchClinic,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  child: const Icon(Icons.search, color: Colors.white),
                )
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'Your current location',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _callAmbulance,
                  icon: const Icon(Icons.local_hospital),
                  label: const Text('Call Ambulance'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 200, 238, 225),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 15,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
}
