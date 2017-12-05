module Game.Servers.Hardware.Requests.UpdateMotherboard
    exposing
        ( Response(..)
        , request
        , receive
        )

import Json.Decode as Decode
    exposing
        ( Decoder
        , Value
        , decodeValue
        )
import Json.Encode as Encode
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..))
import Game.Servers.Shared exposing (CId)
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Servers.Hardware.Messages exposing (..)
import Decoders.Hardware


type Response
    = Okay Motherboard
    | Error


request : Motherboard -> CId -> ConfigSource a -> Cmd Msg
request motherboard cid =
    Requests.request (Topics.updateMotherboard cid)
        (UpdateMotherboardRequest >> Request)
    <|
        Motherboard.encode motherboard


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            json
                |> decodeValue Decoders.Hardware.motherboard
                |> Requests.report
                |> Maybe.map Okay

        _ ->
            Just Error
