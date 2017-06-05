module Apps.Explorer.Messages exposing (Msg(..))

import Game.Servers.Filesystem.Models exposing (FilePath)
import Apps.Explorer.Menu.Messages as Menu


type Msg
    = MenuMsg Menu.Msg
    | GoPath FilePath
