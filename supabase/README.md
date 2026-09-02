# Supabase migrations

SQL migrations for the PulseHub Supabase project, applied in filename order.

## Applying locally / to a project

```
supabase link --project-ref <your-project-ref>
supabase db push
```

Or paste the file contents into the Supabase dashboard's SQL editor.

These migrations are not run by `flutter test` — there's no live Postgres
in the test environment, so they're reviewed by hand and applied to a real
Supabase project separately from the app's automated test suite.
