module Game.Account.Bounces.Models
    exposing
        ( Model
        , ID
        , Bounce
        , Path
        , initialModel
        , get
        , emptyBounce
        , insert
        , remove
        , getName
        , getPath
        )

import Dict exposing (Dict)
import Game.Network.Types as Network


type alias Model =
    Dict ID Bounce


type alias ID =
    String


type alias Bounce =
    { name : String
    , path : Path
    }


type alias Path =
    List Network.NIP


initialModel : Model
initialModel =
    Dict.empty


get : ID -> Model -> Maybe Bounce
get id model =
    if id == "" then
        Just emptyBounce
    else
        Dict.get id model


emptyBounce : Bounce
emptyBounce =
    { name = "None"
    , path = []
    }


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
