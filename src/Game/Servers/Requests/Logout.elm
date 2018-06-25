module Game.Servers.Requests.Logout exposing (Data, logoutRequest)

import Json.Decode as Decode exposing (Value)
import Requests.Requests as Requests exposing (report)
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..), emptyPayload)
import Game.Servers.Shared exposing (CId)


{-| Resultado do request, pode ser um erro ou um CId. A pesar do erro não
ser tratado, é melhor utilizar result desde já pois é certo que um dia o erro
será tratado.
-}
type alias Data =
    Result () CId


{-| Cria um Cmd de request para deslogar do servidor.
-}
logoutRequest : CId -> FlagsSource a -> Cmd Data
logoutRequest id flagsSrc =
    flagsSrc
        |> Requests.request (Topics.serverLogout id)
            emptyPayload
        |> Cmd.map (uncurry <| receiver flagsSrc id)



-- internals


{-| Decodifica resposta do request.
-}
receiver :
    FlagsSource a
    -> CId
    -> Code
    -> Value
    -> Data
receiver flagsSrc cid code _ =
    case code of
        OkCode ->
            Result.Ok cid
                |> report "Servers.Logout" code flagsSrc
                |> Result.mapError (always ())

        _ ->
            Err ()
