// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'auth_service.dart';
// import 'landing_page.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final AuthService _authService = AuthService();

//   // Basic Info State
//   String _name = "Loading...";
//   String _email = "Loading...";
//   String? _imagePath;

//   // Medical Info State
//   String _age = "N/A";
//   String _gender = "N/A";
//   String _height = "N/A";
//   String _weight = "N/A";
//   String _allergies = "None";
//   String _medications = "None";

//   bool _isLoading = true;

//   final List<String> _allergyOptions = [
//     'None (No known allergies)', 'Peanuts', 'Tree Nuts', 'Milk / Dairy',
//     'Eggs', 'Wheat', 'Soy', 'Fish', 'Shellfish', 'Penicillin',
//     'Sulfa Drugs', 'Aspirin', 'Ibuprofen', 'Latex', 'Pollen', 'Dust Mites'
//   ];
//   final List<String> _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     final name = await _authService.getUserName();
//     final email = await _authService.getUserEmail();
//     final imagePath = await _authService.getProfileImagePath();

//     // Fetch new medical data
//     final medicalData = await _authService.getMedicalProfile();

//     if (mounted) {
//       setState(() {
//         _name = name ?? "User";
//         _email = email ?? "No Email";
//         _imagePath = imagePath;

//         _age = medicalData['age']!;
//         _gender = medicalData['gender']!;
//         _height = medicalData['height']!;
//         _weight = medicalData['weight']!;
//         _allergies = medicalData['allergies']!;
//         _medications = medicalData['medications']!;

//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _pickImage() async {
//     final ImagePicker picker = ImagePicker();
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
//                 final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//                 if (image != null) _saveImage(image.path);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_camera),
//               title: const Text('Camera'),
//               onTap: () async {
//                 Navigator.of(context).pop();
//                 final XFile? image = await picker.pickImage(source: ImageSource.camera);
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
//     setState(() => _imagePath = path);
//   }

//   void _showEditBasicDialog() {
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
//               decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person)),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () async {
//               await _authService.updateProfile(name: nameController.text, email: emailController.text);
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

//   // NEW: Dialog to edit Medical Information
//   void _showEditMedicalDialog() {
//     final ageController = TextEditingController(text: _age == 'N/A' ? '' : _age);
//     final heightController = TextEditingController(text: _height == 'N/A' ? '' : _height);
//     final weightController = TextEditingController(text: _weight == 'N/A' ? '' : _weight);
//     final medsController = TextEditingController(text: _medications == 'None' ? '' : _medications);

//     // Ensure the current value exists in the options, otherwise default to the first option
//     String? tempGender = _genderOptions.contains(_gender) ? _gender : _genderOptions.first;
//     String? tempAllergy = _allergyOptions.contains(_allergies) ? _allergies : _allergyOptions.first;

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setDialogState) {
//           return AlertDialog(
//             title: const Text('Edit Medical Info'),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(child: TextField(controller: ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Age"))),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: DropdownButtonFormField<String>(
//                           value: tempGender,
//                           decoration: const InputDecoration(labelText: "Gender"),
//                           items: _genderOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
//                           onChanged: (val) => setDialogState(() => tempGender = val),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Expanded(child: TextField(controller: heightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Height (cm)"))),
//                       const SizedBox(width: 12),
//                       Expanded(child: TextField(controller: weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Weight (kg)"))),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   DropdownButtonFormField<String>(
//                     value: tempAllergy,
//                     isExpanded: true,
//                     decoration: const InputDecoration(labelText: "Allergies"),
//                     items: _allergyOptions.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
//                     onChanged: (val) => setDialogState(() => tempAllergy = val),
//                   ),
//                   const SizedBox(height: 12),
//                   TextField(controller: medsController, decoration: const InputDecoration(labelText: "Current Meds (e.g. Napa)")),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//               ElevatedButton(
//                 onPressed: () async {
//                   await _authService.saveMedicalProfile(
//                     age: ageController.text,
//                     gender: tempGender ?? 'N/A',
//                     height: heightController.text,
//                     weight: weightController.text,
//                     allergies: tempAllergy ?? 'None',
//                     medications: medsController.text.isEmpty ? 'None' : medsController.text,
//                   );
//                   _loadUserData(); // Reload the UI with new data
//                   if (mounted) Navigator.pop(context);
//                 },
//                 child: const Text('Save'),
//               ),
//             ],
//           );
//         }
//       ),
//     );
//   }

//   void _handleLogout() async {
//     await _authService.logout();
//     if (mounted) {
//       Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LandingPage()), (route) => false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         foregroundColor: Theme.of(context).primaryColor,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: Stack(
//                       children: [
//                         Container(
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.blue.shade100, width: 4),
//                             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
//                           ),
//                           child: CircleAvatar(
//                             radius: 70,
//                             backgroundColor: Colors.grey[200],
//                             backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
//                             child: _imagePath == null ? const Icon(Icons.person, size: 80, color: Colors.grey) : null,
//                           ),
//                         ),
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
//                                 border: Border.all(color: Colors.white, width: 3),
//                               ),
//                               child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   Center(
//                     child: Column(
//                       children: [
//                         Text(_name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 8),
//                         Text(_email, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 32),

//                   // --- MEDICAL INFORMATION CARD ---
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         "Medical Information",
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.edit_note, color: Colors.blue),
//                         onPressed: _showEditMedicalDialog,
//                         tooltip: "Edit Medical Info",
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
//                     ),
//                     child: Column(
//                       children: [
//                         _buildInfoRow(Icons.cake, "Age", _age),
//                         const Divider(height: 24),
//                         _buildInfoRow(Icons.person, "Gender", _gender),
//                         const Divider(height: 24),
//                         Row(
//                           children: [
//                             Expanded(child: _buildInfoRow(Icons.height, "Height", "$_height cm")),
//                             Expanded(child: _buildInfoRow(Icons.monitor_weight, "Weight", "$_weight kg")),
//                           ],
//                         ),
//                         const Divider(height: 24),
//                         _buildInfoRow(Icons.warning_amber_rounded, "Allergies", _allergies, isAlert: _allergies != 'None (No known allergies)' && _allergies != 'None'),
//                         const Divider(height: 24),
//                         _buildInfoRow(Icons.medication, "Current Meds", _medications),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 32),

//                   // Actions
//                   ListTile(
//                     onTap: _showEditBasicDialog,
//                     tileColor: Colors.white,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                     leading: Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
//                       child: const Icon(Icons.edit, color: Colors.blue),
//                     ),
//                     title: const Text("Edit Account Details", style: TextStyle(fontWeight: FontWeight.w600)),
//                     trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 16),

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

//   // Helper widget to build the rows in the Medical Info card
//   Widget _buildInfoRow(IconData icon, String label, String value, {bool isAlert = false}) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 20, color: isAlert ? Colors.red[400] : Colors.blueGrey[400]),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
//               const SizedBox(height: 2),
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                   color: isAlert ? Colors.red[700] : Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'auth_service.dart';
import 'landing_page.dart';
import 'app_colors.dart'; // Your minimal color palette

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
    'None (No known allergies)',
    'Peanuts',
    'Tree Nuts',
    'Milk / Dairy',
    'Eggs',
    'Wheat',
    'Soy',
    'Fish',
    'Shellfish',
    'Penicillin',
    'Sulfa Drugs',
    'Aspirin',
    'Ibuprofen',
    'Latex',
    'Pollen',
    'Dust Mites',
  ];
  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

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
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.ash,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.teal,
              ),
              title: const Text(
                'Photo Library',
                style: TextStyle(color: AppColors.ink),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) _saveImage(image.path);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.teal,
              ),
              title: const Text(
                'Camera',
                style: TextStyle(color: AppColors.ink),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) _saveImage(image.path);
              },
            ),
            const SizedBox(height: 16),
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
        backgroundColor: AppColors.white,
        title: const Text(
          'Edit Account Details',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogTextField(
              nameController,
              "Full Name",
              Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildDialogTextField(
              emailController,
              "Email",
              Icons.email_outlined,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.slate),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepTeal,
              foregroundColor: AppColors.white,
            ),
            onPressed: () async {
              await _authService.updateProfile(
                name: nameController.text,
                email: emailController.text,
              );
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

  void _showEditMedicalDialog() {
    final ageController = TextEditingController(
      text: _age == 'N/A' ? '' : _age,
    );
    final heightController = TextEditingController(
      text: _height == 'N/A' ? '' : _height,
    );
    final weightController = TextEditingController(
      text: _weight == 'N/A' ? '' : _weight,
    );
    final medsController = TextEditingController(
      text: _medications == 'None' ? '' : _medications,
    );

    String? tempGender = _genderOptions.contains(_gender)
        ? _gender
        : _genderOptions.first;
    String? tempAllergy = _allergyOptions.contains(_allergies)
        ? _allergies
        : _allergyOptions.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.white,
            title: const Text(
              'Edit Medical Info',
              style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogTextField(
                          ageController,
                          "Age",
                          null,
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: tempGender,
                          isExpanded:
                              true, // 1. ADDED: Forces the dropdown to respect parent width bounds
                          dropdownColor: AppColors.white,
                          decoration: _dialogInputDecoration("Gender"),
                          items: _genderOptions
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                    overflow: TextOverflow
                                        .ellipsis, // 2. ADDED: Truncates "Prefer not to say" to "Prefer not to..."
                                    style: const TextStyle(
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setDialogState(() => tempGender = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogTextField(
                          heightController,
                          "Height (cm)",
                          null,
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDialogTextField(
                          weightController,
                          "Weight (kg)",
                          null,
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: tempAllergy,
                    isExpanded: true,
                    dropdownColor: AppColors.white,
                    decoration: _dialogInputDecoration("Allergies"),
                    items: _allergyOptions
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.ink),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setDialogState(() => tempAllergy = val),
                  ),
                  const SizedBox(height: 16),
                  _buildDialogTextField(
                    medsController,
                    "Current Meds",
                    Icons.medication_outlined,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.slate),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepTeal,
                  foregroundColor: AppColors.white,
                ),
                onPressed: () async {
                  await _authService.saveMedicalProfile(
                    age: ageController.text,
                    gender: tempGender ?? 'N/A',
                    height: heightController.text,
                    weight: weightController.text,
                    allergies: tempAllergy ?? 'None',
                    medications: medsController.text.isEmpty
                        ? 'None'
                        : medsController.text,
                  );
                  _loadUserData();
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LandingPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cloud,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.deepTeal,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.deepTeal),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// PROFILE HEADER
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.mist, width: 6),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.ink.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 64,
                            backgroundColor: AppColors.white,
                            backgroundImage: _imagePath != null
                                ? FileImage(File(_imagePath!))
                                : null,
                            child: _imagePath == null
                                ? const Icon(
                                    Icons.person_outline,
                                    size: 60,
                                    color: AppColors.ash,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.deepTeal,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.cloud,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: AppColors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _email,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.slate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  /// MEDICAL INFORMATION CARD
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Medical Profile",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.teal,
                          size: 20,
                        ),
                        onPressed: _showEditMedicalDialog,
                        tooltip: "Edit Medical Info",
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.mist,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.mist, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ink.withOpacity(0.03),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoRow(
                                Icons.cake_outlined,
                                "Age",
                                _age,
                              ),
                            ),
                            Expanded(
                              child: _buildInfoRow(
                                Icons.person_outline,
                                "Gender",
                                _gender,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Divider(
                            color: AppColors.mist.withOpacity(0.8),
                            height: 1,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoRow(
                                Icons.height,
                                "Height",
                                "$_height cm",
                              ),
                            ),
                            Expanded(
                              child: _buildInfoRow(
                                Icons.monitor_weight_outlined,
                                "Weight",
                                "$_weight kg",
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Divider(
                            color: AppColors.mist.withOpacity(0.8),
                            height: 1,
                          ),
                        ),
                        _buildInfoRow(
                          Icons.warning_amber_rounded,
                          "Primary Allergy",
                          _allergies,
                          isAlert:
                              _allergies != 'None (No known allergies)' &&
                              _allergies != 'None',
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Divider(
                            color: AppColors.mist.withOpacity(0.8),
                            height: 1,
                          ),
                        ),
                        _buildInfoRow(
                          Icons.medication_outlined,
                          "Current Medications",
                          _medications,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// ACTIONS
                  const Text(
                    "Account",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildActionTile(
                    icon: Icons.manage_accounts_outlined,
                    title: "Edit Account Details",
                    onTap: _showEditBasicDialog,
                  ),
                  const SizedBox(height: 12),

                  // _buildActionTile(
                  //   icon: Icons.settings_outlined,
                  //   title: "App Settings",
                  //   onTap: () {}, // Route to SettingsPage
                  // ),
                  const SizedBox(height: 32),

                  /// LOGOUT BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.softRed,
                        foregroundColor: AppColors.alertRed,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        "Log Out",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  // Helper: Rows inside the Medical Card
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isAlert = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: isAlert ? AppColors.alertRed : AppColors.teal,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.slate,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isAlert ? AppColors.alertRed : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper: Action Tiles
  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      tileColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.mist, width: 1.5),
      ),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.mist,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.teal, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.ash,
      ),
    );
  }

  // Helper: Dialog Text Fields
  Widget _buildDialogTextField(
    TextEditingController controller,
    String label,
    IconData? icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: AppColors.ink),
      decoration: _dialogInputDecoration(label, icon: icon),
    );
  }

  // Helper: Common Dialog Input Decoration
  InputDecoration _dialogInputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.slate),
      prefixIcon: icon != null ? Icon(icon, color: AppColors.teal) : null,
      filled: true,
      fillColor: AppColors.mist,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.deepTeal, width: 2),
      ),
    );
  }
}
