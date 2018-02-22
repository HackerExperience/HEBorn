module Game.Account.Bounces.Requests.Update exposing (updateRequest)

import Utils.Json.Decode exposing (commonError, message)
import Json.Decode as Decode exposing (Decoder, decodeValue, succeed, fail)
import Json.Encode as Encode exposing (Value)
import Requests.Requests as Requests exposing (report_)
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Game.Account.Models exposing (..)
import Game.Account.Bounces.Models as Bounces
import Game.Account.Bounces.Shared as Bounces exposing (UpdateError(..))
import Game.Account.Database.Models as Database
import Game.Meta.Types.Network as Network


type alias Data =
    Result UpdateError ()


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
        |> Cmd.map (uncurry <| receiver flagsSrc)



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
                |> Maybe.andThen (Database.getPassword >> Just)
                |> Maybe.withDefault ""

        encode ( id, ip ) =
            Encode.object
                [ ( "ip", Encode.string ip )
                , ( "network_id", Encode.string id )
                , ( "password", Encode.string password )
                ]
    in
        encode nip


errorToString : UpdateError -> String
errorToString error =
    case error of
        UpdateBadRequest ->
            "Bad Request"

        UpdateUnknown ->
            "Unknown"


errorMessage : Decoder UpdateError
errorMessage =
    message <|
        \str ->
            case str of
                "bad_request" ->
                    succeed UpdateBadRequest

                value ->
                    fail <| commonError "bounce update error message" value


receiver : FlagsSource a -> Code -> Value -> Data
receiver flagsSrc code value =
    case code of
        OkCode ->
            Ok ()

        _ ->
            value
                |> decodeValue errorMessage
                |> report_ "Bounces.Update" code flagsSrc
                |> Result.mapError (always UpdateUnknown)
                |> Result.andThen Err
