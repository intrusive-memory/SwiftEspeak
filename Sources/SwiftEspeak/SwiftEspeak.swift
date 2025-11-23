import Foundation
import CEspeak

/// SwiftEspeak - A Swift wrapper for the eSpeak speech synthesis library
public class SwiftEspeak {

    // MARK: - Properties

    private var isInitialized = false

    // MARK: - Initialization

    /// Creates a new SwiftEspeak instance
    /// - Throws: `SpeakError.initializationFailed` if eSpeak cannot be initialized
    public init() throws {
        // Initialize eSpeak with no audio output by default (for voice discovery)
        // We'll enable audio output when actually synthesizing speech
        let sampleRate = espeak_Initialize(
            AUDIO_OUTPUT_RETRIEVAL,
            0,  // Buffer length (0 = default)
            nil, // Path (nil = default)
            0    // Options
        )

        guard sampleRate > 0 else {
            throw SpeakError.initializationFailed
        }

        isInitialized = true
    }

    deinit {
        if isInitialized {
            espeak_Terminate()
        }
    }

    // MARK: - Speech Synthesis

    /// Synthesizes and speaks the given text immediately
    /// - Parameters:
    ///   - text: The text to speak
    ///   - language: Optional language code (e.g., "en", "fr")
    /// - Throws: `SpeakError` if synthesis fails
    public func speak(_ text: String, language: String? = nil) throws {
        // TODO: Implement speech synthesis
    }

    /// Generates an audio file from the given text
    /// - Parameters:
    ///   - text: The text to synthesize
    ///   - outputPath: Path where the audio file should be saved
    ///   - voice: Optional voice identifier
    ///   - speed: Optional speaking rate in words per minute
    ///   - pitch: Optional pitch adjustment (0-99)
    ///   - volume: Optional volume level (0-200)
    /// - Throws: `SpeakError` if file generation fails
    public func generateAudioFile(
        text: String,
        outputPath: String,
        voice: String? = nil,
        speed: Int? = nil,
        pitch: Int? = nil,
        volume: Int? = nil
    ) throws {
        // TODO: Implement audio file generation
    }

    /// Synthesizes speech to audio data in memory
    /// - Parameter text: The text to synthesize
    /// - Returns: Audio data
    /// - Throws: `SpeakError` if synthesis fails
    public func synthesizeToData(text: String) throws -> Data {
        // TODO: Implement in-memory synthesis
        return Data()
    }

    // MARK: - Voice Management

    /// Returns a list of available voices
    /// - Parameter language: Optional language filter
    /// - Returns: Array of available voices
    /// - Throws: `SpeakError` if voice enumeration fails
    public func listVoices(language: String? = nil) throws -> [Voice] {
        var voiceSpec: espeak_VOICE?

        // If a language filter is specified, create a voice spec
        if let lang = language {
            voiceSpec = espeak_VOICE(
                name: nil,
                languages: strdup(lang),
                identifier: nil,
                gender: 0,
                age: 0,
                variant: 0,
                xx1: 0,
                score: 0,
                spare: nil
            )
        }

        // Get the list of voices from eSpeak
        guard let voiceList = espeak_ListVoices(voiceSpec != nil ? &voiceSpec : nil) else {
            // Free the duplicated string if we created one
            if let spec = voiceSpec, let languages = spec.languages {
                free(UnsafeMutableRawPointer(mutating: languages))
            }
            throw SpeakError.synthesisFailure("Failed to enumerate voices")
        }

        var voices: [Voice] = []
        var index = 0

        // Iterate through the NULL-terminated array
        while let voicePtr = voiceList[index] {
            let espeakVoice = voicePtr.pointee

            // Extract voice name (identifier is the actual voice name)
            let name: String
            if let identifier = espeakVoice.identifier {
                name = String(cString: identifier)
            } else if let voiceName = espeakVoice.name {
                name = String(cString: voiceName)
            } else {
                index += 1
                continue
            }

            // Extract language code (first language in the list)
            var languageCode = ""
            if let languages = espeakVoice.languages {
                languageCode = String(cString: languages)
                // Language string may have priority numbers, extract just the code
                if let spaceIndex = languageCode.firstIndex(of: " ") {
                    languageCode = String(languageCode[..<spaceIndex])
                }
            }

            // Map gender from eSpeak constants
            let gender: Gender
            switch espeakVoice.gender {
            case 1:  // Male
                gender = .male
            case 2:  // Female
                gender = .female
            default:
                gender = .neutral
            }

            // Extract age (0 means unspecified)
            let age: Int? = espeakVoice.age > 0 ? Int(espeakVoice.age) : nil

            let voice = Voice(
                name: name,
                language: languageCode,
                gender: gender,
                age: age,
                variant: Int(espeakVoice.variant)
            )

            voices.append(voice)
            index += 1
        }

        // Clean up the voice spec if we created one
        if let spec = voiceSpec, let languages = spec.languages {
            free(UnsafeMutableRawPointer(mutating: languages))
        }

        return voices
    }

    /// Sets the current voice for synthesis
    /// - Parameter voiceName: The voice identifier to use
    /// - Throws: `SpeakError.voiceNotFound` if the voice doesn't exist
    public func setVoice(_ voiceName: String) throws {
        let result = espeak_SetVoiceByName(voiceName)

        // espeak_SetVoiceByName returns EE_OK (0) on success
        if result != EE_OK {
            throw SpeakError.voiceNotFound(voiceName)
        }
    }

    // MARK: - Configuration

    /// Updates synthesis configuration
    /// - Parameter block: Closure that modifies the configuration
    public func configure(_ block: (inout Configuration) -> Void) {
        var config = Configuration()
        block(&config)
        // TODO: Apply configuration to eSpeak
    }
}

// MARK: - Supporting Types

/// Voice information
public struct Voice {
    public let name: String
    public let language: String
    public let gender: Gender
    public let age: Int?
    public let variant: Int

    public init(name: String, language: String, gender: Gender, age: Int?, variant: Int) {
        self.name = name
        self.language = language
        self.gender = gender
        self.age = age
        self.variant = variant
    }
}

/// Voice gender
public enum Gender {
    case male
    case female
    case neutral
}

/// Synthesis configuration
public struct Configuration {
    public var speed: Int = 175        // Words per minute (80-450)
    public var pitch: Int = 50         // Pitch (0-99)
    public var volume: Int = 100       // Volume (0-200)
    public var wordGap: Int = 0        // Pause between words (10ms units)
    public var voice: String?          // Voice identifier

    public init() {}
}

/// Errors that can occur during speech synthesis
public enum SpeakError: Error {
    case initializationFailed
    case voiceNotFound(String)
    case synthesisFailure(String)
    case fileWriteError(String)
    case invalidParameter(String)
}
