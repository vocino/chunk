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

  void dispose() {}
}
