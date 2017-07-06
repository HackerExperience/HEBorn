module Apps.Hebamp.View exposing (view)

import Json.Decode as Json
import Html exposing (..)
import Html.Attributes exposing (src, type_, controls)
import Html.CssHelpers
import Html.Events exposing (on, onClick)
import Game.Data as Game
import Apps.Hebamp.Messages exposing (Msg(..))
import Apps.Hebamp.Models exposing (..)
import Apps.Hebamp.Resources exposing (Classes(..), prefix)
import Apps.Hebamp.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


targetCurrentTime : Json.Decoder Float
targetCurrentTime =
    Json.at [ "target", "currentTime" ] Json.float


onTimeUpdate : (Float -> msg) -> Attribute msg
onTimeUpdate msg =
    on "timeupdate" (Json.map msg targetCurrentTime)


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    div
        [ class [ Container ] ]
        [ div [ class [ Header ] ] [ text ":" ]
        , div [ class [ Player ] ]
            [ div [ class [ Vis ] ]
                [ text <|
                    " "
                        ++ (toString <| floor <| (flip (/)) 60 <| app.audioData.currentTime)
                        ++ ":"
                        ++ (toString <| (flip (%)) 60 <| floor <| app.audioData.currentTime)
                ]
            , div [ class [ Vis, Title ] ] [ text app.audioData.label ]
            , div [ class [ Inf ] ] []
            , div [ class [ Inf, KHz ] ] []
            , div [ class [ MonoStereo ] ] [ text "mono" ]
            , div [ class [ Bar, Volume ] ] []
            , div [ class [ Bar, Balanced ] ] []
            , div [ class [ Btn, Ext, Left ] ] [ text "EQ" ]
            , div [ class [ Btn, Ext ] ] [ text "PL" ]
            , div [ class [ Sidebar ] ] []
            , div [ class [ Btn, PlayerB, First ] ] [ span [ class [ Icon, IconStepBackward ] ] [] ]
            , div [ class [ Btn, PlayerB ] ] [ span [ class [ Icon, IconPlay ], onClick Play ] [] ]
            , div [ class [ Btn, PlayerB ] ] [ span [ class [ Icon, IconPause ], onClick Pause ] [] ]
            , div [ class [ Btn, PlayerB ] ] [ span [ class [ Icon, IconStop ], onClick Pause ] [] ]
            , div [ class [ Btn, PlayerB ] ] [ span [ class [ Icon, IconStepForward ] ] [] ]
            , div [ class [ Btn, PlayerB, First ] ] [ span [ class [ Icon, IconEject ], onClick Pause ] [] ]
            , div [ class [ Btn, Ext, Left ] ] [ text "SHUFFLE" ]
            , div [ class [ Btn, Ext, Left ] ] [ text "RAND " ]
            ]
        , audio
            [ src app.audioData.mediaUrl
            , type_ app.audioData.mediaType
            , controls False
            , onTimeUpdate TimeUpdate
            , id "audio-player"
            ]
            []
        , menuView model
        ]
