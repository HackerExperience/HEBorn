module Game.Meta.Types.Notifications exposing (..)

import Time exposing (Time)
import Dict exposing (Dict)


type alias Notifications a =
    Dict Id (Notification a)


type alias Id =
    ( Time, Int )


type alias Notification a =
    { content : a
    , isRead : Bool
    }


empty : Notifications a
empty =
    Dict.empty


isEmpty : Notifications a -> Bool
isEmpty =
    Dict.isEmpty


get : Id -> Notifications a -> Maybe (Notification a)
get id =
    Dict.get id


insert : Time -> Notification a -> Notifications a -> Notifications a
insert created value notifications =
    Dict.insert
        (findId ( created, 0 ) notifications)
        value
        notifications


filterUnreaded : Notifications a -> Notifications a
filterUnreaded =
    Dict.filter (\_ -> .isRead >> not)


countUnreaded : Notifications a -> Int
countUnreaded =
    let
        counter k v a =
            if (not v.isRead) then
                a + 1
            else
                a
    in
        Dict.foldl counter 0


{-| If there is another one born in the same time,
increase the right counter, recursively.
-}
findId : ( Time, Int ) -> Notifications a -> Id
findId (( birth, from ) as pig) notifications =
    notifications
        |> Dict.get pig
        |> Maybe.map (\twin -> findId ( birth, from + 1 ) notifications)
        |> Maybe.withDefault pig


markRead : Bool -> Id -> Notifications a -> Notifications a
markRead value_ id notifications =
    notifications
        |> get id
        |> Maybe.map
            ((\n -> { n | isRead = value_ })
                >> (flip (Dict.insert id) notifications)
            )
        |> Maybe.withDefault notifications


readAll : Notifications a -> Notifications a
readAll =
    Dict.map (\k v -> { v | isRead = True })


create : a -> Notification a
create content =
    { content = content
    , isRead = False
    }
