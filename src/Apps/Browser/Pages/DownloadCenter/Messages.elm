module Apps.Browser.Pages.DownloadCenter.Messages exposing (Msg(..))

import Game.Meta.Types.Network exposing (NIP)


type Msg
    = UpdatePasswordField String
    | SetShowingPanel Bool
    | LoginFailed
    | Cracked NIP String
