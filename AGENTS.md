# Papeeta - Agent Coding Guidelines

This document provides guidelines for agents working on the Papeeta Flutter project.

## Project Overview

- **Type**: Flutter mobile application (iOS, Android, Web, macOS, Linux, Windows)
- **SDK**: Flutter 3.8.0+ (FVM configured at `.fvm/versions/3.8.5`)
- **State Management**: flutter_bloc (BLoC pattern)
- **Routing**: go_router
- **Dependency Injection**: get_it
- **HTTP Client**: dio

## Build/Lint/Test Commands

### Running the App
```bash
flutter run
flutter run -d ios
flutter run -d android
flutter run -d chrome  # Web
```

### Linting & Analysis
```bash
flutter analyze
flutter analyze --fatal-infos --fatal-warnings
```

### Testing
```bash
flutter test                           # Run all tests
flutter test test/path/to/file_test.dart  # Run single test file
flutter test --coverage                # With coverage
flutter test --name "pattern"          # Match pattern
```

### Building
```bash
flutter build ios --simulator --no-codesign  # iOS simulator
flutter build ios --release                  # iOS release
flutter build apk --debug                    # Android debug
flutter build apk --release                  # Android release
flutter build web                            # Web
```

## Code Style Guidelines

### General Rules
- Follow the Dart style guide: https://dart.dev/guides/language/effective-dart
- Linting via `analysis_options.yaml` using `package:flutter_lints/flutter.yaml`
- Run `flutter analyze` before committing

### Imports
```dart
// Order: dart: libs, package: libs, relative imports
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:papeeta/core/di/injection.dart';

// Use 'show'/'hide' to avoid unused symbols
import 'package:flutter/material.dart' show BuildContext, StatelessWidget;
```

### Naming Conventions
- **Classes/Enums/Extensions**: `PascalCase` (e.g., `AuthBloc`, `RecipeEntity`)
- **Functions/Variables**: `camelCase` (e.g., `loginUser`)
- **Constants**: `camelCase` with `k` prefix (e.g., `kDefaultTimeout`)
- **Files**: `snake_case.dart` (e.g., `auth_bloc.dart`)
- **BLoC Events/States**: `*_event.dart`, `*_state.dart`

### Code Organization
```
lib/
├── core/              # Shared utilities, DI, router
├── features/         # Feature modules (feature-driven)
│   └── feature_name/
│       ├── data/     # DTOs, datasources, repositories impl
│       ├── domain/   # Entities, repository interfaces
│       └── presentation/  # BLoC, pages, widgets
├── pages/            # Top-level pages
├── widgets/          # Shared widgets
└── main.dart
```

### BLoC Pattern
- Use `flutter_bloc` for state management
- Events in `*_event.dart`, states in `*_state.dart`, bloc in `*_bloc.dart`
- Use `Equatable` for states/events
- Handle errors in BLoC, emit error states

```dart
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await repository.login(event.email, event.password);
      emit(Authenticated(user));
    } catch (e) {
      emit(const AuthError('Login failed'));
      emit(Unauthenticated());
    }
  }
}
```

### Error Handling
- Use try-catch for async operations
- Emit error states in BLoCs for UI feedback
- Use user-friendly error messages (in Spanish, as per project locale)
- Always reset to stable state after errors

### Types
- Use strong typing - avoid `dynamic`
- Use `final` for variables that don't change
- Use `const` constructors where applicable

### Widgets
- Use `const` constructors for widgets when possible
- Extract reusable widgets into separate files
- Follow Flutter naming: `CustomWidgetName`
- Use `StatelessWidget` when state isn't needed

### Strings
- Use single quotes: `'hello'`
- Use double quotes for interpolated strings: `"Hello $name"`

### Other Conventions
- Avoid `print()` - use a proper logger
- Use `late` sparingly
- Prefer composition over inheritance
- Keep functions short and focused

## Key Dependencies
```yaml
dependencies:
  flutter_bloc: ^9.1.1
  go_router: ^15.1.2
  get_it: ^9.2.0
  equatable: ^2.0.7
  dio: ^5.9.0
  cached_network_image: ^3.4.1
  flutter_secure_storage: ^9.2.4
  image_picker: ^1.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

## Environment
- API base URL: `lib/global/enviroment.dart`
- Assets: `images/`, `fonts/Inter/`
- FVM version: 3.8.5 (in `.fvmrc`)

## Workflow
1. Make changes in feature modules under `lib/features/`
2. Run `flutter analyze` to check for issues
3. Test on device/emulator with `flutter run`
4. Build release with appropriate platform command
