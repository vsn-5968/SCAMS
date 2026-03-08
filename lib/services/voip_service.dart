import 'dart:typed_data';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class VoIPService {
  // --- Credentials from Agora Console ---
  static const String appId = "c815f7e1396647a9bbf44bb46305cbb2";
  static const String token = "007eJxTYGDa+dZLR2n9zBl6c3hbPx4TnTmnuXnn2t5layZ+PMrREB6iwJBsYWiaZp5qaGxpZmZinmiZlJRmYpKUZGJmbGCanJRkxP7QPrMhkJGhRs6cmZEBAkF8HoaS1OKS+OSMxLy81BwGBgBngyJV";

  late RtcEngine _engine;
  bool _isInitialized = false;
  AudioFrameObserver? _audioFrameObserver;

  // Callback to send the mixed audio data to the CallScreen
  Function(Uint8List)? onMixedAudioChunkReceived;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await [Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("[VoIPService] Local user ${connection.localUid} joined channel: ${connection.channelId}");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("[VoIPService] Remote user $remoteUid joined");
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          print("[VoIPService] Remote user $remoteUid left channel");
        },
      ),
    );

    _engine.setMixedAudioFrameParameters(
      sampleRate: 16000,
      channel: 1,
      samplesPerCall: 1024,
    );

    _audioFrameObserver = AudioFrameObserver(
      onMixedAudioFrame: (String channelId, AudioFrame frame) {
        if (frame.buffer != null && onMixedAudioChunkReceived != null) {
          onMixedAudioChunkReceived!(frame.buffer!);
        }
      },
    );

    _engine.getMediaEngine().registerAudioFrameObserver(_audioFrameObserver!);

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableAudio();

    _isInitialized = true;
  }

  Future<void> joinChannel(String channelId) async {
    if (!_isInitialized) await initialize();
    await _engine.joinChannel(
      token: token,
      channelId: channelId, // Use the provided channelId
      uid: 0,
      options: const ChannelMediaOptions(publishMicrophoneTrack: true),
    );
  }

  Future<void> leaveChannel() async {
    if (!_isInitialized) return;
    await _engine.leaveChannel();
  }

  Future<void> dispose() async {
    if (!_isInitialized) return;
    if (_audioFrameObserver != null) {
      _engine.getMediaEngine().unregisterAudioFrameObserver(_audioFrameObserver!);
    }
    await _engine.release();
    _isInitialized = false;
  }
}
