// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/cache/cache.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/ios/handler.dart';

String? iOSIncomingPushUUID;

// SG: iOS shows a CallKit call for every VoIP push, the caller's cancel too.
// We remember which ring each call started, so a cancel can end it.
final _ringByCallID = <String, String>{};
final _canceledCallIDs = <String>{};

/// @nodoc
///
/// [iOS] VoIP event callback
void onIncomingPushReceived(Map<dynamic, dynamic> extras, String uuid) async {
  ///   extras:{
  ///     aps: {
  ///        alert: {title: user_870125, body: im message}
  ///     },
  ///     payload: {
  ///        "operation_type":"text_msg",
  ///        "id":"116802",
  ///        "sender":{
  ///            "id":"870125","name":"user_870125"
  ///        },
  ///        "type":1
  ///     },
  ///     zego: {version: 1, zpns_request_id: 4855622119122677075}
  ///     },
  ///     uuid:Instance of 'UUIDImpl'
  /// }
  ZegoLoggerService.logInfo(
    'on message received: '
    'extras:$extras, uuid:$uuid',
    tag: 'call-invitation',
    subTag: 'offline',
  );

  // SG: checked before the 'zego' key test below, because cancel pushes
  // may not carry that key and would be dropped while still ringing.
  final callID = extras['call_id']?.toString() ?? '';
  if (_isCancel(extras)) {
    _endRings(callID, thisRing: uuid);
    return;
  }
  // The invite came after its cancel (pushes can arrive out of order).
  if (_canceledCallIDs.contains(callID)) {
    _endRings(callID, thisRing: uuid);
    return;
  }

  final isZegoMessage = extras.keys.contains('zego');
  if (!isZegoMessage) {
    ZegoLoggerService.logInfo(
      'is not zego protocol, drop it',
      tag: 'call-invitation',
      subTag: 'offline',
    );
    return;
  }

  iOSIncomingPushUUID = uuid;
  if (callID.isNotEmpty) _ringByCallID[callID] = uuid;

  final handler = ZegoCallIOSBackgroundMessageHandler();
  await handler.handleMessage(messageExtras: Map<String, Object?>.from(extras));
}

// SG: true when the push is the caller's cancel_invitation.
bool _isCancel(Map<dynamic, dynamic> extras) {
  var payload = extras['payload'];
  if (payload is String) {
    try {
      payload = jsonDecode(payload);
    } catch (_) {
      return false;
    }
  }
  return payload is Map &&
      payload['operation_type'] == BackgroundMessageType.cancelInvitation.text;
}

// SG: ends the ring this push started and the ring of the call it cancels.
void _endRings(String callID, {required String thisRing}) {
  if (callID.isNotEmpty) _canceledCallIDs.add(callID);
  final inviteRing = _ringByCallID.remove(callID);
  ZegoLoggerService.logInfo(
    'call $callID canceled, ending rings: $thisRing, $inviteRing',
    tag: 'call-invitation',
    subTag: 'offline',
  );

  for (final ring in {thisRing, inviteRing}.nonNulls) {
    ZegoUIKit().getSignalingPlugin().reportCallEnded(
      ZegoSignalingPluginCXCallEndedReason.callEndedReasonRemoteEnded,
      ring,
    );
  }
  if (inviteRing != null && iOSIncomingPushUUID == inviteRing) {
    iOSIncomingPushUUID = null;
    // The invite saved itself for replay at startup; forget it.
    ZegoUIKitCallCache().offlineCallKit.clearCallID();
  }
}
