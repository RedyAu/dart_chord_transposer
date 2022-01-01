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

import 'package:chord_transposer/src/chord.dart' show chordRanks, Chord;
import 'package:chord_transposer/src/key_signature_processor.dart'
    show KeySignature, KeySignatureProcessor;

/// An object that transposes chords into any given key.
class ChordTransposer {
  /// An object that parses and calculates key signatures.
  final KeySignatureProcessor _kSP = KeySignatureProcessor();

  /// Finds the number of semitones between the given keys.
  int _semitonesBetween(KeySignature a, KeySignature b) => b.rank - a.rank;

  /// Finds the key that is a specified number of semitones above/below the current key.
  KeySignature _transposeKey(KeySignature currentKey, int semitones) {
    final int _newRank = (currentKey.rank + semitones + 12) % 12;
    return _kSP.fromRank(_newRank);
  }

  /// Given the current key and the number of semitones to transpose, returns a mapping from each note to a transposed note.
  Map<String, String> _createTranspositionMap(
      KeySignature currentKey, KeySignature newKey) {
    Map<String, String> _map = {};
    final int _semitones = _semitonesBetween(currentKey, newKey);
    final List<String> _scale = newKey.chromaticScale;
    chordRanks.forEach((_chord, _rank) {
      final int newRank = (_rank + _semitones + 12) % 12;
      _map.addAll({_chord: _scale[newRank]});
    });
    return _map;
  }

  /// Transposes the root and bass of the given chord using the given transpositionMap.
  Chord _transposeChordFromTranspositionMap(
      Chord chord, Map<String, String> transpositionMap) {
    return Chord(transpositionMap[chord.root]!, chord.suffix,
        chord.bass.isNotEmpty ? transpositionMap[chord.bass]! : '');
  }

  /// Finds chords in the given lyrics and transposes them to the given key.
  String _transposeLyricsFromTranspositionMap(String lyrics, String? fromKey,
      KeySignature Function(KeySignature fromKey) toKey, bool ignoreInvalids) {
    String _newLyrics = '';
    KeySignature _fromKey;
    Map<String, String> _transpositionMap = {};

    final List<RegExpMatch> _matches =
        RegExp(r"\[([^\]]*)").allMatches(lyrics).toList();

    int _lastMatchEnd = 0;

    for (int x = 0; x < _matches.length; x++) {
      if (Chord.isChord(_matches[x].group(1)!) || !ignoreInvalids) {
        final Chord _oldChord = Chord.parse(_matches[x].group(1)!);
        // If not already, calcuate _fromKey and create the transpositionMap.
        if (_transpositionMap.isEmpty) {
          if (fromKey != null) {
            _fromKey = _kSP.parse(fromKey);
          } else {
            _fromKey = _kSP.guessKeySignature(_oldChord);
          }
          _transpositionMap =
              _createTranspositionMap(_fromKey, toKey(_fromKey));
        }
        final String _newChord =
            _transposeChordFromTranspositionMap(_oldChord, _transpositionMap)
                .toString();
        _newLyrics +=
            lyrics.substring(_lastMatchEnd, _matches[x].start + 1) + _newChord;
        _lastMatchEnd = _matches[x].end;
      }
    }
    _newLyrics += lyrics.substring(_lastMatchEnd);

    return _newLyrics;
  }

  /// Transposes the given lyrics to the given key.
  String lyricsToKey(
      {required String lyrics,
      String? fromKey,
      required String toKey,
      bool ignoreInvalids = true}) {
    return _transposeLyricsFromTranspositionMap(
        lyrics, fromKey, (_fromKey) => _kSP.parse(toKey), ignoreInvalids);
  }

  /// Transposes the given lyrics up the given semitones.
  String lyricsUp(
      {required String lyrics,
      String? fromKey,
      required int semitones,
      bool ignoreInvalids = true}) {
    return _transposeLyricsFromTranspositionMap(lyrics, fromKey,
        (_fromKey) => _transposeKey(_fromKey, semitones), ignoreInvalids);
  }

  /// Transposes the given lyrics down the given semitones.
  String lyricsDown(
      {required String lyrics,
      String? fromKey,
      required int semitones,
      bool ignoreInvalids = true}) {
    return lyricsUp(
        lyrics: lyrics,
        fromKey: fromKey,
        semitones: -semitones,
        ignoreInvalids: ignoreInvalids);
  }

  /// Transposes the given chord to the given key.
  String chordToKey(
      {required String chord, required String fromKey, required String toKey}) {
    final Chord _newChord = Chord.parse(chord);
    final KeySignature _fromKey = _kSP.parse(fromKey);
    final Map<String, String> _transpositionMap =
        _createTranspositionMap(_fromKey, _kSP.parse(toKey));
    return _transposeChordFromTranspositionMap(_newChord, _transpositionMap)
        .toString();
  }

  /// Transposes the given chords to the given key.
  List<String> chordsToKey(
      {required List<String> chords, String? fromKey, required String toKey}) {
    if (chords.isEmpty) return [];

    List<Chord> _oldChords = chords.map((chord) => Chord.parse(chord)).toList();
    List<String> _newChords = [];
    final KeySignature _fromKey = fromKey != null
        ? _kSP.parse(fromKey)
        : _kSP.guessKeySignature(_oldChords[0]);
    final KeySignature _toKey = _kSP.parse(toKey);
    final Map<String, String> _transpositionMap =
        _createTranspositionMap(_fromKey, _toKey);

    for (Chord _chord in _oldChords) {
      _newChords.add(
          _transposeChordFromTranspositionMap(_chord, _transpositionMap)
              .toString());
    }

    return _newChords;
  }

  /// Tranposes the given chord up the given semitones.
  String chordUp(
      {required String chord, String? fromKey, required int semitones}) {
    final Chord _newChord = Chord.parse(chord);
    final KeySignature _fromKey = fromKey != null
        ? _kSP.parse(fromKey)
        : _kSP.guessKeySignature(_newChord);
    final KeySignature _toKey = _transposeKey(_fromKey, semitones);
    final Map<String, String> _transpositionMap =
        _createTranspositionMap(_fromKey, _toKey);
    return _transposeChordFromTranspositionMap(_newChord, _transpositionMap)
        .toString();
  }

  /// Transposes the given chord down the given semitones.
  String chordDown(
      {required String chord, String? fromKey, required int semitones}) {
    return chordUp(chord: chord, fromKey: fromKey, semitones: -semitones);
  }

  /// Tranposes the given chords up the given semitones.
  List<String> chordsUp(
      {required List<String> chords, String? fromKey, required int semitones}) {
    if (chords.isEmpty) return [];

    List<Chord> _oldChords = chords.map((chord) => Chord.parse(chord)).toList();
    List<String> _newChords = [];
    final KeySignature _fromKey = fromKey != null
        ? _kSP.parse(fromKey)
        : _kSP.guessKeySignature(_oldChords[0]);
    final KeySignature _toKey = _transposeKey(_fromKey, semitones);
    final Map<String, String> _transpositionMap =
        _createTranspositionMap(_fromKey, _toKey);

    for (Chord _chord in _oldChords) {
      _newChords.add(
          _transposeChordFromTranspositionMap(_chord, _transpositionMap)
              .toString());
    }

    return _newChords;
  }

  /// Tranposes the given chords down the given semitones.
  List<String> chordsDown(
      {required List<String> chords, String? fromKey, required int semitones}) {
    return chordsUp(chords: chords, fromKey: fromKey, semitones: -semitones);
  }
}
