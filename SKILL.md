---
name: clone-rebrand-site
description: Use when the user wants to clone a reference website/repo and rebuild it as a new, independent project with the same structure and behavior, but with placeholder content, media, and branding standing in for the original until real assets are supplied. Triggers on "clone this site", "use this repo as a template", "rebuild with the same behavior but change the content/logo/images", "rebrand this codebase".
---

# Clone & Rebrand Site

Turn a reference repo into a new project: keep the mechanics (framework, layout, interactive behavior), strip everything that belongs to the original (their git history, their copy, their media, their brand), and leave clearly-marked placeholders so real content can drop in later without touching code.

## Step 1 — Clone and inspect before changing anything

Clone the reference repo into the target directory (or a scratch location if the target isn't empty) and read every page/component/config file — don't skim. Identify:

- The stack (framework, styling, animation libs) and how the project is run/built.
- Every **page** and **component**, and which ones hold real behavior vs. are already-empty stubs.
- Anything that is genuinely the source project's IP: brand name, logo, copy, images, video frames. This is what gets replaced.
- Anything that is pure mechanism: scroll/animation logic, layout structure, state handling, config. This is what gets kept as-is.

Don't assume — some "components" in a reference repo may already be gutted placeholders with nothing to copy. Say so rather than inventing content that was never there.

## Step 2 — Ask before making irreversible choices

Use `AskUserQuestion` for decisions that are expensive to get wrong later, typically:

1. **Git history** — fresh repo with no ties to the original remote, or keep the cloned history (fork-like)? Default recommendation: fresh repo, since this is becoming an independent project.
2. **Missing media** — the reference repo's images/logo/video frames belong to the original site. Default: strip them and leave a documented placeholder slot (folder + naming convention + a visible placeholder UI) rather than reusing someone else's assets or inventing fake ones.
3. **Stub sections** — if the reference repo has components that are already empty placeholders, ask whether to flesh them out with generic bracketed placeholder content (`[Primary Headline]`, `[Your Brand]`) matching the site's typical structure, or leave them empty.
4. **Brand placeholder style** — a concrete working name (e.g. the project folder's name) vs. generic `[Your Brand]`-style brackets everywhere.

## Step 3 — Strip what isn't yours to keep

- Remove `.git` and re-init fresh (per Step 2's answer) so the new project has no ties to the original remote/history.
- Remove build caches (`.next`, `dist`, `node_modules`, etc.) — never carry someone else's build output forward, and make sure `.gitignore` actually excludes it (check; reference repos sometimes commit `.next` by mistake).
- Remove the original's real media assets (photos, logo files, frame sequences) — don't keep them "just for now." If the user later supplies a zip of real assets, extract and rename to your documented convention (see Step 4).

## Step 4 — Replace content, preserve behavior

- Swap real copy for generic bracketed placeholders (`[Primary CTA]`, `[Service Name]`, `[Your Brand]`) — never invent specific marketing claims on the user's behalf.
- Leave interactive/animation logic untouched unless it's hardcoded to the missing assets (e.g. a frame count, a file extension, a filename pattern) — those need to degrade gracefully.
- For any element waiting on real media (logo, hero image, frame sequence), build a visible placeholder (dashed border box, clear instructional text) instead of a silent blank space or an infinite loading state — the user should be able to see exactly where and how to drop the real file in.
- Document the expected filename convention, count, and format for any multi-file asset slot (e.g. a `README.md` inside the target folder) so dropping in real files later requires zero code changes.

## Step 5 — Verify, don't just build

`npm run build` succeeding is not proof the site works. Also:

- Run the dev server (and `build` + `start` for a production check) and actually load the page — headless-browser screenshot if there's no display, per the `run` skill's browser-driven pattern.
- Check console/page errors, not just the HTTP status.
- Scroll/interact through the behavior that was supposedly "preserved" (e.g. a scroll-driven animation) and confirm it still functions with placeholder/missing media.
- When real assets arrive later (e.g. a zip of frames), extract them, rename to the documented convention, update any hardcoded count/extension in the code to match what was actually delivered (counts and formats from a zip often don't match the original placeholder assumption), and re-verify the same way.

## Step 6 — Don't commit unless asked

Git init is reasonable once "fresh repo" is chosen (Step 2), but leave the working tree uncommitted until the user explicitly asks for a commit — this mirrors the general rule of never committing without being asked.

## How to run this skill

1. Clone + inspect (Step 1) — build a real picture of what's mechanism vs. what's the original's content, don't guess.
2. Ask the irreversible-choice questions (Step 2) before touching git history or deleting assets.
3. Strip original IP (Step 3), replace with placeholders while preserving behavior (Step 4).
4. Verify end-to-end, visually, not just via a green build (Step 5).
5. Leave the result uncommitted (Step 6) unless told otherwise.
