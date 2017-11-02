module Driver.Websocket.Models exposing (Model, EventBase, initialModel)

import Dict exposing (Dict)
import Json.Decode exposing (Value)
import Driver.Websocket.Messages exposing (..)
import Phoenix.Socket as Socket
import Phoenix.Channel as Channel


type alias Model =
    { socket : Socket.Socket Msg
    , channels : Channels
    }


type alias Channels =
    Dict String (Channel.Channel Msg)


type alias EventBase =
    { data : Value
    , event : String
    }


initialSocket : String -> String -> Socket.Socket Msg
initialSocket apiWsUrl token =
    apiWsUrl
        |> Socket.init
        |> Socket.withParams [ ( "token", token ) ]
        |> Socket.onOpen (Connected token)
        |> Socket.onClose (\_ -> Disconnected)


initialModel : String -> String -> Model
initialModel apiWsUrl token =
    { socket = initialSocket apiWsUrl token
    , channels = Dict.empty
    }
