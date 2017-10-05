module Decoders.Storyline exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode
    exposing
        ( Decoder
        , andThen
        , map
        , succeed
        , fail
        , bool
        , float
        , string
        , list
        , dict
        )
import Json.Decode.Pipeline exposing (decode, required, optional, resolve)
import Utils.Json.Decode exposing (optionalMaybe)
import Events.Storyline.Emails as Emails
import Events.Storyline.Missions as Missions
import Game.Storyline.Emails.Models as Emails
import Game.Storyline.Missions.Models as Missions exposing (Missions(..), Goals(..))
import Game.Storyline.Missions.Actions as Missions
import Game.Storyline.Models as Story


story : Decoder Story.Model
story =
    decode Story.Model
        |> optional "enabled" bool False
        |> required "missions" missions
        |> required "email" emails



-- mission decoders


missions : Decoder Missions.Model
missions =
    decode recognizeMission
        |> optionalMaybe "mission" string
        |> optionalMaybe "goals" string
        |> optionalMaybe "current" string
        |> optionalMaybe "next" string
        |> resolve


recognizeMission :
    Maybe String
    -> Maybe String
    -> Maybe String
    -> Maybe String
    -> Decoder Missions.Model
recognizeMission mission goals current next =
    case ( mission, goals, current, next ) of
        ( Just "tutorial", Just "intro", Just current, Just next ) ->
            next
                |> Missions.Step current (Missions.fromStep current)
                |> Just
                |> Missions.Model
                    Tutorial
                    TutorialIntroduction
                |> succeed

        ( Nothing, Nothing, Nothing, Nothing ) ->
            succeed <| Missions.Model NoMission NoGoal Nothing

        _ ->
            fail "Unrecgonized mission state"



-- email decoders


emails : Decoder Emails.Model
emails =
    let
        initAbout id person =
            case person.about of
                Nothing ->
                    { person | about = (Emails.personMetadata id) }

                _ ->
                    person
    in
        map (Dict.map initAbout) (dict person)


person : Decoder Emails.Person
person =
    decode Emails.Person
        |> optionalMaybe "about" about
        |> optional "messages" messages Dict.empty
        |> optional "responses" responses []


about : Decoder Emails.About
about =
    decode Emails.About
        |> required "email" string
        |> required "name" string
        |> required "picture" string


messages : Decoder Emails.Messages
messages =
    map Dict.fromList (list message)


toMessage : ( Float, String, String ) -> Decoder ( Float, Emails.Message )
toMessage ( time, direction, phrase ) =
    case direction of
        "sended" ->
            succeed ( time, Emails.Sended phrase )

        "received" ->
            succeed ( time, Emails.Received phrase )

        _ ->
            fail ("Unrecgonized direction `" ++ direction ++ "'")


message : Decoder ( Float, Emails.Message )
message =
    decode (,,)
        |> required "time" float
        |> required "direction" string
        |> required "phrase" string
        |> andThen toMessage


responses : Decoder Emails.Responses
responses =
    list string


receive : Decoder Emails.ReceiveData
receive =
    decode (,,)
        |> required "from" string
        |> required "messages" messages
        |> optional "responses" responses []
