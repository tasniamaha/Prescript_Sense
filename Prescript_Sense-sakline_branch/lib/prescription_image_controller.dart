import 'package:flutter/foundation.dart';
import 'image_input/image_source_service.dart';
import 'image_input/image_model.dart';
import 'image_input/image_validator.dart';

class PrescriptionImageController {
  final ImageSourceService _imageService = ImageSourceService();
  PrescriptionImage? _currentImage;

  // Getters
  PrescriptionImage? get currentImage => _currentImage;
  bool get hasImage => _currentImage != null;
  bool get isWeb => kIsWeb;
  String get platformName => _imageService.platformName;

  // Get available features on current platform
  Map<String, bool> get availableFeatures => _imageService.getAvailableFeatures();

  // Check if camera is supported
  bool get isCameraSupported => _imageService.isCameraSupported;

  // Check if gallery is supported
  bool get isGallerySupported => _imageService.isGallerySupported;

  // Get image from camera
  Future<PrescriptionImage?> getImageFromCamera() async {
    try {
      print('\n=== BackendController: Camera Request ===');
      
      if (!isCameraSupported) {
        throw Exception('Camera is not supported on this platform ($platformName)');
      }

      final image = await _imageService.pickFromCamera();
      
      if (image != null) {
        _currentImage = image;
        print('Image successfully stored in controller');
        print('Current image: ${_currentImage.toString()}');
        return image;
      }
      
      print('No image selected (user cancelled)');
      return null;
    } catch (e) {
      print('Backend controller camera error: $e');
      _currentImage = null;
      rethrow;
    }
  }

  // Get image from gallery
  Future<PrescriptionImage?> getImageFromGallery() async {
    try {
      print('\n=== BackendController: Gallery Request ===');
      
      final image = await _imageService.pickFromGallery();
      
      if (image != null) {
        _currentImage = image;
        print('Image successfully stored in controller');
        print('Current image: ${_currentImage.toString()}');
        return image;
      }
      
      print('No image selected (user cancelled)');
      return null;
    } catch (e) {
      print('Backend controller gallery error: $e');
      _currentImage = null;
      rethrow;
    }
  }

  // Clear current image
  void clearImage() {
    print('Clearing current image');
    _currentImage = null;
  }

  // Get detailed image information
  String getImageInfo() {
    if (_currentImage == null) {
      return 'No image selected';
    }

    final platform = kIsWeb ? 'Web' : 'Native';
    final storageType = kIsWeb ? 'Bytes' : 'File';

    return '''
Platform: $platform ($platformName)
Storage: $storageType
Image ID: ${_currentImage!.id}
Name: ${_currentImage!.name}
Source: ${_currentImage!.origin == ImageOrigin.camera ? 'Camera' : 'Gallery'}
Size: ${_currentImage!.fileSizeFormatted} (${_currentImage!.fileSizeInMB.toStringAsFixed(2)} MB)
Extension: ${_currentImage!.extension}
Captured: ${_currentImage!.capturedAt.toString()}
Path: ${_currentImage!.path}
Valid: ${_currentImage!.isValid}
    ''';
  }

  // Validate current image
  bool validateCurrentImage() {
    if (_currentImage == null) {
      print('Validation: No image to validate');
      return false;
    }
    
    print('Validating current image...');
    final isValid = ImageValidator.isValid(_currentImage!);
    print('Validation result: $isValid');
    return isValid;
  }

  // Get validation error message if any
  String? getValidationError() {
    if (_currentImage == null) return 'No image selected';
    
    final result = ImageValidator.validate(_currentImage!);
    return result.errorMessage;
  }

  // Get platform information
  String getPlatformInfo() {
    final features = availableFeatures;
    return '''
Platform: $platformName
Camera Support: ${features['camera'] == true ? 'Yes' : 'No'}
Gallery Support: ${features['gallery'] == true ? 'Yes' : 'No'}
Web Platform: ${features['isWeb'] == true ? 'Yes' : 'No'}
    ''';
  }

  // Reset controller
  void reset() {
    print('Resetting backend controller');
    _currentImage = null;
  }

  // Get quick status
  String getStatus() {
    if (_currentImage == null) {
      return 'No image selected';
    }
    return 'Image: ${_currentImage!.name} (${_currentImage!.fileSizeFormatted})';
  }
}