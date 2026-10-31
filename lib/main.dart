import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() => runApp(const RadioApp());

class RadioApp extends StatelessWidget {
  const RadioApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'راديو القرآن',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF0F1A14),
      ),
      home: const HomePage(),
    );
  }
}

class Station {
  final String name;
  final String url;
  final IconData icon;
  Station(this.name, this.url, this.icon);
}

final stations = [
  Station('إذاعة القرآن الكريم - الأردن',
      'https://jrtv-live.ercdn.net/jrradio/quranradio.m3u8', Icons.menu_book),
  Station('Mp3Quran - السعودية',
      'https://qurango.net/radio/mix', Icons.mosque),
  Station('قناة العربية الإخبارية',
      'https://live.alarabiya.net/alarabiapublish/alarabiya.smil/playlist.m3u8',
      Icons.newspaper),
  Station('تلاوات قرآنية متنوعة',
      'http://live.mp3quran.net:9834/', Icons.headphones),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AudioPlayer _player = AudioPlayer();
  int? _currentIndex;
  bool _loading = false;
  bool _playing = false;

  Future<void> _play(int index) async {
    try {
      setState(() {
        _loading = true;
        _currentIndex = index;
      });
      await _player.setUrl(stations[index].url);
      _player.play();
      setState(() {
        _loading = false;
        _playing = true;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر التشغيل: $e')),
        );
      }
    }
  }

  void _togglePlay() {
    if (_playing) {
      _player.pause();
      setState(() => _playing = false);
    } else if (_currentIndex != null) {
      _player.play();
      setState(() => _playing = true);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('راديو القرآن 📻'),
        backgroundColor: Colors.green.shade800,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: stations.length,
              itemBuilder: (context, i) {
                final active = _currentIndex == i;
                return Card(
                  color: active ? Colors.green.shade900 : const Color(0xFF1C2B22),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(stations[i].icon,
                        color: active ? Colors.amber : Colors.greenAccent),
                    title: Text(stations[i].name,
                        style: const TextStyle(color: Colors.white)),
                    trailing: active && _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.amber))
                        : IconButton(
                            icon: Icon(
                              active && _playing
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              color: Colors.amber,
                              size: 34,
                            ),
                            onPressed: () {
                              if (active) {
                                _togglePlay();
                              } else {
                                _play(i);
                              }
                            },
                          ),
                  ),
                );
              },
            ),
          ),
          if (_currentIndex != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.green.shade900,
              child: Row(
                children: [
                  const Icon(Icons.radio, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'يعمل الآن: ${stations[_currentIndex!].name}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: Icon(_playing ? Icons.pause : Icons.play_arrow,
                        color: Colors.white),
                    onPressed: _togglePlay,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
