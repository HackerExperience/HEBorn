module Setup.Requests.Setup exposing (Response(..), request, receive)

import Requests.Requests as Requests
import Requests.Topics as Topics
import Json.Encode as Encode exposing (Value)
import Requests.Types exposing (ConfigSource, Code(..))
import Setup.Messages exposing (..)
import Setup.Models exposing (..)
import Game.Account.Models as Account
import Decoders.Game exposing (ServersToJoin)


type Response
    = Okay


request : Value -> Account.ID -> ConfigSource a -> Cmd Msg
request name id =
    let
        payload =
            Encode.object [ ( "page", name ) ]
    in
        Requests.request (Topics.accountSetup id)
            (SetupRequest >> Request)
            payload


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            Just Okay

        _ ->
            let
                _ =
                    Debug.log "▶ Setup Error Code:" code
            in
                Nothing
