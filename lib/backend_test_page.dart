import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'backend/backend_controller.dart';
import 'backend/image_input/image_model.dart';

class BackendTestPage extends StatefulWidget {
  const BackendTestPage({super.key});

  @override
  State<BackendTestPage> createState() => _BackendTestPageState();
}

class _BackendTestPageState extends State<BackendTestPage> {
  final BackendController _controller = BackendController();
  String _statusMessage = 'Ready to test';
  PrescriptionImage? _testImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateStatus('Ready to test\n${_controller.getPlatformInfo()}');
  }

  void _updateStatus(String message) {
    setState(() {
      _statusMessage = message;
    });
    print('Status: $message');
  }

  Future<void> _testCamera() async {
    _updateStatus('Testing camera...');
    setState(() => _isLoading = true);

    try {
      final image = await _controller.getImageFromCamera();
      
      if (image != null) {
        setState(() => _testImage = image);
        _updateStatus('✓ Camera test passed!\n${_controller.getImageInfo()}');
      } else {
        _updateStatus('✗ Camera test: User cancelled');
      }
    } catch (e) {
      _updateStatus('✗ Camera test failed: $e');
      print('Full camera error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testGallery() async {
    _updateStatus('Testing gallery...');
    setState(() => _isLoading = true);

    try {
      print('Opening gallery picker...');
      final image = await _controller.getImageFromGallery();
      
      if (image != null) {
        print('Image selected successfully');
        setState(() => _testImage = image);
        _updateStatus('✓ Gallery test passed!\n${_controller.getImageInfo()}');
      } else {
        print('User cancelled selection');
        _updateStatus('✗ Gallery test: User cancelled');
      }
    } catch (e) {
      _updateStatus('✗ Gallery test failed: $e');
      print('Full gallery error: $e');
      print('Error type: ${e.runtimeType}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _testValidation() {
    if (_testImage == null) {
      _updateStatus('✗ No image to validate. Pick an image first.');
      return;
    }

    print('=== Manual Validation Test ===');
    print('Testing image: ${_testImage!.name}');
    
    final isValid = _controller.validateCurrentImage();
    print('Validation result: $isValid');
    
    if (isValid) {
      _updateStatus('✓ Validation test passed!\nImage is valid.');
    } else {
      _updateStatus('✗ Validation test failed!\nImage is invalid.');
    }
  }

  void _clearTest() {
    _controller.clearImage();
    setState(() {
      _testImage = null;
      _statusMessage = 'Cleared. Ready for new test.\n${_controller.getPlatformInfo()}';
    });
  }

  void _checkState() {
    final hasImage = _controller.hasImage;
    final info = _controller.getImageInfo();
    _updateStatus('Has Image: $hasImage\n\n$info');
  }

  Widget _buildImagePreview() {
    if (_testImage == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Image Preview:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: kIsWeb && _testImage!.bytes != null
                ? Image.memory(
                    _testImage!.bytes!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildErrorWidget(error);
                    },
                  )
                : _testImage!.file != null
                    ? Image.file(
                        _testImage!.file!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildErrorWidget(error);
                        },
                      )
                    : _buildErrorWidget('No image data'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Platform: ${kIsWeb ? "Web" : "Native"}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          'Origin: ${_testImage!.origin == ImageOrigin.camera ? "Camera" : "Gallery"}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          'Size: ${_testImage!.fileSizeInMB.toStringAsFixed(2)} MB',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          'Name: ${_testImage!.name}',
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(
            'Error loading image:\n$error',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Test Suite'),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Platform Info Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: kIsWeb ? Colors.blue[100] : Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    kIsWeb ? Icons.language : Icons.phone_android,
                    size: 16,
                    color: kIsWeb ? Colors.blue[900] : Colors.green[900],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    kIsWeb ? 'Web Platform' : 'Native Platform',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kIsWeb ? Colors.blue[900] : Colors.green[900],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // Status Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Status:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusMessage,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Image Preview
            _buildImagePreview(),

            // Loading Indicator
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),

            // Test Buttons
            if (!_isLoading) ...[
              const Text(
                'Image Source Tests:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: Text(kIsWeb 
                  ? 'Test Camera (Limited on Web)' 
                  : 'Test Camera (Desktop Not Supported)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: _testCamera,
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Test Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: _testGallery,
              ),

              const SizedBox(height: 24),

              const Text(
                'Validation & State Tests:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text('Test Validation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: _testValidation,
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                icon: const Icon(Icons.info),
                label: const Text('Check State'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: _checkState,
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                icon: const Icon(Icons.clear),
                label: const Text('Clear Test'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: _clearTest,
              ),
            ],

            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF4A90E2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Platform Support:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kIsWeb
                        ? '✓ Gallery: Full support\n'
                          '⚠ Camera: Limited browser support'
                        : '✓ Gallery: Full support\n'
                          '⚠ Camera: Android/iOS only (not desktop)',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}