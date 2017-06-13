module Landing.Login.Requests.Login
    exposing
        ( Response(..)
        , request
        , receive
        )

import Json.Decode as Decode exposing (Decoder, Value, decodeValue)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Json.Encode as Encode
import Core.Config exposing (Config)
import Landing.Login.Messages exposing (..)
import Requests.Requests as Requests
import Requests.Topics exposing (Topic(..))
import Requests.Types exposing (Code(..))


type Response
    = OkResponse String String
    | ErrorResponse
    | NoOp


request : String -> String -> Config -> Cmd Msg
request username password =
    Requests.request AccountLoginTopic
        (LoginRequest >> Request)
        Nothing
        (encoder username password)


receive : Code -> Value -> Response
receive code json =
    case code of
        OkCode ->
            json
                |> decodeValue decoder
                |> Requests.report

        NotFoundCode ->
            ErrorResponse

        _ ->
            NoOp



-- internals


encoder : String -> String -> Value
encoder username password =
    Encode.object
        [ ( "username", Encode.string username )
        , ( "password", Encode.string password )
        ]


decoder : Decoder Response
decoder =
    decode OkResponse
        |> required "token" Decode.string
        |> required "account_id" Decode.string
