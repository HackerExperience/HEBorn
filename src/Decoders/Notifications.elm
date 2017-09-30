module Decoders.Notifications exposing (..)

import Dict
import Json.Decode
    exposing
        ( Decoder
        , succeed
        , fail
        , field
        , andThen
        , map
        , list
        , string
        , float
        , bool
        )
import Json.Decode.Pipeline exposing (decode, optional, required)
import Game.Notifications.Models exposing (..)


{-| TODO: proposed for removal
-}
notificationsField : Decoder (Model -> b) -> Decoder b
notificationsField =
    optional "notifications" model initialModel


model : Decoder Model
model =
    map Dict.fromList (list notification)


notification : Decoder ( ID, Notification )
notification =
    field "type" string
        |> andThen content
        |> andThen base


content : String -> Decoder Content
content type_ =
    case type_ of
        "simple" ->
            decode (Simple)
                |> required "title" string
                |> required "msg" string
                |> fromMeta

        _ ->
            fail "Unknow notification type"


fromMeta :
    Decoder Content
    -> Decoder Content
fromMeta =
    field "meta"


base : Content -> Decoder ( ID, Notification )
base content =
    decode
        (\c r -> ( ( c, 0 ), Notification content r ))
        |> required "created" float
        |> optional "read" bool False
