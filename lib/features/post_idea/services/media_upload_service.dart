import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../utils/constants/api_config.dart';

/// Result of a pre-signed URL request
class PresignedUrlResult {
  final String uploadUrl;
  final String fileKey;
  final String publicUrl;
  final int expiresIn;

  PresignedUrlResult({
    required this.uploadUrl,
    required this.fileKey,
    required this.publicUrl,
    required this.expiresIn,
  });

  factory PresignedUrlResult.fromJson(Map<String, dynamic> json) {
    return PresignedUrlResult(
      uploadUrl: json['uploadUrl'] as String,
      fileKey: json['fileKey'] as String,
      publicUrl: json['publicUrl'] as String,
      expiresIn: json['expiresIn'] as int,
    );
  }
}

/// Represents a file to upload (works on both web and mobile)
class UploadFile {
  final String name;
  final Uint8List bytes;

  UploadFile({required this.name, required this.bytes});
}

/// Service for uploading media to DigitalOcean Spaces via secure pre-signed URLs
///
/// Flow:
/// 1. Request pre-signed URL from backend (backend has Spaces credentials)
/// 2. Upload file directly to Spaces using the pre-signed URL
/// 3. Return the public URL for storing in the database
///
/// This ensures Spaces credentials NEVER touch the mobile app
class MediaUploadService {
  static final MediaUploadService _instance = MediaUploadService._internal();
  factory MediaUploadService() => _instance;
  MediaUploadService._internal();

  /// Get the current user's Firebase ID token for authentication
  Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  /// Get authenticated headers for API requests
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getIdToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Request a pre-signed URL from the backend
  Future<PresignedUrlResult> _getPresignedUrl({
    required String fileType,
    required String mimeType,
  }) async {
    final headers = await _getAuthHeaders();

    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.presignedUrl}'),
          headers: headers,
          body: jsonEncode({'fileType': fileType, 'mimeType': mimeType}),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to get upload URL');
    }

    final data = jsonDecode(response.body);
    return PresignedUrlResult.fromJson(data['data']);
  }

  /// Request multiple pre-signed URLs at once
  Future<List<PresignedUrlResult>> _getBatchPresignedUrls(
    List<Map<String, String>> files,
  ) async {
    final headers = await _getAuthHeaders();

    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.batchPresignedUrls}'),
          headers: headers,
          body: jsonEncode({'files': files}),
        )
        .timeout(ApiConfig.timeout);

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to get upload URLs');
    }

    final data = jsonDecode(response.body);
    final results = data['data'] as List;

    return results
        .where((r) => r['success'] == true)
        .map((r) => PresignedUrlResult.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Upload bytes directly to Spaces using a pre-signed URL
  Future<void> _uploadToSpaces({
    required String uploadUrl,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final client = http.Client();

    try {
      final request = http.Request('PUT', Uri.parse(uploadUrl));
      request.headers['Content-Type'] = mimeType;
      request.headers['x-amz-acl'] = 'public-read';
      request.bodyBytes = bytes;

      final streamedResponse = await client
          .send(request)
          .timeout(ApiConfig.uploadTimeout);

      if (streamedResponse.statusCode != 200) {
        throw Exception(
          'Upload failed with status: ${streamedResponse.statusCode}',
        );
      }

      debugPrint('✅ File uploaded successfully');
    } finally {
      client.close();
    }
  }

  /// Upload a single image and return its public URL
  Future<UploadedMedia> uploadImage(UploadFile file) async {
    final mimeType = _getMimeType(file.name, 'image');

    debugPrint('📤 Requesting pre-signed URL for image...');
    final presigned = await _getPresignedUrl(
      fileType: 'image',
      mimeType: mimeType,
    );

    debugPrint('📤 Uploading image to Spaces...');
    await _uploadToSpaces(
      uploadUrl: presigned.uploadUrl,
      bytes: file.bytes,
      mimeType: mimeType,
    );

    return UploadedMedia(
      url: presigned.publicUrl,
      fileKey: presigned.fileKey,
      type: 'image',
      mimeType: mimeType,
    );
  }

  /// Upload a single video and return its public URL
  Future<UploadedMedia> uploadVideo(UploadFile file) async {
    final mimeType = _getMimeType(file.name, 'video');

    debugPrint('📤 Requesting pre-signed URL for video...');
    final presigned = await _getPresignedUrl(
      fileType: 'video',
      mimeType: mimeType,
    );

    debugPrint('📤 Uploading video to Spaces...');
    await _uploadToSpaces(
      uploadUrl: presigned.uploadUrl,
      bytes: file.bytes,
      mimeType: mimeType,
    );

    return UploadedMedia(
      url: presigned.publicUrl,
      fileKey: presigned.fileKey,
      type: 'video',
      mimeType: mimeType,
    );
  }

  /// Upload multiple images and return their public URLs
  Future<List<UploadedMedia>> uploadImages(List<UploadFile> files) async {
    if (files.isEmpty) return [];

    final fileInfos = files.map((f) {
      return <String, String>{
        'fileType': 'image',
        'mimeType': _getMimeType(f.name, 'image'),
      };
    }).toList();

    debugPrint('📤 Requesting ${files.length} pre-signed URLs...');
    final presignedUrls = await _getBatchPresignedUrls(fileInfos);

    if (presignedUrls.length != files.length) {
      debugPrint('⚠️ Some pre-signed URLs failed to generate');
    }

    final results = <UploadedMedia>[];

    await Future.wait(
      List.generate(presignedUrls.length, (i) async {
        try {
          final mimeType = _getMimeType(files[i].name, 'image');
          await _uploadToSpaces(
            uploadUrl: presignedUrls[i].uploadUrl,
            bytes: files[i].bytes,
            mimeType: mimeType,
          );
          results.add(
            UploadedMedia(
              url: presignedUrls[i].publicUrl,
              fileKey: presignedUrls[i].fileKey,
              type: 'image',
              mimeType: mimeType,
              order: i,
            ),
          );
        } catch (e) {
          debugPrint('❌ Failed to upload image $i: $e');
        }
      }),
    );

    return results;
  }

  /// Get MIME type from file name
  String _getMimeType(String fileName, String type) {
    final ext = fileName.split('.').last.toLowerCase();

    if (type == 'image') {
      switch (ext) {
        case 'jpg':
        case 'jpeg':
          return 'image/jpeg';
        case 'png':
          return 'image/png';
        case 'gif':
          return 'image/gif';
        case 'webp':
          return 'image/webp';
        default:
          return 'image/jpeg';
      }
    } else {
      switch (ext) {
        case 'mp4':
          return 'video/mp4';
        case 'mov':
          return 'video/quicktime';
        case 'avi':
          return 'video/avi';
        case 'webm':
          return 'video/webm';
        default:
          return 'video/mp4';
      }
    }
  }
}

/// Represents an uploaded media file
class UploadedMedia {
  final String url;
  final String fileKey;
  final String type; // 'image' or 'video'
  final String mimeType;
  final int order;

  UploadedMedia({
    required this.url,
    required this.fileKey,
    required this.type,
    required this.mimeType,
    this.order = 0,
  });

  Map<String, dynamic> toJson() => {
    'url': url,
    'fileKey': fileKey,
    'type': type,
    'mimeType': mimeType,
    'order': order,
  };
}
