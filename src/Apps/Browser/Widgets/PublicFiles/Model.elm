module Apps.Browser.Widgets.PublicFiles.Model exposing (Model)

import Game.Servers.Filesystem.Shared exposing (ForeignFileBox)


type alias Model =
    List ForeignFileBox
