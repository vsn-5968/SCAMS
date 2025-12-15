import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class VoIPService {
  // REPLACE THESE WITH YOUR AGORA APP ID AND TOKEN
  static const String appId = "c815f7e1396647a9bbf44bb46305cbb2";
  static const String token = "007eJxTYGDa+dZLR2n9zBl6c3hbPx4TnTmnuXnn2t5layZ+PMrREB6iwJBsYWiaZp5qaGxpZmZinmiZlJRmYpKUZGJmbGCanJRkxP7QPrMhkJGhRs6cmZEBAkF8HoaS1OKS+OSMxLy81BwGBgBngyJV"; // Can be empty if app is in testing mode
  static const String channelId = "test_channel";

  late RtcEngine _engine;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request permissions
    await [Permission.microphone, Permission.camera].request();

    // Create and initialize the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    // Register event handlers
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("Local user ${connection.localUid} joined");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("Remote user $remoteUid joined");
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          print("Remote user $remoteUid left channel");
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableAudio();
    
    _isInitialized = true;
  }

  Future<void> joinChannel() async {
    if (!_isInitialized) await initialize();
    
    await _engine.joinChannel(
      token: token,
      channelId: channelId,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> leaveChannel() async {
    await _engine.leaveChannel();
  }

  Future<void> dispose() async {
    await _engine.release();
    _isInitialized = false;
  }
}
