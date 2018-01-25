module Game.Account.Bounces.Requests.Create exposing (createRequest)

import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Game.Account.Models exposing (..)
import Game.Account.Bounces.Models as Bounces
import Game.Account.Database.Models as Database
import Game.Meta.Types.Network as Network


type alias Data =
    Result String ()


createRequest :
    Database.HackedServers
    -> Bounces.Bounce
    -> ID
    -> FlagsSource a
    -> Cmd Data
createRequest hackedServers bounce id flagsSrc =
    flagsSrc
        |> Requests.request_ (Topics.bounceCreate id) (encoder hackedServers bounce)
        |> Cmd.map (uncurry receiver)



-- internals


encoder : Database.HackedServers -> Bounces.Bounce -> Value
encoder hackedServers bounce =
    let
        valueList =
            List.map (encodeNIP hackedServers) bounce.path
    in
        Encode.object
            [ ( "name", Encode.string bounce.name )
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
