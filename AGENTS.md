# AI Development Rules

These rules apply to all work in this project. Direct user instructions for a
specific task take precedence.

## Project structure

- Features: `lib/app/modules/`
- Shared widgets: `lib/app/widgets/`
- API clients: `lib/app/data/api/`
- Services: `lib/app/data/services/`
- Models: `lib/app/data/models/`
- Routes: `lib/app/routes/`
- Core constants: `lib/app/core/constants/`

Use these locations for new work. Move existing code only when the requested
change requires it; do not reorganize unrelated files.

## Change policy

- Do not scan the complete repository for small changes. Start with files
  explicitly mentioned in the prompt.
- **Graphify first:** Before reading or scanning multiple codebase files, query
  the local Graphify graph with `dart run tool/graphify.dart query "<term>"`
  or inspect `graphify-out/graph.json` to identify exact dependencies and
  consumers. If Graphify is unavailable, report that prerequisite and limit
  inspection to the named files until it is available.
- Read only direct imports, callers, and dependencies when required. Ask before
  expanding to unrelated modules.
- Modify only files required for the requested change. Use a small patch instead
  of rewriting a complete file.
- Use BLoC as the primary state-management pattern and preserve existing naming
  conventions. Do not migrate unrelated code as part of a small change.

## UI and widget policy

- Prefer `ListView`, slivers, and other scrolling list patterns for collections
  over `SingleChildScrollView` with a `Column` of repeated items.
- Check `lib/app/widgets/` for a suitable shared widget before implementing UI.
  Reuse it instead of creating a feature-local duplicate. Also check the
  feature's direct dependencies before creating a new widget.
- Keep item widgets lightweight and reusable. Use lazy builders such as
  `ListView.builder` for dynamic or potentially long lists.
- Avoid `StatefulWidget` wherever possible. Put application and feature state in
  BLoCs, and render it with `StatelessWidget`, `BlocBuilder`, or `BlocListener`.
  Use a `StatefulWidget` only for truly local widget lifecycle state that does
  not belong in a BLoC, and keep that state minimal.
- Use the shared `AppText` widget in place of Flutter's `Text` widget in new or
  modified UI. If `AppText` is absent, implement it in `lib/app/widgets/`
  before adding new UI that requires text.

## Verification

- Format only modified Dart files.
- Run analysis only on modified files or the affected feature.
- Run the smallest relevant test suite.
- Review `git diff` after implementation. If this directory has no Git
  repository, report that the diff check is unavailable.
- **Keep Graphify synchronized:** After any code change, run
  `dart run tool/graphify.dart --update` to update the knowledge graph, report,
  and visualizations. If the Graphify tool is absent, report the missing
  prerequisite; do not claim the graph was updated.
