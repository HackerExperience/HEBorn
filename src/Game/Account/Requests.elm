module Game.Account.Requests
    exposing
        ( Response(..)
        , logout
        , handler
        )

import Core.Config exposing (Config)
import Game.Account.Messages exposing (..)
import Requests.Requests exposing (request, report)
import Requests.Types exposing (Code(..))
import Requests.Topics exposing (Topic(..))
import Json.Encode as Encode exposing (Value)


type Response
    = LogoutResponse


logout : String -> Config -> Cmd AccountMsg
logout token =
    let
        payload =
            Encode.object
                [ ( "token", Encode.string token ) ]
    in
        request AccountLogoutTopic
            (LogoutRequestMsg >> Request)
            Nothing
            payload


handler : RequestMsg -> Response
handler request =
    case request of
        LogoutRequestMsg ( code, json ) ->
            logoutHandler code json



-- internals


logoutHandler : Code -> Value -> Response
logoutHandler code json =
    LogoutResponse
