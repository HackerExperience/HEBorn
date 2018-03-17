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
        , getNameWithBounce
        , subscribeFor
        , isEmpty
        , getBounces
        , getIds
        )

import Dict exposing (Dict)
import Game.Meta.Types.Network as Network
import Game.Account.Bounces.Shared exposing (..)
import Game.Meta.Types.Desktop.Apps exposing (Reference)


type alias RequestId =
    String



{- Model
   optimistics: stores the AppId of a BounceManager
      that is waiting for a bounce being created on a specific requestId
      when this requestId arrives in some event, the update checks if there is
      some BounceManager (Generally used to reload) waiting for this Bounce and
      if the requestId exists on optimistics, update will send a dispatch to
      that specific BounceManager waiting for the Bounce
-}


type alias Model =
    { bounces : Dict ID Bounce
    , optimistics : Dict RequestId Reference
    }


type alias Bounce =
    { name : String
    , path : Path
    }


type alias Path =
    List Network.NIP


initialModel : Model
initialModel =
    Model Dict.empty Dict.empty


get : ID -> Model -> Maybe Bounce
get id model =
    Dict.get id model.bounces


subscribeFor : String -> String -> Model -> Model
subscribeFor requestId appId model =
    { model | optimistics = Dict.insert requestId appId model.optimistics }


emptyBounce : Bounce
emptyBounce =
    { name = "Untitled Bounce"
    , path = []
    }


insert : ID -> Bounce -> Model -> Model
insert id bounce model =
    { model | bounces = Dict.insert id bounce model.bounces }


remove : ID -> Model -> Model
remove id model =
    { model | bounces = Dict.remove id model.bounces }


getName : ID -> Model -> Maybe String
getName id model =
    model
        |> get id
        |> Maybe.map .name


getNameWithBounce : Bounce -> String
getNameWithBounce =
    .name


getPath : ID -> Model -> Maybe Path
getPath id model =
    model
        |> get id
        |> Maybe.map .path


setName : String -> Bounce -> Bounce
setName name bounce =
    { bounce | name = name }


isEmpty : Model -> Bool
isEmpty =
    .bounces >> Dict.isEmpty


getIds : Model -> List ID
getIds =
    .bounces >> Dict.keys


getBounces : Model -> Dict ID Bounce
getBounces =
    .bounces
