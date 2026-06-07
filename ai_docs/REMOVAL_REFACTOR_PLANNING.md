# Planning Removal Refactors

When a plan removes a type, enum, or field from a domain model (freezed/TypeScript interface), all consumers break the moment the model changes. Don't split "remove from model" and "fix consumers" into separate stages — they can't be verified independently (`flutter analyze` / `npm run build` will fail).

## Stage structure

1. **Remove & fix (single stage):** Delete the type/fields from the domain model AND fix all compile errors across consumers (data, presentation, routing, Cloud Functions). This is one atomic unit — it either compiles or it doesn't.
2. **Cleanup stage:** Delete dead code files, remove localization keys, regenerate codegen.
3. **Verification stage:** Final grep for stale references + analyze + build.

This applies equally to Dart freezed models and TypeScript interfaces — if `ItemDoc` loses a field, every `.ts` file that reads that field must be fixed in the same stage.

## Origin

Learned during the `005-refactor-business-account` feature (2026-05-23). The plan had 7 stages split by layer (domain → data → presentation → routing → cleanup → functions → verify). In practice, Stage 1 (domain model deletion) cascaded compile errors into all other layers, forcing Stages 2–4 and 6 to be completed immediately. The remaining `/implement` calls were no-ops.
