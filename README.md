A Dart package for transposing chords into any given key.

## Features
- Transpose chords from one key to another
- Transpose chords up or down semitones
- Find chords in lyrics and transpose them into another key
- Find chords in lyrics and transpose up or down semitones
- Support for different notation systems (English, German, and German with accidentals)
- Case sensitivity support (preserves lowercase/uppercase chord format)

## Usage
First initialize the ChordTransposer:
```dart
final transposer = ChordTransposer();
```

### Notation systems
The package supports three different notation systems:

```dart
// English notation (default)
final transposer = ChordTransposer();
// or explicitly
final englishTransposer = ChordTransposer(notation: NoteNotation.english);

// German notation
final germanTransposer = ChordTransposer(notation: NoteNotation.german);

// German notation with accidentals
final germanAccTransposer = ChordTransposer(notation: NoteNotation.germanWithAccidentals);
```

#### Notation comparison

| English | German | German with Accidentals |
|---------|--------|----------------------|
| C       | C      | C                    |
| C#      | Cis    | C#                   |
| Db      | Des    | Db                   |
| D       | D      | D                    |
| D#      | Dis    | D#                   |
| Eb      | Es     | Eb                   |
| E       | E      | E                    |
| F       | F      | F                    |
| F#      | Fis    | F#                   |
| Gb      | Ges    | Gb                   |
| G       | G      | G                    |
| G#      | Gis    | G#                   |
| Ab      | As     | Ab                   |
| A       | A      | A                    |
| A#      | Ais    | A#                   |
| Bb      | B      | B                    |
| B       | H      | H                    |

### Transpose chords
Transpose a single chord from one key to another:
```dart
// English notation
transposer.chordToKey(chord: 'D/F#', fromKey: 'A', toKey: 'G'); // => C/E

// German notation
germanTransposer.chordToKey(chord: 'D/Fis', fromKey: 'A', toKey: 'G'); // => C/E
```
Transpose multiple chords from one key to another. If `fromKey` is not given, it will use the first chord in the list:

```dart
// English notation
transposer.chordsToKey(chords: ['C', 'F', 'Am', 'G7', 'Bdim'], toKey: 'E'); // => [E, A, C#m, B7, D#dim]

// German notation
germanTransposer.chordsToKey(chords: ['C', 'F', 'Am', 'G7', 'Hdim'], toKey: 'E'); // => [E, A, C#m, B7, Disdim]
```
Transpose a single chord up or down semitones:
```dart
// English notation
transposer.chordUp(chord: 'D', semitones: 5); // => G
transposer.chordDown(chord: 'Bb', semitones: 2); // => Ab

// German notation
germanTransposer.chordUp(chord: 'D', semitones: 5); // => G
germanTransposer.chordDown(chord: 'B', semitones: 2); // => As
```
Transpose multiple chords up or down semitones:
```dart
// English notation
transposer.chordsUp(chords: ['D','Aadd9'], semitones: 4); // => [Gb, Dbadd9]
transposer.chordsDown(chords: ['Bb7/D', 'Eb'], semitones: 6); // => [E7/G#, A]

// German notation
germanTransposer.chordsUp(chords: ['D','Aadd9'], semitones: 4); // => [Ges, Desadd9]
germanTransposer.chordsDown(chords: ['B7/D', 'Es'], semitones: 6); // => [E7/Gis, A]
```

### Transpose lyrics
```dart
final lyrics = '''
[C]Twinkle, twinkle [F]little [C]star.
[F]How I [C]wonder [G7]what you [C]are.
''';
```
Tranpose lyrics from one key to another. If `fromKey` is not given, it will use the first chord in the lyrics. When `ignoreInvalids` is set to `true` (default), it will ignore all invalid chords. When it is set to `false`, it will throw an error if there is an invalid chord:
```dart
transposer.lyricsToKey(lyrics: lyrics, fromKey: 'C', toKey: 'G'); // =>
// [G]Twinkle, twinkle [C]little [G]star.
// [C]How I [G]wonder [D7]what you [G]are.
```
Transpose lyrics up or down semitones:
```dart
// English notation
transposer.lyricsUp(lyrics: lyrics, semitones: 5); // =>
// [F]Twinkle, twinkle [A#]little [F]star.
// [A#]How I [F]wonder [C7]what you [F]are.

// German notation
germanTransposer.lyricsUp(lyrics: lyrics, semitones: 5); // =>
// [F]Twinkle, twinkle [B]little [F]star.
// [B]How I [F]wonder [C7]what you [F]are.

// English notation
transposer.lyricsDown(lyrics: lyrics, semitones: 3); // =>
// [A]Twinkle, twinkle [D]little [A]star.
// [D]How I [A]wonder [E7]what you [A]are.

// German notation
germanTransposer.lyricsDown(lyrics: lyrics, semitones: 3); // =>
// [A]Twinkle, twinkle [D]little [A]star.
// [D]How I [A]wonder [E7]what you [A]are.
```

## Additional information
This package built to work with paurakhsharma's [flutter_chord](https://github.com/paurakhsharma/flutter_chord) package and was inpsired by ddycai's [chord-transposer](https://github.com/ddycai/chord-transposer) npm package.