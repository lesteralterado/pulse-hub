# mint-livekit-token

Reference implementation of the token-minting endpoint the mobile app's
`LiveKitService` expects, for when this project gets a real LiveKit
deployment. **Not deployed** — the app currently treats every call to it
as a "video calling isn't set up yet" failure, by design.

## To turn this on

1. Create a LiveKit Cloud project (or a self-hosted LiveKit server) and
   get its URL, API key, and API secret.
2. Deploy this function:
   ```
   supabase functions deploy mint-livekit-token
   ```
3. Set its secrets:
   ```
   supabase secrets set LIVEKIT_API_KEY=... LIVEKIT_API_SECRET=...
   ```
4. Add the `livekit_client` Flutter package and wire the call screen
   (`lib/features/meetings/presentation/meeting_call_page.dart`) up to
   actually connect to the room using the token this function returns.
   Room name convention: `meeting-<meeting id>`.

No other app-side changes should be needed — `LiveKitService` already
calls this function by name.
