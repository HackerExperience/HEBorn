module Landing.Login.Requests
    exposing
        ( Response(..)
        , login
        , handler
        )

import Core.Config exposing (Config)
import Landing.Login.Messages exposing (..)
import Requests.Requests exposing (request, report)
import Requests.Types exposing (Code(..))
import Requests.Topics exposing (Topic(..))
import Json.Encode as Encode
import Json.Decode exposing (Value, string, decodeString, dict, decodeValue)
import Json.Decode.Pipeline exposing (decode, required, optional)


type Response
    = LoginResponse String String
    | NoOp


login : String -> String -> Config -> Cmd Msg
login username password =
    let
        payload =
            Encode.object
                [ ( "username", Encode.string username )
                , ( "password", Encode.string password )
                ]
    in
        request AccountLoginTopic
            (LoginRequestMsg >> Request)
            Nothing
            payload


handler : RequestMsg -> Response
handler request =
    case request of
        LoginRequestMsg ( code, json ) ->
            loginHandler code json



-- internals


loginHandler : Code -> String -> Response
loginHandler code json =
    let
        decoder =
            decode LoginResponse
                |> required "token" string
                |> required "account_id" string
    in
        case code of
            OkCode ->
                report (decodeString decoder json)

            _ ->
                NoOp
