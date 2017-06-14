module Landing.SignUp.Requests.SignUp
    exposing
        ( Response(..)
        , request
        , receive
        )

import Json.Decode as Decode exposing (Value, decodeString)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Json.Encode as Encode
import Core.Config exposing (Config)
import Landing.SignUp.Messages exposing (..)
import Requests.Requests as Requests
import Requests.Topics exposing (Topic(..))
import Requests.Types exposing (Code(..))


type Response
    = OkResponse String String String
    | ErrorResponse


request : String -> String -> String -> Config -> Cmd Msg
request email username password =
    Requests.request AccountCreateTopic
        (SignUpRequest >> Request)
        Nothing
        (encoder email username password)


receive : Code -> String -> Response
receive code json =
    case code of
        OkCode ->
            Requests.report (decodeString decoder json)

        _ ->
            ErrorResponse



-- internals


encoder email username password =
    Encode.object
        [ ( "email", Encode.string email )
        , ( "username", Encode.string username )
        , ( "password", Encode.string password )
        ]


decoder =
    decode OkResponse
        |> required "username" Decode.string
        |> required "email" Decode.string
        |> required "account_id" Decode.string
