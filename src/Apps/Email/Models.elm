module Apps.Email.Models exposing (..)


type alias Model =
    {}


name : String
name =
    "Thunderpigeon"


title : Model -> String
title model =
    "Thunderpigeon"


icon : String
icon =
    "email"


initialModel : Model
initialModel =
    {}


windowInitSize : ( Float, Float )
windowInitSize =
    ( 200, 550 )
