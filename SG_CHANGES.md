# StudentGator changes to ZEGO Call Kit 4.24.7

Base: ZEGO `zego_uikit_prebuilt_call` 4.24.7. Every change is marked `SG:` in the code.
Upgrading ZEGO means re-applying these on the new version.

| Change | File | Why |
|---|---|---|
| Ring before the ZIM login | `callkit/android/handler.call.dart` | The login can take minutes in doze; the ring waited for it |
| Re-login instead of opening the app | `callkit/android/handler.call.dart` | Android 10+ blocks opening an app from the background, so a sleeping phone never rang |
| Answer/Decline wait for the login | `callkit/android/handler.call.dart` | A fast tap reached ZIM while logged out and the call was lost |
| Forget the saved call on cancel | `callkit/android/handler.call.dart` | Opening the app right after a cancel replayed the call |
| Replay a saved call only if it is for this user and, if unanswered, still ringing | `mixins/private/private.dart` | Old calls rang on app start with nobody calling |
| Saved call uses the invite's ring time (40 s), not a fixed 60 s | `callkit/android/handler.call.dart` | Matches the CRM |
| Notification fallback without the overlay permission | `notification/notification_manager.dart` | Earlier fix (fb7586b) |
