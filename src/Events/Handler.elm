module Events.Handler exposing (Error, handler, report)

import Json.Decode exposing (Value)
import Driver.Websocket.Channels as Ws
import Events.Account.Handler as Account
import Events.Server.Handler as Server
import Events.BackFlix.Handler as BackFlix
import Events.Config exposing (..)


type alias Error =
    { event : String
    , channel : Ws.Channel
    , message : String
    }


handler :
    Config msg
    -> Ws.Channel
    -> Result String ( String, String, Value )
    -> Result Error msg
handler config channel result =
    case result of
        Ok ( event, requestId, value ) ->
            case router config channel requestId event value of
                Ok event ->
                    Ok event

                Err "" ->
                    Err <| Error event channel "Couldn't match event name."

                Err msg ->
                    Err <| Error event channel msg

        Err msg ->
            Err <| Error "*" channel msg


report : Error -> String
report { event, channel, message } =
    "⚠ Event '"
        ++ event
        ++ " from channel '"
        ++ toString channel
        ++ "' can't be handled:\n"
        ++ message



-- inte


router :
    Config msg
    -> Ws.Channel
    -> String
    -> String
    -> Value
    -> Result String msg
router config channel requestId event json =
    case channel of
        Ws.AccountChannel _ ->
            Account.events config.forAccount requestId event json

        Ws.ServerChannel id ->
            Server.events config.forServer requestId id event json

        Ws.BackFlixChannel ->
            BackFlix.events config.forBackFlix requestId event json
