import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:online_chat/services/agora_token_service.dart';

class AgoraCallService {
  static RtcEngine? _engine;

  static Future<RtcEngine> ensureEngineInitialized({
    required String appId,
    bool enableVideo = false,
  }) async {
    if (_engine != null) return _engine!;

    final engine = createAgoraRtcEngine();
    await engine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    if (enableVideo) {
      await engine.enableVideo();
    } else {
      await engine.enableAudio();
    }

    _engine = engine;
    return engine;
  }

  static Future<String> generateToken({
    required String channelName,
    required int uid,
    int expireTimeSeconds = 86400,
  }) async {
    return AgoraTokenService.getTokenWithRetry(
      channelName: channelName,
      uid: uid,
      expireTime: expireTimeSeconds,
    );
  }

  static Future<void> joinChannel({
    required RtcEngine engine,
    required String token,
    required String channelId,
    required int uid,
    bool isBroadcaster = true,
  }) async {
    await engine.joinChannel(
      token: token,
      channelId: channelId,
      uid: uid,
      options: ChannelMediaOptions(
        clientRoleType: isBroadcaster
            ? ClientRoleType.clientRoleBroadcaster
            : ClientRoleType.clientRoleAudience,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  static Future<void> renewToken(String token) async {
    await _engine?.renewToken(token);
  }

  static Future<void> leaveChannel() async {
    await _engine?.leaveChannel();
  }

  static Future<void> dispose() async {
    await _engine?.leaveChannel();
    await _engine?.release();
    _engine = null;
  }
}


