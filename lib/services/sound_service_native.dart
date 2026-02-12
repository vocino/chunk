import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playDing() async {
    await _player.play(AssetSource('sounds/ding.wav'));
  }

  void dispose() {
    _player.dispose();
  }
}
