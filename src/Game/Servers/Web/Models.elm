module Game.Servers.Web.Models
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
import Game.Servers.Web.Types exposing (..)
import Game.Servers.Web.Dummy exposing (dummyTunnel)


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
        Webserver ->
            True

        NoWebserver ->
            True

        -- TODO: add exceptions for store and banks
        _ ->
            False


blankSite : String -> Site
blankSite url =
    { url = url
    , type_ = Blank
    , meta = Nothing
    }


unknownSite : String -> Site
unknownSite url =
    { url = url
    , type_ = Unknown
    , meta = Nothing
    }


homepageSite : String -> Site
homepageSite url =
    { url = url
    , type_ = Home
    , meta = Nothing
    }


get : String -> Model -> Site
get str model =
    case String.split "/" str of
        [ "about:blank" ] ->
            blankSite str

        [ "about:home" ] ->
            homepageSite str

        [ "" ] ->
            blankSite str

        host :: req ->
            case List.reverse (String.split "." host) of
                -- Top Level Domains go here
                "dmy" :: domain ->
                    { url = str
                    , type_ = dummyTunnel <| domain ++ req
                    , meta = Nothing
                    }

                _ ->
                    case Dict.get str model of
                        Just site ->
                            site

                        Nothing ->
                            unknownSite str

        _ ->
            unknownSite str


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
