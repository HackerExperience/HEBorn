module Game.Servers.Processes.Requests.Bruteforce
    exposing
        ( Data
        , bruteforceRequest
        )

import Json.Decode exposing (Value, decodeValue)
import Json.Encode as Encode
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Game.Meta.Types.Network as Network
import Game.Servers.Shared exposing (CId)


-- not a bool because we'll threat errors


type alias Data =
    Result () ()


bruteforceRequest :
    Network.ID
    -> Network.IP
    -> CId
    -> FlagsSource a
    -> Cmd Data
bruteforceRequest network targetIp cid flagsSrc =
    flagsSrc
        |> Requests.request (Topics.bruteforce cid)
            (encoder network targetIp)
        |> Cmd.map (uncurry receiver)



-- internals


encoder : Network.ID -> Network.IP -> Value
encoder network targetIp =
    Encode.object
        [ ( "network_id", Encode.string <| network )
        , ( "ip", Encode.string <| targetIp )
        , ( "bounces", Encode.list [] )
        ]


receiver : Code -> Value -> Data
receiver code json =
    case code of
        OkCode ->
            Ok ()

        _ ->
            Err ()
