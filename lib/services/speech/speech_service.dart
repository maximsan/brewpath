/// Speaks a word aloud in the language the content is written in.
///
/// No feature code touches the speech package directly — only this interface,
/// the same arrangement payments, ads and analytics use. See ADR-0012.
abstract class SpeechService {
  /// Whether the platform can speak [languageTag] at all.
  ///
  /// A device with no voice installed for the language answers false, and the
  /// speaker is not drawn: a control that cannot do its one job is worse than
  /// its absence.
  Future<bool> canSpeak(String languageTag);

  /// Speaks [text] in [languageTag], cutting off anything already speaking.
  ///
  /// Pressing twice restarts the word rather than queueing a second reading,
  /// which is what the design does: `speechSynthesis.cancel()` before every
  /// `speak()`.
  Future<void> speak(String text, {required String languageTag});

  /// Stops and releases the platform's synthesizer.
  Future<void> dispose();
}

/// The language the content is written in.
///
/// English is the master and the only folder that ships today (ADR-0008); when
/// a language folder arrives it carries its own tag, and this constant becomes
/// a lookup. The device's own language is deliberately not consulted — a French
/// phone reading an English course must not pronounce *doppio* in French.
const String contentLanguageTag = 'en-US';
