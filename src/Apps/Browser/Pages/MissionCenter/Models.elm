module Apps.Browser.Pages.MissionCenter.Models
    exposing
        ( getTitle
        , getSite
        )

import Game.Web.Types as Web


getTitle : String
getTitle =
    "Mission Center"


getSite : ( Web.Type, Maybe Web.Meta )
getSite =
    ( Web.MissionCenter, Nothing )
