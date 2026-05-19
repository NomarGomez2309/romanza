import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

class SpotifyPlaylist {
  const SpotifyPlaylist({
    required this.name,
    required this.owner,
    required this.url,
    required this.imageUrl,
  });

  final String name;
  final String owner;
  final String url;
  final String? imageUrl;
}

class SpotifyConnection {
  const SpotifyConnection({
    required this.displayName,
    required this.onRepeatPlaylist,
  });

  final String displayName;
  final SpotifyPlaylist? onRepeatPlaylist;
}

class SpotifyService {
  static const _clientId = String.fromEnvironment('SPOTIFY_CLIENT_ID');
  static const _redirectUri = 'romanza://spotify-auth';
  static const _callbackScheme = 'romanza';
  static const _scopes = [
    'playlist-read-private',
    'playlist-read-collaborative',
    'user-read-private',
  ];

  bool get isConfigured => _clientId.isNotEmpty;

  Future<SpotifyConnection?> connect() async {
    if (!isConfigured) return null;

    final verifier = _randomVerifier();
    final challenge = _challengeFor(verifier);
    final state = _randomVerifier(length: 24);

    final authUrl = Uri.https('accounts.spotify.com', '/authorize', {
      'response_type': 'code',
      'client_id': _clientId,
      'scope': _scopes.join(' '),
      'redirect_uri': _redirectUri,
      'code_challenge_method': 'S256',
      'code_challenge': challenge,
      'state': state,
      'show_dialog': 'true',
    });

    final result = await FlutterWebAuth2.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: _callbackScheme,
    );
    final callback = Uri.parse(result);

    if (callback.queryParameters['state'] != state) {
      return null;
    }

    final code = callback.queryParameters['code'];
    if (code == null) return null;

    final token = await _exchangeCode(code: code, verifier: verifier);
    if (token == null) return null;

    final profile = await _getProfile(token);
    final playlists = await _getPlaylists(token);
    final onRepeat = _findOnRepeat(playlists);

    return SpotifyConnection(
      displayName: profile ?? 'Spotify',
      onRepeatPlaylist: onRepeat,
    );
  }

  Future<String?> _exchangeCode({
    required String code,
    required String verifier,
  }) async {
    final response = await http.post(
      Uri.https('accounts.spotify.com', '/api/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': _redirectUri,
        'client_id': _clientId,
        'code_verifier': verifier,
      },
    );

    if (response.statusCode != 200) return null;

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['access_token'] as String?;
  }

  Future<String?> _getProfile(String token) async {
    final response = await http.get(
      Uri.https('api.spotify.com', '/v1/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) return null;

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['display_name'] as String?;
  }

  Future<List<SpotifyPlaylist>> _getPlaylists(String token) async {
    final response = await http.get(
      Uri.https('api.spotify.com', '/v1/me/playlists', {'limit': '50'}),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) return const [];

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (json['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>();

    return [
      for (final item in items)
        SpotifyPlaylist(
          name: item['name'] as String? ?? 'Playlist',
          owner:
              (item['owner'] as Map<String, dynamic>?)?['display_name']
                  as String? ??
              'Spotify',
          url:
              (item['external_urls'] as Map<String, dynamic>?)?['spotify']
                  as String? ??
              'https://open.spotify.com',
          imageUrl: _firstImageUrl(item['images'] as List<dynamic>?),
        ),
    ];
  }

  SpotifyPlaylist? _findOnRepeat(List<SpotifyPlaylist> playlists) {
    for (final playlist in playlists) {
      if (playlist.name.toLowerCase().trim() == 'on repeat') {
        return playlist;
      }
    }

    return playlists.isEmpty ? null : playlists.first;
  }

  String _challengeFor(String verifier) {
    final digest = sha256.convert(ascii.encode(verifier));
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  String _randomVerifier({int length = 64}) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();

    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  String? _firstImageUrl(List<dynamic>? images) {
    if (images == null || images.isEmpty) return null;

    final first = images.first;
    if (first is! Map<String, dynamic>) return null;

    return first['url'] as String?;
  }
}
