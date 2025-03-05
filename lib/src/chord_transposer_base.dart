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

import 'chord.dart' show chordRanksFor, Chord, NoteNotation;
import 'key_signature_processor.dart' show KeySignature, KeySignatureProcessor;

/// An object that transposes chords into any given key.
class ChordTransposer {
  /// Note notation to use for parsing and transposing
  final NoteNotation notation;

  /// An object that parses and calculates key signatures.
  late final KeySignatureProcessor _kSP;

  ChordTransposer({this.notation = NoteNotation.english}) {
    _kSP = KeySignatureProcessor(notation: notation);
  }

  /// Finds the number of semitones between the given keys.
  int _semitonesBetween(KeySignature a, KeySignature b) => b.rank - a.rank;

  /// Finds the key that is a specified number of semitones above/below the current key.
  KeySignature _transposeKey(KeySignature currentKey, int semitones) {
    final int newRank = (currentKey.rank + semitones + 12) % 12;
    return _kSP.fromRank(newRank);
  }

  /// Given the current key and the number of semitones to transpose, returns a mapping from each note to a transposed note.
  Map<String, String> _createTranspositionMap(
    KeySignature currentKey,
    KeySignature newKey,
  ) {
    Map<String, String> map = {};
    final int semitones = _semitonesBetween(currentKey, newKey);
    final List<String> scale = newKey.chromaticScale;
    final ranks = chordRanksFor(notation);

    ranks.forEach((chord, rank) {
      final int newRank = (rank + semitones + 12) % 12;
      map.addAll({chord: scale[newRank]});
    });
    return map;
  }

  /// Transposes the root and bass of the given chord using the given transpositionMap.
  Chord _transposeChordFromTranspositionMap(
    Chord chord,
    Map<String, String> transpositionMap,
  ) {
    return Chord(
      transpositionMap[chord.root]!,
      chord.suffix,
      chord.bass.isNotEmpty ? transpositionMap[chord.bass]! : '',
      wasRootLowercase: chord.wasRootLowercase,
    );
  }

  /// Finds chords in the given lyrics and transposes them to the given key.
  String _transposeLyricsFromTranspositionMap(
    String lyrics,
    String? fromKey,
    KeySignature Function(KeySignature fromKey) toKey,
    bool ignoreInvalids,
  ) {
    String newLyrics = '';
    KeySignature fromKey0;
    Map<String, String> transpositionMap = {};

    final List<RegExpMatch> matches =
        RegExp(r"\[([^\]]*)").allMatches(lyrics).toList();

    int lastMatchEnd = 0;

    for (int x = 0; x < matches.length; x++) {
      if (Chord.isChord(matches[x].group(1)!, notation: notation) ||
          !ignoreInvalids) {
        final Chord oldChord = Chord.parse(matches[x].group(1)!, notation);
        // If not already, calcuate _fromKey and create the transpositionMap.
        if (transpositionMap.isEmpty) {
          if (fromKey != null) {
            fromKey0 = _kSP.parse(fromKey);
          } else {
            fromKey0 = _kSP.guessKeySignature(oldChord);
          }
          transpositionMap = _createTranspositionMap(fromKey0, toKey(fromKey0));
        }
        final String newChord =
            _transposeChordFromTranspositionMap(
              oldChord,
              transpositionMap,
            ).toString();
        newLyrics +=
            lyrics.substring(lastMatchEnd, matches[x].start + 1) + newChord;
        lastMatchEnd = matches[x].end;
      }
    }
    newLyrics += lyrics.substring(lastMatchEnd);

    return newLyrics;
  }

  /// Transposes the given lyrics to the given key.
  String lyricsToKey({
    required String lyrics,
    String? fromKey,
    required String toKey,
    bool ignoreInvalids = true,
  }) {
    return _transposeLyricsFromTranspositionMap(
      lyrics,
      fromKey,
      (fromKey) => _kSP.parse(toKey),
      ignoreInvalids,
    );
  }

  /// Transposes the given lyrics up the given semitones.
  String lyricsUp({
    required String lyrics,
    String? fromKey,
    required int semitones,
    bool ignoreInvalids = true,
  }) {
    return _transposeLyricsFromTranspositionMap(
      lyrics,
      fromKey,
      (fromKey) => _transposeKey(fromKey, semitones),
      ignoreInvalids,
    );
  }

  /// Transposes the given lyrics down the given semitones.
  String lyricsDown({
    required String lyrics,
    String? fromKey,
    required int semitones,
    bool ignoreInvalids = true,
  }) {
    return lyricsUp(
      lyrics: lyrics,
      fromKey: fromKey,
      semitones: -semitones,
      ignoreInvalids: ignoreInvalids,
    );
  }

  /// Transposes the given chord to the given key.
  String chordToKey({
    required String chord,
    required String fromKey,
    required String toKey,
  }) {
    final Chord newChord = Chord.parse(chord, notation);
    final KeySignature fromKey0 = _kSP.parse(fromKey);
    final Map<String, String> transpositionMap = _createTranspositionMap(
      fromKey0,
      _kSP.parse(toKey),
    );
    return _transposeChordFromTranspositionMap(
      newChord,
      transpositionMap,
    ).toString();
  }

  /// Transposes the given chords to the given key.
  List<String> chordsToKey({
    required List<String> chords,
    String? fromKey,
    required String toKey,
  }) {
    if (chords.isEmpty) return [];

    List<Chord> oldChords =
        chords.map((chord) => Chord.parse(chord, notation)).toList();
    List<String> newChords = [];
    final KeySignature fromKey0 =
        fromKey != null
            ? _kSP.parse(fromKey)
            : _kSP.guessKeySignature(oldChords[0]);
    final KeySignature toKey0 = _kSP.parse(toKey);
    final Map<String, String> transpositionMap = _createTranspositionMap(
      fromKey0,
      toKey0,
    );

    for (Chord chord in oldChords) {
      newChords.add(
        _transposeChordFromTranspositionMap(chord, transpositionMap).toString(),
      );
    }

    return newChords;
  }

  /// Tranposes the given chord up the given semitones.
  String chordUp({
    required String chord,
    String? fromKey,
    required int semitones,
  }) {
    final Chord newChord = Chord.parse(chord, notation);
    final KeySignature fromKey0 =
        fromKey != null
            ? _kSP.parse(fromKey)
            : _kSP.guessKeySignature(newChord);
    final KeySignature toKey = _transposeKey(fromKey0, semitones);
    final Map<String, String> transpositionMap = _createTranspositionMap(
      fromKey0,
      toKey,
    );
    return _transposeChordFromTranspositionMap(
      newChord,
      transpositionMap,
    ).toString();
  }

  /// Transposes the given chord down the given semitones.
  String chordDown({
    required String chord,
    String? fromKey,
    required int semitones,
  }) {
    return chordUp(chord: chord, fromKey: fromKey, semitones: -semitones);
  }

  /// Tranposes the given chords up the given semitones.
  List<String> chordsUp({
    required List<String> chords,
    String? fromKey,
    required int semitones,
  }) {
    if (chords.isEmpty) return [];

    List<Chord> oldChords =
        chords.map((chord) => Chord.parse(chord, notation)).toList();
    List<String> newChords = [];
    final KeySignature fromKey0 =
        fromKey != null
            ? _kSP.parse(fromKey)
            : _kSP.guessKeySignature(oldChords[0]);
    final KeySignature toKey = _transposeKey(fromKey0, semitones);
    final Map<String, String> transpositionMap = _createTranspositionMap(
      fromKey0,
      toKey,
    );

    for (Chord chord in oldChords) {
      newChords.add(
        _transposeChordFromTranspositionMap(chord, transpositionMap).toString(),
      );
    }

    return newChords;
  }

  /// Tranposes the given chords down the given semitones.
  List<String> chordsDown({
    required List<String> chords,
    String? fromKey,
    required int semitones,
  }) {
    return chordsUp(chords: chords, fromKey: fromKey, semitones: -semitones);
  }
}
