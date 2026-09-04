// Mirrors the RBAC roles from the project brief (section 26) and the
// `user_roles.role` check constraint in supabase/migrations/0001_profiles_and_roles.sql.
export const ADMIN_ROLES = ["admin", "super_admin"] as const;

export type AdminRole = (typeof ADMIN_ROLES)[number];

export function isAdminRole(role: string | null | undefined): role is AdminRole {
  return role != null && (ADMIN_ROLES as readonly string[]).includes(role);
}
