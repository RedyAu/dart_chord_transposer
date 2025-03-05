/*
MIT License

Copyright (c) 2017 Duncan Cai

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

https://github.com/ddycai/chord-transposer
*/

/// This enum is used to differentiate between note notations.
/// | english | german | germanWithAccidentals |
/// |---------|--------|-----------------------|
/// | B       | H      | H                     |
/// | B#      | His    | H#                    |
/// | Bb      | B      | B                     |
/// | E       | E      | E                     |
/// | E#      | Eis    | E#                    |
/// | Eb      | Es     | Eb                    |
enum NoteNotation { english, german, germanWithAccidentals }

/// The rank for each possible chord. Rank is the distance in semitones from C.
Map<String, int> chordRanksFor(NoteNotation notation) {
  switch (notation) {
    case NoteNotation.english:
      return {
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
    case NoteNotation.german:
      return {
        "His": 0,
        "C": 0,
        "Cis": 1,
        "Des": 1,
        "D": 2,
        "Dis": 3,
        "Es": 3,
        "E": 4,
        "Fes": 4,
        "Eis": 5,
        "F": 5,
        "Fis": 6,
        "Ges": 6,
        "G": 7,
        "Gis": 8,
        "As": 8,
        "A": 9,
        "Ais": 10,
        "B": 10,
        "Ces": 11,
        "H": 11,
      };
    case NoteNotation.germanWithAccidentals:
      return {
        "H#": 0,
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
        "B": 10,
        "Cb": 11,
        "H": 11,
      };
  }
}

// For backward compatibility and default value
Map<String, int> get chordRanks => chordRanksFor(NoteNotation.english);

// Regex for recognizing chords.
String rootPatternFor(NoteNotation notation) {
  switch (notation) {
    case NoteNotation.english:
      return r"^(?<root>[A-Ga-g](#|b)?)";
    case NoteNotation.german:
      return r"^(?<root>[A-Ga-g](is|es|s)?|[Hh](is)?|[Bb])";
    case NoteNotation.germanWithAccidentals:
      return r"^(?<root>[A-Ga-g](#|b)?|[Hh](#)?|[Bb])";
  }
}

String bassPatternFor(NoteNotation notation) {
  switch (notation) {
    case NoteNotation.english:
      return r"(\/(?<bass>([A-Ga-g](#|b)?)))?";
    case NoteNotation.german:
      return r"(\/(?<bass>([A-Ga-g](is|es|s)?|[Hh](is)?|[Bb])))?";
    case NoteNotation.germanWithAccidentals:
      return r"(\/(?<bass>([A-Ga-g](#|b)?|[Hh](#)?|[Bb])))?";
  }
}

const String suffixPattern = r"(?<suffix>[^\/]*)?";
const String minorPattern = r"^(minor|min|m[^a]*)";

// Create a function to get the appropriate regex for a given notation
RegExp chordRegexFor(NoteNotation notation) {
  return RegExp(
    rootPatternFor(notation) + suffixPattern + bassPatternFor(notation),
  );
}

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
  final bool wasRootLowercase;

  Chord(this.root, this.suffix, this.bass, {this.wasRootLowercase = false});

  @override
  String toString() {
    String formattedRoot = wasRootLowercase ? root.toLowerCase() : root;
    
    if (bass.isNotEmpty) return "$formattedRoot$suffix/$bass";
    return formattedRoot + suffix;
  }

  bool isMinor() => minorSufficRegex.hasMatch(suffix);

  static Chord parse(
    String text, [
    NoteNotation notation = NoteNotation.english,
  ]) {
    final RegExp regex = chordRegexFor(notation);
    if (!regex.hasMatch(text)) throw Exception("$text is not a valid chord");
    final RegExpMatch result = regex.firstMatch(text)!;
    
    String rootText = result.namedGroup('root')!;
    bool wasRootLowercase = rootText.isNotEmpty && 
                          rootText[0].toLowerCase() == rootText[0] && 
                          rootText[0].toUpperCase() != rootText[0];
    
    // Normalize the root to uppercase for internal representation
    String normalizedRoot = wasRootLowercase 
        ? rootText[0].toUpperCase() + rootText.substring(1) 
        : rootText;
    
    return Chord(
      normalizedRoot,
      result.namedGroup('suffix') ?? '',
      result.namedGroup('bass') ?? '',
      wasRootLowercase: wasRootLowercase,
    );
  }

  static bool isChord(
    String token, {
    NoteNotation notation = NoteNotation.english,
  }) => chordRegexFor(notation).hasMatch(token);
}
