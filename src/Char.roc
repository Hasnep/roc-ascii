module [
    Char,
    fromAsciiByte,
    toAsciiByte,
    # Methods
    compare,
    # Character set
    characterSet,
    isLowercase,
    isUppercase,
    isLetter,
    isDigit,
    isAlphanumeric,
    isOctDigit,
    isHexDigit,
    isWhitespace,
    isPunctuation,
    isControl,
    isPrintable,
    # Methods
    toUppercase,
    toLowercase,
    # Character sets
    lowercaseAlphabet,
    uppercaseAlphabet,
    alphabet,
    digits,
    whitespace,
    punctuation,
    control,
    printable,
    # Control characters
    nul,
    soh,
    stx,
    etx,
    eot,
    enq,
    ack,
    bel,
    bs,
    ht,
    lf,
    vt,
    ff,
    cr,
    so,
    si,
    dle,
    dc1,
    dc2,
    dc3,
    dc4,
    nak,
    syn,
    etb,
    can,
    em,
    sub,
    esc,
    fs,
    gs,
    rs,
    us,
    del,
]

## A single ASCII character.
Char := U8 implements [Eq, Hash]

## Parse an ASCII code point to a [Char], returning an error if the code point is not in the range 0 to 127 inclusive.
fromAsciiByte : U8 -> Result Char [InvalidAscii]
fromAsciiByte = \byte ->
    isValidAsciiByte = \b -> b <= 127
    if isValidAsciiByte byte then
        Ok (@Char byte)
    else
        Err InvalidAscii

## Get the corresponding  ASCII code point of a [Char].
toAsciiByte : Char -> U8
toAsciiByte = \@Char c -> c

## Compare the [ASCIIbetical](https://en.wikipedia.org/wiki/ASCII#Character_order) order of two ASCII characters, i.e. by comparing their code points.
compare : Char, Char -> [LT, EQ, GT]
compare = \@Char a, @Char b -> Num.compare a b

expect compare (@Char 'a') (@Char 'b') == LT
expect compare (@Char 'b') (@Char 'a') == GT
expect compare (@Char 'a') (@Char 'a') == EQ

## Sort a list of ASCII characters in ascending [ASCIIbetical](https://en.wikipedia.org/wiki/ASCII#Character_order) order.
sortAsc : List Char -> List Char
sortAsc = \chars -> List.sortWith chars compare

expect sortAsc [@Char 'b', @Char 'a', @Char 'c'] == [@Char 'a', @Char 'b', @Char 'c']
expect sortAsc [@Char 'c', @Char 'b', @Char 'a'] == [@Char 'a', @Char 'b', @Char 'c']
expect sortAsc [@Char 'a', @Char 'b', @Char 'c'] == [@Char 'a', @Char 'b', @Char 'c']

## Sort a list of ASCII characters in descending [ASCIIbetical](https://en.wikipedia.org/wiki/ASCII#Character_order) order.
sortDesc : List Char -> List Char
sortDesc = \chars -> List.sortWith chars (\a, b -> compare b a)

expect sortDesc [@Char 'b', @Char 'a', @Char 'c'] == [@Char 'c', @Char 'b', @Char 'a']
expect sortDesc [@Char 'c', @Char 'b', @Char 'a'] == [@Char 'c', @Char 'b', @Char 'a']
expect sortDesc [@Char 'a', @Char 'b', @Char 'c'] == [@Char 'c', @Char 'b', @Char 'a']

## Get the ASCII character set of a character.
characterSet : Char -> [LowercaseLetter, UppercaseLetter, Digit, Whitespace, Punctuation, Control]
characterSet = \c ->
    if isLowercase c then
        LowercaseLetter
    else if isUppercase c then
        UppercaseLetter
    else if isDigit c then
        Digit
    else if isWhitespace c then
        Whitespace
    else if isPunctuation c then
        Punctuation
    else if isControl c then
        Control
    else
        crash "Unreachable"

## Check if an ASCII character is a lowercase letter.
isLowercase : Char -> Bool
isLowercase = \@Char c -> 'a' <= c && c <= 'z'

## Check if an ASCII character is an uppercase letter.
isUppercase : Char -> Bool
isUppercase = \@Char c -> 'A' <= c && c <= 'Z'

## Check if an ASCII character is a letter.
isLetter : Char -> Bool
isLetter = \c -> isLowercase c || isUppercase c

## Check if an ASCII character is a digit.
isDigit : Char -> Bool
isDigit = \@Char c -> '0' <= c && c <= '9'

## Check if an ASCII character is an alphanumeric character, i.e. a letter or a digit.
isAlphanumeric : Char -> Bool
isAlphanumeric = \c -> isLetter c || isDigit c

## Check if an ASCII character is an octal digit, i.e. a digit in the range 0 to 7 inclusive.
isOctDigit : Char -> Bool
isOctDigit = \@Char c -> '0' <= c && c <= '7'

## Check if an ASCII character is a hexadecimal digit, i.e. a digit or a letter in the range 0 to 9, a to f, or A to F.
isHexDigit : Char -> Bool
isHexDigit = \@Char c -> ('0' <= c && c <= '9') || ('a' <= c && c <= 'f') || ('A' <= c && c <= 'F')

## Check if an ASCII character is a whitespace character.
isWhitespace : Char -> Bool
isWhitespace = \@Char c -> c == ' ' || c == '\n' || c == '\t'

## Check if an ASCII character is a punctuation character.
isPunctuation : Char -> Bool
isPunctuation = \@Char c -> (33 <= c && c <= 47) || (58 <= c && c <= 64) || (91 <= c && c <= 96) || (123 <= c && c <= 126)

## Check if an ASCII character is a control character.
isControl : Char -> Bool
isControl = \@Char c -> (0 <= c && c <= 31) || c == 127

## Check if an ASCII character is a printable character.
isPrintable : Char -> Bool
isPrintable = \@Char c -> 32 <= c && c <= 126

## Convert a character to uppercase if it is a lowercase letter, otherwise return the character unchanged.
toUppercase : Char -> Char
toUppercase = \@Char c ->
    if 'a' <= c && c <= 'z' then
        @Char (c - 32)
    else
        @Char c

## Convert a character to lowercase if it is an uppercase letter, otherwise return the character unchanged.
toLowercase : Char -> Char
toLowercase = \@Char c ->
    if 'A' <= c && c <= 'Z' then
        @Char (c + 32)
    else
        @Char c

## All the lowercase ASCII letters.
lowercaseAlphabet : List Char
lowercaseAlphabet = List.range { start: At 'a', end: At 'z' } |> List.map @Char

## All the uppercase ASCII letters.
uppercaseAlphabet : List Char
uppercaseAlphabet = List.range { start: At 'A', end: At 'Z' } |> List.map @Char

## All the ASCII letters.
alphabet : List Char
alphabet = List.concat lowercaseAlphabet uppercaseAlphabet

## All the ASCII digits.
digits : List Char
digits = List.range { start: At '0', end: At '9' } |> List.map @Char

## All the ASCII whitespace characters.
whitespace : List Char
whitespace = [' ', '\n', '\t'] |> List.map @Char

## All the ASCII punctuation characters.
punctuation : List Char
punctuation =
    List.range { start: At 33, end: At 47 }
    |> List.concat (List.range { start: At 58, end: At 64 })
    |> List.concat (List.range { start: At 91, end: At 96 })
    |> List.concat (List.range { start: At 123, end: At 126 })
    |> List.map @Char

## All the ASCII control characters.
control : List Char
control =
    List.range { start: At 0, end: At 31 }
    |> List.append 127
    |> List.map @Char

## All the ASCII printable characters.
printable : List Char
printable = List.range { start: At 32, end: At 126 } |> List.map @Char

## The ASCII "Null" (␀) control character
nul : Char
nul = @Char 0
## The ASCII "Start of Heading" (␁) control character
soh : Char
soh = @Char 1
## The ASCII "Start of Text" (␂) control character
stx : Char
stx = @Char 2
## The ASCII "End of Text" (␃) control character
etx : Char
etx = @Char 3
## The ASCII "End of Transmission" (␄) control character
eot : Char
eot = @Char 4
## The ASCII "Enquiry" (␅) control character
enq : Char
enq = @Char 5
## The ASCII "Acknowledgement" (␆) control character
ack : Char
ack = @Char 6
## The ASCII "Bell" (␇) control character
bel : Char
bel = @Char 7
## The ASCII "Backspace" (␈) control character
bs : Char
bs = @Char 8
## The ASCII "Horizontal Tab" (␉) control character
ht : Char
ht = @Char 9
## The ASCII "Line Feed" (␊) control character
lf : Char
lf = @Char 10
## The ASCII "Vertical Tab" (␋) control character
vt : Char
vt = @Char 11
## The ASCII "Form Feed" (␌) control character
ff : Char
ff = @Char 12
## The ASCII "Carriage Return" (␍) control character
cr : Char
cr = @Char 13
## The ASCII "Shift Out" (␎) control character
so : Char
so = @Char 14
## The ASCII "Shift In" (␏) control character
si : Char
si = @Char 15
## The ASCII "Data Link Escape" (␐) control character
dle : Char
dle = @Char 16
## The ASCII "Device Control 1/XON" (␑) control character
dc1 : Char
dc1 = @Char 17
## The ASCII "Device Control 2" (␒) control character
dc2 : Char
dc2 = @Char 18
## The ASCII "Device Control 3/XOFF" (␓) control character
dc3 : Char
dc3 = @Char 19
## The ASCII "Device Control 4" (␔) control character
dc4 : Char
dc4 = @Char 20
## The ASCII "Negative Acknowledgement" (␕) control character
nak : Char
nak = @Char 21
## The ASCII "Synchronous Idle" (␖) control character
syn : Char
syn = @Char 22
## The ASCII "End of Transmission Block" (␗) control character
etb : Char
etb = @Char 23
## The ASCII "Cancel" (␘) control character
can : Char
can = @Char 24
## The ASCII "End of Medium" (␙) control character
em : Char
em = @Char 25
## The ASCII "Substitute" (␚) control character
sub : Char
sub = @Char 26
## The ASCII "Escape" (␛) control character
esc : Char
esc = @Char 27
## The ASCII "File Separator" (␜) control character
fs : Char
fs = @Char 28
## The ASCII "Group Separator" (␝) control character
gs : Char
gs = @Char 29
## The ASCII "Record Separator" (␞) control character
rs : Char
rs = @Char 30
## The ASCII "Unit Separator" (␟) control character
us : Char
us = @Char 31
## The ASCII "Delete" (␡) control character
del : Char
del = @Char 127
