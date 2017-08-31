module Apps.Browser.Pages.NoWebserver.Models
    exposing
        ( Model
        , initialModel
        , getTitle
        , getSite
        )

import Game.Network.Types as Network
import Game.Servers.Web.Types exposing (NoWebserverMetadata)
import Game.Servers.Web.Types as Web exposing (Site)


type alias Model =
    { serverId : String
    , nip : Network.NIP
    }



-- Default page for valid IP without a server


initialModel : NoWebserverMetadata -> Model
initialModel meta =
    Model
        meta.serverId
        meta.nip


getTitle : Model -> String
getTitle model =
    model
        |> (.nip)
        |> Network.toString


getSite : Model -> ( Web.Type, Maybe Web.Meta )
getSite _ =
    ( Web.NoWebserver, Nothing )
