module Game.Servers.Requests.Logout exposing (Data, logoutRequest)

import Json.Decode as Decode exposing (Value)
import Requests.Requests as Requests exposing (report_)
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..), emptyPayload)
import Game.Servers.Shared exposing (CId)


type alias Data =
    Result () CId


logoutRequest : CId -> FlagsSource a -> Cmd Data
logoutRequest id flagsSrc =
    flagsSrc
        |> Requests.request_ (Topics.serverLogout id)
            emptyPayload
        |> Cmd.map (uncurry <| receiver flagsSrc id)



-- internals


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
                |> report_ "Servers.Logout" code flagsSrc
                |> Result.mapError (always ())

        _ ->
            Err ()
