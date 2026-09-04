export function ComingSoon({ title }: { title: string }) {
  return (
    <div>
      <h1 className="text-2xl font-semibold text-slate-900">{title}</h1>
      <p className="mt-2 text-sm text-slate-500">
        This section is not built yet — it lands in a later Admin Dashboard phase.
      </p>
    </div>
  );
}
