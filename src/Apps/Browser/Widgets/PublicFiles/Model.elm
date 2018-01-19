module Apps.Browser.Widgets.PublicFiles.Model exposing (Model)

import Game.Servers.Filesystem.Shared as Filesystem


type alias Model =
    List Filesystem.FileEntry
