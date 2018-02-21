module Decoders.Storyline exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode
    exposing
        ( Decoder
        , succeed
        , fail
        , map
        , andThen
        , field
        , list
        , dict
        , string
        , float
        )
import Json.Decode.Pipeline exposing (decode, required, hardcoded, custom)
import Utils.Json.Decode exposing (optionalMaybe, commonError)
import Game.Storyline.Models exposing (Contact, Model, initialAbout)
import Game.Storyline.Shared exposing (..)
import Game.Storyline.StepActions.Shared exposing (Action)
import Game.Storyline.StepActions.Helper exposing (initialActions)


story : Decoder Model
story =
    contacts


contacts : Decoder (Dict ContactId Contact)
contacts =
    dict contactWithAbout
        |> map
            (Dict.map
                (\id ( about, contact ) ->
                    contact <| Maybe.withDefault (initialAbout id) about
                )
            )


contactWithAbout : Decoder ( Maybe About, About -> Contact )
contactWithAbout =
    decode (,)
        |> optionalMaybe "about" about
        |> custom contact


about : Decoder About
about =
    decode About
        |> required "name" string
        |> required "picture" string


contact : Decoder (About -> Contact)
contact =
    decode Contact
        |> required "replies" replies
        |> required "emails" pastEmails
        |> optionalMaybe "name" stepWithActions
        |> hardcoded Nothing
        |> hardcoded Nothing


replies : Decoder (List Reply)
replies =
    list reply


reply : Decoder Reply
reply =
    andThen replyFromId string


emailId : Decoder Reply
emailId =
    string
        |> field "id"
        |> andThen replyFromId


replyFromId : String -> Decoder Reply
replyFromId id =
    case id of
        "welcome" ->
            succeed Welcome

        "back_thanks" ->
            succeed BackThanks

        "watchiadoing" ->
            succeed WatchIADoing

        "hell_yeah" ->
            succeed HellYeah

        "download_cracker1" ->
            succeed DownloadCracker1
                |> required "ip" string
                |> field "meta"

        "about_that" ->
            succeed AboutThat

        "yeah_right" ->
            succeed YeahRight

        "downloaded" ->
            succeed Downloaded

        "nothing_now" ->
            succeed NothingNow

        "nasty_virus1" ->
            succeed NastyVirus1

        error ->
            fail <| commonError "email type" error


pastEmails : Decoder PastEmails
pastEmails =
    decode (,)
        |> required "timestamp" float
        |> custom pastEmail
        |> list
        |> map Dict.fromList


pastEmail : Decoder PastEmail
pastEmail =
    string
        |> field "sender"
        |> andThen emailFromSender


emailFromSender : String -> Decoder PastEmail
emailFromSender sender =
    case sender of
        "player" ->
            emailId
                |> map FromPlayer

        "contact" ->
            emailId
                |> map FromContact

        error ->
            error
                |> commonError "email sender"
                |> fail


stepWithActions : Decoder ( Step, List Action )
stepWithActions =
    map (\k -> ( k, initialActions k )) step


step : Decoder Step
step =
    andThen stepFromId string


stepFromId : String -> Decoder Step
stepFromId id =
    case id of
        "tutorial@setup_pc" ->
            succeed Tutorial_SetupPC

        "tutorial@download_cracker" ->
            succeed Tutorial_DownloadCracker

        error ->
            fail <| commonError "storyline step id" error
