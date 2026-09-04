export function MetricCard({ label }: { label: string }) {
  return (
    <div className="rounded-lg border border-slate-200 bg-white p-4">
      <p className="text-sm text-slate-500">{label}</p>
      <p className="mt-2 text-2xl font-semibold text-slate-900">—</p>
    </div>
  );
}

export function MetricGroup({
  title,
  metrics,
}: {
  title: string;
  metrics: readonly string[];
}) {
  return (
    <section>
      <h2 className="text-sm font-semibold uppercase tracking-wide text-slate-500">
        {title}
      </h2>
      <div className="mt-3 grid grid-cols-2 gap-4 sm:grid-cols-4">
        {metrics.map((metric) => (
          <MetricCard key={metric} label={metric} />
        ))}
      </div>
    </section>
  );
}
