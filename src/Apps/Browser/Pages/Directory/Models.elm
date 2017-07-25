module Apps.Browser.Pages.Directory.Models
    exposing
        ( getTitle
        , getSite
        )

import Game.Web.Types as Web


getTitle : String
getTitle =
    "Directory"


getSite : ( Web.Type, Maybe Web.Meta )
getSite =
    ( Web.Directory, Nothing )
