module Decoders.ServerNotifications exposing (..)

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
import Game.Meta.Types.Notifications exposing (..)
import Game.Servers.Notifications.Models exposing (..)
import Game.Servers.Notifications.Shared exposing (..)


{-| TODO: proposed for removal
-}
notificationsField : Decoder (Model -> b) -> Decoder b
notificationsField =
    optional "notifications" model empty


model : Decoder Model
model =
    map Dict.fromList (list notification)


notification : Decoder ( Id, Notification Content )
notification =
    field "type" string
        |> andThen content
        |> andThen base


content : String -> Decoder Content
content type_ =
    case type_ of
        "simple" ->
            decode Generic
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


base : Content -> Decoder ( Id, Notification Content )
base content =
    decode
        (\c r -> ( ( c, 0 ), Notification content r ))
        |> required "created" float
        |> optional "read" bool False
