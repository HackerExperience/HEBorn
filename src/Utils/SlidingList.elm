module Utils.SlidingList
    exposing
        ( SlidingList
        , empty
          --
        , isEmpty
        , length
        , reverse
        , member
          --
        , singleton
          --
        , nth
        , focusNth
        , removeNth
        , current
        , getRear
        , getFront
        , clearRear
        , clearFront
          --
        , toList
        , toIndexedList
          --
        , map
        , filter
        , rollForward
        , rollBackward
        , cons
        , consAside
        , drop
        , replace
          --
        , indexedMap
        )

{-
   This data structure is kinda like a SlidingList, but it doesn't provide O(1)
   cons/push, it's more like a sliding list with O(1) insertion on it's focal
   point.

   While this data structure is kinda fast (still some room for improvements),
   it's not mature and will need to be moved out of this codebase as it would
   be easier to maintain it as a UX data structure library.
-}

import Utils exposing (andJust)
import Maybe as Maybe exposing (Maybe)


type alias SlidingList a =
    { front : List a
    , rear : List a
    , rearLength : Int
    }


empty : SlidingList a
empty =
    { front = []
    , rear = []
    , rearLength = 0
    }


singleton : a -> SlidingList a
singleton item =
    { front = [ item ]
    , rear = []
    , rearLength = 0
    }


isEmpty : SlidingList a -> Bool
isEmpty { rear, front } =
    List.isEmpty rear && List.isEmpty front


member : a -> SlidingList a -> Bool
member item { front, rear } =
    List.member item front || List.member item rear


length : SlidingList a -> Int
length { rearLength, front } =
    rearLength + List.length front


reverse : SlidingList a -> SlidingList a
reverse { front, rear } =
    let
        ( rear_, rearLength ) =
            List.foldl
                (\item ( list, len ) -> ( item :: list, len + 1 ))
                ( [], 0 )
                front

        front_ =
            List.reverse rear
    in
        { front = front_
        , rear = rear_
        , rearLength = rearLength
        }


current : SlidingList a -> Maybe a
current { front } =
    List.head front


nth : Int -> SlidingList a -> Maybe a
nth index { rear, front, rearLength } =
    let
        pos =
            index - rearLength
    in
        if pos > 0 then
            let
                dropNum =
                    rearLength - (abs pos)
            in
                rear
                    |> List.drop dropNum
                    |> List.head
        else
            front
                |> List.drop (abs pos)
                |> List.head


focusNth : Int -> SlidingList a -> SlidingList a
focusNth index ({ rear, front, rearLength } as list) =
    if index == rearLength then
        list
    else
        let
            diff =
                index - rearLength

            direction =
                if diff > 0 then
                    rollForward
                else
                    rollBackward

            reduce =
                \acc n ->
                    if n > 0 then
                        reduce (direction acc) (n - 1)
                    else
                        acc
        in
            reduce list (abs diff)


removeNth : Int -> SlidingList a -> SlidingList a
removeNth index ({ rear, front, rearLength } as list) =
    let
        diff =
            index - rearLength

        n =
            abs diff
    in
        if index == rearLength then
            drop list
        else if diff > 0 && n <= (List.length front) then
            -- TODO: cache frontLength to make this faster
            { list | front = dropNth n front }
        else if diff < 0 && n <= rearLength then
            { list | rear = dropNth n rear, rearLength = rearLength - 1 }
        else
            list


getRear : SlidingList a -> List a
getRear { rear } =
    rear


getFront : SlidingList a -> List a
getFront { front } =
    front
        |> List.tail
        |> Maybe.withDefault []


clearRear : SlidingList a -> SlidingList a
clearRear ({ rear, front } as list) =
    { list | rear = [], rearLength = 0 }


clearFront : SlidingList a -> SlidingList a
clearFront ({ rear, front } as list) =
    let
        front_ =
            front
                |> List.head
                |> andJust List.singleton
                |> Maybe.withDefault []
    in
        { list | front = front_ }


map : (a -> a) -> SlidingList a -> SlidingList a
map fun ({ rear, front } as list) =
    let
        map =
            List.map fun
    in
        { list | rear = map rear, front = map front }


filter : (a -> Bool) -> SlidingList a -> SlidingList a
filter fun ({ rear, front } as list) =
    -- TODO: this could be optimized
    let
        filter =
            List.filter fun

        rear_ =
            filter rear

        front_ =
            filter front

        rearLength =
            List.length rear_
    in
        { list | rear = rear_, front = front_, rearLength = rearLength }


rollForward : SlidingList a -> SlidingList a
rollForward ({ rear, front, rearLength } as list) =
    case List.head front of
        Just item ->
            let
                front_ =
                    front
                        |> List.tail
                        |> Maybe.withDefault ([])
            in
                { front = front_
                , rear = item :: rear
                , rearLength = rearLength + 1
                }

        Nothing ->
            list


rollBackward : SlidingList a -> SlidingList a
rollBackward ({ rear, front, rearLength } as list) =
    case List.head rear of
        Just item ->
            let
                rear_ =
                    rear
                        |> List.tail
                        |> Maybe.withDefault []
            in
                { front = item :: front
                , rear = rear_
                , rearLength = rearLength - 1
                }

        Nothing ->
            list


cons : a -> SlidingList a -> SlidingList a
cons item ({ front } as list) =
    { list | front = item :: front }


consAside : a -> SlidingList a -> SlidingList a
consAside newItem ({ front, rear, rearLength } as list) =
    -- TODO: rename to consRoll
    case List.head front of
        Just oldItem ->
            let
                front_ =
                    front
                        |> List.tail
                        |> Maybe.withDefault []
            in
                { list
                    | front = newItem :: front_
                    , rear = oldItem :: rear
                    , rearLength = rearLength + 1
                }

        Nothing ->
            cons newItem list


replace : a -> SlidingList a -> SlidingList a
replace item ({ front } as list) =
    case List.tail front of
        Just front_ ->
            { list | front = item :: front_ }

        Nothing ->
            { list | front = [ item ] }


drop : SlidingList a -> SlidingList a
drop ({ rear, front, rearLength } as list) =
    let
        front_ =
            front
                |> List.tail
                |> Maybe.withDefault []
    in
        if List.isEmpty front_ then
            case List.head rear of
                Just item ->
                    let
                        rear_ =
                            rear
                                |> List.tail
                                |> Maybe.withDefault []
                    in
                        { list
                            | front = [ item ]
                            , rear = rear_
                            , rearLength = rearLength - 1
                        }

                Nothing ->
                    { list | front = front_ }
        else
            { list | front = front_ }


indexedMap : (( a, Int ) -> a) -> SlidingList a -> SlidingList a
indexedMap fun list =
    indexedApply List.map fun list


toList : SlidingList a -> List a
toList { rear, front } =
    List.foldr (::) rear front


toIndexedList : SlidingList a -> List ( a, Int )
toIndexedList { rear, front } =
    let
        ( rear_, length ) =
            rear
                |> List.reverse
                |> withIndex 0

        ( front_, _ ) =
            withIndex length front
    in
        List.foldr (::) (List.reverse rear_) front_



-- private


dropNth : Int -> List a -> List a
dropNth n list =
    let
        left =
            List.take n list

        right =
            list
                |> List.drop n
                |> List.tail
                |> Maybe.withDefault []
    in
        left ++ right


withIndex : Int -> List a -> ( List ( a, Int ), Int )
withIndex initial list =
    let
        reducer =
            \item ( list, index ) -> ( ( item, index ) :: list, index + 1 )
    in
        List.foldl reducer ( [], initial ) list


indexedApply :
    (b -> List ( a, Int ) -> List c)
    -> b
    -> SlidingList a
    -> SlidingList c
indexedApply operation fun ({ rear, front } as list) =
    let
        ( revRear, rearLength ) =
            rear
                |> List.reverse
                |> withIndex 0

        ( revFront, _ ) =
            withIndex rearLength front

        rear_ =
            revRear
                |> operation fun
                |> List.reverse

        front_ =
            operation fun revFront
    in
        { front = front_, rear = rear_, rearLength = rearLength }
