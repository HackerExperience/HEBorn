module Utils.List
    exposing
        ( last
        , move
        , indexedFoldl
        , indexedFoldr
        )


last : List a -> Maybe a
last =
    List.foldl (Just >> always) Nothing


move : Int -> Int -> List a -> List a
move from to list =
    -- TODO: clear this function
    let
        reducer append i next ( state, found, list ) =
            if state == 0 && from == i then
                ( 1, Just next, list )
            else if state == 1 && to == i then
                let
                    list_ =
                        found
                            |> Maybe.map (\item -> append item next list)
                            |> Maybe.withDefault []
                in
                    ( 2, Nothing, list_ )
            else
                ( state, found, next :: list )
    in
        if from < to then
            let
                ( _, _, list_ ) =
                    indexedFoldl (reducer appendLeft) ( 0, Nothing, [] ) list
            in
                List.reverse list_
        else if from > to then
            let
                ( _, _, list_ ) =
                    indexedFoldr (reducer appendRight) ( 0, Nothing, [] ) list
            in
                list_
        else
            list


indexedFoldl : (Int -> a -> b -> b) -> b -> List a -> b
indexedFoldl func init xs =
    xs
        |> List.foldl (countUp func) ( init, 0 )
        |> Tuple.first


indexedFoldr : (Int -> a -> b -> b) -> b -> List a -> b
indexedFoldr func init xs =
    xs
        |> List.foldr (countDown func) ( init, (List.length xs) - 1 )
        |> Tuple.first



-- internals


appendLeft : a -> a -> List a -> List a
appendLeft a b list =
    b :: (a :: list)


appendRight : a -> a -> List a -> List a
appendRight a b list =
    a :: (b :: list)


countUp : (Int -> a -> b -> b) -> a -> ( b, Int ) -> ( b, Int )
countUp func value ( acc, index ) =
    ( func index value acc, index + 1 )


countDown : (Int -> a -> b -> b) -> a -> ( b, Int ) -> ( b, Int )
countDown func value ( acc, index ) =
    ( func index value acc, index - 1 )
