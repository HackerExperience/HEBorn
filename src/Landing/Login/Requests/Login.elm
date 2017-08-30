module Landing.Login.Requests.Login
    exposing
        ( Response(..)
        , request
        , receive
        )

import Json.Decode as Decode exposing (Decoder, Value, decodeValue)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Json.Encode as Encode
import Landing.Login.Messages exposing (..)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..))


type Response
    = Okay String String
    | Error


request : String -> String -> ConfigSource a -> Cmd Msg
request username password =
    Requests.request Topics.login
        (LoginRequest >> Request)
        Nothing
        (encoder username password)


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            json
                |> decodeValue decoder
                |> Requests.report

        NotFoundCode ->
            Just Error

        _ ->
            Nothing



-- internals


encoder : String -> String -> Value
encoder username password =
    Encode.object
        [ ( "username", Encode.string username )
        , ( "password", Encode.string password )
        ]


decoder : Decoder Response
decoder =
    decode Okay
        |> required "token" Decode.string
        |> required "account_id" Decode.string
