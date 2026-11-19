# Web design source — pinned

The chat redesign is copied from the web project, **not** from the XD file.

```
repo    https://github.com/AlaaAsaad57/Trydos.git
branch  development      ← NOT main
```

`main` is behind: on 2026-10-28 it lagged `development` by 4344 lines inside
`components/DemoApp1` alone, and was missing nine files (ReactionSheet,
AnimatedEmoji, CategorySheet, ReminderSheet, ArchivedSheet, NewChatSheet,
PickSheet, reactionFly, useHorizontalSwipe). Building against `main` produced
a menu that does not exist in the live demo.

The live demo renders `development`: https://trydos.ramaaz.dev/sy-en/demo

## How to refresh the local copy

```
cd web_design
git fetch --depth 1 origin development
git checkout FETCH_HEAD
```

Then re-read the files you are matching. Always check the live demo page
against what you read — if they differ, the clone is stale.
