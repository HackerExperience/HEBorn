module Utils.Core exposing (..)


swap : (a -> b -> c -> d) -> c -> b -> a -> d
swap function =
    (\a b c -> function c b a)


(>>>) : (a -> b -> c) -> (c -> d) -> (a -> b -> d)
(>>>) f g a b =
    g (f a b)
infixl 9 >>>


(>>>>) : (a -> b -> c -> d) -> (d -> e) -> (a -> b -> c -> e)
(>>>>) f g a b c =
    g (f a b c)
infixl 9 >>>>


(>>>>>) : (a -> b -> c -> d -> e) -> (e -> f) -> (a -> b -> c -> d -> f)
(>>>>>) f g a b c d =
    g (f a b c d)
infixl 9 >>>>>


(>>>>>>) : (a -> b -> c -> d -> e -> f) -> (f -> g) -> (a -> b -> c -> d -> e -> g)
(>>>>>>) f g a b c d e =
    g (f a b c d e)
infixl 9 >>>>>>
