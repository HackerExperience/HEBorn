module Game.Account.Requests.Logout exposing (request)

import Json.Encode as Encode exposing (Value)
import Game.Account.Messages exposing (..)
import Game.Account.Models exposing (..)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))


request : String -> ID -> FlagsSource a -> Cmd Msg
request token id =
    let
        payload =
            Encode.object
                [ ( "token", Encode.string token ) ]
    in
        Requests.request (Topics.logout id)
            (LogoutRequest >> Request)
            payload
