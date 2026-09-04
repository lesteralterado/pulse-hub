import { redirect } from "next/navigation";
import { getCurrentAdmin } from "@/lib/auth/current-admin";
import { Sidebar } from "@/components/sidebar";

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const admin = await getCurrentAdmin();

  if (!admin) {
    redirect("/not-authorized");
  }

  return (
    <div className="flex min-h-screen bg-slate-50">
      <Sidebar email={admin.email} />
      <main className="flex-1 p-8">{children}</main>
    </div>
  );
}
