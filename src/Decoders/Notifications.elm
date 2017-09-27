module Decoders.Notifications exposing (..)

import Dict
import Json.Decode exposing (Decoder, succeed, fail, field, andThen, list, string, float, bool)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Game.Notifications.Models exposing (..)


notification : Decoder ( ID, Notification )
notification =
    field "type" string
        |> andThen notificationContent
        |> andThen notificationBase


fromMeta :
    Decoder Content
    -> Decoder Content
fromMeta =
    field "meta"


notificationContent : String -> Decoder Content
notificationContent type_ =
    case type_ of
        "simple" ->
            decode (Simple)
                |> required "title" string
                |> required "msg" string
                |> fromMeta

        _ ->
            fail "Unknow notification type"


notificationBase : Content -> Decoder ( ID, Notification )
notificationBase content =
    decode
        (\c r -> ( ( c, 0 ), Notification content r ))
        |> required "created" float
        |> optional "read" bool False


notifications : Decoder Model
notifications =
    notification
        |> list
        |> andThen
            (Dict.fromList >> succeed)


notificationsField :
    Decoder (Model -> b)
    -> Decoder b
notificationsField =
    optional "notifications" notifications Dict.empty
