app [main!] { ascii: "../src/main.roc" }

import ascii.Ascii

main! = |_| {
	str = "Hello, World!"
	str_ascii = Ascii.from_str(str)?
	upper_ascii = str_ascii.to_uppercase()
	echo!("${str}\n")
	echo!("${upper_ascii.to_str()}\n")
	Ok({})
}
