module Apps.Browser.Widgets.PublicFiles.Model exposing (Model)

import Game.Servers.Filesystem.Models as Filesystem


type alias Model =
    List Filesystem.FileEntry
