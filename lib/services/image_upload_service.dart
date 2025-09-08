import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart';
import '../models/image_upload_response.dart';

class ImageUploadService {
  static const String baseUrl = 'http://164.92.175.72:3001';
  static const String deleteEndpoint = '/api/images/delete';
  static const String uploadEndpoint = '/api/images/upload';
  static const Duration timeoutDuration = Duration(seconds: 30);

  Future<ImageUploadResponse> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse('$baseUrl$uploadEndpoint');

      // Create multipart request
      final request = http.MultipartRequest('POST', uri);

      // Add the image file to the request
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();

      final multipartFile = http.MultipartFile(
        'image', // parameter name for the image
        fileStream,
        fileLength,
        filename: basename(imageFile.path),
      );

      request.files.add(multipartFile);

      // Send the request with timeout
      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      // Accept both 200 and 201 status codes as success
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return ImageUploadResponse.fromJson(jsonResponse);
      } else {
        throw HttpException(
          'Failed to upload image: ${response.statusCode}',
          uri: uri,
        );
      }
    } on SocketException catch (e) {
      print('Network error uploading image: $e');
      throw NetworkException('No internet connection or server is down');
    } on TimeoutException catch (e) {
      print('Timeout uploading image: $e');
      throw NetworkException('Request timed out. Please try again.');
    } on http.ClientException catch (e) {
      print('HTTP client error uploading image: $e');
      throw NetworkException(
          'Network error occurred. Please check your connection.');
    } on FormatException catch (e) {
      print('Invalid response format: $e');
      throw AppException('Invalid server response. Please try again.');
    } on HttpException catch (e) {
      print('HTTP error: $e');
      throw AppException('Server error: ${e.message}');
    } catch (e) {
      print('Unexpected error uploading image: $e');
      throw AppException('Failed to upload image. Please try again.');
    }
  }

  /// Upload a file (PDF, documents, etc.) with file prefix instead of image prefix
  Future<ImageUploadResponse> uploadFile(File file) async {
    try {
      final uri = Uri.parse('$baseUrl$uploadEndpoint');

      // Create multipart request
      final request = http.MultipartRequest('POST', uri);

      // Add a parameter to indicate this is a file upload (not image)
      request.fields['file_type'] = 'file';

      // Add the file to the request
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();

      final multipartFile = http.MultipartFile(
        'image', // Keep same parameter name for compatibility
        fileStream,
        fileLength,
        filename: basename(file.path),
      );

      request.files.add(multipartFile);

      // Send the request with timeout
      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      // Accept both 200 and 201 status codes as success
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return ImageUploadResponse.fromJson(jsonResponse);
      } else {
        throw HttpException(
          'Failed to upload file: ${response.statusCode}',
          uri: uri,
        );
      }
    } on SocketException catch (e) {
      print('Network error uploading file: $e');
      throw NetworkException('No internet connection or server is down');
    } on TimeoutException catch (e) {
      print('Timeout uploading file: $e');
      throw NetworkException('Request timed out. Please try again.');
    } on http.ClientException catch (e) {
      print('HTTP client error uploading file: $e');
      throw NetworkException(
          'Network error occurred. Please check your connection.');
    } on FormatException catch (e) {
      print('Invalid response format: $e');
      throw AppException('Invalid server response. Please try again.');
    } on HttpException catch (e) {
      print('HTTP error: $e');
      throw AppException('Server error: ${e.message}');
    } catch (e) {
      print('Unexpected error uploading file: $e');
      throw AppException('Failed to upload file. Please try again.');
    }
  }

  /// Upload and optionally replace an existing image on the server
  Future<ImageUploadResponse> uploadImageAndUpdateImage(
    File imageFile, {
    String? previousImageUrl,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$uploadEndpoint');
      final request = http.MultipartRequest('POST', uri);

      if (previousImageUrl != null && previousImageUrl.isNotEmpty) {
        request.fields['previous_image_url'] = previousImageUrl;
      }

      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      request.files.add(http.MultipartFile(
        'image',
        stream,
        length,
        filename: basename(imageFile.path),
      ));

      // Send the request with timeout
      final streamed = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ImageUploadResponse.fromJson(json.decode(response.body));
      } else {
        throw HttpException(
          'Upload & update failed: ${response.statusCode}',
          uri: uri,
        );
      }
    } on SocketException catch (e) {
      print('Network error in uploadImageAndUpdateImage: $e');
      throw NetworkException('No internet connection or server is down');
    } on TimeoutException catch (e) {
      print('Timeout in uploadImageAndUpdateImage: $e');
      throw NetworkException('Request timed out. Please try again.');
    } on http.ClientException catch (e) {
      print('HTTP client error in uploadImageAndUpdateImage: $e');
      throw NetworkException(
          'Network error occurred. Please check your connection.');
    } on FormatException catch (e) {
      print('Invalid response format: $e');
      throw AppException('Invalid server response. Please try again.');
    } on HttpException catch (e) {
      print('HTTP error: $e');
      throw AppException('Server error: ${e.message}');
    } catch (e) {
      print('Unexpected error in uploadImageAndUpdateImage: $e');
      throw AppException('Failed to update image. Please try again.');
    }
  }

  /// Delete an image from the server
  Future<ImageDeleteResponse> deleteImage(String imageUrl) async {
    try {
      final uri = Uri.parse('$baseUrl$deleteEndpoint');
      final resp = await http
          .delete(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'image_url': imageUrl}),
          )
          .timeout(timeoutDuration);

      print(resp.body);

      if (resp.statusCode == 200) {
        print("deleted");
        return ImageDeleteResponse.fromJson(json.decode(resp.body));
      } else {
        throw HttpException(
          'Delete failed: ${resp.statusCode}',
          uri: uri,
        );
      }
    } on SocketException catch (e) {
      print('Network error deleting image: $e');
      throw NetworkException('No internet connection or server is down');
    } on TimeoutException catch (e) {
      print('Timeout deleting image: $e');
      throw NetworkException('Request timed out. Please try again.');
    } on http.ClientException catch (e) {
      print('HTTP client error deleting image: $e');
      throw NetworkException(
          'Network error occurred. Please check your connection.');
    } on FormatException catch (e) {
      print('Invalid response format: $e');
      throw AppException('Invalid server response. Please try again.');
    } on HttpException catch (e) {
      print('HTTP error: $e');
      throw AppException('Server error: ${e.message}');
    } catch (e) {
      print('Unexpected error deleting image: $e');
      throw AppException('Failed to delete image. Please try again.');
    }
  }
}

// Custom exception classes for better error handling
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}

class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}
