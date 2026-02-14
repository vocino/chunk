import 'dart:js_interop';

@JS('Audio')
extension type _JSAudio._(JSObject _) implements JSObject {
  external _JSAudio(String src);
  external JSPromise<JSAny?> play();
}

class SoundService {
  Future<void> playDing() async {
    _JSAudio('assets/sounds/ding.wav').play();
  }

  Future<void> playPop() async {
    _JSAudio('assets/sounds/pop.wav').play();
  }

  Future<void> playChime() async {
    _JSAudio('assets/sounds/chime.wav').play();
  }

  void dispose() {}
}
