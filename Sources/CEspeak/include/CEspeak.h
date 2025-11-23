#ifndef CESPEAK_H
#define CESPEAK_H

// This header bridges eSpeak-NG C API to Swift
// It wraps the main eSpeak functions needed for voice discovery and synthesis

#include <espeak-ng/speak_lib.h>

// Re-export commonly used eSpeak constants and types for Swift access
// These make it easier to work with eSpeak from Swift code

// Audio output modes
#define ESPEAK_AUDIO_OUTPUT_PLAYBACK      AUDIO_OUTPUT_PLAYBACK
#define ESPEAK_AUDIO_OUTPUT_RETRIEVAL     AUDIO_OUTPUT_RETRIEVAL
#define ESPEAK_AUDIO_OUTPUT_SYNCHRONOUS   AUDIO_OUTPUT_SYNCHRONOUS
#define ESPEAK_AUDIO_OUTPUT_SYNCH_PLAYBACK AUDIO_OUTPUT_SYNCH_PLAYBACK

// Position types
#define ESPEAK_POS_CHARACTER    POS_CHARACTER
#define ESPEAK_POS_WORD         POS_WORD
#define ESPEAK_POS_SENTENCE     POS_SENTENCE

// Initialization flags
#define ESPEAK_INITIALIZE_PHONEME_EVENTS  espeakINITIALIZE_PHONEME_EVENTS
#define ESPEAK_INITIALIZE_PHONEME_IPA     espeakINITIALIZE_PHONEME_IPA
#define ESPEAK_INITIALIZE_DONT_EXIT       espeakINITIALIZE_DONT_EXIT

#endif /* CESPEAK_H */
