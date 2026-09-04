import { createClient } from "@/lib/supabase/server";
import { isAdminRole, type AdminRole } from "@/lib/auth/roles";

export type CurrentAdmin = {
  userId: string;
  email: string | null;
  roles: AdminRole[];
};

// Authoritative RBAC check for every protected page/layout: proxy.ts only
// confirms a session exists, not that it belongs to an admin, so each
// Server Component re-checks here rather than trusting the proxy alone
// (see the "Data Security" guidance in Next.js's proxy docs).
//
// `user_roles` only has a "view own rows" RLS policy (migration 0001), which
// is exactly what this needs: the signed-in user reading their own roles.
export async function getCurrentAdmin(): Promise<CurrentAdmin | null> {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) return null;

  const { data: roleRows } = await supabase
    .from("user_roles")
    .select("role")
    .eq("user_id", user.id);

  const roles = (roleRows ?? [])
    .map((row) => row.role as string)
    .filter(isAdminRole);

  if (roles.length === 0) return null;

  return { userId: user.id, email: user.email ?? null, roles };
}
