module Game.Storyline.Emails.Contents exposing (..)

import Game.Shared exposing (ID)
import Game.Meta.Types.Network exposing (IP)


type Content
    = HelloWorld String
    | WelcomePCSetup
    | BackThanks
    | DownloadCrackerPublicFTP IP
    | GiveMoreInfo ID
    | MoreInfo
    | Sure


toId : Content -> String
toId content =
    case content of
        HelloWorld _ ->
            "hello_world"

        WelcomePCSetup ->
            "welcome_pc_setup"

        BackThanks ->
            "back_thanks"

        DownloadCrackerPublicFTP _ ->
            "download_cracker_public_ftp"

        GiveMoreInfo _ ->
            "give_more_info"

        MoreInfo ->
            "more_info"

        Sure ->
            "sure"
