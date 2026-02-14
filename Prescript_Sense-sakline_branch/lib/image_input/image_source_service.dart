import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'image_model.dart';
import 'image_validator.dart';

class ImageSourceService {
  final ImagePicker _picker = ImagePicker();

  // Check platform capabilities
  bool get isCameraSupported {
    if (kIsWeb) {
      return true; // Web has limited camera support
    }
    return Platform.isAndroid || Platform.isIOS;
  }

  bool get isGallerySupported {
    return true; // All platforms support gallery
  }

  String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  Future<PrescriptionImage?> pickFromCamera() async {
    try {
      print('=== Camera Picker ===');
      print('Platform: $platformName');
      
      // Check if camera is supported
      if (!kIsWeb && !isCameraSupported) {
        throw ImagePickerException(
          'Camera is not supported on $platformName. Please use gallery instead.'
        );
      }

      final XFile? xFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (xFile == null) {
        print('User cancelled camera picker');
        return null;
      }

      return await _processPickedImage(xFile, ImageOrigin.camera);
    } catch (e) {
      print('Camera error: $e');
      if (e is ImageValidationException || e is ImagePickerException) {
        rethrow;
      }
      throw ImagePickerException('Failed to capture image: ${e.toString()}');
    }
  }

  Future<PrescriptionImage?> pickFromGallery() async {
    try {
      print('=== Gallery Picker ===');
      print('Platform: $platformName');
      
      final XFile? xFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (xFile == null) {
        print('User cancelled gallery picker');
        return null;
      }

      return await _processPickedImage(xFile, ImageOrigin.gallery);
    } catch (e) {
      print('Gallery error: $e');
      if (e is ImageValidationException || e is ImagePickerException) {
        rethrow;
      }
      throw ImagePickerException('Failed to select image: ${e.toString()}');
    }
  }

  Future<PrescriptionImage> _processPickedImage(XFile xFile, ImageOrigin origin) async {
    final String imagePath = xFile.path;
    final String imageName = xFile.name;
    
    print('Processing image: $imageName');
    print('Path: $imagePath');

    PrescriptionImage image;

    if (kIsWeb) {
      // For web: use bytes
      print('Using bytes for web platform');
      final bytes = await xFile.readAsBytes();
      
      if (bytes.isEmpty) {
        throw ImagePickerException('Failed to read image data');
      }
      
      print('Read ${bytes.length} bytes');
      
      image = PrescriptionImage(
        bytes: bytes,
        file: null,
        name: imageName,
        path: imagePath,
        origin: origin,
        capturedAt: DateTime.now(),
        id: _generateImageId(),
      );
    } else {
      // For mobile/desktop: use File
      print('Using File for native platform');
      final File file = File(imagePath);
      
      if (!file.existsSync()) {
        throw ImagePickerException('Selected file does not exist at path: $imagePath');
      }
      
      final fileSize = file.lengthSync();
      print('File exists, size: $fileSize bytes');
      
      image = PrescriptionImage(
        file: file,
        bytes: null,
        name: imageName,
        path: imagePath,
        origin: origin,
        capturedAt: DateTime.now(),
        id: _generateImageId(),
      );
    }

    // Validate the image
    print('Validating image...');
    final validationResult = ImageValidator.validate(image);
    
    if (!validationResult.isValid) {
      throw ImageValidationException(
        validationResult.errorMessage ?? 'Invalid image',
      );
    }

    print('Image processed and validated successfully');
    print('Image details: $image');
    return image;
  }

  String _generateImageId() {
    return 'IMG_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Helper method to check available features
  Map<String, bool> getAvailableFeatures() {
    return {
      'camera': isCameraSupported,
      'gallery': isGallerySupported,
      'isWeb': kIsWeb,
    };
  }
}

class ImageValidationException implements Exception {
  final String message;
  ImageValidationException(this.message);

  @override
  String toString() => message;
}

class ImagePickerException implements Exception {
  final String message;
  ImagePickerException(this.message);

  @override
  String toString() => message;
}
