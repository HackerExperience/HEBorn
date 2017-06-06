module Landing.SignUp.Requests
    exposing
        ( Response(..)
        , create
        , handler
        )

import Landing.SignUp.Messages exposing (..)
import Core.Config exposing (Config)
import Requests.Requests exposing (request, report)
import Requests.Types exposing (Code(..))
import Requests.Topics exposing (Topic(..))
import Json.Encode as Encode
import Json.Decode exposing (Value, string, decodeString, dict, decodeValue)
import Json.Decode.Pipeline exposing (decode, required, optional)


type Response
    = CreateResponse String String String
    | NoOp


create : String -> String -> String -> Config -> Cmd Msg
create email username password =
    let
        payload =
            Encode.object
                [ ( "email", Encode.string email )
                , ( "username", Encode.string username )
                , ( "password", Encode.string password )
                ]
    in
        request AccountCreateTopic
            (CreateRequestMsg >> Request)
            Nothing
            payload


handler : RequestMsg -> Response
handler request =
    case request of
        CreateRequestMsg ( code, json ) ->
            createHandler code json


createHandler : Code -> String -> Response
createHandler code json =
    let
        decoder =
            decode CreateResponse
                |> required "username" string
                |> required "email" string
                |> required "account_id" string
    in
        case code of
            OkCode ->
                report (decodeString decoder json)

            _ ->
                NoOp
