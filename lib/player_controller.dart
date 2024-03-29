import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'AudioDataModel/data_model.dart';
import 'api_handler.dart';
// Import your SongApi class here

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _player = AudioPlayer();
  List<SongData> _songs = []; // Store the fetched songs here
  int _currentIndex = 0; // Track the index of the currently playing song

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        title: Text("Audio Player"),
      ),
      body: SafeArea(

        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.only(top:100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    child: Image.network(SongData as String),
                    color: Colors.lightBlue.shade300,
                    height: 300,
                    width: 290,
                  ),
                  SizedBox(height:20,),
                  _sourceSelect(),
                  SizedBox(height:20,),
                  _progessBar(),
                  SizedBox(height:1,),
                  _playerControlButtons(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _songs.length,
                      itemBuilder: (context, index) {
                        final song = _songs[index];
                        return ListTile(
                          title: Text(song.title),
                          onTap: () {
                            _playSong(index);
                          },
                        );
                      },
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _setupAudioPlayer(List<SongData> songs) async {
    try {
      _songs = songs;
      final List<AudioSource> audioSources = songs.map((song) {
        return AudioSource.uri(Uri.parse(song.songLink));
      }).toList();
      await _player.setAudioSource(ConcatenatingAudioSource(children: audioSources));
      _player.currentIndexStream.listen((index) {
        setState(() {
          _currentIndex = index ?? 0;
        });
      });
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  void _playSong(int index) {
    _player.seek(Duration.zero, index: index);
    _player.play();
  }

  void _pauseSong() {
    _player.pause();
  }

  void _skipToNext() {
    _player.seekToNext();
  }

  void _skipToPrevious() {
    _player.seekToPrevious();
  }

  Widget _sourceSelect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        MaterialButton(
          color: Colors.purple,
          child: Text("Fetch Songs"),
          onPressed: () async {
            try {
              final api = SongApi();
              final List<SongData> songs = await api.fetchSongs();
              _setupAudioPlayer(songs);
            } catch (e) {
              print('Error fetching songs: $e');
            }
          },
        ),
      ],
    );
  }

  Widget _progessBar() {
    return StreamBuilder<Duration?>(
      stream: _player.positionStream,
      builder: (context, snapshot) {
        return ProgressBar(
          progress: snapshot.data ?? Duration.zero,
          buffered: _player.bufferedPosition,
          total: _player.duration ?? Duration.zero,
          onSeek: (duration) {
            _player.seek(duration);
          },
        );
      },
    );
  }

  Widget _playerControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.skip_previous),
          onPressed: _skipToPrevious,
        ),
        StreamBuilder<PlayerState>(
          stream: _player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final playing = playerState?.playing ?? false;
            if (playing) {
              return IconButton(
                icon: Icon(Icons.pause),
                onPressed: _pauseSong,
              );
            } else {
              return IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () => _playSong(_currentIndex),
              );
            }
          },
        ),
        IconButton(
          icon: Icon(Icons.skip_next),
          onPressed: _skipToNext,
        ),
      ],
    );
  }
}
