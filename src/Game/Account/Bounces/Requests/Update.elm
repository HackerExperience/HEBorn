module Game.Account.Bounces.Requests.Update exposing (updateRequest)

import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Game.Account.Models exposing (..)
import Game.Account.Bounces.Models as Bounces
import Game.Account.Bounces.Shared as Bounces
import Game.Account.Database.Models as Database
import Game.Meta.Types.Network as Network


type alias Data =
    Result String ()


updateRequest :
    Database.HackedServers
    -> Bounces.ID
    -> Bounces.Bounce
    -> ID
    -> FlagsSource a
    -> Cmd Data
updateRequest hackedServers bounceId bounce id flagsSrc =
    flagsSrc
        |> Requests.request_ (Topics.bounceUpdate id) (encoder hackedServers bounceId bounce)
        |> Cmd.map (uncurry receiver)



-- internals


encoder : Database.HackedServers -> Bounces.ID -> Bounces.Bounce -> Value
encoder hackedServers bounceId bounce =
    let
        valueList =
            List.map (encodeNIP hackedServers) bounce.path
    in
        Encode.object
            [ ( "bounce_id", Encode.string bounceId )
            , ( "name", Encode.string bounce.name )
            , ( "links", Encode.list valueList )
            ]


encodeNIP : Database.HackedServers -> Network.NIP -> Value
encodeNIP hackedServers nip =
    let
        password =
            nip
                |> flip (Database.getHackedServer) hackedServers
                |> Database.getPassword

        encode ( id, ip ) =
            Encode.object
                [ ( "ip", Encode.string ip )
                , ( "network_id", Encode.string id )
                , ( "password", Encode.string password )
                ]
    in
        encode nip


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
