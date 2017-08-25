module Apps.Browser.Pages.Template.Models
    exposing
        ( getTitle
        , getSite
        )

import Game.Servers.Web.Types as Web


getTitle : String
getTitle =
    "title"


getSite : ( Web.Type, Maybe Web.Meta )
getSite =
    ( Web.Template, Nothing )
