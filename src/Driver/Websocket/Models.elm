module Driver.Websocket.Models exposing (Model, initialModel, eventsFromChannel)

import Driver.Websocket.Messages exposing (Msg(..))
import Driver.Websocket.Channels exposing (Channel(..))
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


initialSocket : String -> Socket.Socket Msg
initialSocket apiWsUrl =
    Socket.init apiWsUrl


initialChannels : List (Channel.Channel Msg)
initialChannels =
    [ Channel.init "requests" ]


initialEvents : EventsByChannel
initialEvents =
    { account = Events.map AccountEvent AccountEvents.events
    }


initialModel : String -> Model
initialModel apiWsUrl =
    { socket = initialSocket apiWsUrl
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
