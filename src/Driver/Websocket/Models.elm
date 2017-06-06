module Driver.Websocket.Models
    exposing
        ( Model
        , initialModel
        )

import Driver.Websocket.Messages exposing (Msg(..))
import Phoenix.Socket as Socket
import Phoenix.Channel as Channel


type alias Model =
    { socket : Socket.Socket Msg
    , channels : List (Channel.Channel Msg)
    , defer : Bool
    }


type Channel
    = ChannelAccount
    | ChannelRequests


initialSocket : String -> Socket.Socket Msg
initialSocket apiWsUrl =
    Socket.init apiWsUrl


initialChannels : List (Channel.Channel Msg)
initialChannels =
    [ Channel.init "requests" ]


initialModel : String -> Model
initialModel apiWsUrl =
    { socket = initialSocket apiWsUrl
    , channels = initialChannels
    , defer = True
    }
