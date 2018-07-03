module Game.Servers.Requests.Resync exposing (Data, resyncRequest)

{-| Contém request de `Resync`, é utilizado para normalizar os dados da model
consistentes caso alguma inconsistẽncia aconteça.
-}

import Time exposing (Time)
import Json.Decode as Decode exposing (Value, decodeValue)
import Requests.Requests as Requests exposing (report)
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..), emptyPayload)
import Decoders.Servers
import Game.Servers.Models exposing (..)
import Game.Servers.Shared exposing (..)


{-| Resultado do request, pode ser um erro ou um `CId` junto do `Server`.

A pesar do erro não ser tratado, é melhor utilizar result desde já pois é
certo que um dia o erro será tratado.

-}
type alias Data =
    Result () ( CId, Server )


{-| Cria um `Cmd` de request para sincronizar dados do servidor.
-}
resyncRequest : CId -> Time -> Maybe GatewayCache -> FlagsSource a -> Cmd Data
resyncRequest id time gatewayCache flagsSrc =
    flagsSrc
        |> Requests.request (Topics.serverResync id)
            emptyPayload
        |> Cmd.map (uncurry <| receiver flagsSrc id time gatewayCache)



-- funções internas


{-| Decodifica resposta do request.
-}
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
