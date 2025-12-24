import 'dart:convert';
import 'dart:developer' as developer;

import 'package:agora_token_generator/agora_token_generator.dart';
import 'package:http/http.dart' as http;

/// Service for generating Agora tokens dynamically based on channel name
class AgoraTokenService {
  // Agora App ID
  static const String appId = 'b34885418c364475beccdac659ee63c5';

  // App Certificate (for token generation - keep this secure!)
  // In production, this should be stored securely and never exposed in client code
  // For now, you'll need to get this from Agora Console
  static const String appCertificate = '43ee893b06304601a02b383970a7fe68';

  // Token server URL (for production - optional)
  // If you have a token server, set this URL
  static const String? tokenServerUrl = null; // e.g., 'https://your-token-server.com/token'

  /// Generate or fetch token for a specific channel
  ///
  /// [channelName] - The dynamic channel name
  /// [uid] - User ID (0 for auto-assign)
  /// [expireTime] - Token expiration time in seconds (default: 24 hours)
  ///
  /// Returns the token string, or empty string if generation fails
  static Future<String> getToken({
    required String channelName,
    int uid = 0,
    int expireTime = 86400, // 24 hours
  }) async {
    try {
      // Option 1: Use token server (recommended for production)
      developer.log("tokenServerUrl ::::::::::::::::: $tokenServerUrl");
      if (tokenServerUrl != null && tokenServerUrl!.isNotEmpty) {
        return await _fetchTokenFromServer(channelName, uid, expireTime);
      }

      // Option 2: Generate token locally (for development/testing only)
      // Note: This requires the app certificate which should NOT be in client code
      // For production, always use a token server
      return await _generateTokenLocally(channelName, uid, expireTime);
    } catch (e, stackTrace) {
      developer.log(
        'Error generating token: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'AgoraTokenService',
      );
      // Return empty string to use no token (works for development with App ID only)
      return '';
    }
  }

  /// Fetch token from your token server (recommended for production)
  static Future<String> _fetchTokenFromServer(
    String channelName,
    int uid,
    int expireTime,
  ) async {
    try {
      final url = Uri.parse('$tokenServerUrl?channel=$channelName&uid=$uid&expire=$expireTime');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'] as String? ?? '';
        if (token.isEmpty) {
          developer.log(
            'Token server responded without token',
            name: 'AgoraTokenService',
          );
        }
        return token;
      } else {
        developer.log(
          'Token server error: ${response.statusCode} - ${response.body}',
          name: 'AgoraTokenService',
        );
        return '';
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching token from server: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'AgoraTokenService',
      );
      return '';
    }
  }

  /// Generate token locally (for development only)
  ///
  /// WARNING: This requires the app certificate which should NOT be exposed
  /// in client-side code. Use only for development/testing.
  /// For production, always use a token server.
  static Future<String> _generateTokenLocally(
    String channelName,
    int uid,
    int expireTime,
  ) async {
    // If app certificate is not set, return empty string
    // Agora allows using App ID only for development (limited)
    if (appCertificate.isEmpty || appCertificate == 'YOUR_APP_CERTIFICATE' || appId.isEmpty) {
      developer.log(
        'App certificate/App ID not set. Using App ID only (development mode).',
        name: 'AgoraTokenService',
      );
      return '';
    }

    // Ensure non-zero uid for token generation
    final int safeUid = uid == 0 ? 1 : uid;
    final int tokenExpireSeconds = expireTime;
    final String token = RtcTokenBuilder.buildTokenWithUid(
      appId: appId,
      appCertificate: appCertificate,
      channelName: channelName,
      uid: safeUid,
      tokenExpireSeconds: tokenExpireSeconds,
    );

    developer.log('🎯 RTC Token: $token');
    return token;

    /*   developer.log(
      'Local token generation not implemented. Using App ID only mode.',
      name: 'AgoraTokenService',
    );
    return '';*/
  }

  /// Get token with retry logic
  static Future<String> getTokenWithRetry({
    required String channelName,
    int uid = 0,
    int expireTime = 86400,
    int maxRetries = 3,
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        final token = await getToken(
          channelName: channelName,
          uid: uid,
          expireTime: expireTime,
        );
        developer.log("token :::::::::::::::::::::::::${token}");
        if (token.isNotEmpty) {
          return token;
        }

        // Wait before retry (exponential backoff)
        if (i < maxRetries - 1) {
          await Future.delayed(Duration(seconds: (i + 1) * 2));
        }
      } catch (e) {
        developer.log(
          'Token generation attempt ${i + 1} failed: $e',
          name: 'AgoraTokenService',
        );
      }
    }

    // Return empty string after all retries failed
    return '';
  }
}
