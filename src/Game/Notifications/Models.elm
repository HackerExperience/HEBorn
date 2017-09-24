module Game.Notifications.Models exposing (..)

import Time exposing (Time)
import Dict exposing (Dict)
import Random.Pcg as Random
import Utils.Model.RandomUuid as RandomUuid


-- TODO: add notification data


type alias Model =
    Dict ID Notification


type alias ID =
    RandomUuid.Uuid


type alias Notification =
    { content : Content, created : Time, isRead : Bool }


type Content
    = Simple String String -- Title Message
    | NewEmail String String -- Person_ID Preview_Message


initialModel : Model
initialModel =
    Dict.empty


new : Time -> Content -> Notification
new lastTick content =
    { content = content
    , created = lastTick
    , isRead = False
    }


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


insert : ID -> Notification -> Model -> Model
insert id value =
    Dict.insert id value


markRead : Bool -> ID -> Model -> Model
markRead value_ id model =
    model
        |> get id
        |> Maybe.map
            ((\n -> { n | isRead = value_ })
                >> (flip (insert id) model)
            )
        |> Maybe.withDefault model


getSorted : Model -> List ( ID, Notification )
getSorted =
    Dict.toList
        >> List.sortBy (\( _, { created } ) -> created)
