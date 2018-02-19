module Decoders.Storyline exposing (..)

import Json.Decode as Decode
    exposing
        ( Decoder
        , succeed
        , fail
        , map
        , andThen
        , list
        , dict
        , string
        )
import Json.Decode.Pipeline exposing (decode, required, hardcoded, custom)
import Game.Storyline.Models exposing (..)
import Game.Storyline.Shared exposing (..)
import Decoders.Emails exposing (..)
import Decoders.Missions exposing (..)


story : Decoder Model
story =
    decode Model contacts


contacts : Decoder (Dict String Contact)
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


contact : Decoder (About -> Contact)
contact =
    decode Contact
        |> required "replies" (list reply)
        |> required "emails" pastEmails
        |> optionalMaybe "name" step
        |> hardcoded "objective" Nothing
        |> hardcoded "quest" Nothing


reply : Decoder Reply
reply id =
    andThen replyFromId string


replyFromId : String -> Decoder Reply
replyFromId =
    case id of
        "welcome" ->
            succeed Welcome

        "back_thanks" ->
            succeed BackThanks

        "download_cracker1" ->
            succeed DownloadCrackerPublicFTP
                |> required "ip" string
                |> field "meta"

        error ->
            fail <| commonError "email type" error


pastEmails : Decoder PastEmails
pastEmails =
    decode (,)
        |> required "timestamp" floa
        |> required "sender" pastEmail
        |> list
        |> map Dict.fromList


pastEmail : Decoder PastEmail
pastEmail =
    andThen emailFromSender string


emailFromSender : String -> Decoder PastEmail
emailFromSender sender =
    case sender of
        "player" ->
            field "id" reply
                |> map FromPlayer

        "contact" ->
            field "id" reply
                |> map FromContact

        error ->
            fail <| commonError "email sender" error


step : Decoder ( Step, List Action )
step =
    string
        |> andThen stepFromId
        |> map (\k -> ( k, initialActions k ))


stepFromId : String -> Decoder Step
stepFromId id =
    case id of
        "tutorial@setup_pc" ->
            succeed Tutorial_SetupPC

        "tutorial@download_cracker" ->
            succeed Tutorial_DownloadCracker

        error ->
            fail <| commonError "storyline step id" error
