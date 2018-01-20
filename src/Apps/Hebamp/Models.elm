module Apps.Hebamp.Models exposing (..)

import Apps.Hebamp.Shared exposing (..)


type alias Model =
    { playerId : String
    , now : Maybe AudioData
    , prev : List AudioData
    , next : List AudioData
    , currentTime : Float
    }


name : String
name =
    "Hebamp"


title : Model -> String
title model =
    let
        musicTitle =
            model.now
                |> Maybe.map .label
                |> Maybe.withDefault ""

        posfix =
            if (String.length musicTitle) > 12 then
                Just (": \"" ++ (String.left 10 musicTitle) ++ "[...]\"")
            else if (String.length musicTitle) > 0 then
                Just (": \"" ++ musicTitle ++ "\"")
            else
                Nothing
    in
        posfix
            |> Maybe.map ((++) name)
            |> Maybe.withDefault name


icon : String
icon =
    "hebamp"


initialModel : String -> List AudioData -> Model
initialModel id playlist =
    let
        ( now, next ) =
            case playlist of
                head :: tail ->
                    ( Just head, tail )

                [] ->
                    ( Nothing, [] )
    in
        { playerId = "audio-" ++ id
        , now = now
        , prev = []
        , next = next
        , currentTime = 0
        }
