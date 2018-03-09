module Landing.Requests.SignUp exposing (Data, signUpRequest)

import Json.Decode as Decode exposing (Decoder, Value, decodeValue)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Requests.Requests as Requests exposing (report)
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))


type alias Data =
    Result () ( String, String, String )


signUpRequest : String -> String -> String -> FlagsSource a -> Cmd Data
signUpRequest email username password flagsSrc =
    flagsSrc
        |> Requests.request Topics.register (encoder email username password)
        |> Cmd.map (uncurry <| receiver flagsSrc)



-- internals


encoder : String -> String -> String -> Value
encoder email username password =
    Encode.object
        [ ( "email", Encode.string email )
        , ( "username", Encode.string username )
        , ( "password", Encode.string password )
        ]


receiver : FlagsSource a -> Code -> Value -> Data
receiver flagsSrc code value =
    case code of
        OkCode ->
            value
                |> decodeValue decoder
                |> report "Landing.SignUp" code flagsSrc
                |> Result.mapError (always ())

        _ ->
            Err ()


decoder : Decoder ( String, String, String )
decoder =
    decode (,,)
        |> required "username" Decode.string
        |> required "email" Decode.string
        |> required "account_id" Decode.string
