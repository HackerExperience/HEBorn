module Driver.Websocket.Launch exposing (launch)

import Dict exposing (Dict)
import Phoenix.Socket as Socket
import Driver.Websocket.Messages exposing (..)
import Driver.Websocket.Models exposing (..)


launch : (Msg -> msg) -> ApiUrl -> Token -> ClientName -> Model msg
launch toMsg apiWsUrl token client =
    { socket = initialSocket toMsg apiWsUrl token client
    , channels = Dict.empty
    }


initialSocket :
    (Msg -> msg)
    -> ApiUrl
    -> Token
    -> ClientName
    -> Socket.Socket msg
initialSocket toMsg apiWsUrl token client =
    apiWsUrl
        |> Socket.init
        |> Socket.withParams [ ( "token", token ), ( "client", client ) ]
        |> Socket.onOpen (toMsg <| Connected token client)
        |> Socket.onClose (always <| toMsg Disconnected)
