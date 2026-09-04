import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";

// Creates a fresh Supabase client per request, backed by the request's
// cookies. Server Components can't write cookies (no-op catch below) —
// session refresh there relies on proxy.ts having already run first.
export async function createClient() {
  const cookieStore = await cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            for (const { name, value, options } of cookiesToSet) {
              cookieStore.set(name, value, options);
            }
          } catch {
            // Called from a Server Component render — ignore, proxy.ts
            // handles session refresh for that case.
          }
        },
      },
    },
  );
}
