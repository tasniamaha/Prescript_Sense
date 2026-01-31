import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:prescript_sense/prescription_image_controller.dart';
// Update path if needed
import 'image_input/image_model.dart'; // For ImageOrigin enum

class AudioReaderPage extends StatelessWidget {
  AudioReaderPage({super.key});

  // Create a single instance of the controller for this page
  final PrescriptionImageController _imageController = PrescriptionImageController();

  Future<void> _pickImage(BuildContext context, ImageOrigin origin) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading image...'), duration: Duration(seconds: 2)),
      );

      final PrescriptionImage? image = origin == ImageOrigin.camera
          ? await _imageController.getImageFromCamera()
          : await _imageController.getImageFromGallery();

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected')),
        );
        return;
      }

      // Success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image uploaded: ${image.name} (${image.fileSizeFormatted})'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = _imageController.hasImage;

=======

class AudioReaderPage extends StatelessWidget {
  const AudioReaderPage({super.key});

  @override
  Widget build(BuildContext context) {
>>>>>>> sakline_branch
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Audio Reader'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Upload Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
<<<<<<< HEAD
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
=======
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withOpacity(0.6),
>>>>>>> sakline_branch
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.upload_file,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Upload Prescription',
<<<<<<< HEAD
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
=======
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
>>>>>>> sakline_branch
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Upload or select a prescription image to convert it into audio.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
<<<<<<< HEAD
                      onPressed: () => _pickImage(context, ImageOrigin.camera),
=======
                      onPressed: () {
                        // Camera upload placeholder
                      },
>>>>>>> sakline_branch
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
<<<<<<< HEAD
                      onPressed: () => _pickImage(context, ImageOrigin.gallery),
=======
                      onPressed: () {
                        // Gallery upload placeholder
                      },
>>>>>>> sakline_branch
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Choose from Gallery'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

<<<<<<< HEAD
=======
              // Audio Section
>>>>>>> sakline_branch
              Icon(
                Icons.volume_up,
                size: 120,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 24),

              const Text(
                'Listen to your prescription',
                textAlign: TextAlign.center,
<<<<<<< HEAD
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
=======
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
>>>>>>> sakline_branch
              ),

              const SizedBox(height: 16),

              const Text(
                'Convert your scanned prescription or extracted text into clear audio output using AI-powered text-to-speech.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
<<<<<<< HEAD
                onPressed: hasImage
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Playing audio... (TTS integration coming soon)'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                        // TODO: Integrate flutter_tts or backend TTS here
                        // You can access the image via _imageController.currentImage
                      }
                    : null, // Disabled if no image
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play Prescription Audio'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
=======
                onPressed: () {
                  // Play audio placeholder
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play Prescription Audio'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
>>>>>>> sakline_branch
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
<<<<<<< HEAD
                onPressed: hasImage
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Audio stopped')),
                        );
                        // TODO: Stop TTS playback
                      }
                    : null,
                icon: const Icon(Icons.stop),
                label: const Text('Stop Audio'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
=======
                onPressed: () {
                  // Stop audio placeholder
                },
                icon: const Icon(Icons.stop),
                label: const Text('Stop Audio'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
>>>>>>> sakline_branch
                  backgroundColor: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> sakline_branch
