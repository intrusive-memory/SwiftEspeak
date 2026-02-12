# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

For detailed project documentation, architecture, and development guidelines, see **[AGENTS.md](AGENTS.md)**.

## Quick Reference

**Project**: SwiftEspeak - A Swift wrapper for eSpeak-NG text-to-speech engine

**Platforms**: macOS 11.0+, iOS 14.0+

**Key Components**:
- Text-to-speech synthesis via eSpeak-NG
- Voice discovery and selection
- Audio file generation (WAV)
- `swift-espeak` CLI tool (similar to macOS `say`)

**Important Notes**:
- **Experimental Status**: This library is incomplete and under development. The API is unstable and subject to change. **Do not use in production.**
- Requires eSpeak-NG installed via Homebrew: `brew install espeak-ng`
- Uses C bridging via `systemLibrary` target (`CEspeak`) with pkg-config
- See [AGENTS.md](AGENTS.md) for complete architecture, C bridging patterns, and implementation status
