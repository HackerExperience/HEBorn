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

        WatchIADoing ->
            [ text "Oh wow, that's great, welcome back then! Do you plan to lay low or what?" ]

        HellYeah ->
            [ text "This is my work, and I need money "
            , text "¯\\_(ツ)_/¯"
            , text ". Got any software you can hand me?"
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

        YeahRight ->
            [ text "Yeah, right..." ]

        Downloaded ->
            [ text "Got it, thanks."
            , text "I lost touch with all my contacts... got any gig for me?"
            ]

        NothingNow ->
            [ text "Hmm nothing now, but I'll refer to you if someone shows up looking for a job." ]

        NastyVirus1 ->
            [ text "But as long as you are idle... "
            , text "You know the #RCN? I heard they developed a nasty virus."
            ]

        NastyVirus2 ->
            [ text "Wanna try to \"borrow\" it? "
            , text "Might work like an, er, angel investment if you find a good PC to install it."
            ]

        Punks1 ->
            [ text "Those punks still around? "
            , text "I'm pretty sure they are the ones who framed me... "
            , text "Anyway, sure I'm in. Where do I get it?"
            ]

        Punks2 ->
            [ text "Well, the folks there may have a good reputation, "
            , text "but they have a backup server that's quite easy to get in. "
            ]

        Punks3 ip ->
            [ text "Try this: "
            , addr onOpenBrowser ip
            , text " - I'll join you"
            ]

        DlaydMuch1 ->
            [ text "I wonder, did you ever used this version of the DLaydOS?" ]

        DlaydMuch2 ->
            [ text "Nah, things sure have changed a lot!" ]

        DlaydMuch3 ->
            [ text "Heh, you'll get used to it. Check out the TaskManager" ]

        DlaydMuch4 ->
            [ text "You can see all processes running on your server there, how much "
            , text "resources it uses, how much time is left. These things."
            ]

        Noice ->
            [ text "Noice" ]

        NastyVirus3 ->
            [ text "Finally you are in. See if you can find the virus on their filesystem." ]

        VirusSpotted1 ->
            [ text "You were right! #RCN.spy right there." ]

        VirusSpotted2 ->
            [ text "Good, get it." ]

        PointlessConvo1 ->
            [ text "That baby is a 3.0 spyware. Must be worth a fortune on the black market." ]

        PointlessConvo2 ->
            [ text "Meh, spywares are on a low now. People already share everything about them on social networks anyway." ]

        PointlessConvo3 ->
            [ text "Yeah, later on you gotta tell me what that Snapchato thing is..." ]

        PointlessConvo4 ->
            [ text "Mostly nudes." ]

        PointlessConvo5 ->
            [ text "Oh." ]

        CleanYourLogs ->
            []
