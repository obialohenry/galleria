# Galleria Photo App

## Overview
Galleria is a Flutter mobile application that allows users to capture photos, automatically save them to the device’s native      gallery under a custom album ("Galleria"), store photo metadata locally, retrieve and display stored photos in a grid format,     and prepare photos for future cloud synchronization.

This project was built as part of a technical assessment, with emphasis on code quality, architectural decisions, and problem-solving approach.

## Folder Structure

lib/
├─ config/                 # App-wide constants
│  ├─ app_colors.dart      # Color palette
│  └─ app_strings.dart     # String constants
│
├─ local_storage/           # Hive/local database related files
│  └─ photo_local_db.dart  # Photo storage and retrieval
│
├─ model/                  # Data models
│  └─ local/
│     ├─ camera_state.dart
│     ├─ dashboard_state.dart
│     ├─ dummy_data.dart
│     ├─ photo_model.dart
│     └─ photo_model.g.dart
│
├─ src/                    # Centralized imports for easier access
│  ├─ config.dart
│  ├─ model.dart
│  ├─ screens.dart
│  └─ view_model.dart
│
├─ utils/                  # Utility/helper functions
│  └─ util_functions.dart
│
├─ view/                   # UI layer
│  ├─ components/          # Reusable UI widgets (e.g., AppText)
│  └─ screens/             # Individual app screens
│
├─ view_model/             # State management using Riverpod
│  ├─ cameras_view_model.dart
│  └─ dashboard_view_model.dart
│
├─ cloud_sync/             # Cloud synchronization logic
│
└─ main.dart               # App entry point


## Features Implemented (Sprint-based)

### Sprint 1: Core UI & Local Photo Capture
This sprint focused on establishing the application foundation, core navigation, and the complete local photo capture pipeline.
#### Features Implemented
- Bottom navigation dashboard with two primary sections:
  - Take a Photo – Camera interface for capturing photos
  - Photos – In-app gallery displaying photos taken with the app

- Camera integration for photo capture

- Automatic saving of captured photos to the device’s native gallery
  - Photos are grouped under a custom album named "Galleria"

- Local persistence of photo metadata, including:
  - Date & time captured
  - Local file path
  - Sync status (default: not synced)

- Grid view display of locally saved photos

- Photo detail screen with:
  - Photo preview
  - Date & time information
  - Location address (when permission is granted)
  - Local file path
  - Manual "Sync this photo" action (UI only at this stage)

- Visual sync status indicators

#### Known Issues & Observations (Sprint 1)
The following behaviors were observed during testing and are documented for transparency:
1. Initial Photo Preview Delay (First App Launch)
  On first use of the app, when the user taps the Take Photo button and grants location permission, there is a noticeable delay     before the captured image appears in the preview screen.

2. Subsequent Photo Capture Preview Delay
  A similar short delay occurs whenever a new photo is captured, before the image is rendered on the preview screen.
  
Note: Despite this delay, the photo capture, saving process, and gallery updates work correctly.

#### Platform-Specific Notes

##### iOS (gallery_saver_plus configuration)
The gallery_saver_plus plugin requires additional iOS configuration within the Podfile to function correctly.

Because development was done on Windows, the iOS-specific Podfile setup could not be applied or tested locally. This configuration step is documented here for reviewers and future setup on macOS.

### Sprint 2 – Cloud Synchronization
This sprint focused on syncing a single image file with the cloud using Firebase (Firebase storage).
#### Feature Implemented
- "Sync this photo" action button in the photo details screen
  - Compresses an image file to 1280x720.
  - Uploads the compressed file to Firebase storage and return a cloud reference URL.
  - Display feedback to a user, throught the entire process, on the screen.

#### Platform-Specific Notes

##### iOS (Firebase configuration)
The Firebase plugins requires additional iOS configuration within the Podfile to function correctly.

Because development was done on Windows, the iOS-specific Podfile setup could not be applied or tested locally. This configuration step is documented here for reviewers and future setup on macOS.

## Tech Stack & Decisions
 - Flutter – Cross-platform mobile framework

 - State Management: Riverpod

 - Camera: camera plugin

 - Gallery Saving: gallery_saver_plus

 - Local Persistence: Hive

 - Location: geolocator

 - Reverse Geocoding: geocoding

 - Code Generation: hive_generator, build_runner

 - File System Access: path_provider

 - Date & Time Formatting: intl

 - Scan Device Gallery: photo_manager

 - ID generation: UUID

 - Camera capture sound: audioplayers

 - Required for all Firebase services: firebase_core

 - Uploading and managing files in Firebase Cloud Storage: firebase_storage

 - Anonymous authentication: firebase_auth

 - Compress image file's: flutter_image_compress

 - Checks if device has network access: connectivity_plus

 - Checks if device has internet connection: dio
  
## Next Planned Sprints

- Batch and scheduled sync

## Setup Instructions

1. Clone the repository

2. Run flutter pub get

3. Ensure camera, storage, and location permissions are granted

4. Run the app on a physical device (recommended for camera & gallery testing)

### Permissions

This app relies on multiple permissions to function correctly:

- **Camera & Audio permissions**  
  On first launch, the app will request permission to:
  - Take pictures
  - Record videos
  - Record audio  

  These permissions are required by the `camera` plugin itself and **must be accepted** for the photo capture functionality (Sprint 1) to work.

- **Media / Gallery access permission**  
  On initial installation and startup, the app will also request permission to access media on the device.

  This permission is required because:
  - Photos captured by Galleria are saved directly to a dedicated **Galleria album** on the device.
  - On app startup, the app **scans the Galleria album** and reconciles the images found there with the locally persisted photo metadata stored in Hive.
  - Without this permission, the app cannot correctly load or reconcile previously captured photos.

