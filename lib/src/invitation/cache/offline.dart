// Package imports:
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/protocols.dart';

class ZegoUIKitOfflineCallKitCache {
  String callkitCalIDCacheKey = 'callkit_call_id';
  String callkitParamsCacheKey = 'callkit_params';

  /// cached ID of the current cal
  Future<void> setCallID(String callID) async {
    ZegoLoggerService.logInfo(
      'set offline callkit id:$callID',
      tag: 'call-invitation',
      subTag: 'callkit',
    );

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(callkitCalIDCacheKey, callID);
  }

  /// @nodoc
  ///
  /// Retrieve the cached ID of the current call, which is stored in the handler received from ZPNS.
  Future<String?> getCallID() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // SG: see getCacheParams
    return prefs.getString(callkitCalIDCacheKey);
  }

  /// cached ID of the current cal
  Future<void> clearCallID() async {
    ZegoLoggerService.logInfo(
      'clear offline callkit id',
      tag: 'call-invitation',
      subTag: 'callkit',
    );

    final prefs = await SharedPreferences.getInstance();
    prefs.remove(callkitCalIDCacheKey);
  }

  /// cached ID of the current params
  Future<void> setCacheParams(
    ZegoCallInvitationOfflineCallKitCacheParameterProtocol
    callKitParameterProtocol,
  ) async {
    callKitParameterProtocol.datetime = DateTime.now().millisecondsSinceEpoch;
    final jsonString = callKitParameterProtocol.toJson();
    ZegoLoggerService.logInfo(
      'set offline callkit params:$jsonString',
      tag: 'call-invitation',
      subTag: 'callkit',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(callkitParamsCacheKey, jsonString).then((result) {
      ZegoLoggerService.logInfo(
        'set offline callkit params done, result:$result',
        tag: 'call-invitation',
        subTag: 'callkit',
      );
    });
  }

  Future<ZegoCallInvitationOfflineCallKitCacheParameterProtocol>
  getCacheParams() async {
    final prefs = await SharedPreferences.getInstance();
    // SG: on Android a killed app's Accept is saved here by the background
    // isolate, while the app's own copy of these prefs was loaded at startup.
    // Without a reload the app read "accept:false", rang in-app for a call
    // that was already accepted, and never joined the room.
    await prefs.reload();
    final jsonString = prefs.getString(callkitParamsCacheKey) ?? '';

    return ZegoCallInvitationOfflineCallKitCacheParameterProtocol.fromJson(
      jsonString,
    );
  }

  Future<void> clearCacheParams() async {
    ZegoLoggerService.logInfo(
      'clear offline callkit params',
      tag: 'call-invitation',
      subTag: 'callkit',
    );

    final prefs = await SharedPreferences.getInstance();
    prefs.remove(callkitParamsCacheKey);

    ZegoLoggerService.logInfo(
      'clear offline callkit params done',
      tag: 'call-invitation',
      subTag: 'callkit',
    );
  }
}
