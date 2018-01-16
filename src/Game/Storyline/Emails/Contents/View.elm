module Game.Storyline.Emails.Contents.View exposing (..)

import Html exposing (Html, text)
import Game.Data as Game
import Game.Models as Game
import Game.Account.Models as Account
import Game.Storyline.Emails.Contents exposing (Content(..))
import Game.Storyline.Emails.Contents.Messages exposing (..)
import UI.Inlines.Networking exposing (..)


view : Game.Data -> Content -> List (Html Msg)
view data content =
    case content of
        HelloWorld some ->
            [ text <| "hello world! " ++ some ]

        WelcomePCSetup ->
            let
                username =
                    data
                        |> Game.getGame
                        |> Game.getAccount
                        |> Account.getUsername
            in
                [ text <|
                    "Hey, "
                        ++ username
                        ++ "! There are some rumours you just got out of jail..."
                ]

        BackThanks ->
            [ text "Yep, the king is back! I'm needing a starter kit for getting back to work!"
            , text " Care to share one with me?"
            ]

        DownloadCrackerPublicFTP downloadCenterIP ->
            [ text "Sure. I've set up a public FTP server at "
            , addr OpenAddr downloadCenterIP
            , text ", you probably need that cracker for starters..."
            ]

        MoreInfo ->
            [ text "Tell me more..." ]

        Sure ->
            [ text "Sure" ]

        GiveMoreInfo step ->
            [ text "Blabla" ]
