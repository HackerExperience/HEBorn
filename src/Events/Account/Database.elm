module Events.Account.Database
    exposing
        ( Event(..)
        , PasswordAcquiredData
        , handler
        )

import Dict
import Json.Decode
    exposing
        ( Decoder
        , succeed
        , fail
        , decodeValue
        , andThen
        , maybe
        , list
        , string
        , float
        )
import Json.Decode.Pipeline exposing (decode, required, optional)
import Utils.Events exposing (Handler, notify, commonError)
import Game.Network.Types exposing (NIP)
import Game.Account.Database.Models exposing (..)


-- TODO: move changed to sync


type Event
    = Changed Model
    | PasswordAcquired PasswordAcquiredData


type alias PasswordAcquiredData =
    { nip : NIP
    , password : String
    , processId : String
    , gatewayId : String
    }


handler : String -> Handler Event
handler event json =
    case event of
        "changed" ->
            onChanged json

        "server_password_acquired" ->
            onServerPasswordAcquired json

        _ ->
            Nothing



-- internals


onChanged : Handler Event
onChanged =
    let
        activeVirus =
            decode (,)
                |> required "id" string
                |> required "since" float

        virus =
            decode (\a b c -> ( a, b, c ))
                |> required "id" string
                |> required "filename" string
                |> required "version" float

        serverType =
            let
                guesser str =
                    case str of
                        "corp" ->
                            succeed Corporation

                        "npc" ->
                            succeed NPC

                        "player" ->
                            succeed Player

                        error ->
                            fail <| commonError "server_type" error
            in
                andThen guesser string

        serverDecoder =
            decode
                (\nId ipAddr p l n v a t r ->
                    ( ( nId, ipAddr )
                    , HackedServer p l n v a t r
                    )
                )
                |> required "netid" string
                |> required "ip" string
                |> required "password" string
                |> optional "label" (maybe string) Nothing
                |> optional "notes" (maybe string) Nothing
                |> required "viruses" (list virus)
                |> optional "active" (maybe activeVirus) Nothing
                |> required "type" serverType
                |> optional "remote" (maybe string) Nothing

        servers =
            list serverDecoder
                |> andThen (Dict.fromList >> succeed)

        decoder =
            decode Model
                |> required "servers" servers
                |> required "accounts" (list string)
                |> required "wallets" (list string)

        handler json =
            decodeValue decoder json
                |> Result.map Changed
                |> notify
    in
        handler


onServerPasswordAcquired : Handler Event
onServerPasswordAcquired =
    let
        constructor sIp nId pass procId gId =
            { nip = ( nId, sIp )
            , password = pass
            , processId = procId
            , gatewayId = gId
            }

        decoder =
            decode constructor
                |> required "server_ip" string
                |> required "network_id" string
                |> required "password" string
                |> required "process_id" string
                |> required "gateway_id" string

        handler json =
            decodeValue decoder json
                |> Result.map PasswordAcquired
                |> notify
    in
        handler
