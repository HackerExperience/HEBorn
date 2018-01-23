module Game.Web.Models
    exposing
        ( Model
        , LoadingPages
        , initialModel
        , startLoading
        , finishLoading
        )

import Dict exposing (Dict)
import Game.Meta.Types.Requester exposing (Requester)
import Game.Meta.Types.Network as Network


type alias Model =
    { loadingPages : LoadingPages
    }


type alias LoadingPages =
    Dict Network.NIP Requester


initialModel : Model
initialModel =
    { loadingPages = Dict.empty }


startLoading : Network.NIP -> Requester -> Model -> Model
startLoading id requester model =
    let
        loadingPages =
            Dict.insert id requester model.loadingPages
    in
        { model | loadingPages = loadingPages }


finishLoading : Network.NIP -> Model -> ( Maybe Requester, Model )
finishLoading nip model =
    let
        request =
            Dict.get nip model.loadingPages

        loadingPages =
            Dict.remove nip model.loadingPages
    in
        ( request, { model | loadingPages = loadingPages } )
