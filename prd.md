📄 Product Requirements Document (PRD)

🧠 Product Name

WallFlux 

🎯 Purpose

WallFlux is a Flutter-based Android app that automatically updates the device wallpaper at user-defined intervals. Users select their preferred wallpaper niches during onboarding, and the app fetches high-quality images from Unsplash. It also allows manual wallpaper setting from a browsable grid.

👤 Target Audience

Android users who enjoy dynamic, personalized wallpapers

Users who prefer automation and minimal manual interaction

Design-conscious individuals seeking aesthetic customization

🧩 Key Features

1. Onboarding Flow

Triggered on first launch

Steps:

Welcome screen

Niche selection (multi-select from predefined categories)

Time interval selection:

Presets: 1h, 2h, 4h, 6h, 12h, Daily

Custom time: via TimePicker

Data stored locally using Hive or SharedPreferences

2. Wallpaper Grid (Homepage)

Infinite scroll using GridView.builder and pagination

Wallpapers fetched from Unsplash API based on selected niches

Tap to preview full-screen

Option to manually set wallpaper

3. Auto Wallpaper Update

Background task scheduled via android_alarm_manager_plus

Wallpaper changes at selected interval or specific time

Fetches new image from Unsplash and sets it using flutter_wallpaper_manager

Handles offline fallback using cached images

4. Settings Screen

Modify selected niches

Change time interval or custom time

Toggle auto-change on/off

View current wallpaper info (optional)

5. Favorites (Optional Enhancement)

Users can favorite wallpapers

Option to rotate wallpapers only from favorites

🛠️ Technical Requirements

Component

Technology / Package

UI Framework

Flutter

API Integration

Unsplash API via http or dio

Wallpaper Management

flutter_wallpaper_manager

Background Scheduling

android_alarm_manager_plus

Local Storage

Hive, SharedPreferences

Image Caching

cached_network_image

State Management

Provider, Riverpod, or Bloc

📱 UX Requirements

Clean, minimal UI with emphasis on image content

Responsive grid layout

Smooth transitions between onboarding, home, and settings

Feedback on wallpaper change success/failure

Dark mode support (optional)

🔐 Permissions

Internet access

Set wallpaper

Foreground service (for scheduled tasks)

Exact alarm permission (Android 12+ for custom time)

📊 Metrics for Success

Daily active users

Number of wallpapers set manually vs automatically

Most selected niches

Retention after onboarding

API usage vs cache fallback ratio

🚧 Development Phases

Phase 1: MVP

Onboarding

Wallpaper grid with infinite scroll

Manual wallpaper setting

Auto-change with preset intervals

Phase 2: Enhancements

Custom time scheduling

Favorites and offline rotation

Dynamic theming

Analytics integration