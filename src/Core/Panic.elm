module Core.Panic exposing (view)

import Core.Messages exposing (Msg(Shutdown))
import Html exposing (..)
import Html.Attributes as Html
import Html.Events exposing (onClick)
import Css
    exposing
        ( backgroundColor
        , color
        , textAlign
        , width
        , maxWidth
        , minHeight
        , fontSize
        , flex
        , displayFlex
        , flexDirection
        , alignItems
        , marginTop
        , cursor
        , hex
        , px
        , int
        , pct
        , left
        , center
        , column
        , pointer
        )
import Css.Colors exposing (white)
import Css.Utils exposing (selectableText)


style : List Css.Style -> Attribute Msg
style =
    Css.asPairs >> Html.style


view : String -> String -> Html Msg
view code message =
    div
        [ style
            [ backgroundColor <| hex "007aff"
            , color white
            , textAlign center
            , width <| pct 100
            , minHeight <| pct 100
            , displayFlex
            , flexDirection column
            , alignItems center
            ]
        ]
        [ div [ style [ flex <| int 1 ] ] []
        , div
            [ style
                [ maxWidth <| px 640
                , textAlign left
                , flex <| int 0
                ]
            ]
            [ h1 [ style [ fontSize <| px 72, marginTop <| px 0 ] ]
                [ text "(ノò_ó)ノ︵┻━━━┻" ]
            , h3 []
                [ text "D'Lay'D OS ran into a problem that it couldn't (never)"
                , br [] []
                , text "handle and now it needs to restart."
                ]
            , h5 []
                [ text <| "You can ask on discord: " ++ code ]
            , h5 [ style [ selectableText ] ]
                [ text message ]
            , br [] []
            , h4
                [ onClick Shutdown
                , style [ textAlign center, cursor pointer ]
                ]
                [ text "Click here to logout." ]
            , br [] []
            , p [ style [ fontSize <| px 7 ] ] [ text "70.111.100.97.45.83.69.33" ]
            ]
        , div [ style [ flex <| int 1 ] ] []
        ]
