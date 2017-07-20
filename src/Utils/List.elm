module Utils.List
    exposing
        ( find
        , memberIndex
        , findIndex
        , move
        , last
        , splitOut
        , indexedFoldl
        , indexedFoldr
        , foldlWhile
        , foldrWhile
        )


find : (a -> Bool) -> List a -> Maybe a
find check list =
    let
        reducer item acc =
            if (check item) then
                ( True, Just item )
            else
                ( False, Nothing )

        ( _, value ) =
            foldlWhile reducer Nothing list
    in
        value


memberIndex : comparable -> List comparable -> Maybe Int
memberIndex elm =
    findIndex ((==) elm)


findIndex : (a -> Bool) -> List a -> Maybe Int
findIndex check list =
    let
        reducer item acc =
            if (check item) then
                ( True, acc )
            else
                ( False, acc + 1 )

        ( found, index ) =
            foldlWhile reducer 0 list
    in
        if found then
            Just index
        else
            Nothing


last : List a -> Maybe a
last =
    List.foldl (Just >> always) Nothing


splitOut : Int -> List a -> ( List a, List a )
splitOut n xs =
    ( List.take n xs, List.drop (n + 1) xs )


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


foldlWhile : (a -> b -> ( Bool, b )) -> b -> List a -> ( Bool, b )
foldlWhile func acc list =
    case list of
        [] ->
            ( False, acc )

        head :: tail ->
            let
                result =
                    func head acc

                ( halt, acc_ ) =
                    result
            in
                if halt then
                    result
                else
                    foldlWhile func acc_ tail


foldrWhile : (a -> b -> ( Bool, b )) -> b -> List a -> ( Bool, b )
foldrWhile func acc list =
    foldlWhile func acc (List.reverse list)



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
