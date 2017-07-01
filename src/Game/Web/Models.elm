module Game.Web.Models
    exposing
        ( Model
        , Url
        , initialModel
        , get
        , refresh
        , remove
        , isHackable
        )

import Dict exposing (Dict)
import Game.Web.Types exposing (..)


type alias Model =
    Dict Url Site


type alias Url =
    String


initialModel : Model
initialModel =
    Dict.empty


isHackable : Type -> Bool
isHackable t =
    case t of
        Custom ->
            True

        Default ->
            True

        -- TODO: add exceptions for store and banks
        _ ->
            False


get : String -> Model -> Site
get str model =
    case str of
        "about:blank" ->
            { url = str
            , type_ = Blank
            , meta = Nothing
            }

        str ->
            case Dict.get str model of
                Just site ->
                    site

                Nothing ->
                    { url = str
                    , type_ = Unknown
                    , meta = Nothing
                    }


refresh : String -> Site -> Model -> Model
refresh url result model =
    case Dict.get url model of
        Just _ ->
            model

        Nothing ->
            Dict.insert url result model


remove : String -> Model -> Model
remove =
    Dict.remove
