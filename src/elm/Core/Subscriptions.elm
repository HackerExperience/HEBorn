module Core.Subscriptions exposing (subscriptions)

import WebSocket

import Core.Messages exposing (Msg(WSReceivedMessage))
import Core.Models exposing (Model)


subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen "ws://localhost:8080" WSReceivedMessage
