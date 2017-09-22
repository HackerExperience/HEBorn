module Driver.Websocket.Models exposing (Model, initialModel)

import Dict exposing (Dict)
import Driver.Websocket.Messages exposing (..)
import Driver.Websocket.Reports exposing (..)
import Events.Events as Events exposing (Event(..))
import Phoenix.Socket as Socket
import Phoenix.Channel as Channel


type alias Model =
    { socket : Socket.Socket Msg
    , channels : Channels
    }


type alias Channels =
    Dict String (Channel.Channel Msg)


initialSocket : String -> String -> Socket.Socket Msg
initialSocket apiWsUrl token =
    apiWsUrl
        |> Socket.init
        |> Socket.withParams [ ( "token", token ) ]
        |> Socket.onOpen (Connected token |> Events.Report |> Broadcast)
        |> Socket.onClose (\_ -> Disconnected |> Events.Report |> Broadcast)


initialModel : String -> String -> Model
initialModel apiWsUrl token =
    { socket = initialSocket apiWsUrl token
    , channels = Dict.empty
    }
