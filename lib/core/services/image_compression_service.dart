import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service de compression d'images avant upload
/// Réduit la taille des fichiers pour optimiser la bande passante
class ImageCompressionService {
  // Configuration par défaut
  static const int defaultQuality = 80;
  static const int defaultMinWidth = 1024;
  static const int defaultMinHeight = 1024;
  static const int maxFileSizeKB = 500; // 500 KB max

  /// Compresse une image depuis un chemin de fichier
  /// Retourne le chemin du fichier compressé
  Future<String?> compressImageFile(
    String filePath, {
    int quality = defaultQuality,
    int minWidth = defaultMinWidth,
    int minHeight = defaultMinHeight,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('❌ ImageCompression: Fichier non trouvé: $filePath');
        return null;
      }

      // Vérifier la taille originale
      final originalSize = await file.length();
      final originalSizeKB = originalSize / 1024;
      debugPrint('📸 Taille originale: ${originalSizeKB.toStringAsFixed(2)} KB');

      // Si déjà assez petit, retourner l'original
      if (originalSizeKB <= maxFileSizeKB) {
        debugPrint('✅ Image déjà optimisée, pas de compression nécessaire');
        return filePath;
      }

      // Générer le chemin de sortie
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basenameWithoutExtension(filePath);
      final outputPath = '${tempDir.path}/compressed_${fileName}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Compresser
      final result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outputPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
        format: CompressFormat.jpeg,
      );

      if (result == null) {
        debugPrint('❌ ImageCompression: Échec de compression');
        return filePath; // Retourner l'original en cas d'échec
      }

      final compressedSize = await result.length();
      final compressedSizeKB = compressedSize / 1024;
      final reduction = ((originalSize - compressedSize) / originalSize * 100);

      debugPrint('✅ Compression réussie:');
      debugPrint('   - Avant: ${originalSizeKB.toStringAsFixed(2)} KB');
      debugPrint('   - Après: ${compressedSizeKB.toStringAsFixed(2)} KB');
      debugPrint('   - Réduction: ${reduction.toStringAsFixed(1)}%');

      return result.path;
    } catch (e) {
      debugPrint('❌ ImageCompression: Erreur: $e');
      return filePath; // Retourner l'original en cas d'erreur
    }
  }

  /// Compresse une image depuis des bytes
  /// Retourne les bytes compressés
  Future<Uint8List?> compressImageBytes(
    Uint8List bytes, {
    int quality = defaultQuality,
    int minWidth = defaultMinWidth,
    int minHeight = defaultMinHeight,
  }) async {
    try {
      final originalSizeKB = bytes.length / 1024;
      debugPrint('📸 Taille originale: ${originalSizeKB.toStringAsFixed(2)} KB');

      // Si déjà assez petit, retourner l'original
      if (originalSizeKB <= maxFileSizeKB) {
        debugPrint('✅ Image déjà optimisée');
        return bytes;
      }

      final result = await FlutterImageCompress.compressWithList(
        bytes,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
        format: CompressFormat.jpeg,
      );

      final compressedSizeKB = result.length / 1024;
      final reduction = ((bytes.length - result.length) / bytes.length * 100);

      debugPrint('✅ Compression réussie: ${reduction.toStringAsFixed(1)}% de réduction');
      debugPrint('   - Après: ${compressedSizeKB.toStringAsFixed(2)} KB');

      return result;
    } catch (e) {
      debugPrint('❌ ImageCompression: Erreur: $e');
      return bytes;
    }
  }

  /// Compresse plusieurs images en parallèle
  Future<List<String>> compressMultipleImages(
    List<String> filePaths, {
    int quality = defaultQuality,
  }) async {
    final futures = filePaths.map(
      (path) => compressImageFile(path, quality: quality),
    );

    final results = await Future.wait(futures);
    return results.whereType<String>().toList();
  }

  /// Génère une miniature (thumbnail)
  Future<String?> generateThumbnail(
    String filePath, {
    int size = 200,
    int quality = 70,
  }) async {
    return compressImageFile(
      filePath,
      quality: quality,
      minWidth: size,
      minHeight: size,
    );
  }

  /// Nettoie les fichiers compressés temporaires
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      
      int deletedCount = 0;
      for (final file in files) {
        if (file is File && file.path.contains('compressed_')) {
          await file.delete();
          deletedCount++;
        }
      }
      
      debugPrint('🧹 Nettoyage: $deletedCount fichiers temporaires supprimés');
    } catch (e) {
      debugPrint('❌ Cleanup error: $e');
    }
  }
}
