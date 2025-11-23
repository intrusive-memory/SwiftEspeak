# SwiftEspeak

![Tests](https://github.com/intrusive-memory/SwiftEspeak/actions/workflows/tests.yml/badge.svg)
![Experimental](https://img.shields.io/badge/status-experimental-yellow.svg)

A Swift wrapper for [eSpeak](http://espeak.sourceforge.net/), the open source speech synthesis library. SwiftEspeak provides a clean, Swift-friendly API for text-to-speech synthesis and audio file generation.

> **⚠️ EXPERIMENTAL - NOT READY FOR PRODUCTION**
>
> This library is experimental and incomplete. It is being developed as a learning exercise and proof of concept. The API is unstable and subject to change without warning. Features may be missing, incomplete, or non-functional. **Do not use this library in production environments.**

## Overview

SwiftEspeak enables Swift developers to easily integrate text-to-speech capabilities into their applications. The library wraps the eSpeak speech synthesis engine, providing:

- **Voice Discovery** - Enumerate and select from available synthesis voices
- **Audio Generation** - Convert text strings to audio files with customizable parameters
- **Multi-language Support** - Leverage eSpeak's support for dozens of languages and accents
- **Swift-Native API** - Modern Swift interfaces with proper error handling and type safety

## Features

- 🗣️ **Text-to-Speech Synthesis** - Generate spoken audio from text input
- 🎤 **Multiple Voice Support** - Access and select from eSpeak's extensive voice library
- 🌍 **Multi-language** - Support for 50+ languages and regional accents
- 💾 **Audio File Export** - Save synthesized speech as audio files (WAV, etc.)
- ⚙️ **Customizable Parameters** - Control pitch, speed, volume, and other synthesis parameters
- 🦅 **Swift-First Design** - Native Swift API with proper error handling
- 🔧 **Simple Integration** - Easy to integrate into macOS and iOS projects

## Requirements

- macOS 11.0+ / iOS 14.0+
- Swift 5.5+
- Xcode 13.0+

## Installation

### Swift Package Manager

Add SwiftEspeak to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftEspeak.git", from: "1.0.0")
]
```

The eSpeak library dependency is handled automatically by the Swift Package Manager.

### Command Line Utility

SwiftEspeak includes a command line utility target (similar to Apple's `say` command) for text-to-speech synthesis from the terminal. To build and install the CLI tool:

```bash
swift build -c release
# The executable will be available in .build/release/
```

## Quick Start

### Basic Text-to-Speech

```swift
import SwiftEspeak

// Initialize the speech synthesizer
let espeak = try SwiftEspeak()

// Generate audio from text
try espeak.speak("Hello, world!")

// Speak in a different language
try espeak.speak("Bonjour le monde!", language: "fr")
```

### Generate Audio Files

```swift
import SwiftEspeak

let espeak = try SwiftEspeak()

// Generate a WAV file from text
try espeak.generateAudioFile(
    text: "This is a test of the speech synthesis system.",
    outputPath: "/path/to/output.wav"
)

// Generate with specific voice and parameters
try espeak.generateAudioFile(
    text: "Custom voice and speed example",
    outputPath: "/path/to/output.wav",
    voice: "en-us",
    speed: 180,
    pitch: 60
)
```

### List Available Voices

```swift
import SwiftEspeak

let espeak = try SwiftEspeak()

// Get all available voices
let voices = try espeak.listVoices()

for voice in voices {
    print("Voice: \(voice.name)")
    print("  Language: \(voice.language)")
    print("  Gender: \(voice.gender)")
    print("  Age: \(voice.age)")
    print()
}

// Filter voices by language
let englishVoices = try espeak.listVoices(language: "en")
print("English voices: \(englishVoices.map { $0.name })")
```

### Advanced Usage

```swift
import SwiftEspeak

let espeak = try SwiftEspeak()

// Configure synthesis parameters
espeak.configure { config in
    config.speed = 200        // Words per minute (default: 175)
    config.pitch = 70         // 0-99 (default: 50)
    config.volume = 150       // 0-200 (default: 100)
    config.wordGap = 10       // Pause between words in 10ms units
    config.voice = "en-us"    // Voice identifier
}

// Generate audio with configured settings
try espeak.generateAudioFile(
    text: "This uses custom synthesis parameters.",
    outputPath: "/path/to/custom.wav"
)

// Generate audio data in memory (without file)
let audioData = try espeak.synthesizeToData(text: "In-memory synthesis")
// Use audioData for playback or further processing
```

## API Reference

### SwiftEspeak Class

#### Initialization
```swift
init() throws
```
Creates a new SwiftEspeak instance. Throws if eSpeak cannot be initialized.

#### Speaking Methods
```swift
func speak(_ text: String, language: String? = nil) throws
```
Synthesizes and speaks the given text immediately.

```swift
func generateAudioFile(
    text: String,
    outputPath: String,
    voice: String? = nil,
    speed: Int? = nil,
    pitch: Int? = nil,
    volume: Int? = nil
) throws
```
Generates an audio file from the given text with optional parameters.

```swift
func synthesizeToData(text: String) throws -> Data
```
Synthesizes speech to audio data in memory without creating a file.

#### Voice Methods
```swift
func listVoices(language: String? = nil) throws -> [Voice]
```
Returns a list of available voices, optionally filtered by language.

```swift
func setVoice(_ voiceName: String) throws
```
Sets the current voice for synthesis.

#### Configuration
```swift
func configure(_ block: (inout Configuration) -> Void)
```
Updates synthesis configuration using a closure.

### Voice Structure
```swift
struct Voice {
    let name: String          // Voice identifier
    let language: String      // Language code (e.g., "en", "fr")
    let gender: Gender        // .male, .female, or .neutral
    let age: Int?             // Age in years (if specified)
    let variant: Int          // Voice variant number
}
```

### Configuration Structure
```swift
struct Configuration {
    var speed: Int = 175      // Words per minute (80-450)
    var pitch: Int = 50       // Pitch (0-99)
    var volume: Int = 100     // Volume (0-200)
    var wordGap: Int = 0      // Pause between words (10ms units)
    var voice: String?        // Voice identifier
}
```

## Supported Languages

SwiftEspeak supports all languages available in eSpeak, including:

- English (US, UK, Scotland, Ireland, etc.)
- Spanish, French, German, Italian, Portuguese
- Russian, Polish, Czech, Slovak
- Chinese (Mandarin, Cantonese), Japanese, Korean
- Arabic, Hindi, Turkish
- And many more...

Use `listVoices()` to see all available languages on your system.

## Examples

### Command-Line Tool Example

```swift
import SwiftEspeak
import Foundation

@main
struct SpeakTool {
    static func main() throws {
        let espeak = try SwiftEspeak()

        guard CommandLine.arguments.count > 1 else {
            print("Usage: speak <text> [voice]")
            return
        }

        let text = CommandLine.arguments[1]
        let voice = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : nil

        if let voice = voice {
            try espeak.setVoice(voice)
        }

        try espeak.speak(text)
    }
}
```

### macOS App Example

```swift
import SwiftUI
import SwiftEspeak

struct ContentView: View {
    @State private var text = ""
    @State private var selectedVoice: Voice?
    @State private var voices: [Voice] = []
    @State private var espeak: SwiftEspeak?

    var body: some View {
        VStack(spacing: 20) {
            TextEditor(text: $text)
                .frame(height: 200)
                .border(Color.gray)

            Picker("Voice", selection: $selectedVoice) {
                ForEach(voices, id: \.name) { voice in
                    Text("\(voice.name) (\(voice.language))")
                        .tag(voice as Voice?)
                }
            }

            HStack {
                Button("Speak") {
                    speak()
                }

                Button("Save to File") {
                    saveToFile()
                }
            }
        }
        .padding()
        .onAppear {
            setupEspeak()
        }
    }

    private func setupEspeak() {
        do {
            espeak = try SwiftEspeak()
            voices = try espeak?.listVoices() ?? []
            selectedVoice = voices.first
        } catch {
            print("Error: \(error)")
        }
    }

    private func speak() {
        do {
            if let voice = selectedVoice {
                try espeak?.setVoice(voice.name)
            }
            try espeak?.speak(text)
        } catch {
            print("Error: \(error)")
        }
    }

    private func saveToFile() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.wav]
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }

            do {
                if let voice = selectedVoice {
                    try espeak?.setVoice(voice.name)
                }
                try espeak?.generateAudioFile(text: text, outputPath: url.path)
            } catch {
                print("Error: \(error)")
            }
        }
    }
}
```

## Error Handling

SwiftEspeak uses Swift's error handling system. Common errors include:

```swift
enum SpeakError: Error {
    case initializationFailed
    case voiceNotFound(String)
    case synthesisFailure(String)
    case fileWriteError(String)
    case invalidParameter(String)
}
```

Example error handling:

```swift
do {
    let espeak = try SwiftEspeak()
    try espeak.speak("Hello!")
} catch SpeakError.initializationFailed {
    print("Failed to initialize eSpeak")
} catch SpeakError.voiceNotFound(let voiceName) {
    print("Voice '\(voiceName)' not found")
} catch {
    print("Unexpected error: \(error)")
}
```

## Performance Considerations

- **Initialization**: SwiftEspeak initialization is lightweight
- **Synthesis**: Text-to-speech synthesis is CPU-bound but efficient for typical usage
- **File Generation**: Writing audio files is I/O-bound; consider background threads for large batches
- **Memory**: Audio data generation creates in-memory buffers; use file-based methods for very long texts

## Troubleshooting

### "eSpeak not found" error
Ensure eSpeak is installed on your system:
```bash
brew install espeak  # macOS
```

### No voices available
Check your eSpeak installation includes voice data:
```bash
espeak --voices  # Should list available voices
```

### Audio file not created
- Verify write permissions for the output path
- Check that the output directory exists
- Ensure sufficient disk space

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

SwiftEspeak is available under the MIT License. See LICENSE for details.

eSpeak is distributed under the GNU General Public License version 3.

## Related Projects

- [eSpeak](http://espeak.sourceforge.net/) - The underlying speech synthesis engine
- [eSpeak NG](https://github.com/espeak-ng/espeak-ng) - Enhanced version of eSpeak

## Acknowledgments

SwiftEspeak is a wrapper around the excellent eSpeak speech synthesis engine created by Jonathan Duddington.
