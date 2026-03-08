// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';

// class FindNearbyClinicPage extends StatefulWidget {
//   const FindNearbyClinicPage({super.key});

//   @override
//   State<FindNearbyClinicPage> createState() => _FindNearbyClinicPageState();
// }

// class _FindNearbyClinicPageState extends State<FindNearbyClinicPage> {
//   final TextEditingController _searchController = TextEditingController();
//   late GoogleMapController _mapController;

//   // Sample initial location (can be updated with Geolocator)
//   final LatLng _initialPosition = const LatLng(23.8103, 90.4125); // Dhaka

//   final Set<Marker> _markers = {
//     Marker(
//       markerId: MarkerId('clinic1'),
//       position: LatLng(23.8110, 90.4120),
//       infoWindow: InfoWindow(title: 'City Health Clinic'),
//     ),
//     Marker(
//       markerId: MarkerId('clinic2'),
//       position: LatLng(23.8090, 90.4140),
//       infoWindow: InfoWindow(title: 'Downtown Medical Center'),
//     ),
//   };

//   // Launch a phone call to ambulance
//   Future<void> _callAmbulance() async {
//     const tel = 'tel:999'; // Replace with local ambulance number
//     if (await canLaunchUrl(Uri.parse(tel))) {
//       await launchUrl(Uri.parse(tel));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Cannot make a call')),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _mapController.dispose();
//     super.dispose();
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//   }

//   void _searchClinic() {
//     // Mock search: just show snackbar
//     final query = _searchController.text.trim();
//     if (query.isEmpty) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Searching for "$query"...')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Find Nearby Clinic'),
//         backgroundColor: const Color(0xFF1E3A8A),
//       ),
//       body: Column(
//         children: [
//           const SizedBox(height: 12),
//           // --- SEARCH BAR ROW ---
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search clinics or specialties',
//                       prefixIcon: const Icon(Icons.search),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: _searchClinic,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF3B82F6),
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                   ),
//                   child: const Icon(Icons.search, color: Colors.white),
//                 )
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),

//           // --- LOCATION & AMBULANCE ROW (FIXED) ---
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 const Icon(Icons.location_on, color: Colors.red),
//                 const SizedBox(width: 8),

//                 // 1. Wrap the text in Expanded so it can shrink if necessary
//                 const Expanded(
//                   child: Text(
//                     'Your current location',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     overflow: TextOverflow.ellipsis, // 2. Add ellipsis for graceful clipping
//                   ),
//                 ),

//                 // 3. Replace Spacer() with a fixed SizedBox to ensure a minimum gap
//                 const SizedBox(width: 8),

//                 ElevatedButton.icon(
//                   onPressed: _callAmbulance,
//                   icon: const Icon(Icons.local_hospital),
//                   label: const Text('Call Ambulance'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color.fromARGB(255, 200, 238, 225),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),

//           // --- GOOGLE MAP ---
//           Expanded(
//             child: GoogleMap(
//               onMapCreated: _onMapCreated,
//               initialCameraPosition: CameraPosition(
//                 target: _initialPosition,
//                 zoom: 15,
//               ),
//               markers: _markers,
//               myLocationEnabled: true,
//               myLocationButtonEnabled: true,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_colors.dart'; // Ensure you import your color palette

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
    const Marker(
      markerId: MarkerId('clinic1'),
      position: LatLng(23.8110, 90.4120),
      infoWindow: InfoWindow(title: 'City Health Clinic'),
    ),
    const Marker(
      markerId: MarkerId('clinic2'),
      position: LatLng(23.8090, 90.4140),
      infoWindow: InfoWindow(title: 'Downtown Medical Center'),
    ),
  };

  Future<void> _callAmbulance() async {
    const tel = 'tel:999';
    if (await canLaunchUrl(Uri.parse(tel))) {
      await launchUrl(Uri.parse(tel));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cannot make a call'),
          backgroundColor: AppColors.alertRed,
        ),
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
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for "$query"...'),
        backgroundColor: AppColors.deepTeal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cloud,
      appBar: AppBar(
        title: const Text('Nearby Clinics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.deepTeal,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.deepTeal,
          letterSpacing: -0.5,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // --- SEARCH BAR ROW ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppColors.ink),
                    decoration: InputDecoration(
                      hintText: 'Search clinics or specialties',
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
                      fillColor: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.deepTeal,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    onPressed: _searchClinic,
                    icon: const Icon(Icons.search, color: AppColors.white),
                    padding: const EdgeInsets.all(14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // --- LOCATION & AMBULANCE ROW (WITH OVERFLOW FIX) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.softLavender,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.my_location_rounded,
                    color: AppColors.lavenderBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Overflow protection
                const Expanded(
                  child: Text(
                    'Your current location',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: 8),

                // Semantic Danger Button for Emergency
                ElevatedButton.icon(
                  onPressed: _callAmbulance,
                  icon: const Icon(Icons.emergency_rounded, size: 18),
                  label: const Text(
                    'Ambulance',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softRed,
                    foregroundColor: AppColors.alertRed,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // --- GOOGLE MAP ---
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
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
          ),
        ],
      ),
    );
  }
}
