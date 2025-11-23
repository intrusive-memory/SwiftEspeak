# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftEspeak is a Swift wrapper for the eSpeak-NG text-to-speech library. It provides a clean, Swift-friendly API for text-to-speech synthesis and audio file generation across macOS and iOS platforms.

**Platforms**: macOS 11.0+, iOS 14.0+
**Swift Version**: 5.5+

## ⚠️ EXPERIMENTAL STATUS

This library is **experimental** and incomplete. It is being developed as a learning exercise and proof of concept. The API is unstable and subject to change without warning. **Do not use this library in production environments.**

## Essential Build Commands

### System Requirements

**eSpeak-NG Installation:**
```bash
# macOS (required before building)
brew install espeak-ng

# Verify installation
brew list espeak-ng
pkg-config --cflags --libs espeak-ng
```

### Swift Package Manager

```bash
# Build the library
swift build

# Build in release mode
swift build -c release

# Run tests
swift test

# Build the CLI tool
swift build --product swift-espeak

# Run the CLI tool
.build/debug/swift-espeak "Hello, world!"
```

### Xcode Build

```bash
# Build for macOS
xcodebuild build \
  -scheme SwiftEspeak \
  -destination 'platform=macOS' \
  CODE_SIGNING_ALLOWED=NO

# Build for iOS Simulator
xcodebuild build \
  -scheme SwiftEspeak \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO

# Run tests on macOS
xcodebuild test \
  -scheme SwiftEspeak \
  -destination 'platform=macOS' \
  -enableCodeCoverage YES \
  CODE_SIGNING_ALLOWED=NO
```

## Project Structure

```
SwiftEspeak/
├── Sources/
│   ├── CEspeak/               # C bridging module
│   │   ├── include/
│   │   │   ├── CEspeak.h      # C header for eSpeak bridging
│   │   │   └── module.modulemap # Module map for system library
│   ├── SwiftEspeak/           # Main Swift library
│   │   └── SwiftEspeak.swift  # Core implementation
│   └── SwiftEspeakCLI/        # Command-line tool
│       └── main.swift         # CLI entry point
├── Tests/
│   └── SwiftEspeakTests/      # Test suite
└── Package.swift              # Swift package manifest
```

## Core Architecture

### System Library Target

SwiftEspeak uses a `systemLibrary` target to bridge to the eSpeak-NG C library:

- **CEspeak**: System library target with pkg-config for espeak-ng
- **Providers**: Homebrew (macOS) and apt (Linux) package managers
- **Module Map**: Custom module.modulemap for C bridging

### Dependencies

1. **eSpeak-NG** (system): Text-to-speech synthesis engine
2. **swift-argument-parser** (SPM): CLI argument handling

### Key Components

1. **SwiftEspeak**: Main library providing TTS functionality
2. **SwiftEspeakCLI**: Command-line tool (like macOS `say`)
3. **CEspeak**: C bridging module for eSpeak-NG

## Development Workflow

**⚠️ CRITICAL: See [`.claude/WORKFLOW.md`](.claude/WORKFLOW.md) for complete development workflow.**

This project follows a **strict branch-based workflow**:

### Quick Reference

- **Development branch**: `development` (all work happens here)
- **Main branch**: `main` (protected, PR-only)
- **Workflow**: `development` → PR → CI passes → Merge → Tag → Release
- **NEVER** commit directly to `main`
- **NEVER** delete the `development` branch

### CI/CD Requirements

**Main branch is protected:**
- Direct pushes blocked (PRs only)
- No PR review required
- GitHub Actions must pass before merge:
  - macOS Tests: Unit tests on macOS platform
  - iOS Tests: Unit tests on iOS Simulator
  - Code Quality: TODOs, large files, print statements

**See [`.claude/WORKFLOW.md`](.claude/WORKFLOW.md) for:**
- Complete branch strategy
- Commit message conventions
- PR creation templates
- Tagging and release process
- Version numbering (semver)
- Emergency hotfix procedures

## Common Development Tasks

### Adding New Features

When adding features to SwiftEspeak:

1. **Always work on `development` branch**
2. Add functionality to `Sources/SwiftEspeak/SwiftEspeak.swift`
3. Add tests to `Tests/SwiftEspeakTests/`
4. Update `README.md` with usage examples
5. Document in `CHANGELOG.md`
6. Ensure all tests pass before committing

### Working with C Bridging

**Bridging eSpeak-NG C APIs:**

1. C declarations go in `Sources/CEspeak/include/CEspeak.h`
2. Module map in `Sources/CEspeak/include/module.modulemap`
3. Import in Swift: `import CEspeak`
4. Use Swift-friendly wrappers in `SwiftEspeak.swift`

**Common patterns:**

```swift
// Wrapping C functions
func speak(_ text: String) throws {
    // Convert Swift String to C string
    let cString = text.withCString { $0 }

    // Call C function
    let result = espeak_Synth(cString, ...)

    // Check for errors
    guard result == ESPEAK_OK else {
        throw SpeakError.synthesisFailure("...")
    }
}
```

### Error Handling

SwiftEspeak uses Swift's native error handling:

```swift
enum SpeakError: Error {
    case initializationFailed
    case voiceNotFound(String)
    case synthesisFailure(String)
    case fileWriteError(String)
    case invalidParameter(String)
}
```

**Always:**
- Throw descriptive errors
- Document error cases
- Provide helpful error messages

### Testing

**Test Requirements:**
- All new features must have tests
- Tests must pass on both macOS and iOS
- Aim for high code coverage (80%+)
- Use Swift Testing framework (`@Test` macro)

**Running tests:**
```bash
# Quick test run
swift test

# Verbose output
swift test --verbose

# Specific test
swift test --filter SwiftEspeakTests.testVoiceListing
```

## API Design Guidelines

1. **Swift-First**: API should feel natural to Swift developers
2. **Type Safety**: Use enums, structs, and strong typing
3. **Error Handling**: Use `throws` for fallible operations
4. **Documentation**: Add doc comments for all public APIs
5. **Async/Await**: Consider async for long-running operations (future)

## Performance Considerations

- **Initialization**: SwiftEspeak initialization is lightweight
- **Synthesis**: CPU-bound but efficient for typical usage
- **File Generation**: I/O-bound; consider background threads for large batches
- **Memory**: Audio data generation creates in-memory buffers

## Common Patterns

### Initializing SwiftEspeak

```swift
let espeak = try SwiftEspeak()
```

### Synthesizing Speech

```swift
// Speak immediately
try espeak.speak("Hello, world!")

// Generate audio file
try espeak.generateAudioFile(
    text: "Test",
    outputPath: "/path/to/output.wav"
)

// Generate to memory
let audioData = try espeak.synthesizeToData(text: "Test")
```

### Voice Selection

```swift
// List all voices
let voices = try espeak.listVoices()

// List voices for a language
let englishVoices = try espeak.listVoices(language: "en")

// Set a specific voice
try espeak.setVoice("en-us")
```

## Documentation Resources

- `README.md` - User-facing overview and API reference
- `CLAUDE.md` - This file - development guide
- `.claude/WORKFLOW.md` - Development workflow and branch strategy
- `CHANGELOG.md` - Version history (to be created)

## Project Metadata

- **Version**: 0.1.0 (experimental)
- **Swift**: 5.5+
- **Platforms**: macOS 11.0+, iOS 14.0+
- **Dependencies**: eSpeak-NG (system), swift-argument-parser (SPM)
- **License**: MIT (SwiftEspeak), GPL-3 (eSpeak-NG)
- **Status**: Experimental - not production ready

## Important Reminders

- This library wraps eSpeak-NG, which must be installed via Homebrew on macOS
- Always test on both macOS and iOS platforms
- The C bridging layer requires careful memory management
- Follow the development workflow in `.claude/WORKFLOW.md`
- Never commit directly to `main` branch
- Always create PRs from `development` to `main`
- Tag releases after merging to `main`
- Keep `development` and `main` branches in sync after releases

## Troubleshooting

### "eSpeak-NG not found" errors

```bash
# Install eSpeak-NG
brew install espeak-ng

# Verify pkg-config can find it
pkg-config --cflags --libs espeak-ng
```

### Build failures with module not found

1. Ensure `module.modulemap` exists in `Sources/CEspeak/include/`
2. Check that `CEspeak.h` is present
3. Verify eSpeak-NG is installed system-wide

### Tests failing

1. Ensure eSpeak-NG is installed
2. Run `swift build` first
3. Check for missing voice data: `espeak-ng --voices`

## Future Enhancements (Experimental)

As this is an experimental project, future enhancements may include:

- Async/await API for synthesis
- Real-time synthesis callbacks
- Advanced voice parameters (emphasis, prosody)
- SSML support
- Streaming audio output
- Performance benchmarks
- Comprehensive documentation
- Production-ready stability

**Note:** These features are aspirational and may not be implemented.
