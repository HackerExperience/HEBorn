module Apps.FloatingHeads.Models exposing (..)

import Game.Meta.Types.Desktop.Apps exposing (Reference)
import Game.Storyline.Shared exposing (ContactId)


type alias Model =
    { me : Reference
    , activeContact : ContactId
    , mode : Mode
    }


type Mode
    = Compact
    | Expanded


type Params
    = OpenAtContact String


name : String
name =
    "floatingheads"


title : Model -> String
title model =
    "FloatingHeads Title"


icon : String
icon =
    "floatingheads"


initialModel : Maybe String -> Reference -> Model
initialModel contact me =
    case contact of
        Just contact ->
            { me = me
            , activeContact = contact
            , mode = Expanded
            }

        Nothing ->
            { me = me
            , activeContact = "friend"
            , mode = Expanded
            }


getActiveContact : Model -> String
getActiveContact =
    (.activeContact)


setActiveContact : String -> Model -> Model
setActiveContact v m =
    { m | activeContact = v }
