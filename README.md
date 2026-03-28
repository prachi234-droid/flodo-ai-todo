# Flodo AI Task Management App

Track B submission for the Flodo AI Flutter take-home assignment.

## What is included

- Task CRUD with local persistence
- Draft persistence for the create flow
- Search by title and filter by status
- Blocked task dependency styling
- Simulated 2-second delay on create and update with loading protection
- Stretch goal: debounced autocomplete search with title-match highlighting

## Tech choices

- Flutter + Dart
- `shared_preferences` for local persistence of tasks and drafts
- `ChangeNotifier` for app state management

## Setup

1. Install Flutter 3.22+ and confirm `flutter --version` works.
2. From the project root, run `flutter pub get`.
3. If platform folders are missing in your local clone, run `flutter create .`
4. Launch the app with `flutter run`.

## Assignment choices

- Track: B
- Stretch goal: Debounced autocomplete search with title highlight

## Notes

- The create-task form saves draft values continuously. If you close the form and reopen it, unfinished input is restored.
- Blocked tasks are visually muted until their dependency reaches `Done`.

## AI Usage Report

### Helpful prompts

- "Build a Flutter task management app architecture for local persistence, async save states, and draft recovery."
- "Design a polished task list UI with dependency-aware blocked state and debounced highlighted search."

### One AI failure and fix

- An early generated approach overcomplicated persistence with multiple stores and duplicated draft logic.
- I simplified it to a single `shared_preferences` service storing serialized tasks plus one create-form draft object, which reduced edge cases and made the save flow easier to reason about.
