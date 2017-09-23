module Game.Requests.Bootstrap
    exposing
        ( Response(..)
        , Data
        , ServerIndex
        , request
        , receive
        , decoder
        )

import Json.Decode exposing (Decoder, Value, decodeValue, list, bool)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..), emptyPayload)
import Events.Storyline.Missions as Missions
import Events.Storyline.Emails as Emails
import Game.Messages exposing (..)
import Game.Servers.Requests.Bootstrap
    exposing
        ( GatewayData
        , EndpointData
        , gatewayDecoder
        , endpointDecoder
        )
import Game.Storyline.Models as Story
import Game.Storyline.Requests.Bootstrap
    exposing
        ( emailsDecoder
        , missionsDecoder
        )


type Response
    = Okay Data


type alias Data =
    { servers :
        ServerIndex
    , story :
        Story.Model
    }


type alias ServerIndex =
    { gateways :
        List GatewayData
    , endpoints :
        List EndpointData
    }


request : String -> ConfigSource a -> Cmd Msg
request account =
    Requests.request Topics.accountBootstrap
        (BootstrapRequest >> Request)
        (Just account)
        emptyPayload


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            json
                |> decodeValue decoder
                |> Result.map Okay
                |> Requests.report

        _ ->
            Nothing


decoder : Decoder Data
decoder =
    decode Data
        |> required "servers" serverIndexDecoder
        |> optional "story" storyDecoder Story.initialModel



-- internals


serverIndexDecoder : Decoder ServerIndex
serverIndexDecoder =
    decode ServerIndex
        |> required "player" (list gatewayDecoder)
        |> required "remote" (list endpointDecoder)


storyDecoder : Decoder Story.Model
storyDecoder =
    decode Story.Model
        |> optional "enabled" bool False
        |> required "missions" missionsDecoder
        |> required "emails" emailsDecoder
