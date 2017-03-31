module App.Models exposing (Model, Flags
                           , initialModel)

import Uuid
import Random.Pcg exposing (Seed, initialSeed, step)

import Requests.Models exposing (initialRequest, RequestStore)
import Router.Router exposing (Route)
import App.Login.Models
import App.Core.Models
import App.SignUp.Models


type alias Model =
    { appLogin : App.Login.Models.Model
    , appSignUp : App.SignUp.Models.Model
    , route : Route
    , email : String
    , token : Maybe String
    , requests : RequestStore
    , uuid : String
    , seed : Seed
    , core : App.Core.Models.Model
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
        { appLogin = App.Login.Models.initialModel
        , appSignUp = App.SignUp.Models.initialModel
        , route = route
        , email = ""
        , token = Nothing
        , requests = initialRequest
        , uuid = Uuid.toString uuid
        , seed = seed
        , core = App.Core.Models.initialModel
        }

