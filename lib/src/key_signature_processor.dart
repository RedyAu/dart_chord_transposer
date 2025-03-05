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

import 'chord.dart'
    show rootPatternFor, minorPattern, Chord, NoteNotation;

/// Definition of a key signature in a specific notation
class NotationKeyDefinition {
  final String majorKey;
  final String relativeMinor;
  final List<String> flatScale;
  final List<String> sharpScale;

  const NotationKeyDefinition({
    required this.majorKey,
    required this.relativeMinor,
    required this.flatScale,
    required this.sharpScale,
  });
}

/// Complete key signature definition for all notations
class KeyDefinition {
  final int rank;
  final KeyType keyType;
  final bool isStandard; // Standard vs unconventional key
  final Map<NoteNotation, NotationKeyDefinition> notations;

  const KeyDefinition({
    required this.rank,
    required this.keyType,
    this.isStandard = true,
    required this.notations,
  });
}

/// Maps notation types to scales
final Map<NoteNotation, List<List<String>>> baseScales = {
  // English notation scales
  NoteNotation.english: [
    ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"], // flat
    ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"], // sharp
  ],

  // German notation scales
  NoteNotation.german: [
    ["C", "Des", "D", "Es", "E", "F", "Ges", "G", "As", "A", "B", "H"], // flat
    [
      "C",
      "Cis",
      "D",
      "Dis",
      "E",
      "F",
      "Fis",
      "G",
      "Gis",
      "A",
      "Ais",
      "H",
    ], // sharp
  ],

  // German with accidentals scales
  NoteNotation.germanWithAccidentals: [
    ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "B", "H"], // flat
    ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "H"], // sharp
  ],
};

// F# scales (with E#)
final Map<NoteNotation, List<String>> fSharpScales = {
  NoteNotation.english: [
    "C",
    "C#",
    "D",
    "D#",
    "E",
    "E#",
    "F#",
    "G",
    "G#",
    "A",
    "A#",
    "B",
  ],
  NoteNotation.german: [
    "C",
    "Cis",
    "D",
    "Dis",
    "E",
    "Eis",
    "Fis",
    "G",
    "Gis",
    "A",
    "Ais",
    "H",
  ],
  NoteNotation.germanWithAccidentals: [
    "C",
    "C#",
    "D",
    "D#",
    "E",
    "E#",
    "F#",
    "G",
    "G#",
    "A",
    "A#",
    "H",
  ],
};

// Special C# scales (with E# and B#)
final Map<NoteNotation, List<String>> cSharpScales = {
  NoteNotation.english: [
    "B#",
    "C#",
    "D",
    "D#",
    "E",
    "E#",
    "F#",
    "G",
    "G#",
    "A",
    "A#",
    "B",
  ],
  NoteNotation.german: [
    "His",
    "Cis",
    "D",
    "Dis",
    "E",
    "Eis",
    "Fis",
    "G",
    "Gis",
    "A",
    "Ais",
    "H",
  ],
  NoteNotation.germanWithAccidentals: [
    "H#",
    "C#",
    "D",
    "D#",
    "E",
    "E#",
    "F#",
    "G",
    "G#",
    "A",
    "A#",
    "H",
  ],
};

// Special Gb scales (with Cb)
final Map<NoteNotation, List<String>> gFlatScales = {
  NoteNotation.english: [
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
    "Cb",
  ],
  NoteNotation.german: [
    "C",
    "Des",
    "D",
    "Es",
    "E",
    "F",
    "Ges",
    "G",
    "As",
    "A",
    "B",
    "Ces",
  ],
  NoteNotation.germanWithAccidentals: [
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
    "B",
    "Cb",
  ],
};

// Special Cb scales (with Fb)
final Map<NoteNotation, List<String>> cFlatScales = {
  NoteNotation.english: [
    "C",
    "Db",
    "D",
    "Eb",
    "Fb",
    "F",
    "Gb",
    "G",
    "Ab",
    "A",
    "Bb",
    "Cb",
  ],
  NoteNotation.german: [
    "C",
    "Des",
    "D",
    "Es",
    "Fes",
    "F",
    "Ges",
    "G",
    "As",
    "A",
    "B",
    "Ces",
  ],
  NoteNotation.germanWithAccidentals: [
    "C",
    "Db",
    "D",
    "Eb",
    "Fb",
    "F",
    "Gb",
    "G",
    "Ab",
    "A",
    "B",
    "Cb",
  ],
};

enum KeyType { flat, sharp }

/// Definition of all key signatures
final List<KeyDefinition> keyDefinitions = [
  // C Major
  KeyDefinition(
    rank: 0,
    keyType: KeyType.sharp,
    notations: {
      NoteNotation.english: NotationKeyDefinition(
        majorKey: "C",
        relativeMinor: "Am",
        flatScale: baseScales[NoteNotation.english]![0],
        sharpScale: baseScales[NoteNotation.english]![1],
      ),
      NoteNotation.german: NotationKeyDefinition(
        majorKey: "C",
        relativeMinor: "Am",
        flatScale: baseScales[NoteNotation.german]![0],
        sharpScale: baseScales[NoteNotation.german]![1],
      ),
      NoteNotation.germanWithAccidentals: NotationKeyDefinition(
        majorKey: "C",
        relativeMinor: "Am",
        flatScale: baseScales[NoteNotation.germanWithAccidentals]![0],
        sharpScale: baseScales[NoteNotation.germanWithAccidentals]![1],
      ),
    },
  ),

  // Db/C# Major
  KeyDefinition(
    rank: 1,
    keyType: KeyType.flat,
    notations: {
      NoteNotation.english: NotationKeyDefinition(
        majorKey: "Db",
        relativeMinor: "Bbm",
        flatScale: baseScales[NoteNotation.english]![0],
        sharpScale: baseScales[NoteNotation.english]![1],
      ),
      NoteNotation.german: NotationKeyDefinition(
        majorKey: "Des",
        relativeMinor: "Bm",
        flatScale: baseScales[NoteNotation.german]![0],
        sharpScale: baseScales[NoteNotation.german]![1],
      ),
      NoteNotation.germanWithAccidentals: NotationKeyDefinition(
        majorKey: "Db",
        relativeMinor: "Bm",
        flatScale: baseScales[NoteNotation.germanWithAccidentals]![0],
        sharpScale: baseScales[NoteNotation.germanWithAccidentals]![1],
      ),
    },
  ),

  // D Major
  KeyDefinition(
    rank: 2,
    keyType: KeyType.sharp,
    notations: {
      NoteNotation.english: NotationKeyDefinition(
        majorKey: "D",
        relativeMinor: "Bm",
        flatScale: baseScales[NoteNotation.english]![0],
        sharpScale: baseScales[NoteNotation.english]![1],
      ),
      NoteNotation.german: NotationKeyDefinition(
        majorKey: "D",
        relativeMinor: "Hm",
        flatScale: baseScales[NoteNotation.german]![0],
        sharpScale: baseScales[NoteNotation.german]![1],
      ),
      NoteNotation.germanWithAccidentals: NotationKeyDefinition(
        majorKey: "D",
        relativeMinor: "Hm",
        flatScale: baseScales[NoteNotation.germanWithAccidentals]![0],
        sharpScale: baseScales[NoteNotation.germanWithAccidentals]![1],
      ),
    },
  ),

  // Eb Major
  KeyDefinition(
    rank: 3,
    keyType: KeyType.flat,
    notations: {
      NoteNotation.english: NotationKeyDefinition(
        majorKey: "Eb",
        relativeMinor: "Cm",
        flatScale: baseScales[NoteNotation.english]![0],
        sharpScale: baseScales[NoteNotation.english]![1],
      ),
      NoteNotation.german: NotationKeyDefinition(
        majorKey: "Es",
        relativeMinor: "Cm",
        flatScale: baseScales[NoteNotation.german]![0],
        sharpScale: baseScales[NoteNotation.german]![1],
      ),
      NoteNotation.germanWithAccidentals: NotationKeyDefinition(
        majorKey: "Eb",
        relativeMinor: "Cm",
        flatScale: baseScales[NoteNotation.germanWithAccidentals]![0],
        sharpScale: baseScales[NoteNotation.germanWithAccidentals]![1],
      ),
    },
  ),

  // E Major
  KeyDefinition(
    rank: 4,
    keyType: KeyType.sharp,
    notations: {
      NoteNotation.english: NotationKeyDefinition(
        majorKey: "E",
        relativeMinor: "C#m",
        flatScale: baseScales[NoteNotation.english]![0],
        sharpScale: baseScales[NoteNotation.english]![1],
      ),
      NoteNotation.german: NotationKeyDefinition(
        majorKey: "E",
        relativeMinor: "Cism",
        flatScale: baseScales[NoteNotation.german]![0],
        sharpScale: baseScales[NoteNotation.german]![1],
      ),
      NoteNotation.germanWithAccidentals: NotationKeyDefinition(
        majorKey: "E",
        relativeMinor: "C#m",
        flatScale: baseScales[NoteNotation.germanWithAccidentals]![0],
        sharpScale: baseScales[NoteNotation.germanWithAccidentals]![1],
      ),
    },
  ),

  // F Major
  KeyDefinition(
    rank: 5,
    keyType: KeyType.flat,
    notations: {
      NoteNotation.english: NotationKeyDefinition(
        majorKey: "F",
        relativeMinor: "Dm",
        flatScale: baseScales[NoteNotation.english]![0],
        sharpScale: baseScales[NoteNotation.english]![1],
      ),
      NoteNotation.german: NotationKeyDefinition(
        majorKey: "F",
        relativeMinor: "Dm",
        flatScale: baseScales[NoteNotation.german]![0],
        sharpScale: baseScales[NoteNotation.german]![1],
      ),
      NoteNotation.germanWithAccidentals: NotationKeyDefinition(
        majorKey: "F",
        relativeMinor: "Dm",
        flatScale: baseScales[NoteNotation.germanWithAccidentals]![0],
        sharpScale: baseScales[NoteNotation.germanWithAccidentals]![1],
      ),
    },
  ),

  // F# Major
  KeyDefinition(
    rank: 6,
    keyType: KeyType.sharp,
    notations: {
      NoteNotation.english: NotationKeyDefinition(
        majorKey: "F#",
        relativeMinor: "D#m",
        flatScale: baseScales[NoteNotation.english]![0],
        sharpScale: fSharpScales[NoteNotation.english]!,
      ),
      NoteNotation.german: NotationKeyDefinition(
        majorKey: "Fis",
        relativeMinor: "Dism",
        flatScale: baseScales[NoteNotation.german]![0],
        sharpScale: fSharpScales[NoteNotation.german]!,
      ),
      NoteNotation.germanWithAccidentals: NotationKeyDefinition(
        majorKey: "F#",
        relativeMinor: "D#m",
        flatScale: baseScales[NoteNotation.germanWithAccidentals]![0],
        sharpScale: fSharpScales[NoteNotation.germanWithAccidentals]!,
      ),
    },
  ),

  // Gb Major
  KeyDefinition(
    rank: 6,
    keyType: KeyType.flat,
    notations: {
      NoteNotation.english: NotationKeyDefinition(
        majorKey: "Gb",
        relativeMinor: "Ebm",
        flatScale: gFlatScales[NoteNotation.english]!,
        sharpScale: baseScales[NoteNotation.english]![1],
      ),
      NoteNotation.german: NotationKeyDefinition(
        majorKey: "Ges",
        relativeMinor: "Esm",
        flatScale: gFlatScales[NoteNotation.german]!,
        sharpScale: baseScales[NoteNotation.german]![1],
      ),
      NoteNotation.germanWithAccidentals: NotationKeyDefinition(
        majorKey: "Gb",
        relativeMinor: "Ebm",
        flatScale: gFlatScales[NoteNotation.germanWithAccidentals]!,
        sharpScale: baseScales[NoteNotation.germanWithAccidentals]![1],
      ),
    },
  ),

  // G Major
  KeyDefinition(
    rank: 7,
    keyType: KeyType.sharp,
    notations: {
      NoteNotation.english: NotationKeyDefinition(
        majorKey: "G",
        relativeMinor: "Em",
        flatScale: baseScales[NoteNotation.english]![0],
        sharpScale: baseScales[NoteNotation.english]![1],
      ),
      NoteNotation.german: NotationKeyDefinition(
        majorKey: "G",
        relativeMinor: "Em",
        flatScale: baseScales[NoteNotation.german]![0],
        sharpScale: baseScales[NoteNotation.german]![1],
      ),
      NoteNotation.germanWithAccidentals: NotationKeyDefinition(
        majorKey: "G",
        relativeMinor: "Em",
        flatScale: baseScales[NoteNotation.germanWithAccidentals]![0],
        sharpScale: baseScales[NoteNotation.germanWithAccidentals]![1],
      ),
    },
  ),

  // Ab Major
  KeyDefinition(
    rank: 8,
    keyType: KeyType.flat,
    notations: {
      NoteNotation.english: NotationKeyDefinition(
        majorKey: "Ab",
        relativeMinor: "Fm",
        flatScale: baseScales[NoteNotation.english]![0],
        sharpScale: baseScales[NoteNotation.english]![1],
      ),
      NoteNotation.german: NotationKeyDefinition(
        majorKey: "As",
        relativeMinor: "Fm",
        flatScale: baseScales[NoteNotation.german]![0],
        sharpScale: baseScales[NoteNotation.german]![1],
      ),
      NoteNotation.germanWithAccidentals: NotationKeyDefinition(
        majorKey: "Ab",
        relativeMinor: "Fm",
        flatScale: baseScales[NoteNotation.germanWithAccidentals]![0],
        sharpScale: baseScales[NoteNotation.germanWithAccidentals]![1],
      ),
    },
  ),

  // A Major
  KeyDefinition(
    rank: 9,
    keyType: KeyType.sharp,
    notations: {
      NoteNotation.english: NotationKeyDefinition(
        majorKey: "A",
        relativeMinor: "F#m",
        flatScale: baseScales[NoteNotation.english]![0],
        sharpScale: baseScales[NoteNotation.english]![1],
      ),
      NoteNotation.german: NotationKeyDefinition(
        majorKey: "A",
        relativeMinor: "Fism",
        flatScale: baseScales[NoteNotation.german]![0],
        sharpScale: baseScales[NoteNotation.german]![1],
      ),
      NoteNotation.germanWithAccidentals: NotationKeyDefinition(
        majorKey: "A",
        relativeMinor: "F#m",
        flatScale: baseScales[NoteNotation.germanWithAccidentals]![0],
        sharpScale: baseScales[NoteNotation.germanWithAccidentals]![1],
      ),
    },
  ),

  // Bb Major
  KeyDefinition(
    rank: 10,
    keyType: KeyType.flat,
    notations: {
      NoteNotation.english: NotationKeyDefinition(
        majorKey: "Bb",
        relativeMinor: "Gm",
        flatScale: baseScales[NoteNotation.english]![0],
        sharpScale: baseScales[NoteNotation.english]![1],
      ),
      NoteNotation.german: NotationKeyDefinition(
        majorKey: "B",
        relativeMinor: "Gm",
        flatScale: baseScales[NoteNotation.german]![0],
        sharpScale: baseScales[NoteNotation.german]![1],
      ),
      NoteNotation.germanWithAccidentals: NotationKeyDefinition(
        majorKey: "B",
        relativeMinor: "Gm",
        flatScale: baseScales[NoteNotation.germanWithAccidentals]![0],
        sharpScale: baseScales[NoteNotation.germanWithAccidentals]![1],
      ),
    },
  ),

  // B Major
  KeyDefinition(
    rank: 11,
    keyType: KeyType.sharp,
    notations: {
      NoteNotation.english: NotationKeyDefinition(
        majorKey: "B",
        relativeMinor: "G#m",
        flatScale: baseScales[NoteNotation.english]![0],
        sharpScale: baseScales[NoteNotation.english]![1],
      ),
      NoteNotation.german: NotationKeyDefinition(
        majorKey: "H",
        relativeMinor: "Gism",
        flatScale: baseScales[NoteNotation.german]![0],
        sharpScale: baseScales[NoteNotation.german]![1],
      ),
      NoteNotation.germanWithAccidentals: NotationKeyDefinition(
        majorKey: "H",
        relativeMinor: "G#m",
        flatScale: baseScales[NoteNotation.germanWithAccidentals]![0],
        sharpScale: baseScales[NoteNotation.germanWithAccidentals]![1],
      ),
    },
  ),

  // C# Major (unconventional)
  KeyDefinition(
    rank: 1,
    keyType: KeyType.sharp,
    isStandard: false,
    notations: {
      NoteNotation.english: NotationKeyDefinition(
        majorKey: "C#",
        relativeMinor: "A#m",
        flatScale: baseScales[NoteNotation.english]![0],
        sharpScale: cSharpScales[NoteNotation.english]!,
      ),
      NoteNotation.german: NotationKeyDefinition(
        majorKey: "Cis",
        relativeMinor: "Aism",
        flatScale: baseScales[NoteNotation.german]![0],
        sharpScale: cSharpScales[NoteNotation.german]!,
      ),
      NoteNotation.germanWithAccidentals: NotationKeyDefinition(
        majorKey: "C#",
        relativeMinor: "A#m",
        flatScale: baseScales[NoteNotation.germanWithAccidentals]![0],
        sharpScale: cSharpScales[NoteNotation.germanWithAccidentals]!,
      ),
    },
  ),

  // Cb Major (unconventional)
  KeyDefinition(
    rank: 11,
    keyType: KeyType.flat,
    isStandard: false,
    notations: {
      NoteNotation.english: NotationKeyDefinition(
        majorKey: "Cb",
        relativeMinor: "Abm",
        flatScale: cFlatScales[NoteNotation.english]!,
        sharpScale: baseScales[NoteNotation.english]![1],
      ),
      NoteNotation.german: NotationKeyDefinition(
        majorKey: "Ces",
        relativeMinor: "Asm",
        flatScale: cFlatScales[NoteNotation.german]!,
        sharpScale: baseScales[NoteNotation.german]![1],
      ),
      NoteNotation.germanWithAccidentals: NotationKeyDefinition(
        majorKey: "Cb",
        relativeMinor: "Abm",
        flatScale: cFlatScales[NoteNotation.germanWithAccidentals]!,
        sharpScale: baseScales[NoteNotation.germanWithAccidentals]![1],
      ),
    },
  ),

  // D# Major (unconventional)
  KeyDefinition(
    rank: 3,
    keyType: KeyType.sharp,
    isStandard: false,
    notations: {
      NoteNotation.english: NotationKeyDefinition(
        majorKey: "D#",
        relativeMinor: "",
        flatScale: baseScales[NoteNotation.english]![0],
        sharpScale: baseScales[NoteNotation.english]![1],
      ),
      NoteNotation.german: NotationKeyDefinition(
        majorKey: "Dis",
        relativeMinor: "",
        flatScale: baseScales[NoteNotation.german]![0],
        sharpScale: baseScales[NoteNotation.german]![1],
      ),
      NoteNotation.germanWithAccidentals: NotationKeyDefinition(
        majorKey: "D#",
        relativeMinor: "",
        flatScale: baseScales[NoteNotation.germanWithAccidentals]![0],
        sharpScale: baseScales[NoteNotation.germanWithAccidentals]![1],
      ),
    },
  ),
];

class KeySignature {
  String majorKey;
  String relativeMinor;
  KeyType keyType;
  int rank;
  List<String> chromaticScale;
  NoteNotation notation;

  KeySignature(
    this.majorKey,
    this.relativeMinor,
    this.keyType,
    this.rank,
    this.chromaticScale,
    this.notation,
  );
}

/// An object that parses and calculates key signatures.
class KeySignatureProcessor {
  /// A map of all the KeySignatures with their name. &lt;key name, key signature>.
  late Map<String, KeySignature> _keySignatureMap;

  /// A map of all the KeySignatures with their rank. &lt;key rank, key signature>.
  late Map<num, KeySignature> _rankMap;

  final NoteNotation notation;

  KeySignatureProcessor({this.notation = NoteNotation.english}) {
    _keySignatureMap = {};
    _rankMap = {};

    // Generate signatures from the definitions
    for (final keyDef in keyDefinitions) {
      final notationDef = keyDef.notations[notation]!;
      final scale =
          keyDef.keyType == KeyType.flat
              ? notationDef.flatScale
              : notationDef.sharpScale;

      final signature = KeySignature(
        notationDef.majorKey,
        notationDef.relativeMinor,
        keyDef.keyType,
        keyDef.rank,
        scale,
        notation,
      );

      _keySignatureMap[signature.majorKey] = signature;
      if (signature.relativeMinor.isNotEmpty) {
        _keySignatureMap[signature.relativeMinor] = signature;
      }

      // Only add standard keys to rank map to avoid duplicates
      if (keyDef.isStandard && !_rankMap.containsKey(keyDef.rank)) {
        _rankMap[keyDef.rank] = signature;
      }
    }
  }

  /// Returns the KeySignature with the specific name or throws an error if the key signature is not valid.
  KeySignature parse(String text) {
    final regExpForNotation = RegExp(
      "(${rootPatternFor(notation)})($minorPattern)?",
    );

    if (regExpForNotation.hasMatch(text)) {
      final Chord chord = Chord.parse(text, notation);
      final String signatureName =
          chord.isMinor() ? "${chord.root}m" : chord.root;
      final KeySignature? foundSignature = _keySignatureMap[signatureName];
      if (foundSignature != null) return foundSignature;

      // If all else fails, try to find any key with this chord in it.
      for (KeyDefinition keyDef in keyDefinitions) {
        final notationDef = keyDef.notations[notation]!;
        final scale =
            keyDef.keyType == KeyType.flat
                ? notationDef.flatScale
                : notationDef.sharpScale;

        if (scale.contains(chord.root)) {
          return KeySignature(
            notationDef.majorKey,
            notationDef.relativeMinor,
            keyDef.keyType,
            keyDef.rank,
            scale,
            notation,
          );
        }
      }
    }
    throw Exception("$text is not a valid key signature.");
  }

  /// Gets Keysignature from rank.
  KeySignature fromRank(int rank) {
    final normalizedRank = (rank % 12 + 12) % 12; // Ensure it's 0-11
    final KeySignature? signature = _rankMap[normalizedRank];
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
