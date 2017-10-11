module Events.Events exposing (Event(..), events)

import Json.Decode exposing (Value)
import Driver.Websocket.Channels as Ws
import Driver.Websocket.Reports as Ws
import Game.Servers.Shared as Servers
import Events.Account as Account
import Events.Server as Server


type Event
    = Account Account.Event
    | Server Servers.ID Server.Event
    | Report Ws.Report


events : Ws.Channel -> String -> Value -> Maybe Event
events channel event json =
    case router channel event json of
        Ok event ->
            Just event

        Err reason ->
            let
                report =
                    if reason == "" then
                        notFound
                    else
                        decodeError reason

                channelName =
                    Ws.getAddress channel
            in
                report channelName event


router : Ws.Channel -> String -> Value -> Result String Event
router channel event json =
    case channel of
        Ws.RequestsChannel ->
            Err ""

        Ws.AccountChannel _ ->
            Result.map Account <| Account.events event json

        Ws.ServerChannel id ->
            Result.map (Server id) <| Server.events event json


notFound : String -> String -> Maybe Event
notFound channel event =
    let
        msg =
            "no handler for event `"
                ++ event
                ++ "' (channel `"
                ++ channel
                ++ "')"
    in
        report msg


decodeError : String -> String -> String -> Maybe Event
decodeError error channel event =
    let
        msg =
            "event `"
                ++ event
                ++ "' (channel `"
                ++ channel
                ++ "') gone wrong:"
                ++ error
    in
        report msg


report : String -> Maybe Event
report msg =
    ""
        |> Debug.log ("▶ Event Error: " ++ msg)
        |> always Nothing
