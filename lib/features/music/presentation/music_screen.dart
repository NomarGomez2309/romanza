import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/spotify_service.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  static const _ink = Color(0xFF5B5B5B);
  static const _mint = Color(0xFFDDF3EA);
  static const _green = Color(0xFF75D48F);
  static const _sand = Color(0xFFE2C987);
  static const _pink = Color(0xFFF3A1B8);
  static const _paper = Color(0xFFE6E0D5);
  static const _blue = Color(0xFF667396);
  static const _orange = Color(0xFFFF9C39);

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final SpotifyService _spotifyService = SpotifyService();

  SpotifyConnection? _boyfriendConnection;
  SpotifyConnection? _girlfriendConnection;
  _SpotifySlot? _connectingSlot;

  static const _boyfriendTracks = [
    _Track(title: 'Is This Love to You', artist: 'Bryant Barnes'),
    _Track(title: 'Best Part', artist: 'Daniel Caesar, H.E.R.'),
    _Track(title: 'Sweet', artist: 'Cigarettes After Sex'),
    _Track(title: 'Japanese Denim', artist: 'Daniel Caesar'),
  ];

  static const _girlfriendTracks = [
    _Track(title: 'Snooze', artist: 'SZA'),
    _Track(title: 'Moonlight', artist: 'Kali Uchis'),
    _Track(title: 'Lover', artist: 'Taylor Swift'),
    _Track(title: 'Melting', artist: 'Kali Uchis'),
  ];

  Future<void> _connectSpotify(_SpotifySlot slot) async {
    if (!_spotifyService.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega tu Spotify Client ID para conectar la cuenta.'),
        ),
      );
      return;
    }

    setState(() => _connectingSlot = slot);

    final connection = await _spotifyService.connect();

    if (!mounted) return;
    setState(() {
      _connectingSlot = null;
      if (slot == _SpotifySlot.boyfriend) {
        _boyfriendConnection = connection;
      } else {
        _girlfriendConnection = connection;
      }
    });

    if (connection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pude conectar Spotify.')),
      );
    }
  }

  Future<void> _openPlaylist(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pude abrir Spotify ahora mismo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.apply(
      bodyColor: MusicScreen._ink,
      displayColor: MusicScreen._ink,
    );

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: MusicScreen._mint,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(onBack: () => Navigator.of(context).pop()),
                const SizedBox(height: 24),
                _HeroPanel(
                  isConfigured: _spotifyService.isConfigured,
                  onConnect: () => _connectSpotify(_SpotifySlot.boyfriend),
                ),
                const SizedBox(height: 24),
                _PlaylistPanel(
                  title: 'Novio',
                  subtitle: 'On Repeat',
                  color: MusicScreen._blue,
                  tracks: _boyfriendTracks,
                  connection: _boyfriendConnection,
                  isConnecting: _connectingSlot == _SpotifySlot.boyfriend,
                  onConnect: () => _connectSpotify(_SpotifySlot.boyfriend),
                  onOpenPlaylist: _openPlaylist,
                ),
                const SizedBox(height: 24),
                _PlaylistPanel(
                  title: 'Novia',
                  subtitle: 'On Repeat',
                  color: MusicScreen._pink,
                  tracks: _girlfriendTracks,
                  connection: _girlfriendConnection,
                  isConnecting: _connectingSlot == _SpotifySlot.girlfriend,
                  onConnect: () => _connectSpotify(_SpotifySlot.girlfriend),
                  onOpenPlaylist: _openPlaylist,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _SpotifySlot { boyfriend, girlfriend }

class _Track {
  const _Track({required this.title, required this.artist});

  final String title;
  final String artist;
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFD7D7D7),
              border: Border.all(color: MusicScreen._ink, width: 2),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: MusicScreen._ink,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Spotify /',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 23,
              letterSpacing: 0,
            ),
          ),
        ),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFD7D7D7),
            border: Border.all(color: MusicScreen._ink, width: 2),
          ),
        ),
      ],
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.isConfigured, required this.onConnect});

  final bool isConfigured;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      color: MusicScreen._green,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: MusicScreen._ink, width: 2),
              image: const DecorationImage(
                image: AssetImage('assets/images/Spotify.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'On Repeat',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: .95,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Lo que mas esta sonando para cada uno.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _MiniButton(label: 'Connect Spotify', onTap: onConnect),
                if (!isConfigured) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Client ID pendiente',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistPanel extends StatelessWidget {
  const _PlaylistPanel({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.tracks,
    required this.connection,
    required this.isConnecting,
    required this.onConnect,
    required this.onOpenPlaylist,
  });

  final String title;
  final String subtitle;
  final Color color;
  final List<_Track> tracks;
  final SpotifyConnection? connection;
  final bool isConnecting;
  final VoidCallback onConnect;
  final Future<void> Function(BuildContext context, String url) onOpenPlaylist;

  @override
  Widget build(BuildContext context) {
    final isDark = color == MusicScreen._blue;
    final headerColor = isDark ? Colors.white : MusicScreen._ink;

    return _Panel(
      color: color,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: headerColor,
                          fontWeight: FontWeight.w900,
                          height: .9,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: headerColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                _MiniButton(
                  label: isConnecting
                      ? 'Connecting...'
                      : connection == null
                      ? 'Connect Spotify'
                      : 'Open Playlist',
                  onTap: connection == null
                      ? onConnect
                      : () => onOpenPlaylist(
                          context,
                          connection!.onRepeatPlaylist?.url ??
                              'https://open.spotify.com',
                        ),
                ),
              ],
            ),
          ),
          const Divider(height: 2, thickness: 2, color: MusicScreen._ink),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: Column(
              children: [
                if (connection?.onRepeatPlaylist != null)
                  _ConnectedPlaylistRow(playlist: connection!.onRepeatPlaylist!)
                else
                  for (var index = 0; index < tracks.length; index++) ...[
                    _TrackRow(track: tracks[index], index: index + 1),
                    if (index != tracks.length - 1) const SizedBox(height: 8),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectedPlaylistRow extends StatelessWidget {
  const _ConnectedPlaylistRow({required this.playlist});

  final SpotifyPlaylist playlist;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 70),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: MusicScreen._paper,
        border: Border.all(color: MusicScreen._ink, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            color: MusicScreen._sand,
            child: playlist.imageUrl == null
                ? const Icon(Icons.music_note, color: MusicScreen._ink)
                : Image.network(playlist.imageUrl!, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  playlist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  playlist.owner,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({required this.track, required this.index});

  final _Track track;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: MusicScreen._paper,
        border: Border.all(color: MusicScreen._ink, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            color: MusicScreen._sand,
            child: Text(
              '$index',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  track.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: MusicScreen._orange,
            border: Border.all(color: MusicScreen._ink, width: 2),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF275980),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.color,
    required this.child,
    this.padding = const EdgeInsets.all(8),
  });

  final Color color;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: MusicScreen._ink, width: 2),
        boxShadow: const [
          BoxShadow(
            color: MusicScreen._ink,
            blurRadius: 0,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
