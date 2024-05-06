module [unwrap, intersperse]

unwrap = \result, message ->
    when result is
        Ok x -> x
        Err _ -> crash message

intersperse : List (List a), List a -> List a
intersperse = \list, sep ->
    listLen = List.len list
    List.walkWithIndex
        list
        []
        (
            \state, elem, index ->
                state
                |> List.concat elem
                |> (\l -> if index < (listLen - 1) then List.concat l sep else l)
        )

expect
    out = intersperse [['a', 'b'], ['c', 'd'], ['e']] ['x']
    out == ['a', 'b', 'x', 'c', 'd', 'x', 'e']
