module Apps.Browser.Pages.News.Models
    exposing
        ( getTitle
        , getSite
        )

import Game.Servers.Web.Types as Web


getTitle : String
getTitle =
    "News"


getSite : ( Web.Type, Maybe Web.Meta )
getSite =
    ( Web.News, Nothing )
