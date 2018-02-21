module Game.Storyline.Emails.View exposing (..)

import Html exposing (Html, text)
import Game.Storyline.Shared exposing (Reply(..))
import Game.Storyline.Emails.Config exposing (..)
import UI.Inlines.Networking exposing (..)


view : Config msg -> Reply -> List (Html msg)
view { onOpenBrowser, username } content =
    case content of
        Welcome ->
            [ text <|
                "Hey, "
                    ++ username
                    ++ "! There are some rumours you just got out of jail..."
            ]

        BackThanks ->
            [ text "Yep, the king is back! I'm needing a starter kit for getting back to work!"
            , text " Care to share one with me?"
            ]

        DownloadCracker1 downloadCenterIP ->
            [ text "Sure. I've set up a public FTP server at "
            , addr onOpenBrowser downloadCenterIP
            , text ", you probably need that cracker for starters..."
            ]

        AboutThat ->
            [ text "About that coffee..."
            , text "I'll wire you the money someday :roll:"
            ]

        Downloaded ->
            [ text "Got it, thanks."
            , text "I lost touch with all my contacts... got any gig for me?"
            ]

        HellYeah ->
            [ text "This is my work, and I need money "
            , text "¯\\_(ツ)_/¯"
            , text ". Got any software you can hand me?"
            ]

        NastyVirus1 ->
            []

        NothingNow ->
            [ text "Hmm nothing now, but I'll refer to you if someone shows up looking for a job." ]

        WatchIADoing ->
            [ text "Oh wow, that's great, welcome back then! Do you plan to lay low or what?" ]

        YeahRight ->
            [ text "Yeah, right..." ]
