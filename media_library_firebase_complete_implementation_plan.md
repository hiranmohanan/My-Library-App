# Personal Media Library App — Complete Firebase + Flutter Implementation Plan

## 1. Project Overview

Build a personal Media Library mobile application for managing:

- Movies
- TV Series
- Books

The application must be built with:

- Flutter
- Dart
- BLoC
- Clean Architecture
- Feature-first presentation architecture
- Firebase Authentication
- Firebase Realtime Database
- Local persistent caching
- External media APIs
- Material 3
- Selective iOS/Cupertino components
- Light and Dark themes
- Offline-first behavior
- Scalable service abstractions

The application should be designed from the beginning so that additional features, services, APIs, notifications, analytics, storage providers, and synchronization mechanisms can be added without restructuring the entire project.

---

# 2. Core Product Strategy

The application must be offline-aware rather than offline-blocking.

The core strategy is:

```text
Flutter UI
    ↓
BLoC
    ↓
Use Case
    ↓
Repository
    ↓
┌───────────────────────┐
│                       │
Local Data          Remote Data
    │                    │
Local DB          Firebase / APIs
```

The application should prefer local cached data for fast display.

When internet connectivity exists:

```text
Local Cache
    ↓
Display immediately
    ↓
Remote refresh
    ↓
Update local cache
    ↓
Emit updated UI
```

When offline:

```text
Flutter
    ↓
Repository
    ↓
Local Cache
    ↓
UI
```

The application should not show a blocking offline screen.

Users should still be able to:

- Open the application
- Browse cached media
- Search their local library
- Filter cached media
- Sort cached media
- View previously cached details
- Change local UI preferences
- Navigate normally

Operations requiring internet should communicate that internet access is required.

Example:

> You're offline. Connect to the internet to perform this action.

---

# 3. Technology Stack

## Frontend

- Flutter
- Dart
- Material 3
- Cupertino components where appropriate
- BLoC
- Clean Architecture
- Feature-first presentation

## Backend

Firebase:

- Firebase Authentication
- Firebase Realtime Database
- Firebase Storage abstraction for future use
- Firebase Cloud Messaging — future
- Firebase Crashlytics — future
- Firebase Analytics — future
- Firebase Remote Config — future

## Authentication

Initial authentication:

- Phone number
- OTP
- Firebase Authentication

Email/password authentication is not required for the initial version.

## Database

Firebase Realtime Database.

## Local Storage

Use a local persistent storage/database abstraction.

The implementation must remain replaceable.

The local layer should support:

- Save
- Read
- Update
- Delete
- Clear
- Query/filter where practical
- Cache refresh
- Future synchronization metadata

Firebase Realtime Database's own offline persistence can be used as an additional mechanism, but the application should maintain its own local cache/data layer for better control.

## External APIs

Movies and TV:

- TMDB

Books:

- Google Books API

Images:

- Continue using the existing external image/API source initially.

Firebase Storage should be treated as a future replacement/extension, not required for the first implementation.

---

# 4. Final Architecture

```text
                         MEDIA LIBRARY APP
                                │
                         Flutter + Dart
                                │
                    BLoC + Clean Architecture
                                │
        ┌───────────────────────┼────────────────────────┐
        │                       │                        │
   Presentation             Domain                  Data
        │                       │                        │
 Feature-first BLoCs       Entities/UseCases       Repositories
        │                       │                        │
        └───────────────────────┼────────────────────────┘
                                │
                   ┌────────────┴────────────┐
                   │                         │
              Local Storage              Firebase
                   │                         │
          Cached Media / State        ┌──────┼─────────┐
                                      │      │         │
                                    Auth   RTDB    Future Storage
                                      │      │
                                      │      │
                                      └──────┼─────────┐
                                             │         │
                                       Firebase      External
                                       Services       APIs
                                             │
                                   ┌─────────┴─────────┐
                                   │                   │
                                  TMDB             Google Books
```

Dependency direction:

```text
Presentation
      ↓
Domain
      ↓
Data
      ↓
Infrastructure
```

Never allow:

```text
Widget → Firebase
Widget → HTTP
BLoC → Firebase
BLoC → Local Database
```

Instead:

```text
Widget
   ↓
BLoC
   ↓
UseCase
   ↓
Repository
   ↓
DataSource
   ↓
Firebase / API / Local Storage
```

---

# 5. Firebase Architecture

## 5.1 Firebase Authentication

Use Firebase Phone Authentication.

Flow:

```text
User
 ↓
Enter phone number
 ↓
Firebase Auth
 ↓
OTP
 ↓
Verify OTP
 ↓
Firebase User
 ↓
Create/load profile
 ↓
Home
```

Create an abstraction:

```text
AuthService
 ├── sendOtp()
 ├── verifyOtp()
 ├── signOut()
 ├── getCurrentUser()
 ├── isAuthenticated()
 └── authStateChanges()
```

BLoCs must never directly call `FirebaseAuth.instance`.

Preferred flow:

```text
AuthBloc
   ↓
VerifyOtpUseCase
   ↓
AuthRepository
   ↓
FirebaseAuthService
   ↓
Firebase Authentication
```

---

# 6. Firebase Realtime Database Structure

Recommended structure:

```text
users/
    {userId}/
        profile/
            name
            phoneNumber
            createdAt
            updatedAt

        preferences/
            theme
            language

        media/
            {mediaEntryId}/
                mediaType
                externalSource
                externalId
                title
                posterUrl
                description
                language
                releaseDate
                status
                rating
                notes
                createdAt
                updatedAt
```

Example:

```text
users
 └── abc123
      ├── profile
      │    ├── name
      │    └── phoneNumber
      │
      ├── preferences
      │    └── theme
      │
      └── media
           ├── movie_001
           │    ├── title
           │    ├── status
           │    └── posterUrl
           │
           └── book_001
                ├── title
                ├── status
                └── posterUrl
```

The application should not store the entire TMDB or Google Books databases.

Only store media selected by the user and the information required by the application.

---

# 7. Firebase Realtime Database Security Rules

The basic security principle is:

> An authenticated user can only access their own data.

Conceptually:

```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "auth != null && auth.uid === $uid",
        ".write": "auth != null && auth.uid === $uid"
      }
    }
  }
}
```

This is only the starting point.

Production rules should additionally validate:

- Authentication
- Ownership
- Media type
- External source
- External ID
- Required title
- Allowed status
- Rating range
- Data types
- Immutable ownership

Do not trust Flutter-side validation as a security boundary.

Firebase rules must enforce the actual database security model.

---

# 8. Local Storage Strategy

Use a local data abstraction.

```text
LocalStorageService
```

Recommended architecture:

```text
MediaRepository
       │
       ├───────────────┐
       ↓               ↓
LocalDataSource    RemoteDataSource
       │               │
       ↓               ↓
 Local DB          Firebase RTDB
```

The repository controls whether data comes from:

- Local storage
- Firebase
- External APIs

The UI should not know where the data came from.

---

# 9. Offline-First Strategy

## Read

```text
Open Library
     ↓
Read local cache
     ↓
Display cached data
     ↓
Check connectivity
     ↓
If online:
     ↓
Refresh from Firebase
     ↓
Update local cache
     ↓
Emit updated state
```

## Write

Initial MVP strategy:

```text
Create/update/delete
       ↓
Check connectivity
       ↓
Online?
       ├── Yes → Firebase → Local cache
       │
       └── No → Show offline-aware message
```

A full offline write queue can be implemented later.

Do not overcomplicate V1 unless true offline write capability becomes a product requirement.

---

# 10. Offline UX

Do not disable the entire app.

Show a subtle application-wide awareness banner when appropriate:

```text
┌──────────────────────────────┐
│ Offline                      │
│ Showing cached library       │
└──────────────────────────────┘
```

For operations that require internet:

```text
Internet connection required.
Connect to the internet to perform this action.
```

Examples:

- Search TMDB
- Search Google Books
- Add a new external media item
- Sync Firebase
- Authentication
- OTP verification

Cached operations should remain available.

---

# 11. API Architecture

The external API layer must be standardized.

Recommended:

```text
lib/core/network/
    api_client.dart
    api_exception.dart
    api_response.dart
    network_info.dart
    api_headers.dart
    api_constants.dart
```

Then:

```text
lib/data/datasources/remote/
    tmdb_remote_data_source.dart
    google_books_remote_data_source.dart
```

Flow:

```text
TMDB
 ↓
ApiClient
 ↓
TmdbRemoteDataSource
 ↓
MediaRepository
 ↓
UseCase
 ↓
BLoC
 ↓
UI
```

Same pattern for Google Books.

---

# 12. API Client Responsibilities

Create one standardized API client.

Responsibilities:

- GET
- POST
- PUT
- DELETE
- Headers
- Timeout
- Retry
- Response validation
- Error conversion
- Logging
- Future interceptors
- API version handling

Do not scatter:

```dart
http.get(...)
```

throughout BLoCs or widgets.

---

# 13. External API Services

## TMDB

Use TMDB for:

- Movies
- TV Series
- Posters
- Backdrops
- Titles
- Language
- Genres
- Release dates
- Overview
- Ratings
- Other required metadata

## Google Books

Use Google Books for:

- Books
- Title
- Authors
- Cover
- Publisher
- Publication date
- Description
- Language
- ISBN
- Page count
- Categories

API keys/configuration must be centralized.

Never hardcode private secrets in source code.

If a future API requires a private secret, move the call behind a Firebase Cloud Function or another server-side mechanism.

---

# 14. Image Architecture

Current implementation:

```text
External API
     ↓
posterUrl
     ↓
Flutter
```

Do not make the current image implementation dependent on Firebase Storage.

Prepare an abstraction:

```text
ImageSourceService
```

Possible sources:

```text
external
firebase
```

Current:

```text
external
```

Future:

```text
firebase
```

The UI must not care where the image comes from.

---

# 15. Firebase Service Layer

Create Firebase services early.

```text
lib/core/services/firebase/
    firebase_auth_service.dart
    firebase_database_service.dart
    firebase_storage_service.dart
```

Responsibilities:

### FirebaseAuthService

- Send OTP
- Verify OTP
- Sign out
- Current user
- Authentication state

### FirebaseDatabaseService

- Read
- Write
- Update
- Delete
- Stream/listen
- Query

### FirebaseStorageService

Create the abstraction now, even if it is not used initially.

Future responsibilities:

- Upload image
- Delete image
- Get download URL
- Replace image

---

# 16. Core Service Layer

Create service abstractions early so the application can grow.

```text
lib/core/services/

    firebase/
        firebase_auth_service.dart
        firebase_database_service.dart
        firebase_storage_service.dart

    network/
        network_info_service.dart

    storage/
        local_storage_service.dart

    notification/
        local_notification_service.dart

    device/
        device_info_service.dart

    permission/
        permission_service.dart

    logging/
        logger_service.dart

    lifecycle/
        app_lifecycle_service.dart
```

Do not implement unnecessary complexity just because the abstraction exists.

The purpose is to establish clean extension points.

---

# 17. Local Notification Service

Define at the beginning.

```text
LocalNotificationService
 ├── initialize()
 ├── requestPermission()
 ├── show()
 ├── cancel()
 └── cancelAll()
```

Future use cases:

- Watch reminders
- Reading reminders
- Notifications
- Sync events
- Background events

---

# 18. BLoC Architecture

Every feature should separate:

```text
feature_bloc.dart
feature_event.dart
feature_state.dart
```

Use Dart `part` / `part of`.

Example:

```dart
// media_bloc.dart

part 'media_event.dart';
part 'media_state.dart';

class MediaBloc extends Bloc<MediaEvent, MediaState> {
  MediaBloc({
    required GetMediaUseCase getMedia,
  }) : _getMedia = getMedia,
       super(const MediaInitial()) {
    on<LoadMedia>(_onLoadMedia);
  }
}
```

Event:

```dart
part of 'media_bloc.dart';

sealed class MediaEvent {}

class LoadMedia extends MediaEvent {}
```

State:

```dart
part of 'media_bloc.dart';

sealed class MediaState {}

class MediaInitial extends MediaState {}

class MediaLoading extends MediaState {}

class MediaLoaded extends MediaState {}

class MediaFailure extends MediaState {}
```

Maintain this structure consistently.

---

# 19. Feature-First Presentation

Recommended feature organization:

```text
features/
    authentication/
    onboarding/
    home/
    library/
    media_search/
    media_details/
    add_media/
    profile/
    settings/
```

Example:

```text
features/library/

    presentation/
        bloc/
            library_bloc.dart
            library_event.dart
            library_state.dart

        pages/
            library_page.dart

        widgets/
            media_card.dart
            media_filter.dart
            media_status_chip.dart
            library_empty_state.dart
```

The presentation layer should be organized by feature rather than globally by widget type.

---

# 20. Complete Flutter Folder Structure

```text
lib/
│
├── main.dart
│
├── app/
│   ├── app.dart
│   ├── app_router.dart
│   ├── app_theme.dart
│   └── app_bloc_observer.dart
│
├── core/
│   ├── bootstrap/
│   │   └── app_bootstrap.dart
│   │
│   ├── constants/
│   │
│   ├── errors/
│   │
│   ├── extensions/
│   │
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── api_exception.dart
│   │   ├── api_response.dart
│   │   ├── api_constants.dart
│   │   └── network_info.dart
│   │
│   ├── services/
│   │   ├── firebase/
│   │   │   ├── firebase_auth_service.dart
│   │   │   ├── firebase_database_service.dart
│   │   │   └── firebase_storage_service.dart
│   │   │
│   │   ├── network/
│   │   │   └── network_info_service.dart
│   │   │
│   │   ├── storage/
│   │   │   └── local_storage_service.dart
│   │   │
│   │   ├── notification/
│   │   │   └── local_notification_service.dart
│   │   │
│   │   ├── device/
│   │   │   └── device_info_service.dart
│   │   │
│   │   ├── permission/
│   │   │   └── permission_service.dart
│   │   │
│   │   ├── logging/
│   │   │   └── logger_service.dart
│   │   │
│   │   └── lifecycle/
│   │       └── app_lifecycle_service.dart
│   │
│   ├── storage/
│   │
│   ├── utils/
│   │
│   └── widgets/
│
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── media_local_data_source.dart
│   │   │   └── profile_local_data_source.dart
│   │   │
│   │   └── remote/
│   │       ├── firebase_media_data_source.dart
│   │       ├── tmdb_remote_data_source.dart
│   │       └── google_books_remote_data_source.dart
│   │
│   ├── models/
│   │   ├── media_model.dart
│   │   └── profile_model.dart
│   │
│   ├── repositories/
│   │   ├── auth_repository_impl.dart
│   │   └── media_repository_impl.dart
│   │
│   └── mappers/
│       ├── media_mapper.dart
│       └── profile_mapper.dart
│
├── domain/
│   ├── entities/
│   │   ├── media_entity.dart
│   │   └── profile_entity.dart
│   │
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   └── media_repository.dart
│   │
│   └── usecases/
│       ├── authentication/
│       ├── media/
│       └── profile/
│
└── features/
    ├── authentication/
    ├── onboarding/
    ├── home/
    ├── library/
    ├── media_search/
    ├── media_details/
    ├── add_media/
    ├── profile/
    └── settings/
```

Do not create empty files unnecessarily. Create files when their corresponding implementation is actually needed.

---

# 21. Domain Entity

The domain must remain independent of Firebase.

Example:

```text
MediaEntity

id
mediaType
externalSource
externalId
title
posterUrl
description
language
releaseDate
status
rating
notes
createdAt
updatedAt
```

The domain should not know whether the source is:

- Firebase
- TMDB
- Google Books
- SQLite
- Hive
- another API

---

# 22. Data Models

Firebase and API responses should be converted into models.

Architecture:

```text
Firebase JSON
     ↓
MediaModel
     ↓
MediaMapper
     ↓
MediaEntity
     ↓
UseCase
     ↓
BLoC
     ↓
UI
```

Likewise:

```text
TMDB JSON
     ↓
TMDB Model
     ↓
Mapper
     ↓
Domain Entity
```

Never leak raw Firebase JSON into the UI.

---

# 23. Media Status

Movies and Series:

```text
wantToWatch
watching
watched
dropped
```

Books:

```text
wantToRead
reading
completed
dropped
```

Use enums/domain representations rather than arbitrary strings throughout the application.

Map them to Firebase strings at the data boundary.

---

# 24. Media Entity Fields

Recommended:

```text
id
mediaType
externalSource
externalId
title
posterUrl
description
language
releaseDate
status
rating
notes
createdAt
updatedAt
```

Future fields can include:

```text
genres
authors
publisher
isbn
pageCount
backdropUrl
runtime
episodeCount
seasonCount
syncStatus
lastSyncedAt
```

Only add them when the actual feature requires them.

---

# 25. Home Screen

Expected layout:

```text
Good morning

Your Library
────────────────────

Movies       24
Series       12
Books        18

Continue Watching
────────────────────

[Card] [Card] [Card]

Recently Added
────────────────────

[Card] [Card] [Card]

Quick Actions
────────────────────

+ Add Movie
+ Add Series
+ Add Book
```

Use actual user data.

Do not hardcode fake statistics in production.

---

# 26. Library Screen

Top:

```text
Library

[All] [Movies] [Series] [Books]

Search your library...
```

Filters:

```text
Status
Rating
Date Added
A-Z
```

Display modes:

- Grid
- List

Media card:

```text
Poster
Title
Type
Status
Rating
```

---

# 27. Search Screen

Search external APIs.

```text
Search

[ Movies | Series | Books ]

Search...
```

Movies and series:

```text
TMDB
```

Books:

```text
Google Books
```

Result:

```text
Poster
Title
Year / publication date
Type
Rating where available
Add to Library
```

If offline:

```text
External search is unavailable while offline.
```

---

# 28. Media Details Screen

Show:

```text
Large poster

Title

Media type
Release/publication date

Rating

Overview

Genres/categories

Authors for books

Status

User rating

Notes
```

Actions:

```text
Add to Library
Change Status
Edit
Delete
```

---

# 29. Add Media Flow

```text
Tap +
 ↓
Choose Media Type
 ↓
Movie / Series / Book
 ↓
Search external API
 ↓
Select result
 ↓
Preview
 ↓
Select status
 ↓
Save
```

If the user is offline:

```text
You're offline.
Connect to the internet to search and add new media.
```

The rest of the application remains usable.

---

# 30. Authentication UI

Flow:

```text
Welcome
   ↓
Phone Number
   ↓
OTP Verification
   ↓
Profile Setup
   ↓
Home
```

Phone screen:

```text
Welcome back

Enter your mobile number

+91 | __________

[ Continue ]
```

OTP:

```text
Verify your number

Enter the 6-digit code

● ● ● ● ● ●

Didn't receive code?
Resend

[ Verify ]
```

---

# 31. Profile

Display:

```text
Profile

Avatar

Name
Phone

Statistics

Movies
Series
Books

Settings
About
Logout
```

---

# 32. Settings

Appearance:

```text
Theme

Light
Dark
System
```

Prepare future sections:

```text
Notifications
Language
Data
About
```

Theme selection should be persisted locally.

---

# 33. Theme

Use Material 3.

Primary visual identity:

- White
- Black
- Gray shades

Light:

```text
Background       #FFFFFF
Primary Text     #111111
Secondary Text   #666666
Card             #F7F7F7
Border           #E5E5E5
Primary          #111111
On Primary       #FFFFFF
```

Dark:

```text
Background       #000000
Primary Text     #FFFFFF
Secondary Text   #A0A0A0
Card             #111111
Border           #292929
Primary          #FFFFFF
On Primary       #000000
```

Use semantic Material 3 color roles instead of hardcoding colors throughout widgets.

---

# 34. Material 3 + Cupertino

Material 3 should be the primary design system.

Use Cupertino components selectively for platform-aware interactions:

- CupertinoSwitch
- CupertinoDatePicker
- CupertinoActionSheet
- iOS-style segmented controls
- Platform-specific interaction patterns

Do not make Android and iOS look like unrelated applications.

Maintain one visual design language.

---

# 35. Main Navigation

Recommended:

```text
Home
Library
Search
Profile
```

Example:

```text
┌───────────────────────────────┐
│                               │
│          Page Content         │
│                               │
│                               │
├───────────────────────────────┤
│ Home Library Search Profile   │
└───────────────────────────────┘
```

Add can be a prominent action from Library/Search rather than a separate fifth navigation item.

---

# 36. Loading States

Every feature should support explicit states:

```text
Initial
Loading
Success
Empty
Failure
Offline
```

Example:

```text
LibraryInitial
LibraryLoading
LibraryLoaded
LibraryEmpty
LibraryFailure
LibraryOffline
```

Use skeleton loading where appropriate.

---

# 37. Error Architecture

Create:

```text
AppException
 ├── NetworkException
 ├── AuthenticationException
 ├── FirebaseException
 ├── ApiException
 ├── CacheException
 ├── ValidationException
 └── UnknownException
```

Technical exceptions must be converted into user-friendly messages.

Never expose raw Firebase/API exceptions to users.

---

# 38. Dependency Injection

Dependencies should be created outside BLoCs.

Example:

```text
main()
 ↓
AppBootstrap
 ↓
Services
 ↓
DataSources
 ↓
Repositories
 ↓
UseCases
 ↓
BLoCs
 ↓
UI
```

Do not instantiate repositories directly inside BLoCs.

Bad:

```dart
final repository = MediaRepositoryImpl();
```

Better:

```dart
MediaBloc(
  getMediaUseCase: getMediaUseCase,
)
```

---

# 39. Application Bootstrap

Create:

```text
core/bootstrap/app_bootstrap.dart
```

Responsibilities:

```text
initializeFirebase()
initializeLocalStorage()
initializeNotifications()
initializeNetworkServices()
initializeDependencies()
```

Keep `main.dart` minimal.

Expected startup:

```text
main()
 ↓
WidgetsFlutterBinding.ensureInitialized()
 ↓
AppBootstrap
 ↓
Firebase.initializeApp()
 ↓
Local storage initialization
 ↓
Notification service initialization
 ↓
Dependency injection
 ↓
runApp()
```

---

# 40. Figma Strategy

Start the UI design before implementation.

Create these Figma pages:

```text
01 — Foundations
02 — Components
03 — Authentication
04 — Home
05 — Library
06 — Search
07 — Media Details
08 — Add Media
09 — Profile
10 — Settings
11 — States
12 — Responsive
```

Design both:

- Light theme
- Dark theme

---

# 41. Figma Foundations

Define:

- Color tokens
- Typography
- Spacing
- Border radius
- Elevation
- Icons
- Component states

Use an 8px spacing system.

Recommended card radius:

```text
12px – 16px
```

Prioritize readability and accessibility.

---

# 42. Figma Components

Create reusable:

- Primary Button
- Secondary Button
- Text Field
- Search Field
- Filter Chip
- Status Chip
- Media Card
- Poster Card
- Rating Component
- Bottom Navigation
- App Bar
- Dialog
- Bottom Sheet
- Snackbar
- Loading Skeleton
- Empty State
- Error State
- Offline Banner
- Segmented Control
- Toggle
- List Tile
- Profile Tile

---

# 43. Figma Complete AI Prompt

Use the following as the master prompt for Figma AI/Figma Make:

```text
Create a complete mobile application UI design for a personal Media Library application.

The application manages Movies, TV Series, and Books in a personal library.

Design style:
- Minimal
- Modern
- Professional
- Premium but simple
- Developer-oriented
- Clean Material 3 foundation
- Black and white visual identity
- Strong typography
- Subtle borders
- Rounded cards
- Minimal shadows
- No excessive gradients
- No excessive glassmorphism
- No unnecessary decorative elements

The application must support Light Mode and Dark Mode.

LIGHT THEME:
- White primary background
- Black primary text
- Dark gray secondary text
- Very light gray cards
- Light gray borders
- Black primary buttons
- White button text

DARK THEME:
- Black primary background
- White primary text
- Gray secondary text
- Very dark gray cards
- Dark gray borders
- White primary buttons
- Black button text

Use Material 3 design principles.

Use iOS-inspired components selectively:
- Cupertino-style switches
- Cupertino-style date selection
- iOS-style action sheets
- Platform-aware interaction patterns

Keep one unified design language.

Create these Figma pages:

1. Foundations
2. Components
3. Authentication
4. Home
5. Library
6. Search
7. Media Details
8. Add Media
9. Profile
10. Settings
11. Loading States
12. Empty States
13. Error States
14. Offline States
15. Light Theme
16. Dark Theme

FOUNDATIONS:
Create:
- Color tokens
- Typography scale
- Spacing scale
- Border radius
- Elevation
- Icons
- Component states

COMPONENTS:
Create reusable:
- Primary button
- Secondary button
- Text field
- Search field
- Filter chip
- Status chip
- Media card
- Poster card
- Rating component
- Bottom navigation
- App bar
- Dialog
- Bottom sheet
- Snackbar
- Loading skeleton
- Empty state
- Error state
- Offline banner
- Segmented control
- Toggle
- List tile
- Profile tile

AUTHENTICATION:

Welcome:
- App logo
- App name
- Short description
- Continue button

Phone Authentication:
- Phone number field
- Country code
- Continue button
- Privacy information

OTP Verification:
- Six digit OTP input
- Resend OTP
- Countdown
- Verify button

Profile Setup:
- Name
- Optional profile image
- Continue

HOME:

Header:
- Greeting
- Profile icon

Statistics:
- Movies
- Series
- Books

Sections:
- Continue Watching
- Continue Reading
- Recently Added

Quick actions:
- Add Movie
- Add Series
- Add Book

LIBRARY:

Header:
Library

Search field:
Search your library

Category tabs:
- All
- Movies
- Series
- Books

Filters:
- Status
- Rating
- Added date
- Alphabetical

Display:
- Grid view
- List view

Media cards:
- Poster
- Title
- Type
- Status
- Rating

SEARCH:

Header:
Search

Media type selector:
- Movies
- Series
- Books

External sources:
- TMDB for movies and TV series
- Google Books for books

Search results:
- Poster
- Title
- Year/publication date
- Type
- Rating where available
- Add button

MEDIA DETAILS:

Show:
- Large poster
- Title
- Media type
- Release/publication date
- Rating
- Description
- Genres/categories
- Authors for books
- Status
- User rating
- Notes

Actions:
- Add to library
- Change status
- Edit
- Delete

ADD MEDIA:

Flow:
Choose media type
→ Search
→ Results
→ Select media
→ Preview
→ Select status
→ Save

MOVIES/SERIES statuses:
- Want to Watch
- Watching
- Watched
- Dropped

BOOK statuses:
- Want to Read
- Reading
- Completed
- Dropped

PROFILE:

Show:
- Avatar
- Name
- Phone
- Library statistics
- Settings
- About
- Logout

SETTINGS:

Appearance:
- Light
- Dark
- System

Prepare sections for:
- Notifications
- Language
- Data
- About

OFFLINE STATE:

Do not block the entire application.

Show:
"You're offline. Showing cached data."

For online-only actions:
"You're offline. Connect to the internet to perform this action."

LOADING:
Use skeleton loaders where appropriate.

EMPTY:
Create meaningful empty states for:
- Empty library
- No movies
- No series
- No books
- No search results

ERROR:
Create:
- Network error
- Firebase error
- API error
- Authentication error
- Generic error

RESPONSIVE:
Design for:
- Small mobile
- Standard mobile
- Large mobile
- Tablet

Use an 8px spacing system.

Use consistent 12–16px card radius.

Maintain high accessibility contrast.

Use semantic hierarchy.

The final result should look like a production-ready personal media management application, not a generic UI template.
```

---

# 44. Development Phases

## Phase 0 — Product Definition

Deliverables:

- Product requirements
- Feature list
- Navigation
- Data model
- Offline strategy
- Firebase architecture
- API strategy
- Figma plan

Do not start feature coding until the architecture is approved.

---

## Phase 1 — Figma

Create:

- Design system
- Components
- Authentication
- Home
- Library
- Search
- Details
- Add
- Profile
- Settings
- Loading states
- Empty states
- Error states
- Offline states
- Light mode
- Dark mode

---

## Phase 2 — Flutter Foundation

Implement:

- Flutter project
- Material 3
- Theme
- Light/dark/system theme
- Routing
- Core constants
- Error system
- Logger
- Dependency injection
- App bootstrap
- Basic reusable UI components

Do not implement business features yet.

---

## Phase 3 — Firebase Foundation

Configure:

- Firebase project
- Android Firebase configuration
- iOS Firebase configuration
- Firebase Authentication
- Realtime Database
- Firebase rules

Implement:

```text
FirebaseAuthService
FirebaseDatabaseService
FirebaseStorageService
```

---

## Phase 4 — Authentication

Implement:

- Phone number
- OTP
- Authentication state
- Session persistence
- Logout
- Profile creation

Create:

```text
AuthBloc
AuthEvent
AuthState
```

---

## Phase 5 — Local Storage

Implement:

```text
LocalStorageService
MediaLocalDataSource
ProfileLocalDataSource
```

Support:

- Save
- Read
- Update
- Delete
- Clear

Test the cache independently.

---

## Phase 6 — Network/API Foundation

Implement:

```text
ApiClient
NetworkInfo
ApiException
Retry
Timeout
Response parsing
```

Then:

```text
TmdbRemoteDataSource
GoogleBooksRemoteDataSource
```

---

## Phase 7 — Domain Layer

Create:

```text
MediaEntity
ProfileEntity
MediaRepository
AuthRepository
```

Use cases:

```text
GetLibrary
SearchMovies
SearchSeries
SearchBooks
AddMedia
UpdateMedia
DeleteMedia
GetMediaDetails
UpdateStatus
UpdateRating
UpdateNotes
```

---

## Phase 8 — Repository Layer

Implement:

```text
AuthRepositoryImpl
MediaRepositoryImpl
```

Repositories coordinate:

```text
Local
Remote
```

They decide how to retrieve and persist data.

---

## Phase 9 — BLoCs

Create:

```text
AuthBloc
HomeBloc
LibraryBloc
SearchBloc
MediaDetailsBloc
AddMediaBloc
ProfileBloc
SettingsBloc
```

Every BLoC uses:

```text
bloc.dart
event.dart
state.dart
```

with `part` and `part of`.

---

## Phase 10 — UI Implementation

Convert Figma into Flutter in this order:

```text
App Shell
 ↓
Authentication
 ↓
Home
 ↓
Library
 ↓
Search
 ↓
Media Details
 ↓
Add Media
 ↓
Profile
 ↓
Settings
```

Do not build everything simultaneously.

---

## Phase 11 — Offline

Implement:

- Network awareness
- Cached library
- Offline banner
- Online-only operation handling
- Cache refresh
- Reconnect handling

Test using airplane mode.

---

## Phase 12 — Polish

Implement:

- Skeleton loading
- Empty states
- Error states
- Animations
- Accessibility
- Keyboard handling
- Responsive layouts
- Android behavior
- iOS behavior
- Theme transitions
- Image loading/error states

---

## Phase 13 — Testing

Test:

```text
Fresh installation
Returning user
Phone authentication
OTP
Logout
Network failure
Firebase failure
API failure
Offline mode
Reconnect
Empty library
Large library
Duplicate media
Invalid input
Delete
Update
```

Unit tests:

- Use cases
- Repositories
- Mappers
- Validators
- Status logic

BLoC tests:

```text
Event → State
```

Integration tests:

- Authentication
- Add media
- Edit media
- Delete media
- Offline
- Reconnect

---

## Phase 14 — Production Readiness

Review:

- Firebase rules
- API configuration
- API key exposure
- Error handling
- Logging
- Crash handling
- Release configuration
- Android signing
- iOS signing
- Privacy policy
- Terms
- Store metadata

---

# 45. Synchronization Strategy

Initial MVP:

```text
READ:
Local first
   ↓
Firebase refresh
   ↓
Local update
```

WRITE:

```text
Online
 ↓
Firebase
 ↓
Local update
```

DELETE:

```text
Firebase
 ↓
Local delete
```

Later:

```text
Local
  ↕
Repository
  ↕
Pending Operations Queue
  ↕
Firebase
```

Possible future sync status:

```text
synced
pending
failed
```

and:

```text
lastSyncedAt
```

Do not implement a complex synchronization queue unless required.

---

# 46. Duplicate Media Handling

The database should prevent duplicate user entries logically.

Use:

```text
userId
externalSource
externalId
```

as the identity combination.

Examples:

```text
user123 + tmdb + 12345
user123 + google_books + abc123
```

Before adding media:

```text
Check local cache
 ↓
Check Firebase if online
 ↓
If duplicate:
    Show "Already in your library"
```

---

# 47. Security Rules

Security must exist at multiple levels.

## Flutter

- Input validation
- Safe API configuration
- No private secrets

## Firebase

- Authentication required
- User ownership rules
- Field validation
- Allowed values
- Database validation

## API

- Timeouts
- Retry limits
- Error handling
- Response validation

Never depend on UI restrictions for security.

---

# 48. API Key Strategy

Centralize configuration.

Example concept:

```text
AppConfig
 ├── tmdbBaseUrl
 ├── tmdbApiKey
 └── googleBooksBaseUrl
```

Never scatter keys across:

```text
Widgets
BLoCs
Repositories
Models
```

If a future credential is truly private:

```text
Flutter
 ↓
Firebase Cloud Function
 ↓
Private API
```

---

# 49. Service Extensibility

The architecture must leave room for:

```text
Firebase Storage
Firebase Messaging
Firebase Analytics
Firebase Crashlytics
Remote Config
Background Sync
Advanced Notifications
Offline Write Queue
Additional Media APIs
Additional Authentication Methods
```

without restructuring the presentation/domain layers.

---

# 50. AI Development Strategy

The application will be developed with AI coding agents.

Do not ask an AI agent:

> Build the entire application.

Instead divide work into small implementation tasks.

Example sequence:

```text
Task 01
Create Flutter foundation.

Task 02
Implement theme system.

Task 03
Implement routing.

Task 04
Implement Firebase initialization.

Task 05
Implement FirebaseAuthService.

Task 06
Implement phone authentication.

Task 07
Implement local storage abstraction.

Task 08
Implement API client.

Task 09
Implement TMDB service.

Task 10
Implement Google Books service.

Task 11
Implement media domain.

Task 12
Implement media repository.

Task 13
Implement LibraryBloc.

Task 14
Implement Library UI.

...
```

After each major task:

- Run analyzer
- Run tests
- Build
- Review architecture
- Fix regressions

---

# 51. AI Coding Rules

The coding agent must follow these rules:

1. Use Flutter and Dart.
2. Use BLoC.
3. Use Clean Architecture.
4. Use feature-first presentation.
5. Keep BLoC, event and state in separate files.
6. Use `part` / `part of`.
7. Do not call Firebase directly from widgets.
8. Do not call HTTP directly from BLoCs.
9. Use repositories.
10. Use use cases.
11. Use data sources.
12. Keep domain independent of Firebase.
13. Keep API services centralized.
14. Keep Firebase services centralized.
15. Use local caching.
16. Design for offline-first behavior.
17. Do not block the entire app when offline.
18. Do not invent API data.
19. Do not hardcode user-specific data.
20. Do not expose private secrets.
21. Keep components reusable.
22. Keep feature boundaries clear.
23. Avoid unnecessary dependencies.
24. Avoid unnecessary abstractions.
25. Do not implement future features without approval.
26. Run formatting.
27. Run static analysis.
28. Run tests after significant changes.
29. Preserve existing working functionality.
30. Make small, isolated changes.

---

# 52. Definition of Done

The initial production-ready version is complete when:

## Architecture

- Flutter
- Dart
- BLoC
- Clean Architecture
- Feature-first presentation
- Repository pattern
- Use cases
- Data sources
- Dependency injection

## Firebase

- Phone authentication
- OTP
- Session persistence
- Realtime Database
- Secure database rules
- Firebase service abstractions

## Local

- Persistent cache
- Offline library viewing
- Cache refresh
- Theme persistence

## API

- Standard API client
- TMDB integration
- Google Books integration
- Standard error handling
- Timeout
- Retry where appropriate

## UI

- Material 3
- Light theme
- Dark theme
- iOS-inspired components where appropriate
- Responsive layout
- Loading states
- Empty states
- Error states
- Offline states

## Features

- Authentication
- Home
- Library
- Search
- Media details
- Add media
- Edit media
- Delete media
- Status management
- Rating
- Notes
- Profile
- Settings

## Quality

- No architecture violations
- No direct Firebase access from UI
- No direct HTTP access from BLoCs
- No private credentials committed
- Firebase rules reviewed
- Tests passing
- Static analysis passing
- Release builds working

---

# 53. Complete Execution Flow

```text
                         START
                           │
                           ▼
                  Product Definition
                           │
                           ▼
                     Figma Design
                           │
                           ▼
                 Design System / Tokens
                           │
                           ▼
                  Flutter Foundation
                           │
             ┌─────────────┼─────────────┐
             ▼             ▼             ▼
           Theme         Router      Core Services
             │             │             │
             └─────────────┼─────────────┘
                           ▼
                    Firebase Setup
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
           Firebase       RTDB         Rules
             Auth
              │             │
              └─────────────┼────────────┘
                           ▼
                     Local Storage
                           │
                           ▼
                     API Foundation
                           │
                  ┌────────┴────────┐
                  ▼                 ▼
                 TMDB          Google Books
                  │                 │
                  └────────┬────────┘
                           ▼
                      Domain Layer
                           │
                           ▼
                    Data Layer
                           │
                           ▼
                     Repositories
                           │
                           ▼
                         BLoC
                           │
                           ▼
                       Flutter UI
                           │
            ┌──────────────┼──────────────┐
            ▼              ▼              ▼
          Home          Library         Search
            │              │              │
            └──────────────┼──────────────┘
                           ▼
                     Media Details
                           │
                           ▼
                      Add / Edit
                           │
                           ▼
                      Offline Mode
                           │
                           ▼
                       Sync Logic
                           │
                           ▼
                         Tests
                           │
                           ▼
                    Release Readiness
                           │
                           ▼
                         RELEASE
```

---

# 54. Final Architecture Summary

```text
                         FLUTTER APP
                              │
                         Material 3
                              │
                    Feature-first UI
                              │
                           BLoC
                              │
                         Use Cases
                              │
                        Repositories
                              │
             ┌────────────────┼────────────────┐
             │                │                │
          Local            Firebase          APIs
          Cache               │                │
             │          ┌─────┴─────┐     ┌───┴────┐
             │          │           │     │        │
             │         Auth        RTDB  TMDB   Google Books
             │
             └──────────────┬─────────────────────┘
                            │
                       Media Library
```

The central design principle is:

> **The UI should know about the application's domain, not about Firebase.**

The second principle is:

> **The application should remain useful when the network disappears.**

The third principle is:

> **Build the foundation first, then the UI, then the feature details.**

The fourth principle is:

> **Every external dependency should be replaceable through an abstraction.**

This gives the project a strong foundation for future Firebase Storage, notifications, analytics, Crashlytics, cloud functions, background synchronization, additional APIs, and more media types without requiring a major architectural rewrite.
