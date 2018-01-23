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
            splitPlayList playlist
    in
        { playerId = "audio-" ++ id
        , now = now
        , prev = []
        , next = next
        , currentTime = 0
        }


setPlaylist : List AudioData -> Model -> Model
setPlaylist playlist model =
    let
        ( now, next ) =
            splitPlayList playlist
    in
        { model
            | now = now
            , prev = []
            , next = next
            , currentTime = 0
        }


splitPlayList : List AudioData -> ( Maybe AudioData, List AudioData )
splitPlayList playlist =
    case playlist of
        head :: tail ->
            ( Just head, tail )

        [] ->
            ( Nothing, [] )
