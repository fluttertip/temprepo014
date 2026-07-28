import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../config/app_config.dart';

/// Uploads images to Cloudinary via an unsigned upload preset.
///
/// Improvements over v1:
/// - No hardcoded credentials — reads from [AppConfig] (--dart-define).
/// - Progress callback for real upload UI.
/// - Optional folder + tags so assets are organized per environment.
/// - Typed [CloudinaryException] instead of raw `Exception`.
/// - Configurable client injection for testing.
class CloudinaryException implements Exception {
  const CloudinaryException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => 'CloudinaryException($statusCode): $message';
}

class CloudinaryService {
  CloudinaryService({
    String? cloudName,
    String? uploadPreset,
    http.Client? client,
  })  : cloudName = cloudName ?? AppConfig.cloudinaryCloudName,
        uploadPreset = uploadPreset ?? AppConfig.cloudinaryUploadPreset,
        _client = client ?? http.Client();

  final String cloudName;
  final String uploadPreset;
  final http.Client _client;

  Uri get _uploadUri =>
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  /// Uploads a single image and returns its secure URL.
  Future<String> uploadImage(
    File imageFile, {
    String folder = 'rooms',
    List<String> tags = const [],
  }) async {
    final request = http.MultipartRequest('POST', _uploadUri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folder
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: p.basename(imageFile.path),
      ));
    if (tags.isNotEmpty) request.fields['tags'] = tags.join(',');

    final streamed = await _client.send(request);
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200 && streamed.statusCode != 201) {
      throw CloudinaryException(body, statusCode: streamed.statusCode);
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    final secureUrl = json['secure_url'] as String?;
    if (secureUrl == null || secureUrl.isEmpty) {
      throw const CloudinaryException('Response missing secure_url');
    }
    return secureUrl;
  }

  /// Uploads multiple images sequentially, reporting progress 0..1.
  /// v2 rooms support a gallery, not a single image.
  Future<List<String>> uploadImages(
    List<File> files, {
    String folder = 'rooms',
    void Function(double progress)? onProgress,
  }) async {
    final urls = <String>[];
    for (var i = 0; i < files.length; i++) {
      urls.add(await uploadImage(files[i], folder: folder));
      onProgress?.call((i + 1) / files.length);
    }
    return urls;
  }

  /// Cloudinary can transform on-the-fly via URL. Request an appropriately
  /// sized, auto-format, auto-quality variant to cut bandwidth dramatically.
  static String optimized(
    String url, {
    int width = 800,
    int? height,
  }) {
    const marker = '/upload/';
    final idx = url.indexOf(marker);
    if (idx == -1) return url;
    final t = StringBuffer('c_fill,f_auto,q_auto,w_$width');
    if (height != null) t.write(',h_$height');
    return url.replaceFirst(marker, '$marker$t/');
  }

  void dispose() => _client.close();
}
