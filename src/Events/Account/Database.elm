module Events.Account.Database exposing (Event(..), handler, decoder)

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
import Utils.Events exposing (Handler, commonError)
import Game.Account.Database.Models exposing (..)


type Event
    = Changed


handler : String -> Handler Event
handler event json =
    case event of
        "changed" ->
            onChanged json

        _ ->
            Nothing



-- internals


onChanged : Handler Event
onChanged json =
    Just Changed


decoder : Decoder Database
decoder =
    decode Database
        |> required "servers" (list server)
        |> required "accounts" (list string)
        |> required "wallets" (list string)


server : Decoder HackedServer
server =
    decode (\nId ipAddr -> HackedServer ( nId, ipAddr ))
        |> required "netid" string
        |> required "ip" string
        |> required "password" string
        |> optional "label" (maybe string) Nothing
        |> optional "notes" (maybe string) Nothing
        |> required "viruses" (list virus)
        |> optional "active" (maybe activeVirus) Nothing
        |> required "type" serverType
        |> optional "remote" (maybe string) Nothing


serverType : Decoder ServerType
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
        string
            |> andThen guesser


virus : Decoder InstalledVirus
virus =
    decode (\a b c -> ( a, b, c ))
        |> required "id" string
        |> required "filename" string
        |> required "version" float


activeVirus : Decoder RunningVirus
activeVirus =
    decode (,)
        |> required "id" string
        |> required "since" float
