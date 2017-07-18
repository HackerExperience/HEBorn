module Driver.Websocket.Models exposing (Model, initialModel, eventsFromChannel)

import Driver.Websocket.Channels exposing (..)
import Driver.Websocket.Messages exposing (..)
import Driver.Websocket.Reports exposing (..)
import Events.Events as Events exposing (Event(..))
import Events.Account as AccountEvents
import Phoenix.Socket as Socket
import Phoenix.Channel as Channel


type alias Events =
    List ( String, Event )


type alias EventsByChannel =
    { account : Events
    }


type alias Model =
    { socket : Socket.Socket Msg
    , channels : List (Channel.Channel Msg)
    , defer : Bool
    , events : EventsByChannel
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


initialEvents : EventsByChannel
initialEvents =
    { account = Events.map AccountEvent AccountEvents.events
    }


initialModel : String -> String -> Model
initialModel apiWsUrl token =
    { socket = initialSocket apiWsUrl token
    , channels = initialChannels
    , defer = True
    , events = initialEvents
    }


eventsFromChannel : Channel -> Model -> List ( String, Event )
eventsFromChannel channel model =
    case channel of
        AccountChannel ->
            model.events.account

        _ ->
            []
