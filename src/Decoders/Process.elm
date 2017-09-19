module Decoders.Process exposing (..)

import Dict exposing (Dict)
import Game.Servers.Processes.Models exposing (..)
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline exposing (decode, required, optional, custom)


processDict : Decoder (Dict ID Process)
processDict =
    map Dict.fromList processList


processList : Decoder (List ( ID, Process ))
processList =
    list process


process : Decoder ( ID, Process )
process =
    let
        toProcess ( type_, access, state_, file, status, progress, tid, id ) =
            let
                constructor state =
                    ( id, Process type_ access state file progress tid )
            in
                map constructor <| state state_ status
    in
        decode (,,,,,,,)
            |> required "type" type_
            |> required "access" access
            |> required "state" string
            |> optional "file" (maybe file) Nothing
            |> optional "status" (maybe string) Nothing
            |> optional "progress" (maybe progress) Nothing
            |> required "target_id" string
            |> required "process_id" string
            |> andThen toProcess


type_ : Decoder Type
type_ =
    let
        decoder str =
            typeFromName str
                |> Maybe.map succeed
                |> Maybe.withDefault (fail ("Unknown process type" ++ str))
    in
        string |> andThen decoder


access : Decoder Access
access =
    let
        full =
            decode FullAccess
                |> required "origin" string
                |> required "priority" priority
                |> required "usage" resourcesUsage
                |> optional "connection_id" (maybe string) Nothing

        toOriginConnection data =
            case data of
                ( Just origin, Just connectionId ) ->
                    ( origin, connectionId )
                        |> Just
                        |> PartialAccess
                        |> succeed

                _ ->
                    succeed <| PartialAccess Nothing

        partial =
            decode (,)
                |> optional "origin_id" (maybe string) Nothing
                |> optional "connection_id" (maybe string) Nothing
                |> andThen toOriginConnection
    in
        oneOf
            [ map Full full
            , map Partial partial
            ]


state : String -> Maybe String -> Decoder State
state state status =
    case ( state, status ) of
        ( "running", _ ) ->
            succeed Running

        ( "paused", _ ) ->
            succeed Paused

        ( "succeeded", _ ) ->
            succeed <| Succeeded

        ( "failed", status ) ->
            succeed <| Failed status

        ( state, status ) ->
            fail ("Invalid process state `" ++ state ++ "'")


priority : Decoder Priority
priority =
    let
        decode num =
            case num of
                1 ->
                    succeed Lowest

                2 ->
                    succeed Low

                3 ->
                    succeed Normal

                4 ->
                    succeed High

                5 ->
                    succeed Highest

                n ->
                    fail ("Unknown priority " ++ toString n)
    in
        andThen decode int


resourcesUsage : Decoder ResourcesUsage
resourcesUsage =
    decode ResourcesUsage
        |> required "cpu" usage
        |> required "mem" usage
        |> required "down" usage
        |> required "up" usage


usage : Decoder Usage
usage =
    decode (,)
        |> custom (index 0 float)
        |> custom (index 1 string)


progress : Decoder Progress
progress =
    map2 (,) float (maybe float)


file : Decoder ProcessFile
file =
    decode ProcessFile
        |> optional "id" (maybe string) Nothing
        |> optional "version" (maybe float) Nothing
        |> required "name" string
