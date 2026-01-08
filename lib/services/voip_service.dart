import 'dart:typed_data';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class VoIPService {
  // CREDENTIALS - These are correct
  static const String appId = "c815f7e1396647a9bbf44bb46305cbb2";
  static const String token = "007eJxTYPi6jEV+yvX/GdcU46S9rlr/yGD/e/rD6skf9/OHa5ccfvBQgSHZwtA0zTzV0NjSzMzEPNEyKSnNxCQpycTM2MA0OSnJSPxCfGZDICPDvHNTmBgZIBDE52EoSS0uiU/OSMzLS81hYAAAKBIlUA==";
  static const String channelId = "test_channel";

  late RtcEngine _engine;
  bool _isInitialized = false;
  AudioFrameObserver? _audioFrameObserver;

  // Callback to send audio data to your UI or Backend
  Function(Uint8List)? onAudioChunkReceived;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Request permissions
    await [Permission.microphone].request();

    // 2. Create and initialize the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    // 3. Register standard event handlers
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("Local user ${connection.localUid} joined");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("Remote user $remoteUid joined - Call Connected!");
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          print("Remote user $remoteUid left channel");
        },
      ),
    );

    // 4. CRITICAL: Configure Audio Frame Observer
    // Set the audio format on the RtcEngine directly
    _engine.setPlaybackAudioFrameParameters(
      sampleRate: 16000, // Standard for AI models
      channel: 1,        // Mono audio
      mode: RawAudioFrameOpModeType.rawAudioFrameOpModeReadOnly,
      samplesPerCall: 1024,
    );

    _audioFrameObserver = AudioFrameObserver(
      // ... inside the AudioFrameObserver
      onPlaybackAudioFrame: (String channelId, AudioFrame frame) {
        if (frame.buffer != null) {
          // ---- ADD THIS LINE ----
          print("🎧 Received audio chunk! Size: ${frame.buffer!.lengthInBytes} bytes");

          if (onAudioChunkReceived != null) {
            onAudioChunkReceived!(frame.buffer!);
          }
        }
      },
    );

    // Register the observer on the MediaEngine
    _engine.getMediaEngine().registerAudioFrameObserver(_audioFrameObserver!);

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableAudio();

    _isInitialized = true;
  }

  Future<void> joinChannel() async {
    if (!_isInitialized) await initialize();

    await _engine.joinChannel(
      token: token,
      channelId: channelId,
      uid: 0, // Both users will try to join with uid 0. Agora handles this.
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> leaveChannel() async {
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
