module Game.Account.Requests.Logout exposing (request)

import Json.Encode as Encode exposing (Value)
import Game.Account.Messages exposing (..)
import Requests.Requests as Requests
import Requests.Topics exposing (Topic(..))
import Requests.Types exposing (ConfigSource, Code(..))


request : String -> ConfigSource a -> Cmd Msg
request token =
    let
        payload =
            Encode.object
                [ ( "token", Encode.string token ) ]
    in
        Requests.request AccountLogoutTopic
            (LogoutRequest >> Request)
            Nothing
            payload
