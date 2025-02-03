module [
    Ascii,
    from_str,
    to_str,
    from_ascii_bytes,
    to_ascii_bytes,
    # Methods
    compare,
    is_empty,
    to_uppercase,
    to_lowercase,
    concat,
    join,
    join_with,
    repeat,
    starts_with,
    ends_with,
    to_dec,
    to_f64,
    to_f32,
    to_u128,
    to_i128,
    to_u64,
    to_i64,
    to_u32,
    to_i32,
    to_u16,
    to_i16,
    to_u8,
    to_i8,
    len,
    reverse,
    sort_asc,
    sort_desc,
]

import Char
import Char exposing [Char]
import Utils

Ascii : List Char

## Convert a UTF-8 [Str] to an ASCII string.
from_str : Str -> Result Ascii [InvalidAscii]
from_str = |str| str |> Str.to_utf8 |> from_ascii_bytes

## Convert an ASCII string to a UTF-8 [Str].
to_str : Ascii -> Str
to_str = |chars|
    chars
    |> List.map(Char.to_ascii_byte)
    |> Str.from_utf8
    |> Utils.unwrap("ASCII bytes are always valid UTF-8")

# Round trip test
expect
    out = "hello" |> from_str |> Utils.unwrap("") |> to_str
    out == "hello"

## Convert a list of ASCII code points to an ASCII string.
from_ascii_bytes : List U8 -> Result Ascii [InvalidAscii]
from_ascii_bytes = |bytes|
    char_results = List.map(bytes, Char.from_ascii_byte)
    if List.all(char_results, Result.is_ok) then
        Ok(List.map(char_results, |r| Utils.unwrap(r, "We already checked that all the results are Ok.")))
    else
        Err(InvalidAscii)

## Convert an ASCII string to a list of ASCII code points.
to_ascii_bytes : Ascii -> List U8
to_ascii_bytes = |chars| List.map(chars, Char.to_ascii_byte)

## Compare the [ASCIIbetical](https://en.wikipedia.org/wiki/ASCII#Character_order) order of two ASCII strings, i.e. by comparing their code points.
compare : Ascii, Ascii -> [LT, EQ, GT]
compare = |a, b|
    comparison =
        Utils.zip(a, b)
        |> List.walk_until(
            EQ,
            |_, (a_char, b_char)|
                when Char.compare(a_char, b_char) is
                    LT -> Break(LT)
                    EQ -> Continue(EQ)
                    GT -> Break(GT),
        )
    # If the strings are equal up to the length of the shorter string
    if comparison == EQ then
        # Then the shorter string is lexicographically less than the longer string
        Num.compare(len(a), len(b))
    else
        comparison

expect
    a = from_str("hello") |> Utils.unwrap("")
    b = from_str("hello") |> Utils.unwrap("")
    out = compare(a, b)
    out == EQ

expect
    a = from_str("hello") |> Utils.unwrap("")
    b = from_str("world") |> Utils.unwrap("")
    out = compare(a, b)
    out == LT

expect
    a = from_str("world") |> Utils.unwrap("")
    b = from_str("hello") |> Utils.unwrap("")
    out = compare(a, b)
    out == GT

expect
    a = from_str("hello") |> Utils.unwrap("")
    b = from_str("hello!") |> Utils.unwrap("")
    out = compare(a, b)
    out == LT

expect
    a = from_str("") |> Utils.unwrap("")
    b = from_str("") |> Utils.unwrap("")
    out = compare(a, b)
    out == EQ

## Check if an ASCII string is empty.
is_empty : Ascii -> Bool
is_empty = |chars| List.is_empty(chars)

expect
    out = "" |> from_str |> Utils.unwrap("") |> is_empty
    out == Bool.true

expect
    out = "hello" |> from_str |> Utils.unwrap("") |> is_empty
    out == Bool.false

## Convert all the lowercase letters in an ASCII string to uppercase, leaving all other characters unchanged.
to_uppercase : Ascii -> Ascii
to_uppercase = |chars| List.map(chars, Char.to_uppercase)

## Convert all the uppercase letters in an ASCII string to lowercase, leaving all other characters unchanged.
to_lowercase : Ascii -> Ascii
to_lowercase = |chars| List.map(chars, Char.to_lowercase)

## Concatenate two ASCII strings.
concat : Ascii, Ascii -> Ascii
concat = |a, b| List.concat(a, b)

expect
    a = from_str("Hello,") |> Utils.unwrap("")
    b = from_str(" world!") |> Utils.unwrap("")
    out = concat(a, b)
    out == from_str("Hello, world!") |> Utils.unwrap("")

# # withCapacity

# # reserve

## Join a list of ASCII strings.
join : List Ascii -> Ascii
join = |ascii_strings| List.join(ascii_strings)

expect
    a = from_str("hello") |> Utils.unwrap("")
    b = from_str("world") |> Utils.unwrap("")
    c = from_str("!") |> Utils.unwrap("")
    out = join([a, b, c])
    expected_out = Str.join_with(["hello", "world", "!"], "") |> from_str |> Utils.unwrap("")
    out == expected_out

## Join a list of ASCII strings with a separator.
join_with : List Ascii, Ascii -> Ascii
join_with = |ascii_strings, sep| Utils.intersperse(ascii_strings, sep)

expect
    a = from_str("hello") |> Utils.unwrap("")
    b = from_str("world") |> Utils.unwrap("")
    c = from_str("!") |> Utils.unwrap("")
    sep = from_str("_") |> Utils.unwrap("")
    out = join_with([a, b, c], sep)
    expected_out = Str.join_with(["hello", "world", "!"], "_") |> from_str |> Utils.unwrap("")
    out == expected_out

# split : Ascii, Ascii -> List Ascii

## Repeat an ASCII string a specified number of times.
repeat : Ascii, U64 -> Ascii
repeat = |chars, n| chars |> List.repeat(n) |> List.join

expect
    out = from_str("hello") |> Utils.unwrap("") |> repeat(3)
    out == from_str("hellohellohello") |> Utils.unwrap("")

## Check if an ASCII string starts with another ASCII string.
starts_with : Ascii, Ascii -> Bool
starts_with = |haystack, needle| List.starts_with(haystack, needle)

expect "hello" |> from_str |> Utils.unwrap("") |> starts_with((from_str("he") |> Utils.unwrap("")))
expect "hello" |> from_str |> Utils.unwrap("") |> starts_with((from_str("lo") |> Utils.unwrap(""))) |> Bool.not

## Check if an ASCII string ends with another ASCII string.
ends_with : Ascii, Ascii -> Bool
ends_with = |haystack, needle| List.ends_with(haystack, needle)

expect "hello" |> from_str |> Utils.unwrap("") |> ends_with((from_str("lo") |> Utils.unwrap("")))
expect "hello" |> from_str |> Utils.unwrap("") |> ends_with((from_str("he") |> Utils.unwrap(""))) |> Bool.not

# trim
# trimStart
# trimEnd

to_dec : Ascii -> Result Dec [InvalidNumStr]
to_dec = |s| s |> to_str |> Str.to_dec

to_f64 : Ascii -> Result F64 [InvalidNumStr]
to_f64 = |s| s |> to_str |> Str.to_f64

to_f32 : Ascii -> Result F32 [InvalidNumStr]
to_f32 = |s| s |> to_str |> Str.to_f32

to_u128 : Ascii -> Result U128 [InvalidNumStr]
to_u128 = |s| s |> to_str |> Str.to_u128

to_i128 : Ascii -> Result I128 [InvalidNumStr]
to_i128 = |s| s |> to_str |> Str.to_i128

to_u64 : Ascii -> Result U64 [InvalidNumStr]
to_u64 = |s| s |> to_str |> Str.to_u64

to_i64 : Ascii -> Result I64 [InvalidNumStr]
to_i64 = |s| s |> to_str |> Str.to_i64

to_u32 : Ascii -> Result U32 [InvalidNumStr]
to_u32 = |s| s |> to_str |> Str.to_u32

to_i32 : Ascii -> Result I32 [InvalidNumStr]
to_i32 = |s| s |> to_str |> Str.to_i32

to_u16 : Ascii -> Result U16 [InvalidNumStr]
to_u16 = |s| s |> to_str |> Str.to_u16

to_i16 : Ascii -> Result I16 [InvalidNumStr]
to_i16 = |s| s |> to_str |> Str.to_i16

to_u8 : Ascii -> Result U8 [InvalidNumStr]
to_u8 = |s| s |> to_str |> Str.to_u8

to_i8 : Ascii -> Result I8 [InvalidNumStr]
to_i8 = |s| s |> to_str |> Str.to_i8

## Count the number of characters in an ASCII string.
len : Ascii -> U64
len = |chars| List.len(chars)

expect
    out = "hello" |> from_str |> Utils.unwrap("") |> len
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
reverse = |chars| List.reverse(chars)

expect
    out = "hello" |> from_str |> Utils.unwrap("") |> reverse
    out |> to_str == "olleh"

## Sort a list of ASCII strings in ascending [ASCIIbetical](https://en.wikipedia.org/wiki/ASCII#Character_order) order.
sort_asc : List Ascii -> List Ascii
sort_asc = |ascii_strs| List.sort_with(ascii_strs, compare)

expect
    a = from_str("hello") |> Utils.unwrap("")
    b = from_str("world") |> Utils.unwrap("")
    c = from_str("!") |> Utils.unwrap("")
    out = sort_asc([a, b, c])
    out == [c, a, b]

## Sort a list of ASCII strings in descending [ASCIIbetical](https://en.wikipedia.org/wiki/ASCII#Character_order) order.
sort_desc : List Ascii -> List Ascii
sort_desc = |ascii_strs| List.sort_with(ascii_strs, |a, b| compare(b, a))

expect
    a = from_str("hello") |> Utils.unwrap("")
    b = from_str("world") |> Utils.unwrap("")
    c = from_str("!") |> Utils.unwrap("")
    out = sort_desc([a, b, c])
    out == [b, a, c]
