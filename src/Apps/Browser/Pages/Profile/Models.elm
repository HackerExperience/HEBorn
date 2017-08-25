module Apps.Browser.Pages.Profile.Models
    exposing
        ( getTitle
        , getSite
        )

import Game.Servers.Web.Types as Web


getTitle : String
getTitle =
    "Profile"


getSite : ( Web.Type, Maybe Web.Meta )
getSite =
    ( Web.Profile, Nothing )
