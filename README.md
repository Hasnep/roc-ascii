# Roc ASCII

ASCII string and character types in Roc.

## Why you shouldn't use ASCII

- **Limited to only ASCII characters.**
  Roc's builtin `Str` type is encoded using UTF-8, which is designed to support all the world's writing systems, whereas ASCII only supports the letters of the English alphabet (A-Z and a-z), Arabic digits (0-9) and some punctuation characters.
  If your data is user generated, you should probably use a `Str`, especially if the string is a person or a place's name.

## Why you might want to use ASCII

- **Simpler definition of a character**
  In a fixed-length encoding like ASCII, each character is encoded using the same amount of data, for ASCII each character uses one byte.
  UTF-8 is a variable-length encoding, so a single character like the egg emoji (🥚) is encoded as four bytes.
  UTF-8 also supports combining multiple codepoints into a single grapheme, where a codepoint is a single unit of data and a grapheme is a "unit of writing" and is what we normally mean when thinking of a Unicode "character".
  For example, the combining diaeresis codepoint (◌̈) combines with the codepoint before it to create a single grapheme, like in the string "Röc" which contains 5 bytes, 4 codepoints and 3 graphemes.
  ASCII avoids all of this complexity by not supporting characters outside the ASCII range.
- **Ability to index directly into an ASCII string.**
  Because of codepoints like the combining characters, getting the nth character can be tricky.
  Getting the nth grapheme involves knowing how all the possible codepoints combine to create distinct graphemes which can be slow.
  Getting the nth codepoint can split a grapheme like ö into a lowercase letter o codepoint and a combining diaeresis codepoint (◌̈) which doesn't make sense.
  Because of UTF-8's variable-length encoding, getting the nth byte might mean getting a byte from the middle of a codepoint, resulting in invalid UTF-8 data.
  Getting the nth character in an ASCII string is the same as getting the nth byte in the string.
- **Some functions are undefined for Utf-8 strings.**
  The string

  ‫أنا أحب‪Roc™

  (I love Roc™) contains the invisible left-to-right embedding character (`U+202A`) to correctly show Latin letters in an Arabic string.
  If you tried to reverse that string, how would you handle the invisible embedding character?
  The answer is that the reverse function is undefined for Unicode strings.
  Similarly, it's not possible to define uppercase and lowercase transformations for Unicode strings that are each other's inverse.
  This is because the `ı` character (lowercase dotless i) is normally uppercased to `I` (capital i), and then lowercased to `i` (lowercase dotted i).
  However, when using the Turkish or Azerbaijani locales, `I` is lowercased to `ı`.
  Some of this complexity is sidestepped when using ASCII, as it doesn't support any of these characters, but upper and lowercase functions aren't always well-defined when using ASCII.
  For example, in Dutch, the digraph IJ is treated like a single letter when changing case, so the word `ijswafel` (icecream sandwich) should be capitalised as `IJswafel`.

TLDR: If you know that your data will only ever contain characters in the ASCII range, then using ASCII will probably be simpler.
