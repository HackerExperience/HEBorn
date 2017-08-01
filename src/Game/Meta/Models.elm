module Game.Meta.Models
    exposing
        ( Model
        , initialModel
        , getGateway
        , getContext
        )

import Game.Servers.Shared as Servers
import Time exposing (Time)
import Game.Meta.Messages exposing (..)
import Game.Meta.Types exposing (..)


type alias Model =
    { online : Int
    , lastTick : Time
    , context : Context
    , gateway : Maybe Servers.ID
    }


initialModel : Model
initialModel =
    { online = 0
    , lastTick = 0
    , context = Gateway
    , gateway = Just "server1"
    }


getGateway : Model -> Maybe Servers.ID
getGateway =
    .gateway


getContext : Model -> Context
getContext =
    .context
