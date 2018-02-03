module Game.Account.Bounces.Models
    exposing
        ( Model
        , Bounce
        , Path
        , initialModel
        , get
        , emptyBounce
        , insert
        , remove
        , getName
        , setName
        , getPath
        )

import Dict exposing (Dict)
import Game.Meta.Types.Network as Network
import Game.Account.Bounces.Shared exposing (..)


type alias Model =
    Dict ID Bounce


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
    Dict.get id model


emptyBounce : Bounce
emptyBounce =
    { name = "Untitled Bounce"
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


setName : String -> Bounce -> Bounce
setName name bounce =
    { bounce | name = name }
