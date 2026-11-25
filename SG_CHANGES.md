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
| iOS: a cancel push ends the ring | `callkit/ios/entry_point.dart` | iOS rings for every VoIP push, the cancel too, and nothing ended it: rang after hang-up, and Accept opened a dead room |
| iOS: Accept waits up to 10 s (was 2 s) for the call to arrive over ZIM | `mixins/private/ios.callkit.dart` | A killed iPhone logs in only after the push; Accept gave up first and the caller kept ringing |
| Android: re-read the saved call from disk before using it | `cache/offline.dart` | The background isolate saved the Accept, but the app's own startup copy still said not accepted: it rang in-app and never joined the room |
| Android: the background room join sends the token | `callkit/android/handler.call.dart` | ZEGO joined without a token, so with token sign-in the join failed. The app then faked the join, was never in the room, hung up after 2 s, and the caller was never told |
| A close of the in-app pop-up by code does not decline the call | `pages/page_manager.dart` | The pop-up declines on any close not from its own buttons, so Answer from our call notification declined the call first |
| iOS: Decline before the call arrives is refused when it arrives | `mixins/private/ios.callkit.dart`, `callkit/background_service.dart`, `callkit/ios/entry_point.dart` | A killed iPhone declined before its login finished: the refusal had empty IDs, the caller kept ringing, and the phone rang again when the call arrived |
