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


type alias Model =
    { loadingPages : LoadingPages
    }


type alias LoadingPages =
    Dict Servers.ID Requester


type alias Requester =
    { sessionId : String
    , windowId : String
    , context : Context
    , tabId : Int
    }


initialModel : Model
initialModel =
    { loadingPages = Dict.empty }


startLoading : Servers.ID -> Requester -> Model -> Model
startLoading id requester model =
    let
        loadingPages =
            Dict.insert id requester model.loadingPages
    in
        { model | loadingPages = loadingPages }


finishLoading : Servers.ID -> Model -> ( Maybe Requester, Model )
finishLoading id model =
    let
        request =
            Dict.get id model.loadingPages

        loadingPages =
            Dict.remove id model.loadingPages
    in
        ( request, { model | loadingPages = loadingPages } )
