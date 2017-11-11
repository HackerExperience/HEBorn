module Driver.Websocket.Models exposing (Model, EventBase, initialModel)

import Dict exposing (Dict)
import Json.Decode exposing (Value)
import Driver.Websocket.Messages exposing (..)
import Phoenix.Socket as Socket
import Phoenix.Channel as Channel


type alias ApiUrl =
    String


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


initialSocket : ApiUrl -> Token -> ClientName -> Socket.Socket Msg
initialSocket apiWsUrl token client =
    apiWsUrl
        |> Socket.init
        |> Socket.withParams [ ( "token", token ), ( "client", client ) ]
        |> Socket.onOpen (Connected token client)
        |> Socket.onClose (\_ -> Disconnected)


initialModel : ApiUrl -> Token -> ClientName -> Model
initialModel apiWsUrl token client =
    { socket = initialSocket apiWsUrl token client
    , channels = Dict.empty
    }
