module Game.Meta.Models
    exposing
        ( Model
        , KeyMode(..)
        , initialModel
        , getLastTick
        )

import Time exposing (Time)


type alias Model =
    { online : Int
    , lastTick : Time
    , keyFocus : KeyMode
    }


type KeyMode
    = NormalMode
    | InsertMode --When inside INPUT / TEXTAREA
    | SelectMode --Navigate through the last (0-9) window



-- TODO: move active gateway / context to account


initialModel : Model
initialModel =
    { online = 0
    , lastTick = 0
    , keyFocus = NormalMode
    }


getLastTick : Model -> Time
getLastTick =
    .lastTick


getKeyMode : Model -> KeyMode
getKeyMode =
    .keyFocus
