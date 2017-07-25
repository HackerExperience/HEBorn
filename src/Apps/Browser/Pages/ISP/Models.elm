module Apps.Browser.Pages.ISP.Models
    exposing
        ( getTitle
        , getSite
        )

import Game.Web.Types as Web


getTitle : String
getTitle =
    "Internet Service Provider"


getSite : ( Web.Type, Maybe Web.Meta )
getSite =
    ( Web.ISP, Nothing )
