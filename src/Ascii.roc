module [
    Ascii,
    fromStr,
    toStr,
    fromAsciiBytes,
    toAsciiBytes,
    # Methods
    compare,
    isEmpty,
    toUppercase,
    toLowercase,
    concat,
    join,
    joinWith,
    repeat,
    startsWith,
    endsWith,
    toDec,
    toF64,
    toF32,
    toU128,
    toI128,
    toU64,
    toI64,
    toU32,
    toI32,
    toU16,
    toI16,
    toU8,
    toI8,
    len,
    reverse,
    sortAsc,
    sortDesc,
]

import Char
import Char exposing [Char]
import Utils

Ascii : List Char

## Convert a UTF-8 [Str] to an ASCII string.
fromStr : Str -> Result Ascii [InvalidAscii]
fromStr = \str -> str |> Str.toUtf8 |> fromAsciiBytes

## Convert an ASCII string to a UTF-8 [Str].
toStr : Ascii -> Str
toStr = \chars ->
    chars
    |> List.map Char.toAsciiByte
    |> Str.fromUtf8
    |> Utils.unwrap "ASCII bytes are always valid UTF-8"

# Round trip test
expect
    out = "hello" |> fromStr |> Utils.unwrap "" |> toStr
    out == "hello"

## Convert a list of ASCII code points to an ASCII string.
fromAsciiBytes : List U8 -> Result Ascii [InvalidAscii]
fromAsciiBytes = \bytes ->
    charResults = List.map bytes Char.fromAsciiByte
    if List.all charResults Result.isOk then
        Ok (List.map charResults (\r -> Utils.unwrap r "We already checked that all the results are Ok."))
    else
        Err InvalidAscii

## Convert an ASCII string to a list of ASCII code points.
toAsciiBytes : Ascii -> List U8
toAsciiBytes = \chars -> List.map chars Char.toAsciiByte

## Compare the [ASCIIbetical](https://en.wikipedia.org/wiki/ASCII#Character_order) order of two ASCII strings, i.e. by comparing their code points.
compare : Ascii, Ascii -> [LT, EQ, GT]
compare = \a, b ->
    comparison =
        Utils.zip a b
        |> List.walkUntil
            EQ
            (\_, (aChar, bChar) ->
                when Char.compare aChar bChar is
                    LT -> Break LT
                    EQ -> Continue EQ
                    GT -> Break GT
            )
    # If the strings are equal up to the length of the shorter string
    if comparison == EQ then
        # Then the shorter string is lexicographically less than the longer string
        Num.compare (len a) (len b)
    else
        comparison

expect
    a = fromStr "hello" |> Utils.unwrap ""
    b = fromStr "hello" |> Utils.unwrap ""
    out = compare a b
    out == EQ

expect
    a = fromStr "hello" |> Utils.unwrap ""
    b = fromStr "world" |> Utils.unwrap ""
    out = compare a b
    out == LT

expect
    a = fromStr "world" |> Utils.unwrap ""
    b = fromStr "hello" |> Utils.unwrap ""
    out = compare a b
    out == GT

expect
    a = fromStr "hello" |> Utils.unwrap ""
    b = fromStr "hello!" |> Utils.unwrap ""
    out = compare a b
    out == LT

expect
    a = fromStr "" |> Utils.unwrap ""
    b = fromStr "" |> Utils.unwrap ""
    out = compare a b
    out == EQ

## Check if an ASCII string is empty.
isEmpty : Ascii -> Bool
isEmpty = \chars -> List.isEmpty chars

expect
    out = "" |> fromStr |> Utils.unwrap "" |> isEmpty
    out == Bool.true

expect
    out = "hello" |> fromStr |> Utils.unwrap "" |> isEmpty
    out == Bool.false

## Convert all the lowercase letters in an ASCII string to uppercase, leaving all other characters unchanged.
toUppercase : Ascii -> Ascii
toUppercase = \chars -> List.map chars Char.toUppercase

## Convert all the uppercase letters in an ASCII string to lowercase, leaving all other characters unchanged.
toLowercase : Ascii -> Ascii
toLowercase = \chars -> List.map chars Char.toLowercase

## Concatenate two ASCII strings.
concat : Ascii, Ascii -> Ascii
concat = \a, b -> List.concat a b

expect
    a = fromStr "Hello," |> Utils.unwrap ""
    b = fromStr " world!" |> Utils.unwrap ""
    out = concat a b
    out == fromStr "Hello, world!" |> Utils.unwrap ""

# # withCapacity

# # reserve

## Join a list of ASCII strings.
join : List Ascii -> Ascii
join = \asciiStrings -> List.join asciiStrings

expect
    a = fromStr "hello" |> Utils.unwrap ""
    b = fromStr "world" |> Utils.unwrap ""
    c = fromStr "!" |> Utils.unwrap ""
    out = join [a, b, c]
    expectedOut = Str.joinWith ["hello", "world", "!"] "" |> fromStr |> Utils.unwrap ""
    out == expectedOut

## Join a list of ASCII strings with a separator.
joinWith : List Ascii, Ascii -> Ascii
joinWith = \asciiStrings, sep -> Utils.intersperse asciiStrings sep

expect
    a = fromStr "hello" |> Utils.unwrap ""
    b = fromStr "world" |> Utils.unwrap ""
    c = fromStr "!" |> Utils.unwrap ""
    sep = fromStr "_" |> Utils.unwrap ""
    out = joinWith [a, b, c] sep
    expectedOut = Str.joinWith ["hello", "world", "!"] "_" |> fromStr |> Utils.unwrap ""
    out == expectedOut

# split : Ascii, Ascii -> List Ascii

## Repeat an ASCII string a specified number of times.
repeat : Ascii, U64 -> Ascii
repeat = \chars, n -> chars |> List.repeat n |> List.join

expect
    out = fromStr "hello" |> Utils.unwrap "" |> repeat 3
    out == fromStr "hellohellohello" |> Utils.unwrap ""

## Check if an ASCII string starts with another ASCII string.
startsWith : Ascii, Ascii -> Bool
startsWith = \haystack, needle -> List.startsWith haystack needle

expect "hello" |> fromStr |> Utils.unwrap "" |> startsWith (fromStr "he" |> Utils.unwrap "")
expect "hello" |> fromStr |> Utils.unwrap "" |> startsWith (fromStr "lo" |> Utils.unwrap "") |> Bool.not

## Check if an ASCII string ends with another ASCII string.
endsWith : Ascii, Ascii -> Bool
endsWith = \haystack, needle -> List.endsWith haystack needle

expect "hello" |> fromStr |> Utils.unwrap "" |> endsWith (fromStr "lo" |> Utils.unwrap "")
expect "hello" |> fromStr |> Utils.unwrap "" |> endsWith (fromStr "he" |> Utils.unwrap "") |> Bool.not

# trim
# trimStart
# trimEnd

toDec : Ascii -> Result Dec [InvalidNumStr]
toDec = \s -> s |> toStr |> Str.toDec

toF64 : Ascii -> Result F64 [InvalidNumStr]
toF64 = \s -> s |> toStr |> Str.toF64

toF32 : Ascii -> Result F32 [InvalidNumStr]
toF32 = \s -> s |> toStr |> Str.toF32

toU128 : Ascii -> Result U128 [InvalidNumStr]
toU128 = \s -> s |> toStr |> Str.toU128

toI128 : Ascii -> Result I128 [InvalidNumStr]
toI128 = \s -> s |> toStr |> Str.toI128

toU64 : Ascii -> Result U64 [InvalidNumStr]
toU64 = \s -> s |> toStr |> Str.toU64

toI64 : Ascii -> Result I64 [InvalidNumStr]
toI64 = \s -> s |> toStr |> Str.toI64

toU32 : Ascii -> Result U32 [InvalidNumStr]
toU32 = \s -> s |> toStr |> Str.toU32

toI32 : Ascii -> Result I32 [InvalidNumStr]
toI32 = \s -> s |> toStr |> Str.toI32

toU16 : Ascii -> Result U16 [InvalidNumStr]
toU16 = \s -> s |> toStr |> Str.toU16

toI16 : Ascii -> Result I16 [InvalidNumStr]
toI16 = \s -> s |> toStr |> Str.toI16

toU8 : Ascii -> Result U8 [InvalidNumStr]
toU8 = \s -> s |> toStr |> Str.toU8

toI8 : Ascii -> Result I8 [InvalidNumStr]
toI8 = \s -> s |> toStr |> Str.toI8

## Count the number of characters in an ASCII string.
len : Ascii -> U64
len = \chars -> List.len chars

expect
    out = "hello" |> fromStr |> Utils.unwrap "" |> len
    out == 5

# replaceEach
# replaceFirst
# replaceLast

# splitFirst
# splitLast

# releaseExcessCapacity

# withPrefix

# contains

## Reverse the characters in an ASCII string.
reverse : Ascii -> Ascii
reverse = \chars -> List.reverse chars

expect
    out = "hello" |> fromStr |> Utils.unwrap "" |> reverse
    out |> toStr == "olleh"

## Sort a list of ASCII strings in ascending [ASCIIbetical](https://en.wikipedia.org/wiki/ASCII#Character_order) order.
sortAsc : List Ascii -> List Ascii
sortAsc = \asciiStrs -> List.sortWith asciiStrs compare

expect
    a = fromStr "hello" |> Utils.unwrap ""
    b = fromStr "world" |> Utils.unwrap ""
    c = fromStr "!" |> Utils.unwrap ""
    out = sortAsc [a, b, c]
    out == [c, a, b]

## Sort a list of ASCII strings in descending [ASCIIbetical](https://en.wikipedia.org/wiki/ASCII#Character_order) order.
sortDesc : List Ascii -> List Ascii
sortDesc = \asciiStrs -> List.sortWith asciiStrs (\a, b -> compare b a)

expect
    a = fromStr "hello" |> Utils.unwrap ""
    b = fromStr "world" |> Utils.unwrap ""
    c = fromStr "!" |> Utils.unwrap ""
    out = sortDesc [a, b, c]
    out == [b, a, c]
