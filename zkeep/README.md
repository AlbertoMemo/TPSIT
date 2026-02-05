# am043 Todo List

A Flutter todo list app inspired by Google Keep, featuring card-based organization.

## Features

- **Card-based organization**: Create multiple todo cards, each containing its own list of tasks
- **Simple interactions**:
  - Tap on a todo item to mark it as complete/incomplete
  - Long press on a todo item to delete it
  - Click the X button to delete an entire card
- **Clean UI**: Minimal design with a grid layout for easy viewing of multiple cards

## How to Use

1. **Create a new card**: Click the floating action button (+) at the bottom right
2. **Add todos to a card**: Click the "add todo" button inside any card
3. **Mark as complete**: Tap on any todo item to toggle completion status
4. **Delete a todo**: Long press on any todo item
5. **Delete a card**: Click the X button in the top right corner of any card

## Project Structure

lib/
-main.dart       # App entry point and home page
-model.dart      # Data models (TodoCard and Todo)
-notifier.dart   # State management with ChangeNotifier
-widgets.dart    # UI components (TodoCardWidget and TodoItem)

## Dependencies

- `flutter/material.dart`
- `provider` - State management

## Getting Started

1. Make sure you have Flutter installed
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Technical Details

- **State Management**: Uses Provider with ChangeNotifier pattern
- **Layout**: GridView with 2 columns for card display
- **Theme**: Red color scheme
