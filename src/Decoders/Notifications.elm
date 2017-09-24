module Decoders.Notifications exposing (..)

import Dict
import Json.Decode exposing (Decoder, fail, field, andThen, dict, string, float, bool)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Game.Notifications.Models as Notifications exposing (Notification)


{-
   { "type": "simple"
   , "content": {"title": "Hello", "msg": "World"}
   , "created": 1506286664280
   , "read": 0
   }
-}


notification : Decoder Notification
notification =
    field "type" string
        |> andThen notificationContent
        |> andThen notificationBase


fromMeta :
    Decoder Notifications.Content
    -> Decoder Notifications.Content
fromMeta =
    field "meta"


notificationContent : String -> Decoder Notifications.Content
notificationContent type_ =
    case type_ of
        "simple" ->
            decode (Notifications.Simple)
                |> required "title" string
                |> required "msg" string
                |> fromMeta

        _ ->
            fail "Unknow notification type"


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
