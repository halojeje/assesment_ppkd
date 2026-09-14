import 'dart:io';
import 'package:flutter/material.dart';

class ImageHelper {
  /// Mengembalikan ImageProvider<Object> yang mendukung:
  /// - File lokal dari Galeri HP / Device (`FileImage`)
  /// - URL HTTP / HTTPS (`NetworkImage`)
  /// - Path Asset (`AssetImage`)
  /// - Preset Short Name (`dummy1.png`, `dummy2.png`, dll)
  static ImageProvider<Object> getImageProvider(
    String? photoUrl, {
    String defaultAsset = 'assets/images/avatar.png',
  }) {
    if (photoUrl == null || photoUrl.trim().isEmpty) {
      return AssetImage(defaultAsset);
    }
    final cleanUrl = photoUrl.trim();
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return NetworkImage(cleanUrl);
    }
    if (cleanUrl.startsWith('assets/')) {
      return AssetImage(cleanUrl);
    }
    // Cek jika merupakan path file lokal dari galeri device (misal: /storage/..., /data/..., file://..., C:\...)
    if (cleanUrl.startsWith('file://')) {
      return FileImage(File(cleanUrl.replaceFirst('file://', '')));
    }
    if (cleanUrl.startsWith('/') ||
        cleanUrl.contains('\\') ||
        cleanUrl.contains('/storage/') ||
        cleanUrl.contains('/data/') ||
        cleanUrl.contains('Cache/') ||
        cleanUrl.contains('Documents/')) {
      return FileImage(File(cleanUrl));
    }
    if (cleanUrl.endsWith('.png') ||
        cleanUrl.endsWith('.jpg') ||
        cleanUrl.endsWith('.jpeg')) {
      return AssetImage('assets/images/$cleanUrl');
    }
    return AssetImage('assets/images/$cleanUrl.png');
  }

  /// Helper khusus untuk Avatar Profil
  static ImageProvider<Object> getAvatarImage(String? photoUrl) {
    return getImageProvider(photoUrl, defaultAsset: 'assets/images/avatar.png');
  }

  /// Helper khusus untuk Pet Photo / Catatan Hewan
  static ImageProvider<Object> getPetImage(String? photoUrl) {
    return getImageProvider(photoUrl, defaultAsset: 'assets/images/dummy1.png');
  }

  /// Helper Widget untuk Merender Image secara konsisten (Mendukung File Gallery, Asset, Network)
  static Widget buildImage(
    String? photoUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
    String defaultAsset = 'assets/images/dummy1.png',
  }) {
    final imageProvider =
        getImageProvider(photoUrl, defaultAsset: defaultAsset);

    return Image(
      image: imageProvider,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        if (errorWidget != null) return errorWidget;
        return Container(
          width: width,
          height: height,
          color: const Color(0xFFEFF6FF),
          child: const Icon(Icons.pets, color: Color(0xFF5080E8)),
        );
      },
    );
  }
}

/// Helper Top-Level
ImageProvider<Object> getAvatarImage(String? photoUrl) =>
    ImageHelper.getAvatarImage(photoUrl);
ImageProvider<Object> getPetImage(String? photoUrl) =>
    ImageHelper.getPetImage(photoUrl);

