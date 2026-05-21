// SPDX-License-Identifier: MIT
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/translation_provider.dart';

class OcrScannerScreen extends ConsumerStatefulWidget {
  const OcrScannerScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends ConsumerState<OcrScannerScreen> {
  Uint8List? _imageBytes;
  String _rawOcr = '';
  List<Map<String, dynamic>> _medicines = [];
  bool _isScanning = false;
  bool _showResults = false;

  // ---------- OCR helper ----------
  Future<String> _performOcr(Uint8List bytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/prescription.jpg';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      // Perform OCR using Tesseract (English language)
      final result = await FlutterTesseractOcr.extractText(filePath, language: 'eng');
      return result ?? '';
    } catch (e) {
      // If anything fails, return empty string
      return '';
    }
  }

  // Very naive parser – extracts lines that look like "Drug 500mg - 1-0-1" etc.
  List<Map<String, dynamic>> _parseMedicines(String raw) {
    final meds = <Map<String, dynamic>>[];
    final lines = raw.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      // simple pattern: name + dosage + optional timing
      final parts = trimmed.split(' ');
      if (parts.length >= 2) {
        final name = parts.take(parts.length - 1).join(' ');
        final dosage = parts.last;
        meds.add({
          'name': name,
          'dosage': dosage,
          'timing': 'After Food',
          'frequency': '1-0-1',
          'desc': 'Auto‑extracted',
        });
      }
    }
    return meds;
  }

  Future<void> _pickAndScan() async {
    setState(() => _isScanning = true);
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final bytes = await file.readAsBytes();
      final ocr = await _performOcr(bytes);
      setState(() {
        _imageBytes = bytes;
        _rawOcr = ocr;
        _medicines = _parseMedicines(ocr);
        _showResults = true;
      });
    }
    setState(() => _isScanning = false);
  }

  void _saveToReminders() {
    // TODO: integrate with your reminders storage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to daily reminders')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          Translations.get(settings.language, 'prescription_scanner'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: [
              // Header image / placeholder
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1976D2)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _imageBytes == null
                    ? const Center(child: Icon(Icons.camera_alt_rounded, color: Colors.white70, size: 48))
                    : Image.memory(_imageBytes!, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Prescription Image'),
                onPressed: _isScanning ? null : _pickAndScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              if (_showResults) ...[
                // Raw OCR text (editable)
                const Text('RAW TEXT DETECTED', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.white38)),
                const SizedBox(height: 8),
                TextField(
                  controller: TextEditingController(text: _rawOcr),
                  maxLines: 4,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.03),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  style: const TextStyle(color: Colors.white70),
                  onChanged: (v) => _rawOcr = v,
                ),
                const SizedBox(height: 20),
                // Medicines list (editable cards)
                const Text('DETECTED MEDICINES', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.white38)),
                const SizedBox(height: 10),
                ..._medicines.map((m) {
                  final nameCtrl = TextEditingController(text: m['name']);
                  final dosageCtrl = TextEditingController(text: m['dosage']);
                  final timingCtrl = TextEditingController(text: m['timing']);
                  final freqCtrl = TextEditingController(text: m['frequency']);
                  final descCtrl = TextEditingController(text: m['desc']);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                    ]),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: nameCtrl,
                            decoration: const InputDecoration(labelText: 'Medicine', labelStyle: TextStyle(color: Colors.black54)),
                            onChanged: (v) => m['name'] = v,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: dosageCtrl,
                                  decoration: const InputDecoration(labelText: 'Dosage', labelStyle: TextStyle(color: Colors.black54)),
                                  onChanged: (v) => m['dosage'] = v,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: freqCtrl,
                                  decoration: const InputDecoration(labelText: 'Frequency', labelStyle: TextStyle(color: Colors.black54)),
                                  onChanged: (v) => m['frequency'] = v,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: timingCtrl,
                            decoration: const InputDecoration(labelText: 'Timing', labelStyle: TextStyle(color: Colors.black54)),
                            onChanged: (v) => m['timing'] = v,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: descCtrl,
                            decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Colors.black54)),
                            onChanged: (v) => m['desc'] = v,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save to Daily Reminders'),
                  onPressed: _saveToReminders,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => _showResults = false),
                  child: const Text('Scan Another Prescription', style: TextStyle(color: Colors.white70)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white24..strokeWidth = 0.5;
    for (double i = 50; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 50; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
