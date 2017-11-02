module Events.Events exposing (events)

import Json.Decode exposing (Value)
import Driver.Websocket.Channels as Ws
import Core.Dispatch as Dispatch exposing (Dispatch)
import Events.Account as Account
import Events.Server as Server


events : Ws.Channel -> String -> Value -> Maybe Dispatch
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


router : Ws.Channel -> String -> Value -> Result String Dispatch
router channel event json =
    case channel of
        Ws.RequestsChannel ->
            Err ""

        Ws.AccountChannel _ ->
            Account.events event json

        Ws.ServerChannel id ->
            Server.events id event json


notFound : String -> String -> Maybe Dispatch
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


decodeError : String -> String -> String -> Maybe Dispatch
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


report : String -> Maybe Dispatch
report msg =
    ""
        |> Debug.log ("▶ Event Error: " ++ msg)
        |> always Nothing
