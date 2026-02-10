# AGENTS.md

This file provides comprehensive documentation for AI agents working with the SwiftEspeak codebase.

**Current Version**: 0.1.0 (Experimental - February 2026)

---

## Project Overview

SwiftEspeak is a Swift wrapper for the eSpeak-NG text-to-speech engine. It provides a clean, Swift-friendly API for text-to-speech synthesis and audio file generation across macOS and iOS platforms.

**Status**: Experimental - This library is incomplete and under development as a learning exercise and proof of concept. The API is unstable and subject to change without warning. **Do not use in production environments.**

## Project Structure

```
SwiftEspeak/
├── Sources/
│   ├── CEspeak/               # C bridging module
│   │   └── include/
│   │       ├── CEspeak.h      # C header for eSpeak-NG bridging
│   │       └── module.modulemap
│   ├── SwiftEspeak/           # Main library target
│   │   └── SwiftEspeak.swift  # Core implementation
│   └── SwiftEspeakCLI/        # CLI executable target
│       └── main.swift         # CLI entry point (similar to macOS 'say')
├── Tests/
│   └── SwiftEspeakTests/      # Test suite
│       └── SwiftEspeakTests.swift
└── Package.swift              # Swift package manifest
```

## Key Components

| File | Purpose |
|------|---------|
| `SwiftEspeak.swift` | Main library class providing TTS functionality, voice discovery, and synthesis |
| `CEspeak.h` | C bridging header that wraps eSpeak-NG's `speak_lib.h` and re-exports constants |
| `module.modulemap` | System library module map for pkg-config integration |
| `main.swift` (CLI) | Command-line tool for text-to-speech (ArgumentParser-based) |
| `SwiftEspeakTests.swift` | Test suite for initialization, voice listing, and voice setting |

### SwiftEspeak Class API

| Method | Purpose | Status |
|--------|---------|--------|
| `init()` | Initialize eSpeak with `AUDIO_OUTPUT_RETRIEVAL` mode | ✅ Implemented |
| `listVoices(language:)` | Enumerate available voices, optionally filtered by language | ✅ Implemented |
| `setVoice(_:)` | Set the current voice by name | ✅ Implemented |
| `speak(_:language:)` | Synthesize and speak text immediately | ⚠️ TODO |
| `generateAudioFile(text:outputPath:voice:speed:pitch:volume:)` | Generate audio file (WAV) from text | ⚠️ TODO |
| `synthesizeToData(text:)` | Synthesize speech to in-memory audio data | ⚠️ TODO |
| `configure(_:)` | Update synthesis configuration (speed, pitch, volume, etc.) | ⚠️ TODO |

### Supporting Types

- **Voice**: Struct with `name`, `language`, `gender`, `age`, `variant` properties
- **Gender**: Enum (`.male`, `.female`, `.neutral`)
- **Configuration**: Struct for synthesis parameters (speed, pitch, volume, word gap)
- **SpeakError**: Error enum (`.initializationFailed`, `.voiceNotFound`, `.synthesisFailure`, `.fileWriteError`, `.invalidParameter`)

## CLI Commands

The `swift-espeak` CLI tool provides a command-line interface similar to macOS's `say` command.

| Flag/Option | Purpose | Status |
|-------------|---------|--------|
| `text` (argument) | Text to synthesize | ⚠️ TODO (arg parsing implemented) |
| `--voice`, `-v` | Voice identifier to use | ⚠️ TODO |
| `--output`, `-o` | Output audio file path (WAV) | ⚠️ TODO |
| `--rate`, `-r` | Speaking rate in words per minute (default: 175) | ⚠️ TODO |
| `--volume` | Volume level 0-200 (default: 100) | ⚠️ TODO |
| `--pitch`, `-p` | Pitch adjustment 0-99 (default: 50) | ⚠️ TODO |
| `--list-voices` | List all available voices | ⚠️ TODO (UI implemented) |
| `--version` | Display version information | ✅ Implemented |

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| eSpeak-NG | System (Homebrew/apt) | Text-to-speech synthesis engine (C library) |
| swift-argument-parser | 1.2.0+ | CLI argument parsing for SwiftEspeakCLI |

### System Library Integration

SwiftEspeak uses a `systemLibrary` target to bridge to eSpeak-NG:

- **Target**: `CEspeak`
- **pkg-config**: `espeak-ng`
- **Providers**: Homebrew (`espeak-ng`) on macOS, apt (`libespeak-ng-dev`) on Linux
- **Module Map**: Custom `module.modulemap` for C bridging

## Build and Test

**Build Requirements**:
- Swift 5.5+
- macOS 11.0+ / iOS 14.0+
- eSpeak-NG installed via Homebrew: `brew install espeak-ng`

**Swift Package Manager** (preferred for development):

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

**Xcode Build**:

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

## Design Patterns

### C Bridging Architecture

SwiftEspeak bridges to the eSpeak-NG C library using a system library target:

1. **CEspeak Target**: System library with pkg-config for `espeak-ng`
2. **CEspeak.h**: Re-exports eSpeak constants and includes `speak_lib.h`
3. **module.modulemap**: Declares the C module for Swift import
4. **Swift Wrappers**: `SwiftEspeak.swift` wraps C APIs with Swift-friendly types

**Memory Management**:
- Uses `strdup()` and `free()` for C string handling in voice filtering
- Iterates NULL-terminated arrays for voice lists
- `deinit` calls `espeak_Terminate()` for cleanup

### Voice Discovery Pattern

Voice listing uses eSpeak's `espeak_ListVoices()` API:

1. Create optional `espeak_VOICE` spec for language filtering (requires `strdup()` for language string)
2. Call `espeak_ListVoices()` to get NULL-terminated array of voice pointers
3. Iterate through array, extracting name, language, gender, age, variant
4. Free duplicated strings with `free()`
5. Return Swift `[Voice]` array

**Language Code Extraction**: eSpeak language strings include priority numbers (e.g., `"en 5"`). SwiftEspeak strips the priority by splitting on space and taking the first component.

### Error Handling

All fallible operations use Swift's `throws` mechanism:

- `init()` throws `.initializationFailed` if eSpeak initialization returns sample rate ≤ 0
- `setVoice()` throws `.voiceNotFound(String)` if `espeak_SetVoiceByName()` returns non-zero
- `listVoices()` throws `.synthesisFailure(String)` if `espeak_ListVoices()` returns `nil`

### Initialization Pattern

SwiftEspeak initializes eSpeak in `AUDIO_OUTPUT_RETRIEVAL` mode (for voice discovery without audio output). The synthesizer must later switch to `AUDIO_OUTPUT_PLAYBACK` or `AUDIO_OUTPUT_SYNCHRONOUS` for actual speech synthesis (TODO).

## Development Workflow

**Branch Strategy**:
- **development**: All work happens here
- **main**: Protected, PR-only, CI must pass before merge
- Workflow: `development` → PR → CI passes → Merge → Tag → Release

**CI/CD**:
- GitHub Actions must pass on macOS and iOS before merge
- Runners use `macos-26` with Swift 6.2+
- iOS destination: `platform=iOS Simulator,name=iPhone 17,OS=26.1`

**Commit Conventions**:
- Use conventional commit format (e.g., `feat:`, `fix:`, `docs:`, `test:`)
- Tag releases with semver (e.g., `v0.1.0`)

## Testing Strategy

**Test Coverage**:
- ✅ Initialization tests (`testInitialization`)
- ✅ Voice discovery tests (`testListAllVoices`, `testListEnglishVoices`, `testListVoicesByLanguage`, `testVoiceProperties`)
- ✅ Voice setting tests (`testSetVoice`, `testSetInvalidVoice`, `testSetMultipleVoices`)
- ✅ Performance tests (`testVoiceListingPerformance`)
- ⚠️ Speech synthesis tests (TODO: requires audio output implementation)
- ⚠️ Audio file generation tests (TODO: requires file write implementation)

**Test Requirements**:
- All tests must pass on both macOS and iOS
- eSpeak-NG must be installed (`brew install espeak-ng`)
- Tests verify voice data structure and filtering correctness

## Implementation Status

| Feature | Status | Notes |
|---------|--------|-------|
| eSpeak initialization | ✅ Complete | `AUDIO_OUTPUT_RETRIEVAL` mode |
| Voice discovery | ✅ Complete | Enumerates all voices with filtering |
| Voice setting | ✅ Complete | Sets voice by name |
| Language filtering | ✅ Complete | Filters voices by language code |
| Speech synthesis (speak) | ⚠️ TODO | Requires audio output mode switch |
| Audio file generation | ⚠️ TODO | Requires file write and WAV output |
| In-memory synthesis | ⚠️ TODO | Requires audio data retrieval |
| Configuration (speed, pitch, etc.) | ⚠️ TODO | Requires eSpeak parameter setting |
| CLI tool | ⚠️ Partial | Argument parsing complete, synthesis TODO |

## Common Development Tasks

### Adding New Features

1. Work on `development` branch
2. Add functionality to `Sources/SwiftEspeak/SwiftEspeak.swift`
3. Update C bridging header if new eSpeak APIs are needed
4. Add tests to `Tests/SwiftEspeakTests/`
5. Update `README.md` with usage examples
6. Ensure all tests pass before committing

### Working with C Bridging

**Bridging eSpeak-NG C APIs**:

1. C declarations go in `Sources/CEspeak/include/CEspeak.h`
2. Module map in `Sources/CEspeak/include/module.modulemap`
3. Import in Swift: `import CEspeak`
4. Use Swift-friendly wrappers in `SwiftEspeak.swift`

**Common patterns**:

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

### Troubleshooting

**"eSpeak-NG not found" errors**:
```bash
# Install eSpeak-NG
brew install espeak-ng

# Verify pkg-config can find it
pkg-config --cflags --libs espeak-ng
```

**Build failures with module not found**:
1. Ensure `module.modulemap` exists in `Sources/CEspeak/include/`
2. Check that `CEspeak.h` is present
3. Verify eSpeak-NG is installed system-wide

**Tests failing**:
1. Ensure eSpeak-NG is installed
2. Run `swift build` first
3. Check for missing voice data: `espeak-ng --voices`

## API Design Guidelines

1. **Swift-First**: API should feel natural to Swift developers (use structs, enums, throws)
2. **Type Safety**: Use enums, structs, and strong typing (avoid raw integers)
3. **Error Handling**: Use `throws` for fallible operations (no force-unwrapping)
4. **Documentation**: Add doc comments for all public APIs
5. **Async/Await**: Consider async for long-running operations (future enhancement)

## Performance Considerations

- **Initialization**: SwiftEspeak initialization is lightweight (single eSpeak engine instance)
- **Synthesis**: Text-to-speech synthesis is CPU-bound but efficient for typical usage
- **File Generation**: Writing audio files is I/O-bound; consider background threads for large batches
- **Memory**: Audio data generation creates in-memory buffers; use file-based methods for very long texts

## Future Enhancements (Experimental)

As this is an experimental project, future enhancements may include:

- ✅ Voice discovery and listing (DONE)
- ⚠️ Real-time speech synthesis (TODO)
- ⚠️ Audio file generation (WAV, etc.) (TODO)
- ⚠️ In-memory audio data synthesis (TODO)
- ⚠️ Advanced voice parameters (emphasis, prosody) (TODO)
- ⚠️ SSML support (TODO)
- ⚠️ Async/await API for synthesis (TODO)
- ⚠️ Real-time synthesis callbacks (TODO)
- ⚠️ Streaming audio output (TODO)
- ⚠️ Performance benchmarks (TODO)
- ⚠️ Comprehensive documentation (TODO)
- ⚠️ Production-ready stability (TODO)

**Note**: These features are aspirational and may not be implemented.

## Platform Support

- **macOS**: 11.0+ (Big Sur and later)
- **iOS**: 14.0+ (requires eSpeak-NG on-device or simulator)
- **Swift**: 5.5+
- **Xcode**: 13.0+

## License

- **SwiftEspeak**: MIT License
- **eSpeak-NG**: GNU General Public License version 3

## Related Projects

- [eSpeak](http://espeak.sourceforge.net/) - The original speech synthesis engine
- [eSpeak-NG](https://github.com/espeak-ng/espeak-ng) - Enhanced version of eSpeak (used by this library)

## Acknowledgments

SwiftEspeak is a wrapper around the excellent eSpeak-NG speech synthesis engine.
