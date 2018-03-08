module Game.Requests.Resync
    exposing
        ( Data
        , resyncRequest
        , resyncReceive
        )

import Decoders.Game exposing (ServersToJoin)
import Json.Decode exposing (Value, decodeValue)
import Requests.Requests as Requests exposing (report)
import Requests.Topics as Topics
import Requests.Types
    exposing
        ( FlagsSource
        , ResponseType
        , Code(..)
        , emptyPayload
        )
import Game.Messages exposing (..)
import Game.Models exposing (..)
import Game.Account.Models as Account


type alias Data =
    Result () ( Model, ServersToJoin )


resyncRequest : Account.ID -> FlagsSource a -> Cmd ResponseType
resyncRequest id =
    Requests.request (Topics.accountResync id) emptyPayload


resyncReceive : Model -> ResponseType -> Data
resyncReceive model ( code, json ) =
    case code of
        OkCode ->
            json
                |> decodeValue (Decoders.Game.bootstrap model)
                |> report "Game.Resync" code model
                |> Result.mapError (always ())

        _ ->
            Err ()
