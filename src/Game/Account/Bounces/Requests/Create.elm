module Game.Account.Bounces.Requests.Create exposing (createRequest)

import Utils.Json.Decode exposing (commonError, message)
import Json.Decode as Decode exposing (Decoder, decodeValue, succeed, fail)
import Json.Encode as Encode exposing (Value)
import Requests.Types exposing (FlagsSource, Code(..))
import Requests.Topics as Topics
import Requests.Requests as Requests exposing (report_)
import Game.Account.Models exposing (..)
import Game.Account.Bounces.Models as Bounces
import Game.Account.Bounces.Shared as Bounces exposing (CreateError(..))
import Game.Account.Database.Models as Database
import Game.Meta.Types.Network as Network


type alias Data =
    Result CreateError ()


createRequest :
    Database.HackedServers
    -> Bounces.Bounce
    -> ID
    -> String
    -> FlagsSource a
    -> Cmd Data
createRequest hackedServers bounce id requestId flagsSrc =
    flagsSrc
        |> Requests.request_ (Topics.bounceCreate id) (encoder hackedServers bounce requestId)
        |> Cmd.map (uncurry <| receiver flagsSrc)



-- internals


encoder : Database.HackedServers -> Bounces.Bounce -> String -> Value
encoder hackedServers bounce requestId =
    let
        valueList =
            List.map (encodeNIP hackedServers) bounce.path
    in
        Encode.object
            [ ( "name", Encode.string bounce.name )
            , ( "links", Encode.list valueList )
            , ( "request_id", Encode.string requestId )
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


errorToString : CreateError -> String
errorToString error =
    case error of
        CreateBadRequest ->
            "Bad Request"

        CreateFailed ->
            "Bounce creating failed"

        CreateUnknown ->
            "Unknown"


errorMessage : Decoder CreateError
errorMessage =
    message <|
        \str ->
            case str of
                "bad_request" ->
                    succeed CreateBadRequest

                value ->
                    fail <| commonError "bounce create error message" value


receiver : FlagsSource a -> Code -> Value -> Data
receiver flagsSrc code value =
    case code of
        OkCode ->
            Ok ()

        _ ->
            value
                |> decodeValue errorMessage
                |> report_ "Bounces.Create" code flagsSrc
                |> Result.mapError (always CreateUnknown)
                |> Result.andThen Err
