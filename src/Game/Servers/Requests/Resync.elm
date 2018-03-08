module Game.Servers.Requests.Resync exposing (Data, resyncRequest)

import Time exposing (Time)
import Json.Decode as Decode exposing (Value, decodeValue)
import Requests.Requests as Requests exposing (report)
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..), emptyPayload)
import Decoders.Servers
import Game.Servers.Models exposing (..)
import Game.Servers.Shared exposing (..)


type alias Data =
    Result () ( CId, Server )


resyncRequest : CId -> Time -> Maybe GatewayCache -> FlagsSource a -> Cmd Data
resyncRequest id time gatewayCache flagsSrc =
    flagsSrc
        |> Requests.request (Topics.serverResync id)
            emptyPayload
        |> Cmd.map (uncurry <| receiver flagsSrc id time gatewayCache)



-- internals


receiver :
    FlagsSource a
    -> CId
    -> Time
    -> Maybe GatewayCache
    -> Code
    -> Value
    -> Data
receiver flagsSrc cid now gatewayCache code value =
    case code of
        OkCode ->
            value
                |> decodeValue (Decoders.Servers.server now gatewayCache)
                |> report "Servers.Resync" code flagsSrc
                |> Result.map ((,) cid)
                |> Result.mapError (always ())

        _ ->
            Err ()
