import XCTest
@testable import SwiftEspeak

final class SwiftEspeakTests: XCTestCase {

    // MARK: - Initialization Tests

    func testInitialization() throws {
        // Test that SwiftEspeak can be initialized
        let espeak = try SwiftEspeak()
        XCTAssertNotNil(espeak)
    }

    // MARK: - Voice Discovery Tests

    func testListAllVoices() throws {
        let espeak = try SwiftEspeak()
        let voices = try espeak.listVoices()

        // eSpeak should have at least some voices available
        XCTAssertFalse(voices.isEmpty, "eSpeak should have at least one voice available")

        // Verify voice structure
        for voice in voices.prefix(5) {
            XCTAssertFalse(voice.name.isEmpty, "Voice name should not be empty")
            XCTAssertFalse(voice.language.isEmpty, "Voice language should not be empty")
        }
    }

    func testListEnglishVoices() throws {
        let espeak = try SwiftEspeak()
        let englishVoices = try espeak.listVoices(language: "en")

        // There should be English voices
        XCTAssertFalse(englishVoices.isEmpty, "eSpeak should have English voices")

        // All voices should be English variants
        for voice in englishVoices {
            XCTAssertTrue(
                voice.language.hasPrefix("en"),
                "Voice '\(voice.name)' should be an English variant, got language: \(voice.language)"
            )
        }
    }

    func testListVoicesByLanguage() throws {
        let espeak = try SwiftEspeak()

        // Test a few common languages
        let languagesToTest = ["en", "es", "fr", "de"]

        for language in languagesToTest {
            let voices = try espeak.listVoices(language: language)

            // Print for debugging (optional, can be removed)
            if !voices.isEmpty {
                print("Found \(voices.count) voice(s) for language '\(language)'")
            }

            // If voices are found, verify they match the language
            for voice in voices {
                XCTAssertTrue(
                    voice.language.hasPrefix(language),
                    "Voice should be for language '\(language)' but got '\(voice.language)'"
                )
            }
        }
    }

    func testVoiceProperties() throws {
        let espeak = try SwiftEspeak()
        let voices = try espeak.listVoices()

        // Find a voice to test properties
        guard let testVoice = voices.first else {
            XCTFail("No voices available for testing")
            return
        }

        // Test that properties are accessible
        XCTAssertFalse(testVoice.name.isEmpty)
        XCTAssertFalse(testVoice.language.isEmpty)

        // Gender should be one of the valid values
        let validGenders: [Gender] = [.male, .female, .neutral]
        XCTAssertTrue(validGenders.contains(testVoice.gender))

        // Variant should be non-negative
        XCTAssertGreaterThanOrEqual(testVoice.variant, 0)

        print("Test voice: \(testVoice.name)")
        print("  Language: \(testVoice.language)")
        print("  Gender: \(testVoice.gender)")
        print("  Age: \(testVoice.age?.description ?? "unspecified")")
        print("  Variant: \(testVoice.variant)")
    }

    // MARK: - Voice Setting Tests

    func testSetVoice() throws {
        let espeak = try SwiftEspeak()
        let voices = try espeak.listVoices()

        guard let firstVoice = voices.first else {
            XCTFail("No voices available for testing")
            return
        }

        // Should be able to set a valid voice
        XCTAssertNoThrow(try espeak.setVoice(firstVoice.name))
    }

    func testSetInvalidVoice() throws {
        let espeak = try SwiftEspeak()

        // Setting an invalid voice should throw an error
        XCTAssertThrowsError(try espeak.setVoice("invalid_voice_name_12345")) { error in
            guard case SpeakError.voiceNotFound(let voiceName) = error else {
                XCTFail("Expected voiceNotFound error, got \(error)")
                return
            }
            XCTAssertEqual(voiceName, "invalid_voice_name_12345")
        }
    }

    func testSetMultipleVoices() throws {
        let espeak = try SwiftEspeak()
        let voices = try espeak.listVoices()

        // Test switching between multiple voices
        for voice in voices.prefix(5) {
            XCTAssertNoThrow(
                try espeak.setVoice(voice.name),
                "Should be able to set voice '\(voice.name)'"
            )
        }
    }

    // MARK: - Performance Tests

    func testVoiceListingPerformance() throws {
        let espeak = try SwiftEspeak()

        measure {
            _ = try? espeak.listVoices()
        }
    }
}
