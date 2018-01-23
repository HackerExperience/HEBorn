module Game.Requests.Resync
    exposing
        ( Response(..)
        , request
        , receive
        )

import Decoders.Game exposing (ServersToJoin)
import Json.Decode exposing (Value, decodeValue)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..), emptyPayload)
import Game.Messages exposing (..)
import Game.Models exposing (..)
import Game.Account.Models as Account


type Response
    = Okay ( Model, ServersToJoin )


request : Account.ID -> FlagsSource a -> Cmd Msg
request id =
    Requests.request (Topics.accountResync id)
        (ResyncRequest >> Request)
        emptyPayload


receive : Model -> Code -> Value -> Maybe Response
receive model code json =
    case code of
        OkCode ->
            json
                |> decodeValue (Decoders.Game.bootstrap model)
                |> Result.map Okay
                |> Requests.report

        _ ->
            Nothing
