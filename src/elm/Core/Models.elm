module Core.Models exposing (Model, Flags
                            , initialModel)

import Uuid
import Random.Pcg exposing (Seed, initialSeed, step)

import Requests.Models exposing (initialRequest, RequestStore)
import Router.Router exposing (Route)
import Game.Models
import OS.Models
import Apps.Login.Models
import Apps.SignUp.Models


type alias Model =
    { appLogin : Apps.Login.Models.Model
    , appSignUp : Apps.SignUp.Models.Model
    , route : Route
    , requests : RequestStore
    , uuid : String
    , seed : Seed
    , game : Game.Models.GameModel
    , os : OS.Models.Model
    }

type alias Flags =
    { seed : Int
    }

initialModel : Router.Router.Route -> Int -> Model
initialModel route seedFromJS =
    let
        (uuid, seed) = step Uuid.uuidGenerator (initialSeed seedFromJS)
    in
        Debug.log (Uuid.toString uuid)
        { appLogin = Apps.Login.Models.initialModel
        , appSignUp = Apps.SignUp.Models.initialModel
        , route = route
        , requests = initialRequest
        , uuid = Uuid.toString uuid
        , seed = seed
        , game = Game.Models.initialModel
        , os = OS.Models.initialModel
        }

