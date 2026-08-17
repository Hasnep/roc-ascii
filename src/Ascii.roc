import Char exposing [Char]
import Utils

Ascii :: List(Char).{
	from_chars : List(Char) -> Ascii
	from_chars = |chars| Ascii.(chars)

	to_chars : Ascii -> List(Char)
	to_chars = |Ascii.(chars)| chars

	## Round trip test
	expect {
		hello_chars = [
			Char.from_ascii_byte('h')?,
			Char.from_ascii_byte('e')?,
			Char.from_ascii_byte('l')?,
			Char.from_ascii_byte('l')?,
			Char.from_ascii_byte('o')?,
		]
		out = from_chars(hello_chars).to_chars()
		out == hello_chars
	}

	## Convert a UTF-8 [Str] to an ASCII string.
	from_str : Str -> Try(Ascii, [InvalidAscii])
	from_str = |str| {
		str.to_utf8() |> from_ascii_bytes
	}

	## Convert an ASCII string to a UTF-8 [Str].
	to_str : Ascii -> Str
	to_str = |Ascii.(chars)| chars.map(Char.to_ascii_byte) |> Str.from_utf8 ?? {
		crash "ASCII bytes are always valid UTF-8"
	}

	# Round trip test
	expect {
		hello = "hello"
		out = from_str(hello)?.to_str()
		out == hello
	}

	## Convert a list of ASCII code points to an ASCII string.
	from_ascii_bytes : List(U8) -> Try(Ascii, [InvalidAscii])
	from_ascii_bytes = |bytes| {
		char_results = bytes.map(Char.from_ascii_byte)
		if List.all(char_results, Try.is_ok) {
			char_results.map(
				|r| r ?? {
					crash "We already checked that all the results are Ok."
				},
			)
				|> from_chars
				|> Ok
		} else {
			Err(InvalidAscii)
		}
	}

	expect {
		hello = ['h', 'e', 'l', 'l', 'o']
		out = from_ascii_bytes(hello)
		expected_out = from_str("hello")
		out == expected_out
	}

	## Convert an ASCII string to a list of ASCII code points.
	to_ascii_bytes : Ascii -> List(U8)
	to_ascii_bytes = |Ascii.(chars)| chars.map(Char.to_ascii_byte)

	expect {
		hello = from_str("hello")
		out = hello.map_ok(to_ascii_bytes)
		out == Ok(['h', 'e', 'l', 'l', 'o'])
	}

	## Check whether two ASCII strings are equal.
	is_eq : Ascii, Ascii -> Bool
	is_eq = |Ascii.(a), Ascii.(b)| Utils.zip(a, b).fold_until(
		True,
		|_, (a_char, b_char)| if a_char == b_char {
			Continue(True)
		} else {
			Break(False)
		},
	)

	expect {
		a = from_str("hello")
		b = from_str("hello")
		a == b
	}

	expect {
		a = from_str("hello")
		b = from_str("goodbye")
		a != b
	}

	## Compare the [ASCIIbetical](https://en.wikipedia.org/wiki/ASCII#Character_order) order of two ASCII strings, i.e. by comparing their code points.
	compare : Ascii, Ascii -> [LT, EQ, GT]
	compare = |Ascii.(a), Ascii.(b)| {
		comparison =
			Utils.zip(a, b).fold_until(
				EQ,
				|_, (a_char, b_char)| {
					match Char.compare(a_char, b_char) {
						LT => Break(LT)
						EQ => Continue(EQ)
						GT => Break(GT)
					}
				},
			)
		# If the strings are equal up to the length of the shorter string
		if comparison == EQ {
			# Then the shorter string is lexicographically less than the longer string
			a.len().compare(b.len())
		} else {
			comparison
		}
	}

	expect {
		a = from_str("hello")?
		b = from_str("hello")?
		out = compare(a, b)
		out == EQ
	}

	expect {
		a = from_str("hello")?
		b = from_str("goodbye")?
		out = compare(a, b)
		out == GT
	}

	expect {
		a = from_str("goodbye")?
		b = from_str("hello")?
		out = compare(a, b)
		out == LT
	}

	expect {
		a = from_str("hello")?
		b = from_str("hello!")?
		out = compare(a, b)
		out == LT
	}

	expect {
		a = from_str("")?
		b = from_str("")?
		out = compare(a, b)
		out == EQ
	}

	## Check if an ASCII string is empty.
	is_empty : Ascii -> Bool
	is_empty = |Ascii.(chars)| chars.is_empty()

	expect {
		empty = from_str("")?
		out = empty.is_empty()
		out
	}

	expect {
		hello = from_str("hello")?
		out = hello.is_empty()
		out.not()
	}

	## Convert all the lowercase letters in an ASCII string to uppercase, leaving all other characters unchanged.
	to_uppercase : Ascii -> Ascii
	to_uppercase = |Ascii.(chars)| Ascii.(chars.map(Char.to_uppercase))

	expect {
		out = from_str("Hello").map_ok(to_uppercase)
		out == from_str("HELLO")
	}

	## Convert all the uppercase letters in an ASCII string to lowercase, leaving all other characters unchanged.
	to_lowercase : Ascii -> Ascii
	to_lowercase = |Ascii.(chars)| Ascii.(chars.map(Char.to_lowercase))

	expect {
		out = from_str("Hello").map_ok(to_lowercase)
		out == from_str("hello")
	}

	## Concatenate two ASCII strings.
	concat : Ascii, Ascii -> Ascii
	concat = |Ascii.(a), Ascii.(b)| Ascii.(List.concat(a, b))

	expect {
		a = from_str("Hello,")?
		b = from_str(" world!")?
		out = concat(a, b)
		out == from_str("Hello, world!")?
	}

	# withCapacity # TODO

	# reserve # TODO

	## Join a list of ASCII strings.
	join : List(Ascii) -> Ascii
	join = |ascii_strings| Ascii.(ascii_strings.map(to_chars).join())

	expect {
		a = from_str("hello")?
		b = from_str("world")?
		c = from_str("!")?
		out = join([a, b, c])
		expected_out = from_str("helloworld!")?
		out == expected_out
	}

	## Join a list of ASCII strings with a separator.
	join_with : List(Ascii), Ascii -> Ascii
	join_with = |ascii_strings, sep| ascii_strings.map(to_chars) |> Utils.intersperse(to_chars(sep)) |> from_chars

	expect {
		a = from_str("hello")?
		b = from_str("world")?
		c = from_str("!")?
		sep = from_str("_")?
		out = join_with([a, b, c], sep)
		expected_out = Str.join_with(["hello", "world", "!"], "_") |> from_str()?
		out == expected_out
	}

	# split : Ascii, Ascii -> List Ascii
	# split = # TODO

	## Repeat an ASCII string a specified number of times.
	repeat : Ascii, U64 -> Ascii
	repeat = |Ascii.(chars), n| Ascii.(chars.repeat(n).join())

	expect {
		out = from_str("hello").map_ok(|x| x.repeat(3))
		out == from_str("hellohellohello")
	}

	## Check if an ASCII string starts with another ASCII string.
	starts_with : Ascii, Ascii -> Bool
	starts_with = |Ascii.(haystack), Ascii.(needle)| haystack.starts_with(needle)

	expect {
		haystack = from_str("hello")?
		needle = from_str("he")?
		haystack.starts_with(needle)
	}

	expect {
		haystack = from_str("goodbye")?
		needle = from_str("eggs")?
		haystack.starts_with(needle).not()
	}

	## Check if an ASCII string ends with another ASCII string.
	ends_with : Ascii, Ascii -> Bool
	ends_with = |Ascii.(haystack), Ascii.(needle)| haystack.ends_with(needle)

	expect {
		haystack = from_str("hello")?
		needle = from_str("llo")?
		haystack.ends_with(needle)
	}

	expect {
		haystack = from_str("goodbye")?
		needle = from_str("llo")?
		haystack.ends_with(needle).not()
	}

	# trim
	# trim = # TODO
	# trimStart
	# trimStart = # TODO
	# trimEnd
	# trimEnd = # TODO

	to_dec : Ascii -> Try(Dec, [BadNumStr])
	to_dec = |s| s.to_str() |> Dec.from_str

	to_f64 : Ascii -> Try(F64, [BadNumStr])
	to_f64 = |s| s.to_str() |> F64.from_str

	to_f32 : Ascii -> Try(F32, [BadNumStr])
	to_f32 = |s| s.to_str() |> F32.from_str

	to_u128 : Ascii -> Try(U128, [BadNumStr])
	to_u128 = |s| s.to_str() |> U128.from_str

	to_i128 : Ascii -> Try(I128, [BadNumStr])
	to_i128 = |s| s.to_str() |> I128.from_str

	to_u64 : Ascii -> Try(U64, [BadNumStr])
	to_u64 = |s| s.to_str() |> U64.from_str

	to_i64 : Ascii -> Try(I64, [BadNumStr])
	to_i64 = |s| s.to_str() |> I64.from_str

	to_u32 : Ascii -> Try(U32, [BadNumStr])
	to_u32 = |s| s.to_str() |> U32.from_str

	to_i32 : Ascii -> Try(I32, [BadNumStr])
	to_i32 = |s| s.to_str() |> I32.from_str

	to_u16 : Ascii -> Try(U16, [BadNumStr])
	to_u16 = |s| s.to_str() |> U16.from_str

	to_i16 : Ascii -> Try(I16, [BadNumStr])
	to_i16 = |s| s.to_str() |> I16.from_str

	to_u8 : Ascii -> Try(U8, [BadNumStr])
	to_u8 = |s| s.to_str() |> U8.from_str

	to_i8 : Ascii -> Try(I8, [BadNumStr])
	to_i8 = |s| s.to_str() |> I8.from_str

	## Count the number of characters in an ASCII string.
	len : Ascii -> U64
	len = |Ascii.(chars)| chars.len()

	expect {
		out = from_str("hello").map_ok(len)
		out == Ok(5)
	}

	# replaceEach
	# replaceFirst
	# replaceLast

	# splitFirst
	# splitLast

	# releaseExcessCapacity

	# withPrefix

	# contains

	## Reverse the characters in an ASCII string.
	rev : Ascii -> Ascii
	rev = |Ascii.(chars)| Ascii.(chars.rev())

	expect {
		out = from_str("hello").map_ok(rev)
		out == from_str("olleh")
	}

	## Sort a list of ASCII strings in ascending [ASCIIbetical](https://en.wikipedia.org/wiki/ASCII#Character_order) order.
	sort_asc : List(Ascii) -> List(Ascii)
	sort_asc = |ascii_strs| List.sort_with(ascii_strs, compare)

	expect {
		a = from_str("hello")?
		b = from_str("world")?
		c = from_str("!")?
		out = sort_asc([a, b, c])
		out == [c, a, b]
	}

	## Sort a list of ASCII strings in descending [ASCIIbetical](https://en.wikipedia.org/wiki/ASCII#Character_order) order.
	sort_desc : List(Ascii) -> List(Ascii)
	sort_desc = |ascii_strs| List.sort_with(ascii_strs, |a, b| compare(b, a))

	expect {
		a = from_str("hello")?
		b = from_str("world")?
		c = from_str("!")?
		out = sort_desc([a, b, c])
		out == [b, a, c]
	}
}
