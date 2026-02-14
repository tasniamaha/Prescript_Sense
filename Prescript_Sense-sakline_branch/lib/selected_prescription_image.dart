import 'image_input/image_model.dart'; // Update with your actual path

class SelectedPrescriptionImage {
  static PrescriptionImage? image;

  static void clear() {
    image = null;
  }
}