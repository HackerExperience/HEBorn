module Utils.Core exposing (swap)


swap : (a -> b -> c -> d) -> c -> b -> a -> d
swap function =
    (\a b c -> function c b a)
