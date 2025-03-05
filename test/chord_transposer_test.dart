import 'package:chord_transposer/src/chord.dart';
import 'package:chord_transposer/src/chord_transposer_base.dart';
import 'package:chord_transposer/src/key_signature_processor.dart';
import 'package:test/test.dart';

void main() {
  group('Chord Parsing Tests', () {
    test('Should parse English notation chords correctly', () {
      final notation = NoteNotation.english;

      final cChord = Chord.parse('C', notation);
      expect(cChord.root, equals('C'));
      expect(cChord.suffix, isEmpty);
      expect(cChord.bass, isEmpty);

      final gSharpMinor = Chord.parse('G#m', notation);
      expect(gSharpMinor.root, equals('G#'));
      expect(gSharpMinor.suffix, equals('m'));
      expect(gSharpMinor.bass, isEmpty);

      final dMinorWithF = Chord.parse('Dm/F', notation);
      expect(dMinorWithF.root, equals('D'));
      expect(dMinorWithF.suffix, equals('m'));
      expect(dMinorWithF.bass, equals('F'));

      final bFlatMajor7 = Chord.parse('Bbmaj7', notation);
      expect(bFlatMajor7.root, equals('Bb'));
      expect(bFlatMajor7.suffix, equals('maj7'));
      expect(bFlatMajor7.bass, isEmpty);
    });

    test('Should parse German notation chords correctly', () {
      final notation = NoteNotation.german;

      final cChord = Chord.parse('C', notation);
      expect(cChord.root, equals('C'));
      expect(cChord.suffix, isEmpty);
      expect(cChord.bass, isEmpty);

      final hChord = Chord.parse('H', notation); // H is B in English
      expect(hChord.root, equals('H'));
      expect(hChord.suffix, isEmpty);
      expect(hChord.bass, isEmpty);

      final gisMinor = Chord.parse('Gism', notation); // G# minor
      expect(gisMinor.root, equals('Gis'));
      expect(gisMinor.suffix, equals('m'));
      expect(gisMinor.bass, isEmpty);

      final dMinorWithF = Chord.parse('Dm/F', notation);
      expect(dMinorWithF.root, equals('D'));
      expect(dMinorWithF.suffix, equals('m'));
      expect(dMinorWithF.bass, equals('F'));

      final bChord = Chord.parse('B', notation); // B is Bb in English
      expect(bChord.root, equals('B'));
      expect(bChord.suffix, isEmpty);
      expect(bChord.bass, isEmpty);

      final eMajorWithCissBass = Chord.parse('E/Cis', notation);
      expect(eMajorWithCissBass.root, equals('E'));
      expect(eMajorWithCissBass.suffix, isEmpty);
      expect(eMajorWithCissBass.bass, equals('Cis'));
    });

    test('Should parse German notation with accidentals correctly', () {
      final notation = NoteNotation.germanWithAccidentals;

      final cChord = Chord.parse('C', notation);
      expect(cChord.root, equals('C'));

      final hChord = Chord.parse('H', notation); // H is B in English
      expect(hChord.root, equals('H'));

      final gSharpMinor = Chord.parse('G#m', notation);
      expect(gSharpMinor.root, equals('G#'));
      expect(gSharpMinor.suffix, equals('m'));

      final bChord = Chord.parse('B', notation); // B is Bb in English
      expect(bChord.root, equals('B'));
    });

    test('Should throw exception for invalid chords', () {
      expect(() => Chord.parse('X', NoteNotation.english), throwsException);
      expect(() => Chord.parse('J', NoteNotation.german), throwsException);
      expect(
        () => Chord.parse('K', NoteNotation.germanWithAccidentals),
        throwsException,
      );
    });
  });

  group('Transposition Tests', () {
    test('Should transpose English notation chords correctly', () {
      final transposer = ChordTransposer(notation: NoteNotation.english);

      // Transpose C to D (up 2 semitones)
      expect(transposer.chordUp(chord: 'C', semitones: 2), equals('D'));

      // Transpose Dm to Em
      expect(transposer.chordUp(chord: 'Dm', semitones: 2), equals('Em'));

      // Transpose F#m7 to G#m7
      expect(transposer.chordUp(chord: 'F#m7', semitones: 2), equals('G#m7'));

      // Transpose Bb to C
      expect(transposer.chordUp(chord: 'Bb', semitones: 2), equals('C'));

      // Transpose chords down
      expect(transposer.chordDown(chord: 'D', semitones: 2), equals('C'));
    });

    test('Should transpose German notation chords correctly', () {
      final transposer = ChordTransposer(notation: NoteNotation.german);

      // Transpose C to D (up 2 semitones)
      expect(transposer.chordUp(chord: 'C', semitones: 2), equals('D'));

      // Transpose H to C (H is B in English)
      expect(transposer.chordUp(chord: 'H', semitones: 1), equals('C'));

      // Transpose Fis to G
      expect(transposer.chordUp(chord: 'Fis', semitones: 1), equals('G'));

      // Transpose B to H (B is Bb in English)
      expect(transposer.chordUp(chord: 'B', semitones: 1), equals('H'));
    });

    test('Should transpose German with accidentals notation correctly', () {
      final transposer = ChordTransposer(
        notation: NoteNotation.germanWithAccidentals,
      );

      // Transpose C to D (up 2 semitones)
      expect(transposer.chordUp(chord: 'C', semitones: 2), equals('D'));

      // Transpose H to C (H is B in English)
      expect(transposer.chordUp(chord: 'H', semitones: 1), equals('C'));

      // Transpose F# to G
      expect(transposer.chordUp(chord: 'F#', semitones: 1), equals('G'));

      // Transpose B to H (B is Bb in English)
      expect(transposer.chordUp(chord: 'B', semitones: 1), equals('H'));
    });
  });

  group('Key Signature Tests', () {
    test('Should parse key signatures in English notation', () {
      final ksp = KeySignatureProcessor(notation: NoteNotation.english);

      final cMajor = ksp.parse('C');
      expect(cMajor.majorKey, equals('C'));
      expect(cMajor.relativeMinor, equals('Am'));

      final aMinor = ksp.parse('Am');
      expect(aMinor.majorKey, equals('C'));
      expect(aMinor.relativeMinor, equals('Am'));

      final bMajor = ksp.parse('B');
      expect(bMajor.majorKey, equals('B'));
      expect(bMajor.relativeMinor, equals('G#m'));
    });

    test('Should parse key signatures in German notation', () {
      final ksp = KeySignatureProcessor(notation: NoteNotation.german);

      final cMajor = ksp.parse('C');
      expect(cMajor.majorKey, equals('C'));
      expect(cMajor.relativeMinor, equals('Am'));

      final hMajor = ksp.parse('H'); // H is B in English
      expect(hMajor.majorKey, equals('H'));
      expect(hMajor.relativeMinor, equals('Gism'));
    });

    test('Should guess key signature from chord', () {
      final kspEnglish = KeySignatureProcessor(notation: NoteNotation.english);
      final kspGerman = KeySignatureProcessor(notation: NoteNotation.german);

      // English notation
      final cChord = Chord.parse('C', NoteNotation.english);
      final cKey = kspEnglish.guessKeySignature(cChord);
      expect(cKey.majorKey, equals('C'));

      // German notation
      final hChord = Chord.parse('H', NoteNotation.german);
      final hKey = kspGerman.guessKeySignature(hChord);
      expect(hKey.majorKey, equals('H'));
    });
  });

  group('Lyrics Transposition Tests', () {
    test('Should transpose lyrics with English notation chords', () {
      final transposer = ChordTransposer(notation: NoteNotation.english);
      const lyrics = '''
[C]Twinkle, twinkle, [G]little star,
[F]How I [C]wonder [G]what you [C]are!
''';

      // Transpose up 2 semitones (C to D)
      final transposedLyrics = transposer.lyricsUp(
        lyrics: lyrics,
        semitones: 2,
      );
      expect(transposedLyrics, contains('[D]Twinkle'));
      expect(transposedLyrics, contains('[A]little star'));
      expect(transposedLyrics, contains('[G]How I'));
      expect(transposedLyrics, contains('[D]wonder'));
      expect(transposedLyrics, contains('[A]what you'));
      expect(transposedLyrics, contains('[D]are!'));
    });

    test('Should transpose lyrics with German notation chords', () {
      final transposer = ChordTransposer(notation: NoteNotation.german);
      const lyrics = '''
[C]Twinkle, twinkle, [G]little star,
[F]How I [C]wonder [G]what you [C]are!
''';

      // Transpose up 2 semitones (C to D)
      final transposedLyrics = transposer.lyricsUp(
        lyrics: lyrics,
        semitones: 2,
      );
      expect(transposedLyrics, contains('[D]Twinkle'));
      expect(transposedLyrics, contains('[A]little star'));
      expect(transposedLyrics, contains('[G]How I'));
      expect(transposedLyrics, contains('[D]wonder'));
      expect(transposedLyrics, contains('[A]what you'));
      expect(transposedLyrics, contains('[D]are!'));
    });
  });

  group('Chord Progression Tests', () {
    test('Should transpose chord progressions in English notation', () {
      final transposer = ChordTransposer(notation: NoteNotation.english);

      final chords = ['C', 'Am', 'F', 'G'];
      final transposedChords = transposer.chordsUp(
        chords: chords,
        semitones: 7,
      );
      expect(transposedChords, equals(['G', 'Em', 'C', 'D']));
    });

    test('Should transpose chord progressions in German notation', () {
      final transposer = ChordTransposer(notation: NoteNotation.german);

      final chords = ['C', 'Am', 'F', 'G'];
      final transposedChords = transposer.chordsUp(
        chords: chords,
        semitones: 7,
      );
      expect(transposedChords, equals(['G', 'Em', 'C', 'D']));

      // Test with German-specific chord names
      final germanChords = ['C', 'Am', 'Fis', 'H'];
      final germanTransposed = transposer.chordsUp(
        chords: germanChords,
        semitones: 1,
      );
      expect(germanTransposed, equals(['Des', 'Bm', 'G', 'C']));
    });

    test(
      'Should transpose chord progressions in German with accidentals notation',
      () {
        final transposer = ChordTransposer(
          notation: NoteNotation.germanWithAccidentals,
        );

        final chords = ['C', 'Am', 'F#', 'H'];
        final transposedChords = transposer.chordsUp(
          chords: chords,
          semitones: 1,
        );
        expect(transposedChords, equals(['Db', 'Bm', 'G', 'C']));
      },
    );
  });

  group('Edge Cases', () {
    test('Should handle edge cases in English notation', () {
      final transposer = ChordTransposer(notation: NoteNotation.english);

      // B to C transition
      expect(transposer.chordUp(chord: 'B', semitones: 1), equals('C'));

      // E to F transition (no sharp)
      expect(transposer.chordUp(chord: 'E', semitones: 1), equals('F'));

      // Fb edge case (same as E)
      expect(transposer.chordUp(chord: 'Fb', semitones: 1), equals('F'));
    });

    test('Should handle edge cases in German notation', () {
      final transposer = ChordTransposer(notation: NoteNotation.german);

      // H to C transition (H is B in English)
      expect(transposer.chordUp(chord: 'H', semitones: 1), equals('C'));

      // B to H transition (B is Bb in English)
      expect(transposer.chordUp(chord: 'B', semitones: 1), equals('H'));
    });

    test('Should handle chords with complex suffixes', () {
      final transposer = ChordTransposer(notation: NoteNotation.english);

      // Cmaj7b5#9
      expect(
        transposer.chordUp(chord: 'Cmaj7b5#9', semitones: 2),
        equals('Dmaj7b5#9'),
      );

      // G7sus4
      expect(
        transposer.chordUp(chord: 'G7sus4', semitones: 5),
        equals('C7sus4'),
      );
    });

    test('Should handle empty chord list', () {
      final transposer = ChordTransposer();
      expect(transposer.chordsUp(chords: [], semitones: 2), equals([]));
    });
  });
}
