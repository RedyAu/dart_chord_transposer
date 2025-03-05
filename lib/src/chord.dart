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
    if (bass.isNotEmpty) return "$root$suffix/$bass";
    return root + suffix;
  }

  bool isMinor() => minorSufficRegex.hasMatch(suffix);

  static Chord parse(String text) {
    if (!isChord(text)) throw Exception("$text is not a valid chord");
    final RegExpMatch result = chordRegex.firstMatch(text)!;
    return Chord(result.namedGroup('root')!,
        result.namedGroup('suffix') ?? '', result.namedGroup('bass') ?? '');
  }

  static bool isChord(token) => chordRegex.hasMatch(token);
}
