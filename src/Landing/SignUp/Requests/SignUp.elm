module Landing.SignUp.Requests.SignUp
    exposing
        ( Response(..)
        , request
        , receive
        )

import Json.Decode as Decode exposing (Decoder, Value, decodeValue)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Json.Encode as Encode
import Landing.SignUp.Messages exposing (..)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..))


type Response
    = Okay String String String
    | Error


request : String -> String -> String -> ConfigSource a -> Cmd Msg
request email username password =
    Requests.request Topics.register
        (SignUpRequest >> Request)
        (encoder email username password)


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            Requests.report (decodeValue decoder json)

        _ ->
            Just Error



-- internals


encoder : String -> String -> String -> Value
encoder email username password =
    Encode.object
        [ ( "email", Encode.string email )
        , ( "username", Encode.string username )
        , ( "password", Encode.string password )
        ]


decoder : Decoder Response
decoder =
    decode Okay
        |> required "username" Decode.string
        |> required "email" Decode.string
        |> required "account_id" Decode.string
