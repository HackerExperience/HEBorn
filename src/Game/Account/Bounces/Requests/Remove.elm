module Game.Account.Bounces.Requests.Remove exposing (removeRequest)

import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Game.Account.Models exposing (..)
import Game.Account.Bounces.Shared as Bounces


type alias Data =
    Result String ()


removeRequest : Bounces.ID -> ID -> FlagsSource a -> Cmd Data
removeRequest bounceId id flagsSrc =
    flagsSrc
        |> Requests.request_ (Topics.bounceRemove id) (encoder bounceId)
        |> Cmd.map (uncurry receiver)



-- internals


encoder : Bounces.ID -> Value
encoder bounceId =
    Encode.object
        [ ( "bounce_id", Encode.string bounceId ) ]


decodeError : Decoder String
decodeError =
    Decode.string
        |> Decode.field "message"


receiver : Code -> Value -> Result String ()
receiver code value =
    let
        error =
            case decodeValue decodeError value of
                Ok error ->
                    error

                Err msg ->
                    msg
    in
        case code of
            OkCode ->
                Ok ()

            _ ->
                Err error
