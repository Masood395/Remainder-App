# Flutter Reminder App

A simple Flutter app that allows users to set reminders for various activities on specific days of the week. The app uses local notifications to remind users of their scheduled activities. The background of the app features a customizable image.

## Features

- **Schedule Reminders**: Users can select a day, time, and activity for which they want to set a reminder.
- **Local Notifications**: The app sends notifications at the scheduled time.
- **Customizable Background**: The background image of the app can be easily customized.

## Screenshots

![App Screenshot](assets/images/example_screenshot.png)

## Getting Started

### Prerequisites

- **Flutter**: Ensure you have Flutter installed. You can follow the official [Flutter installation guide](https://flutter.dev/docs/get-started/install).
- **Dart SDK**: Make sure Dart SDK is installed.

### Installation

1. **Clone the repository**:

    ```bash
    git clone https://github.com/Masood395/Remainder-App.git
    cd Remainder-App
    ```

2. **Install dependencies**:

    ```bash
    flutter pub get
    ```

3. **Run the app**:

    ```bash
    flutter run
    ```

### Directory Structure

```plaintext
lib/
├── main.dart        # Main entry point of the app
pubspec.yaml         # Project dependencies and assets configuration
assets/
├── images/
│   └── download.png  # Background image
└── sound/
    └── notification-5-158190.mp3  # Custom notification sound
