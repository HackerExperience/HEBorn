module App.Subscriptions exposing (subscriptions)

import WebSocket

import App.Messages exposing (Msg(WSReceivedMessage))
import App.Models exposing (Model)


subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen "ws://localhost:8080" WSReceivedMessage
