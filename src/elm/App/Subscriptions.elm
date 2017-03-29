module App.Subscriptions exposing (subscriptions)

import WebSocket

import App.Messages exposing (Msg(WSReceivedMessage))
import App.Models exposing (Model)


subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen "ws://interactive-1.hackerexperience.com:8080" WSReceivedMessage
