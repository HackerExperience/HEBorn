module Setup.Requests.Setup exposing (Response(..), request, receive)

import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..))
import Game.Messages exposing (..)
import Game.Models exposing (..)
import Game.Account.Models as Account
import Decoders.Game exposing (ServersToJoin)


type Response
    = Okay


request : Account.ID -> ConfigSource a -> Cmd Msg
request id =
    Requests.request (Topics.accountResync id)
        (ResyncRequest >> Request)
        emptyPayload


receive : Model -> Code -> Value -> Maybe Response
receive model code json =
    case code of
        OkCode ->
            Just Okay

        _ ->
            let
                _ =
                    Debug.log "▶ Setup Error Code:" code
            in
                Nothing
