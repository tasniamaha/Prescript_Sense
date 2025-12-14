import 'dart:io';
import 'package:flutter/foundation.dart';

class ImageValidator {
  static const int maxSizeMB = 10;
  static const int maxSizeBytes = maxSizeMB * 1024 * 1024;
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'heic'];

  // For mobile/desktop with File
  static bool isValidSizeFile(File file) {
    try {
      final int sizeInBytes = file.lengthSync();
      final double sizeInMB = sizeInBytes / (1024 * 1024);
      print('File size check: $sizeInBytes bytes = ${sizeInMB.toStringAsFixed(2)} MB (max: $maxSizeMB MB)');
      return sizeInBytes <= maxSizeBytes;
    } catch (e) {
      print('Error checking file size: $e');
      return false;
    }
  }

  // For web with bytes
  static bool isValidSizeBytes(Uint8List bytes) {
    final double sizeInMB = bytes.length / (1024 * 1024);
    print('Bytes size check: ${bytes.length} bytes = ${sizeInMB.toStringAsFixed(2)} MB (max: $maxSizeMB MB)');
    return bytes.length <= maxSizeBytes;
  }

  // Check file extension
  static bool isValidExtension(String path) {
    final String extension = path.split('.').last.toLowerCase();
    print('Extension check: "$extension" in ${allowedExtensions.toString()}');
    final isValid = allowedExtensions.contains(extension);
    if (!isValid) {
      print('Invalid extension. Allowed: ${allowedExtensions.join(", ")}');
    }
    return isValid;
  }

  // Check if file exists (native only)
  static bool fileExists(File file) {
    try {
      return file.existsSync();
    } catch (e) {
      print('Error checking file existence: $e');
      return false;
    }
  }

  // Universal validation for File (mobile/desktop)
  static ValidationResult validateFile(File file, String path) {
    print('=== Starting File Validation ===');
    print('Path: $path');
    
    if (!fileExists(file)) {
      print('Validation failed: File does not exist');
      return ValidationResult(
        isValid: false,
        errorMessage: 'File does not exist',
      );
    }
    print('✓ File exists');

    if (!isValidExtension(path)) {
      print('Validation failed: Invalid extension');
      return ValidationResult(
        isValid: false,
        errorMessage: 'Invalid file format. Allowed formats: ${allowedExtensions.join(", ")}',
      );
    }
    print('✓ Extension valid');

    if (!isValidSizeFile(file)) {
      print('Validation failed: File too large');
      return ValidationResult(
        isValid: false,
        errorMessage: 'Image size exceeds ${maxSizeMB}MB limit',
      );
    }
    print('✓ Size valid');

    print('=== Validation PASSED ===');
    return ValidationResult(isValid: true);
  }

  // Universal validation for bytes (web)
  static ValidationResult validateBytes(Uint8List bytes, String name) {
    print('=== Starting Bytes Validation ===');
    print('Name: $name');

    if (bytes.isEmpty) {
      print('Validation failed: Empty bytes');
      return ValidationResult(
        isValid: false,
        errorMessage: 'Image data is empty',
      );
    }
    print('✓ Bytes not empty (${bytes.length} bytes)');

    if (!isValidExtension(name)) {
      print('Validation failed: Invalid extension');
      return ValidationResult(
        isValid: false,
        errorMessage: 'Invalid file format. Allowed formats: ${allowedExtensions.join(", ")}',
      );
    }
    print('✓ Extension valid');

    if (!isValidSizeBytes(bytes)) {
      print('Validation failed: File too large');
      return ValidationResult(
        isValid: false,
        errorMessage: 'Image size exceeds ${maxSizeMB}MB limit',
      );
    }
    print('✓ Size valid');

    print('=== Validation PASSED ===');
    return ValidationResult(isValid: true);
  }

  // Main validation method - auto-detects platform from PrescriptionImage
  static ValidationResult validate(dynamic image) {
    if (image is File) {
      // Direct File validation (legacy support)
      return validateFile(image, image.path);
    }
    
    // Assume it's PrescriptionImage (from image_model.dart)
    if (kIsWeb) {
      if (image.bytes != null) {
        return validateBytes(image.bytes, image.name);
      } else {
        return ValidationResult(
          isValid: false,
          errorMessage: 'No image data available for web',
        );
      }
    } else {
      if (image.file != null) {
        return validateFile(image.file, image.path);
      } else {
        return ValidationResult(
          isValid: false,
          errorMessage: 'No image file available',
        );
      }
    }
  }

  // Simple boolean check
  static bool isValid(dynamic image) {
    return validate(image).isValid;
  }

  // Get human-readable error message
  static String getErrorMessage(dynamic image) {
    final result = validate(image);
    return result.errorMessage ?? 'Unknown validation error';
  }
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid${errorMessage != null ? ', error: $errorMessage' : ''})';
  }
}