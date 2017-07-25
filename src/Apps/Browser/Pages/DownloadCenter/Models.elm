module Apps.Browser.Pages.DownloadCenter.Models
    exposing
        ( getTitle
        , getSite
        )

import Game.Web.Types as Web


getTitle : String
getTitle =
    "Download Center"


getSite : ( Web.Type, Maybe Web.Meta )
getSite =
    ( Web.DownloadCenter, Nothing )
