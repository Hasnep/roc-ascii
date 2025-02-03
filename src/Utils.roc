module [unwrap, intersperse, zip]

unwrap = |result, message|
    when result is
        Ok(x) -> x
        Err(_) -> crash(message)

intersperse : List (List a), List a -> List a
intersperse = |list, sep|
    list_len = List.len(list)
    List.walk_with_index(
        list,
        [],
        |state, elem, index|
            state
            |> List.concat(elem)
            |> (|l| if index < (list_len - 1) then List.concat(l, sep) else l),
    )

expect
    out = intersperse([['a', 'b'], ['c', 'd'], ['e']], ['x'])
    out == ['a', 'b', 'x', 'c', 'd', 'x', 'e']

zip : List a, List b -> List (a, b)
zip = |a, b| List.map2(a, b, |x, y| (x, y))
