module Driver.Websocket.Models exposing (Model, initialModel)

import Driver.Websocket.Channels exposing (..)
import Driver.Websocket.Messages exposing (..)
import Driver.Websocket.Reports exposing (..)
import Events.Events as Events exposing (Event(..))
import Events.Account as AccountEvents
import Phoenix.Socket as Socket
import Phoenix.Channel as Channel


type alias Model =
    { socket : Socket.Socket Msg
    , channels : List (Channel.Channel Msg)
    , defer : Bool
    }


initialSocket : String -> String -> Socket.Socket Msg
initialSocket apiWsUrl token =
    apiWsUrl
        |> Socket.init
        |> Socket.withParams [ ( "token", token ) ]
        |> Socket.onOpen (Connected token |> Events.Report |> Broadcast)
        |> Socket.onClose (\_ -> Disconnected |> Events.Report |> Broadcast)


initialChannels : List (Channel.Channel Msg)
initialChannels =
    [ Channel.init "requests" ]


initialModel : String -> String -> Model
initialModel apiWsUrl token =
    { socket = initialSocket apiWsUrl token
    , channels = initialChannels
    , defer = True
    }
