import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class LeaveFormController {
  // Allowed Emirates IDs
  final List<String> allowedIds = [
    '784-1986-5206474-0',
  ];

  Future<bool> isInOffice() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }

  Future<Map<String, String>?> extractEmiratesIdFromImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      final text = recognizedText.text;
      final idRegExp = RegExp(r'784-\d{4}-\d{7}-\d');
      final idMatch = idRegExp.firstMatch(text);
      if (idMatch != null) {
        String name = '';
        List<String> lines = text.split('\n');
        for (final line in lines) {
          if (line.trim().toLowerCase().startsWith('name:')) {
            name = line.split(':').skip(1).join(':').trim();
            break;
          }
        }
        if (name.isEmpty) {
          int idLineIndex = lines.indexWhere((line) => idRegExp.hasMatch(line));
          if (idLineIndex > 0) {
            String candidate = lines[idLineIndex - 1].trim();
            if (candidate.isNotEmpty && !idRegExp.hasMatch(candidate)) {
              name = candidate;
            }
          }
        }
        if (name.isEmpty) {
          for (final line in lines) {
            String trimmed = line.trim();
            if (trimmed.isNotEmpty &&
                !idRegExp.hasMatch(trimmed) &&
                RegExp(r'^[A-Z ]+').hasMatch(trimmed) &&
                !RegExp(r'^[0-9\- ]+').hasMatch(trimmed)) {
              name = trimmed;
              break;
            }
          }
        }
        if (name.isEmpty) {
          for (final line in lines) {
            String trimmed = line.trim();
            if (trimmed.isNotEmpty &&
                !idRegExp.hasMatch(trimmed) &&
                !RegExp(r'^[0-9\- ]+').hasMatch(trimmed)) {
              name = trimmed;
              break;
            }
          }
        }
        return {
          'id': idMatch.group(0)!,
          'name': name.isNotEmpty ? name : 'Unknown'
        };
      }
      return null;
    } catch (e) {
      return null;
    } finally {
      textRecognizer.close();
    }
  }
}
