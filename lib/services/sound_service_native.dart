import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playDing() async {
    await _player.play(AssetSource('sounds/ding.wav'));
  }

  Future<void> playPop() async {
    await _player.play(AssetSource('sounds/pop.wav'));
  }

  Future<void> playChime() async {
    await _player.play(AssetSource('sounds/chime.wav'));
  }

  void dispose() {
    _player.dispose();
  }
}
