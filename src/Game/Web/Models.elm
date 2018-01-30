module Game.Web.Models
    exposing
        ( Model
        , LoadingPages
        , initialModel
        , startLoading
        , finishLoading
        )

import Dict exposing (Dict)
import Game.Meta.Types.Apps.Desktop exposing (Requester)
import Game.Meta.Types.Network as Network
import Game.Servers.Shared as Servers exposing (CId)


type alias Model =
    { loadingPages : LoadingPages
    }


type alias LoadingPages =
    Dict Network.NIP ( CId, Requester )


initialModel : Model
initialModel =
    { loadingPages = Dict.empty }


startLoading : Network.NIP -> CId -> Requester -> Model -> Model
startLoading id cid requester model =
    let
        loadingPages =
            Dict.insert id ( cid, requester ) model.loadingPages
    in
        { model | loadingPages = loadingPages }


finishLoading : Network.NIP -> Model -> ( Maybe ( CId, Requester ), Model )
finishLoading nip model =
    let
        request =
            Dict.get nip model.loadingPages

        loadingPages =
            Dict.remove nip model.loadingPages
    in
        ( request, { model | loadingPages = loadingPages } )
