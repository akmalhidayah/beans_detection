import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/app_language.dart';
import '../core/widgets/app_bottom_nav.dart';
import '../core/widgets/coffee_placeholder.dart';
import '../core/widgets/info_card.dart';
import '../core/widgets/primary_button.dart';
import '../core/widgets/secondary_button.dart';
import '../core/widgets/section_title.dart';
import '../models/detection_result.dart';
import '../services/local_auth_service.dart';
import '../services/prediction_api_service.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'result_screen.dart';

enum DetectionMode { camera, upload }

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({
    super.key,
    this.mode = DetectionMode.camera,
  });

  final DetectionMode mode;

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  final _authService = LocalAuthService();
  final ImagePicker _imagePicker = ImagePicker();
  final PredictionApiService _apiService = PredictionApiService();

  File? _selectedImage;
  bool _isLoading = false;
  String _language = AppLanguage.indonesia;

  bool get _isCameraMode => widget.mode == DetectionMode.camera;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isCameraMode ? 'Scan Kamera' : 'Upload Gambar';
    final placeholderTitle = _isCameraMode
        ? 'Preview kamera biji kopi'
        : 'Preview gambar dari galeri';
    final buttonLabel = _isCameraMode
        ? AppLanguage.text('open_camera', _language)
        : AppLanguage.text('choose_image', _language);
    final buttonIcon = _isCameraMode
        ? Icons.photo_camera_rounded
        : Icons.photo_library_rounded;

    return Scaffold(
      backgroundColor: AppColors.lightCream,
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(
                    title: _isCameraMode ? 'Scan Citra Kopi' : 'Upload Citra',
                    subtitle: _isCameraMode
                        ? 'Arahkan kamera ke biji kopi yang akan dianalisis'
                        : 'Pilih gambar biji kopi dari perangkat',
                  ),
                  const SizedBox(height: 14),
                  _ImagePreview(
                    imageFile: _selectedImage,
                    placeholderTitle: placeholderTitle,
                  ),
                  const SizedBox(height: 18),
                  SecondaryButton(
                    label: buttonLabel,
                    icon: buttonIcon,
                    onPressed: _isLoading ? null : _pickImage,
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: AppLanguage.text('analyze_now', _language),
                    icon: Icons.analytics_rounded,
                    onPressed: _isLoading ? null : _analyze,
                  ),
                  const SizedBox(height: 24),
                  const SectionTitle(title: 'Parameter Analisis'),
                  const SizedBox(height: 12),
                  const _AnalysisParameterPanel(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _isCameraMode ? 1 : 2,
        language: _language,
        onTap: (index) => _handleBottomNavigation(context, index),
      ),
    );
  }

  Future<void> _loadLanguage() async {
    final language = await _authService.getLanguage();
    if (!mounted) return;
    setState(() => _language = language);
  }

  Future<void> _pickImage() async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: _isCameraMode ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 92,
      );

      if (pickedImage == null) return;

      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    } catch (_) {
      _showMessage(
        'Gagal membuka ${_isCameraMode ? 'kamera' : 'galeri'}. Periksa izin aplikasi.',
      );
    }
  }

  Future<void> _analyze() async {
    final imageFile = _selectedImage;
    if (imageFile == null) {
      _showMessage('Pilih atau ambil gambar terlebih dahulu.');
      return;
    }

    setState(() => _isLoading = true);
    _showLoadingDialog();

    DetectionResult? result;

    try {
      final backendOnline = await _apiService.checkHealth();
      if (!backendOnline) {
        throw Exception('Backend offline. Pastikan server sedang berjalan.');
      }
      result = await _apiService.predictImage(imageFile);
    } catch (exception) {
      if (mounted) {
        _showMessage(_friendlyError(exception));
      }
    } finally {
      if (mounted) {
        Navigator.pop(context);
        setState(() => _isLoading = false);
      }
    }

    final prediction = result;
    if (!mounted || prediction == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(result: prediction)),
    );
  }

  String _friendlyError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _showLoadingDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _AnalysisLoadingDialog(),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleBottomNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case 1:
        if (widget.mode != DetectionMode.camera) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const DetectionScreen(mode: DetectionMode.camera),
            ),
          );
        }
        break;
      case 2:
        if (widget.mode != DetectionMode.upload) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const DetectionScreen(mode: DetectionMode.upload),
            ),
          );
        }
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HistoryScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.imageFile,
    required this.placeholderTitle,
  });

  final File? imageFile;
  final String placeholderTitle;

  @override
  Widget build(BuildContext context) {
    final image = imageFile;
    if (image == null) {
      return CoffeePlaceholder(
        height: 292,
        iconSize: 74,
        title: placeholderTitle,
        subtitle: 'Pastikan biji kopi terlihat jelas dan pencahayaan cukup.',
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: 1.42,
        child: Image.file(
          image,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }
}

class _AnalysisParameterPanel extends StatelessWidget {
  const _AnalysisParameterPanel();

  @override
  Widget build(BuildContext context) {
    return const InfoCard(
      child: Column(
        children: [
          _ParameterRow(label: 'Metode', value: 'YOLOv11'),
          _ParameterRow(label: 'Input', value: 'Citra Digital'),
          _ParameterRow(label: 'Objek', value: 'Biji Kopi'),
          _ParameterRow(label: 'Jenis Kopi', value: 'Arabika / Robusta'),
          _ParameterRow(
            label: 'Kelas Output',
            value: 'Grade A, Grade B, Grade C',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ParameterRow extends StatelessWidget {
  const _ParameterRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyText,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisLoadingDialog extends StatelessWidget {
  const _AnalysisLoadingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primaryBrown),
            SizedBox(height: 18),
            Text(
              'Menganalisis citra biji kopi menggunakan model YOLOv11...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.darkText,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
