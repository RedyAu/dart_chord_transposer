/// The rank for each possible chord. Rank is the distance in semitones from C.
const Map<String, int> chordRanks = {
  "B#": 0,
  "C": 0,
  "C#": 1,
  "Db": 1,
  "D": 2,
  "D#": 3,
  "Eb": 3,
  "E": 4,
  "Fb": 4,
  "E#": 5,
  "F": 5,
  "F#": 6,
  "Gb": 6,
  "G": 7,
  "G#": 8,
  "Ab": 8,
  "A": 9,
  "A#": 10,
  "Bb": 10,
  "Cb": 11,
  "B": 11,
};

// Regex for recognizing chords.
const String rootPattern = r"^(?<root>[A-G](#|b)?)";
const String suffixPattern = r"(?<suffix>[^\/]*)?";
const String bassPattern = r"(\/(?<bass>([A-G](#|b)?)))?";
const String minorPattern = r"^(minor|min|m[^a]*)";
final RegExp chordRegex = RegExp("$rootPattern$suffixPattern$bassPattern");
final RegExp minorSufficRegex = RegExp(minorPattern);

/// Represents a musical chord. For example, Ddim/F# would have:
///
/// root: D
/// suffix: dim
/// bass: F#
class Chord {
  final String root;
  final String suffix;
  final String bass;

  Chord(this.root, this.suffix, this.bass);

  @override
  String toString() {
    if (bass.isNotEmpty) return root + suffix + "/" + bass;
    return root + suffix;
  }

  bool isMinor() => minorSufficRegex.hasMatch(suffix);

  static Chord parse(String text) {
    if (!isChord(text)) throw Exception("$text is not a valid chord");
    final RegExpMatch _result = chordRegex.firstMatch(text)!;
    return Chord(_result.namedGroup('root')!, _result.namedGroup('suffix') ?? '', _result.namedGroup('bass') ?? '');
  }

  static bool isChord(token) => chordRegex.hasMatch(token);
}
