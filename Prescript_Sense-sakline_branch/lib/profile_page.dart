// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'auth_service.dart';
// import 'landing_page.dart'; // Needed for Logout navigation

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final AuthService _authService = AuthService();

//   // State Variables
//   String _name = "Loading...";
//   String _email = "Loading...";
//   String? _imagePath;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   // 1. Load Data from Storage
//   Future<void> _loadUserData() async {
//     final name = await _authService.getUserName();
//     final email = await _authService.getUserEmail();
//     final imagePath = await _authService.getProfileImagePath();

//     if (mounted) {
//       setState(() {
//         _name = name ?? "User";
//         _email = email ?? "No Email";
//         _imagePath = imagePath;
//         _isLoading = false;
//       });
//     }
//   }

//   // 2. Pick and Save Image
//   Future<void> _pickImage() async {
//     final ImagePicker picker = ImagePicker();

//     // Show modal to ask Camera or Gallery
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => SafeArea(
//         child: Wrap(
//           children: [
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('Photo Library'),
//               onTap: () async {
//                 Navigator.of(context).pop();
//                 final XFile? image = await picker.pickImage(
//                   source: ImageSource.gallery,
//                 );
//                 if (image != null) _saveImage(image.path);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_camera),
//               title: const Text('Camera'),
//               onTap: () async {
//                 Navigator.of(context).pop();
//                 final XFile? image = await picker.pickImage(
//                   source: ImageSource.camera,
//                 );
//                 if (image != null) _saveImage(image.path);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _saveImage(String path) async {
//     await _authService.updateProfile(imagePath: path);
//     setState(() {
//       _imagePath = path;
//     });
//   }

//   // 3. Edit Profile Dialog
//   void _showEditDialog() {
//     final nameController = TextEditingController(text: _name);
//     final emailController = TextEditingController(text: _email);

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit Profile'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(
//                 labelText: "Full Name",
//                 prefixIcon: Icon(Icons.person),
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(
//                 labelText: "Email",
//                 prefixIcon: Icon(Icons.email),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               // Save changes
//               await _authService.updateProfile(
//                 name: nameController.text,
//                 email: emailController.text,
//               );
//               // Update UI
//               setState(() {
//                 _name = nameController.text;
//                 _email = emailController.text;
//               });
//               if (mounted) Navigator.pop(context);
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }

//   // 4. Logout Logic
//   void _handleLogout() async {
//     await _authService.logout();
//     if (mounted) {
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const LandingPage()),
//         (route) => false,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: Colors.transparent, // Clean look
//         elevation: 0,
//         foregroundColor: Theme.of(context).primaryColor,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 20),

//                   // --- Profile Picture Section ---
//                   Center(
//                     child: Stack(
//                       children: [
//                         // The Image Avatar
//                         Container(
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(
//                               color: Colors.blue.shade100,
//                               width: 4,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 20,
//                                 offset: const Offset(0, 10),
//                               ),
//                             ],
//                           ),
//                           child: CircleAvatar(
//                             radius: 70,
//                             backgroundColor: Colors.grey[200],
//                             backgroundImage: _imagePath != null
//                                 ? FileImage(File(_imagePath!))
//                                 : null,
//                             child: _imagePath == null
//                                 ? const Icon(
//                                     Icons.person,
//                                     size: 80,
//                                     color: Colors.grey,
//                                   )
//                                 : null,
//                           ),
//                         ),
//                         // The Edit Icon Badge
//                         Positioned(
//                           bottom: 0,
//                           right: 0,
//                           child: InkWell(
//                             onTap: _pickImage,
//                             child: Container(
//                               padding: const EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: Theme.of(context).primaryColor,
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: Colors.white,
//                                   width: 3,
//                                 ),
//                               ),
//                               child: const Icon(
//                                 Icons.camera_alt,
//                                 color: Colors.white,
//                                 size: 24,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 32),

//                   // --- User Details ---
//                   Text(
//                     _name,
//                     style: const TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     _email,
//                     style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//                   ),

//                   const SizedBox(height: 40),

//                   // --- Action Buttons ---

//                   // Edit Profile
//                   ListTile(
//                     onTap: _showEditDialog,
//                     tileColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     leading: Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: const Icon(Icons.edit, color: Colors.blue),
//                     ),
//                     title: const Text(
//                       "Edit Profile Details",
//                       style: TextStyle(fontWeight: FontWeight.w600),
//                     ),
//                     trailing: const Icon(
//                       Icons.arrow_forward_ios,
//                       size: 16,
//                       color: Colors.grey,
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   // Settings (Placeholder navigation)
//                   ListTile(
//                     onTap: () {
//                       // Navigate to Settings Page if you have one
//                     },
//                     tileColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     leading: Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: Colors.purple.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: const Icon(Icons.settings, color: Colors.purple),
//                     ),
//                     title: const Text(
//                       "App Settings",
//                       style: TextStyle(fontWeight: FontWeight.w600),
//                     ),
//                     trailing: const Icon(
//                       Icons.arrow_forward_ios,
//                       size: 16,
//                       color: Colors.grey,
//                     ),
//                   ),

//                   const SizedBox(height: 40),

//                   // Logout Button
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: _handleLogout,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red[50],
//                         foregroundColor: Colors.red,
//                         elevation: 0,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                       ),
//                       icon: const Icon(Icons.logout),
//                       label: const Text("Log Out"),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }



import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'auth_service.dart';
import 'landing_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();

  // Basic Info State
  String _name = "Loading...";
  String _email = "Loading...";
  String? _imagePath;
  
  // Medical Info State
  String _age = "N/A";
  String _gender = "N/A";
  String _height = "N/A";
  String _weight = "N/A";
  String _allergies = "None";
  String _medications = "None";
  
  bool _isLoading = true;

  final List<String> _allergyOptions = [
    'None (No known allergies)', 'Peanuts', 'Tree Nuts', 'Milk / Dairy', 
    'Eggs', 'Wheat', 'Soy', 'Fish', 'Shellfish', 'Penicillin', 
    'Sulfa Drugs', 'Aspirin', 'Ibuprofen', 'Latex', 'Pollen', 'Dust Mites'
  ];
  final List<String> _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await _authService.getUserName();
    final email = await _authService.getUserEmail();
    final imagePath = await _authService.getProfileImagePath();
    
    // Fetch new medical data
    final medicalData = await _authService.getMedicalProfile();

    if (mounted) {
      setState(() {
        _name = name ?? "User";
        _email = email ?? "No Email";
        _imagePath = imagePath;
        
        _age = medicalData['age']!;
        _gender = medicalData['gender']!;
        _height = medicalData['height']!;
        _weight = medicalData['weight']!;
        _allergies = medicalData['allergies']!;
        _medications = medicalData['medications']!;
        
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Library'),
              onTap: () async {
                Navigator.of(context).pop();
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) _saveImage(image.path);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.of(context).pop();
                final XFile? image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) _saveImage(image.path);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveImage(String path) async {
    await _authService.updateProfile(imagePath: path);
    setState(() => _imagePath = path);
  }

  void _showEditBasicDialog() {
    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(text: _email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _authService.updateProfile(name: nameController.text, email: emailController.text);
              setState(() {
                _name = nameController.text;
                _email = emailController.text;
              });
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // NEW: Dialog to edit Medical Information
  void _showEditMedicalDialog() {
    final ageController = TextEditingController(text: _age == 'N/A' ? '' : _age);
    final heightController = TextEditingController(text: _height == 'N/A' ? '' : _height);
    final weightController = TextEditingController(text: _weight == 'N/A' ? '' : _weight);
    final medsController = TextEditingController(text: _medications == 'None' ? '' : _medications);
    
    // Ensure the current value exists in the options, otherwise default to the first option
    String? tempGender = _genderOptions.contains(_gender) ? _gender : _genderOptions.first;
    String? tempAllergy = _allergyOptions.contains(_allergies) ? _allergies : _allergyOptions.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Medical Info'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: TextField(controller: ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Age"))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: tempGender,
                          decoration: const InputDecoration(labelText: "Gender"),
                          items: _genderOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) => setDialogState(() => tempGender = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: heightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Height (cm)"))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Weight (kg)"))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: tempAllergy,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: "Allergies"),
                    items: _allergyOptions.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (val) => setDialogState(() => tempAllergy = val),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: medsController, decoration: const InputDecoration(labelText: "Current Meds (e.g. Napa)")),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  await _authService.saveMedicalProfile(
                    age: ageController.text,
                    gender: tempGender ?? 'N/A',
                    height: heightController.text,
                    weight: weightController.text,
                    allergies: tempAllergy ?? 'None',
                    medications: medsController.text.isEmpty ? 'None' : medsController.text,
                  );
                  _loadUserData(); // Reload the UI with new data
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LandingPage()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue.shade100, width: 4),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                          ),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                            child: _imagePath == null ? const Icon(Icons.person, size: 80, color: Colors.grey) : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        Text(_name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(_email, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- MEDICAL INFORMATION CARD ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Medical Information",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_note, color: Colors.blue),
                        onPressed: _showEditMedicalDialog,
                        tooltip: "Edit Medical Info",
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.cake, "Age", _age),
                        const Divider(height: 24),
                        _buildInfoRow(Icons.person, "Gender", _gender),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(child: _buildInfoRow(Icons.height, "Height", "$_height cm")),
                            Expanded(child: _buildInfoRow(Icons.monitor_weight, "Weight", "$_weight kg")),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(Icons.warning_amber_rounded, "Allergies", _allergies, isAlert: _allergies != 'None (No known allergies)' && _allergies != 'None'),
                        const Divider(height: 24),
                        _buildInfoRow(Icons.medication, "Current Meds", _medications),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Actions
                  ListTile(
                    onTap: _showEditBasicDialog,
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.edit, color: Colors.blue),
                    ),
                    title: const Text("Edit Account Details", style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text("Log Out"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Helper widget to build the rows in the Medical Info card
  Widget _buildInfoRow(IconData icon, String label, String value, {bool isAlert = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: isAlert ? Colors.red[400] : Colors.blueGrey[400]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isAlert ? Colors.red[700] : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}