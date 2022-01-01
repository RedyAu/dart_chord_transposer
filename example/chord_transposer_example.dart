import 'package:chord_transposer/chord_transposer.dart';

void main() {
  // Initialize the ChordTransposer.
  final transposer = ChordTransposer();

  // Transpose chord D/F# from key A to key G.
  print(
      transposer.chordToKey(chord: 'D/F#', fromKey: 'A', toKey: 'G')); // => C/E

  // Transpose chords C, F, Am, G7 and Bdim from key C to key E.
  print(transposer.chordsToKey(
      chords: ['C', 'F', 'Am', 'G7', 'Bdim'],
      toKey: 'E')); // => [E, A, C#m, B7, D#dim]

  // Transpose chord D chord up 5 semitones.
  print(transposer.chordUp(chord: 'D', semitones: 5)); // => G

  // Transpose chord Bb chord down 2 semitones.
  print(transposer.chordDown(chord: 'Bb', semitones: 2)); // => Ab

  // Transpose chords D and Aadd9 up 4 semitones.
  print(transposer
      .chordsUp(chords: ['D', 'Aadd9'], semitones: 4)); // => [Gb, Dbadd9]

  // Transpose chords Bb7/D and Eb down 6 semitones.
  print(transposer
      .chordsDown(chords: ['Bb7/D', 'Eb'], semitones: 6)); // => [E7/G#, A]

  final lyrics = '''
[C]Twinkle, twinkle [F]little [C]star.
[F]How I [C]wonder [G7]what you [C]are.
''';

  //Tranpose lyrics from key C to key G.
  print(transposer.lyricsToKey(lyrics: lyrics, fromKey: 'C', toKey: 'G')); // =>
  // [G]Twinkle, twinkle [C]little [G]star.
  // [C]How I [G]wonder [D7]what you [G]are.

  // Transpose lyrics up 5 semitones.
  print(transposer.lyricsUp(lyrics: lyrics, semitones: 5)); // =>
  // [F]Twinkle, twinkle [A]little [F]star.
  // [Bb]How I [F]wonder [C7]what you [F]are.

  // Transpose lyrics down 3 semitones.
  print(transposer.lyricsDown(lyrics: lyrics, semitones: 3)); // =>
  // [A]Twinkle, twinkle [D]little [A]star.
  // [D]How I [A]wonder [E7]what you [A]are.
}
