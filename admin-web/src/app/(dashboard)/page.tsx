import { MetricGroup } from "@/components/metric-card";

// Overview Dashboard — project brief section 31. Real numbers land once
// each area (Users, Community, Meetings, Learning, Subscriptions,
// Blockchain) gets its own admin phase; this shell just proves the layout
// and RBAC gate work end to end.
export default function OverviewPage() {
  return (
    <div className="space-y-8">
      <h1 className="text-2xl font-semibold text-slate-900">Dashboard</h1>

      <MetricGroup
        title="Users"
        metrics={["Total users", "Active users", "New users", "Suspended users"]}
      />
      <MetricGroup
        title="Community"
        metrics={["Posts", "Comments", "Reports", "Active groups"]}
      />
      <MetricGroup
        title="Meetings"
        metrics={["Upcoming meetings", "Live meetings", "Participants"]}
      />
      <MetricGroup
        title="Learning"
        metrics={["Active learners", "Course completions", "Quiz statistics"]}
      />
      <MetricGroup
        title="Subscriptions"
        metrics={[
          "Active subscriptions",
          "Expiring subscriptions",
          "Subscription transactions",
          "BOT revenue",
        ]}
      />
      <MetricGroup
        title="Blockchain"
        metrics={[
          "BOT transactions",
          "Failed transactions",
          "Pending transactions",
          "Smart-contract events",
        ]}
      />
    </div>
  );
}
