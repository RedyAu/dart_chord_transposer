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

// ignore_for_file: non_constant_identifier_names

import 'chord.dart' show rootPattern, minorPattern, Chord;

// Chromatic scale starting from C using flats only.
const List<String> flatScale = [
  "C",
  "Db",
  "D",
  "Eb",
  "E",
  "F",
  "Gb",
  "G",
  "Ab",
  "A",
  "Bb",
  "Cb"
];

// Chromatic scale starting from C using sharps only.
const List<String> sharpScale = [
  "C",
  "C#",
  "D",
  "D#",
  "E",
  "F",
  "F#",
  "G",
  "G#",
  "A",
  "A#",
  "B"
];

// Chromatic scale for F# major which includes E#.
final List<String> FSharpScale =
    sharpScale.map((note) => identical(note, "F") ? "E#" : note).toList();

// Chromatic scale for C# major which includes E# and B#.
final List<String> CSharpScale =
    FSharpScale.map((note) => identical(note, "C") ? "B#" : note).toList();

// Chromatic scale for Gb major which includes Cb.
final List<String> GFlatScale =
    flatScale.map((note) => identical(note, "B") ? "Cb" : note).toList();

// Chromatic scale for Cb major which includes Cb and Fb.
final List<String> CFlatScale =
    GFlatScale.map((note) => identical(note, "E") ? "Fb" : note).toList();

final RegExp keySignatureRegExp = RegExp("($rootPattern)($minorPattern)?");

enum KeyType { flat, sharp }

class KeySignature {
  String majorKey;
  String relativeMinor;
  KeyType keyType;
  int rank;
  List<String> chromaticScale;
  KeySignature(this.majorKey, this.relativeMinor, this.keyType, this.rank,
      this.chromaticScale);
}

// A list of all the available key signatures.
final List<KeySignature> signatures = [
  KeySignature("C", "Am", KeyType.sharp, 0, sharpScale),
  KeySignature("Db", "Bbm", KeyType.flat, 1, flatScale),
  KeySignature("D", "Bm", KeyType.sharp, 2, sharpScale),
  KeySignature("Eb", "Cm", KeyType.flat, 3, flatScale),
  KeySignature("E", "C#m", KeyType.sharp, 4, sharpScale),
  KeySignature("F", "Dm", KeyType.flat, 5, flatScale),
  KeySignature("Gb", "Ebm", KeyType.flat, 6, GFlatScale),
  KeySignature("F#", "D#m", KeyType.sharp, 6, FSharpScale),
  KeySignature("G", "Em", KeyType.sharp, 7, sharpScale),
  KeySignature("Ab", "Fm", KeyType.flat, 8, flatScale),
  KeySignature("A", "F#m", KeyType.sharp, 9, sharpScale),
  KeySignature("Bb", "Gm", KeyType.flat, 10, flatScale),
  KeySignature("B", "G#m", KeyType.sharp, 11, sharpScale),

  // Unconventional key signatures:
  KeySignature("C#", "A#m", KeyType.sharp, 1, CSharpScale),
  KeySignature("Cb", "Abm", KeyType.flat, 11, CFlatScale),
  KeySignature("D#", "", KeyType.sharp, 8, sharpScale),
];

/// An object that parses and calculates key signatures.
class KeySignatureProcessor {
  /// A map of all the KeySignatures with their name. `<`key name, key signature>.
  late Map<String, KeySignature> _keySignatureMap;

  /// A map of all the KeySignatures with their rank. `<`key rank, key signature>.
  late Map<num, KeySignature> _rankMap;

  KeySignatureProcessor() {
    _keySignatureMap = {};
    _rankMap = {};

    /// Generated the rankMap and keySignatureMap from the list of signatures.
    for (KeySignature signature in signatures) {
      _keySignatureMap.addAll({signature.majorKey: signature});
      _keySignatureMap.addAll({signature.relativeMinor: signature});
      if (!_rankMap.containsKey(signature.rank)) {
        _rankMap.addAll({signature.rank: signature});
      }
    }
  }

  /// Returns the KeySignature with the specific name or throws an error if the key signature is not valid.
  KeySignature parse(String text) {
    if (keySignatureRegExp.hasMatch(text)) {
      final Chord chord = Chord.parse(text);
      final String signatureName =
          chord.isMinor() ? "${chord.root}m" : chord.root;
      final KeySignature? foundSignature = _keySignatureMap[signatureName];
      if (foundSignature != null) return foundSignature;

      // If all else fails, try to find any key with this chord in it.
      for (KeySignature signature in signatures) {
        if (signature.chromaticScale.contains(chord.root)) return signature;
      }
    }
    throw Exception("$text is not a valid key signature.");
  }

  /// Gets Keysignature from rank.
  KeySignature fromRank(int rank) {
    final KeySignature? signature = _rankMap[rank];
    if (signature != null) return signature;
    throw Exception("$rank is not a valid rank.");
  }

  /// Transforms the given chord into a key signature.
  KeySignature guessKeySignature(Chord chord) {
    String signature = chord.root;
    if (chord.isMinor()) signature += "m";
    return parse(signature);
  }
}
