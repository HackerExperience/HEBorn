module Game.Account.Bounces.Models
    exposing
        ( Model
        , ID
        , Bounce
        , Path
        , IP
        , initialModel
        , get
        , insert
        , remove
        , getName
        , getPath
        )

import Dict exposing (Dict)


type alias Model =
    Dict ID Bounce


type alias ID =
    String


type alias Bounce =
    { name : String
    , path : Path
    }


type alias Path =
    List IP


type alias IP =
    String


initialModel : Model
initialModel =
    Dict.empty


get : ID -> Model -> Maybe Bounce
get =
    Dict.get


insert : ID -> Bounce -> Model -> Model
insert =
    Dict.insert


remove : ID -> Model -> Model
remove =
    Dict.remove


getName : ID -> Model -> Maybe String
getName id model =
    model
        |> get id
        |> Maybe.map .name


getPath : ID -> Model -> Maybe Path
getPath id model =
    model
        |> get id
        |> Maybe.map .path
