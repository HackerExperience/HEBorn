module Apps.Browser.Pages.FBI.Models
    exposing
        ( getTitle
        , getSite
        )

import Game.Web.Types as Web


getTitle : String
getTitle =
    "Federal Bureal Intelligence"


getSite : ( Web.Type, Maybe Web.Meta )
getSite =
    ( Web.FBI, Nothing )
