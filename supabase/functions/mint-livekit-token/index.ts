// Reference implementation — NOT deployed. See README.md in this
// directory for what's missing and how to turn this on.
//
// Verifies the caller is signed in and an accepted participant of the
// requested meeting (mirrors the RLS check meeting_participants already
// enforces for read access — a non-empty query result means they're a
// member), then mints a short-lived LiveKit token scoped to that
// meeting's room. Room naming convention: `meeting-${meeting_id}`,
// matching what the Flutter client will join once livekit_client is
// wired up (see lib/services/livekit/livekit_service.dart).

import { createClient } from 'npm:@supabase/supabase-js@2';
import { AccessToken } from 'npm:livekit-server-sdk@2';

Deno.serve(async (req) => {
  try {
    const { meeting_id } = await req.json();
    if (!meeting_id) {
      return new Response(JSON.stringify({ error: 'meeting_id is required' }), {
        status: 400,
      });
    }

    const authHeader = req.headers.get('Authorization') ?? '';
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } },
    );

    const { data: userData, error: userError } = await supabase.auth.getUser();
    if (userError || !userData.user) {
      return new Response(JSON.stringify({ error: 'Not authenticated' }), { status: 401 });
    }
    const user = userData.user;

    const { data: participant, error: participantError } = await supabase
      .from('meeting_participants')
      .select('user_id')
      .eq('meeting_id', meeting_id)
      .eq('user_id', user.id)
      .maybeSingle();

    if (participantError || !participant) {
      return new Response(
        JSON.stringify({ error: 'Not a participant of this meeting' }),
        { status: 403 },
      );
    }

    const apiKey = Deno.env.get('LIVEKIT_API_KEY')!;
    const apiSecret = Deno.env.get('LIVEKIT_API_SECRET')!;

    const token = new AccessToken(apiKey, apiSecret, {
      identity: user.id,
      ttl: '2h',
    });
    token.addGrant({
      room: `meeting-${meeting_id}`,
      roomJoin: true,
      canPublish: true,
      canSubscribe: true,
    });

    return new Response(JSON.stringify({ token: await token.toJwt() }), {
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: String(error) }), { status: 500 });
  }
});
