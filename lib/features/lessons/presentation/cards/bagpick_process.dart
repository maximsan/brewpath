/// How the three processes are written for a learner.
///
/// A process travels as its key — `washed`, `honey`, `natural` — because that
/// is what the content authors and what an answer is compared against. The
/// label is only ever for reading.
library;

const Map<String, String> _labels = {
  'washed': 'Washed',
  'honey': 'Honey',
  'natural': 'Natural',
};

/// [process] as a learner reads it, falling back to the key itself so an
/// unrecognised process still names something rather than rendering blank.
String processLabel(String process) => _labels[process] ?? process;
