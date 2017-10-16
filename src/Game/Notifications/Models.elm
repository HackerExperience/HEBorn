module Game.Notifications.Models exposing (..)

import Time exposing (Time)
import Dict exposing (Dict)


-- TODO: add notification data


type alias Model =
    Dict ID Notification


type alias ID =
    ( Time, Int )


type alias Notification =
    { content : Content, isRead : Bool }


type Content
    = Simple String String -- Title Message
    | NewEmail String String -- Person_ID Preview_Message
    | DownloadStarted


initialModel : Model
initialModel =
    Dict.empty


filterUnreaded : Model -> Model
filterUnreaded =
    Dict.filter (\_ -> .isRead >> not)


countUnreaded : Model -> Int
countUnreaded =
    let
        counter k v a =
            if (not v.isRead) then
                a + 1
            else
                a
    in
        Dict.foldl counter 0


get : ID -> Model -> Maybe Notification
get id =
    Dict.get id


{-| If there is another one born in the same time, increase the right counter, recursively |
-}
findId : ( Time, Int ) -> Model -> ID
findId (( birth, from ) as pig) model =
    model
        |> Dict.get pig
        |> Maybe.map (\twin -> findId ( birth, from + 1 ) model)
        |> Maybe.withDefault pig


insert : Time -> Notification -> Model -> Model
insert created value model =
    Dict.insert
        (findId ( created, 0 ) model)
        value
        model


markRead : Bool -> ID -> Model -> Model
markRead value_ id model =
    model
        |> get id
        |> Maybe.map
            ((\n -> { n | isRead = value_ })
                >> (flip (Dict.insert id) model)
            )
        |> Maybe.withDefault model


create : Content -> Notification
create content =
    { content = content
    , isRead = False
    }
