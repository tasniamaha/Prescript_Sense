import 'dart:io';
import 'package:flutter/foundation.dart';

enum ImageOrigin {
  camera,
  gallery,
}

class PrescriptionImage {
  // For mobile/desktop (native platforms)
  final File? file;
  
  // For web platform
  final Uint8List? bytes;
  
  final String name;
  final String path;
  final ImageOrigin origin;
  final DateTime capturedAt;
  final String? id;

  PrescriptionImage({
    this.file,
    this.bytes,
    required this.name,
    required this.path,
    required this.origin,
    required this.capturedAt,
    this.id,
  }) : assert(file != null || bytes != null, 'Either file or bytes must be provided');

  // Check if running on web
  bool get isWeb => kIsWeb;

  // Get file size in megabytes
  double get fileSizeInMB {
    try {
      if (kIsWeb && bytes != null) {
        return bytes!.length / (1024 * 1024);
      } else if (file != null) {
        final fileBytes = file!.lengthSync();
        return fileBytes / (1024 * 1024);
      }
      return 0.0;
    } catch (e) {
      print('Error calculating file size: $e');
      return 0.0;
    }
  }

  // Get file size in bytes
  int get fileSizeInBytes {
    try {
      if (kIsWeb && bytes != null) {
        return bytes!.length;
      } else if (file != null) {
        return file!.lengthSync();
      }
      return 0;
    } catch (e) {
      print('Error getting file size in bytes: $e');
      return 0;
    }
  }

  // Get formatted file size string
  String get fileSizeFormatted {
    final sizeInBytes = fileSizeInBytes;
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  // Get file extension
  String get extension {
    return name.split('.').last.toLowerCase();
  }

  // Check if image is valid
  bool get isValid {
    return (file != null || bytes != null) && 
           name.isNotEmpty && 
           fileSizeInBytes > 0;
  }

  PrescriptionImage copyWith({
    File? file,
    Uint8List? bytes,
    String? name,
    String? path,
    ImageOrigin? origin,
    DateTime? capturedAt,
    String? id,
  }) {
    return PrescriptionImage(
      file: file ?? this.file,
      bytes: bytes ?? this.bytes,
      name: name ?? this.name,
      path: path ?? this.path,
      origin: origin ?? this.origin,
      capturedAt: capturedAt ?? this.capturedAt,
      id: id ?? this.id,
    );
  }

  // Convert to JSON (useful for storage/transmission)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'origin': origin.toString(),
      'capturedAt': capturedAt.toIso8601String(),
      'id': id,
      'sizeInBytes': fileSizeInBytes,
      'isWeb': isWeb,
    };
  }

  @override
  String toString() {
    return 'PrescriptionImage(name: $name, origin: $origin, size: $fileSizeFormatted, id: $id)';
  }
}
