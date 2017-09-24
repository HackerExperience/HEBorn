module Decoders.Notifications exposing (..)

import Dict
import Json.Decode exposing (Decoder, andThen, dict, string, float, bool)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Game.Notifications.Models as Notifications exposing (Notification)


notification : Decoder Notification
notification =
    -- TODO
    decode (Notifications.Simple)
        |> required "title" string
        |> required "msg" string
        |> andThen notificationBase


notificationBase : Notifications.Content -> Decoder Notification
notificationBase content =
    decode (Notification content)
        |> required "created" float
        |> required "read" bool


notifications : Decoder Notifications.Model
notifications =
    (dict notification)


notificationsField :
    Decoder (Notifications.Model -> b)
    -> Decoder b
notificationsField =
    optional "notifications" notifications Dict.empty
