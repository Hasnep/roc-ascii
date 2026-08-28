Utils :: [].{
	join_with : List(List(a)), List(a) -> List(a)
	join_with = |list, sep| {
		list.fold_with_index(
			[],
			|state, elem, index|
				state.concat(elem)
					|> (|l| if index < (list.len() - 1) {
						List.concat(l, sep)
					} else {
						l
					}),

		)
	}

	expect {
		out = join_with([['a', 'b'], ['c', 'd'], ['e']], ['x'])
		out == ['a', 'b', 'x', 'c', 'd', 'x', 'e']
	}

	zip : List(a), List(b) -> List((a, b))
	zip = |a, b| a.map2(b, |x, y| (x, y))

	expect {
		out = zip([1, 2, 3], [A, B, C])
		out == [(1, A), (2, B), (3, C)]
	}
}
