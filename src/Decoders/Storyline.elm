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
import Game.Storyline.Models exposing (Contact, Model, initialAbout, fromContacts)
import Game.Storyline.Shared exposing (..)
import Game.Storyline.StepActions.Shared exposing (Action)
import Game.Storyline.StepActions.Helper exposing (initialActions)


story : Decoder Model
story =
    contacts
        |> map (\contacts -> fromContacts contacts)


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
    decode
        (\r e s ->
            case s of
                Just ( q, s, a ) ->
                    Contact r e (Just ( s, a )) Nothing (Just q)

                Nothing ->
                    Contact r e Nothing Nothing Nothing
        )
        |> required "replies" replies
        |> required "emails" pastEmails
        |> optionalMaybe "name" stepWithActions


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

        "nasty_virus2" ->
            succeed NastyVirus2

        "punks1" ->
            succeed Punks1

        "punks2" ->
            succeed Punks2

        "punks3" ->
            succeed Punks3
                |> required "ip" string
                |> field "meta"

        "dlayd_much1" ->
            succeed DlaydMuch1

        "dlayd_much2" ->
            succeed DlaydMuch2

        "dlayd_much3" ->
            succeed DlaydMuch3

        "dlayd_much4" ->
            succeed DlaydMuch4

        "noice" ->
            succeed Noice

        "nasty_virus3" ->
            succeed NastyVirus3

        "virus_spotted1" ->
            succeed VirusSpotted1

        "virus_spotted2" ->
            succeed VirusSpotted2

        "pointless_convo1" ->
            succeed PointlessConvo1

        "pointless_convo2" ->
            succeed PointlessConvo2

        "pointless_convo3" ->
            succeed PointlessConvo3

        "pointless_convo4" ->
            succeed PointlessConvo4

        "pointless_convo5" ->
            succeed PointlessConvo5

        "clean_your_logs" ->
            succeed CleanYourLogs

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


stepWithActions : Decoder ( Quest, Step, List Action )
stepWithActions =
    map (\( q, k ) -> ( q, k, initialActions k )) step


step : Decoder ( Quest, Step )
step =
    flip andThen string <|
        \id ->
            case String.split "@" id of
                [ "tutorial", step ] ->
                    map ((,) Tutorial) <|
                        case step of
                            "setup_pc" ->
                                succeed Tutorial_SetupPC

                            "download_cracker" ->
                                succeed Tutorial_DownloadCracker

                            "nasty_virus" ->
                                succeed Tutorial_NastyVirus

                            error ->
                                fail <| commonError "storyline tutorial step id" error

                error ->
                    fail <| commonError "storyline quest id" error
