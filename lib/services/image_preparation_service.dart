import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PreparedImage {
  const PreparedImage({required this.file, required this.mimeType, this.bytes});
  final XFile file;
  final String mimeType;
  final Uint8List? bytes;
}

class ImagePreparationService {
  static const maxBytes = 5 * 1024 * 1024;

  Future<PreparedImage> prepare(XFile source) async {
    if (kIsWeb) {
      final extension = p.extension(source.name).toLowerCase();
      if (!const ['.jpg', '.jpeg', '.png'].contains(extension)) {
        throw const FormatException('Format gambar harus JPG, JPEG, atau PNG.');
      }
      final bytes = await source.readAsBytes();
      _validateSize(bytes.length);
      return PreparedImage(
        file: source,
        bytes: bytes,
        mimeType: extension == '.png' ? 'image/png' : 'image/jpeg',
      );
    }

    final input = File(source.path);
    if (!await input.exists()) {
      throw const FormatException('File gambar tidak ditemukan.');
    }
    final temporary = await getTemporaryDirectory();
    final base = 'coffee_${DateTime.now().microsecondsSinceEpoch}';
    XFile? output;
    for (final quality in const [82, 72, 62]) {
      final target = p.join(temporary.path, '${base}_q$quality.jpg');
      output = await FlutterImageCompress.compressAndGetFile(
        input.path,
        target,
        format: CompressFormat.jpeg,
        quality: quality,
        minWidth: 1600,
        minHeight: 1600,
        keepExif: false,
      );
      if (output != null && await File(output.path).length() <= maxBytes) break;
    }
    if (output == null) {
      throw const FormatException('Gambar tidak dapat diproses.');
    }
    _validateSize(await File(output.path).length());
    return PreparedImage(file: output, mimeType: 'image/jpeg');
  }

  void _validateSize(int size) {
    if (size <= 0) throw const FormatException('File gambar kosong.');
    if (size > maxBytes) {
      throw const FormatException(
          'Ukuran gambar terlalu besar. Maksimal 5 MB.');
    }
  }
}
