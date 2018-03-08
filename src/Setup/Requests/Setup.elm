module Setup.Requests.Setup exposing (Data, setupRequest)

import Requests.Requests as Requests
import Requests.Topics as Topics
import Json.Encode as Encode exposing (Value)
import Requests.Types exposing (FlagsSource, Code(..))
import Setup.Models exposing (..)
import Game.Account.Models as Account


type alias Data =
    Result () ()


setupRequest : List PageModel -> Account.ID -> FlagsSource a -> Cmd Data
setupRequest pages id flagsSrc =
    let
        payload =
            Encode.object
                [ ( "pages", Encode.list <| encodeDone pages ) ]
    in
        flagsSrc
            |> Requests.request (Topics.clientSetup id) payload
            |> Cmd.map (uncurry receiver)



-- internals


receiver : Code -> Value -> Data
receiver code json =
    case code of
        OkCode ->
            Ok ()

        _ ->
            -- TODO: add better error handling
            always (Err ()) <|
                Debug.log "▶ Setup Error Code:" code
