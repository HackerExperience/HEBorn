module Game.Web.Models
    exposing
        ( Model
        , LoadingPages
        , Requester
        , initialModel
        , startLoading
        , finishLoading
        )

import Dict exposing (Dict)
import Game.Servers.Shared as Servers
import Game.Meta.Types exposing (Context(..))
import Game.Web.Types exposing (..)
import Game.Network.Types as Network


type alias Model =
    { loadingPages : LoadingPages
    }


type alias LoadingPages =
    Dict Network.NIP Requester


type alias Requester =
    { sessionId : String
    , windowId : String
    , context : Context
    , tabId : Int
    }


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
