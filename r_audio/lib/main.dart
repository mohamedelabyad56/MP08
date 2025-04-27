import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

/// Obtiene la lista de archivos MP3 desde el AssetManifest.json
Future<List<String>> getMusicFiles() async {
  final manifestContent = await rootBundle.loadString('AssetManifest.json');
  final Map<String, dynamic> manifestMap = json.decode(manifestContent);
  final musicFiles = manifestMap.keys
      .where((String key) => key.startsWith('assets/music/'))
      .toList();
  return musicFiles;
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Audio Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PlaylistScreen(),
    );
  }
}

class PlaylistScreen extends StatefulWidget {
  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<String> _songs = [];
  int? _currentSongIndex;
  bool _isPlaying = false;
  double _volume = 1.0;
  Duration? _duration;
  Duration _position = Duration.zero;
  bool _shuffleMode = false;
  bool _loopMode = false;
  ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadSongs();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController!);
    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });
    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null) {
        setState(() {
          _currentSongIndex = index;
          _isPlaying = _audioPlayer.playing;
          _animationController?.forward(from: 0.0);
        });
      }
    });
  }

  /// Carga las canciones
  Future<void> _loadSongs() async {
    try {
      final songPaths = await getMusicFiles();
      setState(() {
        _songs = songPaths;
        _playlist = ConcatenatingAudioSource(
          children: songPaths.map((path) => AudioSource.asset(path)).toList(),
        );
      });
      await _audioPlayer.setAudioSource(_playlist);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading songs: $e')),
      );
    }
  }

  /// Reproduce la canción seleccionada
  Future<void> _playSong(int index) async {
    try {
      await _audioPlayer.seek(Duration.zero, index: index);
      await _audioPlayer.play();
      setState(() {
        _currentSongIndex = index;
        _isPlaying = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing song: $e')),
      );
    }
  }

  /// Alterna entre reproducir y pausar
  void _togglePlayPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else if (_currentSongIndex != null) {
      await _audioPlayer.play();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  /// Reproduce la canción siguiente
  void _playNextSong() {
    if (_currentSongIndex != null && _currentSongIndex! < _songs.length - 1) {
      _playSong(_currentSongIndex! + 1);
    } else if (_loopMode) {
      _playSong(0);
    }
  }

  /// Reproduce la canción anterior
  void _playPreviousSong() {
    if (_currentSongIndex != null && _currentSongIndex! > 0) {
      _playSong(_currentSongIndex! - 1);
    } else if (_loopMode) {
      _playSong(_songs.length - 1);
    }
  }

  /// Actualiza el volumen
  void _updateVolume(double volume) {
    setState(() {
      _volume = volume;
    });
    _audioPlayer.setVolume(volume);
  }

  /// Cambia la posición de reproducción
  void _seekTo(double value) {
    if (_duration != null) {
      final newPosition = _duration! * value;
      _audioPlayer.seek(newPosition);
    }
  }

  /// Alterna el modo aleatorio
  void _toggleShuffle() async {
    setState(() {
      _shuffleMode = !_shuffleMode;
    });
    await _audioPlayer.setShuffleModeEnabled(_shuffleMode);
  }

  /// Alterna el modo de repetición
  void _toggleLoop() async {
    setState(() {
      _loopMode = !_loopMode;
    });
    await _audioPlayer.setLoopMode(_loopMode ? LoopMode.all : LoopMode.off);
  }

  /// Construye el item de la lista con diseño estilizado
  Widget _buildSongItem(int index) {
    final songPath = _songs[index];
    final fileName = songPath.split('/').last;
    final isCurrent = index == _currentSongIndex;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isCurrent ? 8 : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.music_note, color: Colors.white),
        ),
        title: Text(
          fileName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Toca para reproducir'),
        trailing: isCurrent
            ? AnimatedContainer(
          duration: Duration(milliseconds: 300),
          child: IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _togglePlayPause,
          ),
        )
            : Icon(Icons.chevron_right),
        onTap: () => _playSong(index),
      ),
    );
  }

  /// Muestra la sección “Now Playing” con diseño avanzado
  Widget _buildNowPlaying() {
    final songName = _currentSongIndex != null ? _songs[_currentSongIndex!].split('/').last : 'No song playing';
    final progress = _duration != null && _duration!.inMilliseconds > 0
        ? _position.inMilliseconds / _duration!.inMilliseconds
        : 0.0;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.blueGrey],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: FadeTransition(
        opacity: _fadeAnimation!,
        child: Column(
          children: [
            // Título de la canción
            Text(
              songName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            // Controles de reproducción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous, color: Colors.white, size: 32),
                  onPressed: _playPreviousSong,
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  child: IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: Colors.white,
                      size: 48,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.skip_next, color: Colors.white, size: 32),
                  onPressed: _playNextSong,
                ),
              ],
            ),
            // Barra de progreso
            Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (value) => _seekTo(value),
              activeColor: Colors.white,
              inactiveColor: Colors.white30,
            ),
            // Duración actual y total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_position),
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  _formatDuration(_duration ?? Duration.zero),
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            // Control de volumen
            Row(
              children: [
                Icon(Icons.volume_up, color: Colors.white, size: 24),
                Expanded(
                  child: Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) => _updateVolume(value),
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                  ),
                ),
              ],
            ),
            // Modos shuffle y loop
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.shuffle,
                    color: _shuffleMode ? Colors.white : Colors.white60,
                  ),
                  onPressed: _toggleShuffle,
                ),
                IconButton(
                  icon: Icon(
                    Icons.repeat,
                    color: _loopMode ? Colors.white : Colors.white60,
                  ),
                  onPressed: _toggleLoop,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Formatea la duración en mm:ss
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_songs.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Advanced Audio Player'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.blueGrey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Advanced Audio Player'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.blueGrey],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _songs.length,
              itemBuilder: (context, index) => _buildSongItem(index),
            ),
          ),
          _buildNowPlaying(),
        ],
      ),
    );
  }
}