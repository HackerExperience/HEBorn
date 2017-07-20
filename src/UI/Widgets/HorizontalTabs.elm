module UI.Widgets.HorizontalTabs
    exposing
        ( hzTabs
        , hzCustomTabs
        , hzPlainTabs
        , panel
        , tab
        , panelSelector
        , tabSelector
        )

import Html exposing (Html, Attribute, node, text)
import Html.Events exposing (onClick)
import Utils.Html.Attributes exposing (selectedAttr)


type alias Renderer a msg =
    Bool -> a -> ( List (Attribute msg), List (Html msg) )


hzTabs :
    (a -> Bool)
    -> Renderer a msg
    -> (a -> msg)
    -> List a
    -> Html msg
hzTabs check render handler list =
    let
        mapper item =
            renderItem (check item) render handler item
    in
        renderContainer mapper list


hzCustomTabs :
    (a -> Bool)
    -> (a -> msg)
    -> List ( Renderer a msg, a )
    -> Html msg
hzCustomTabs check handler list =
    let
        mapper ( render, item ) =
            renderItem (check item) render handler item
    in
        renderContainer mapper list


hzPlainTabs :
    (String -> Bool)
    -> Renderer String msg
    -> (String -> msg)
    -> List String
    -> Html msg
hzPlainTabs check render =
    hzTabs check (\_ str -> ( [], [ text str ] ))



-- elements and selectors


panel : List (Attribute msg) -> List (Html msg) -> Html msg
panel =
    node panelNode


panelSelector : String
panelSelector =
    panelNode


tab : List (Attribute msg) -> List (Html msg) -> Html msg
tab =
    node tabNode


tabSelector : String
tabSelector =
    panelSelector ++ " > " ++ tabNode



-- internals


panelNode : String
panelNode =
    "panel"


tabNode : String
tabNode =
    "tab"


renderItem : Bool -> Renderer a msg -> (a -> msg) -> a -> Html msg
renderItem active render handler item =
    let
        ( attrs, childs ) =
            render active item
    in
        childs
            |> (tab <|
                    [ onClick (handler item)
                    , selectedAttr active
                    ]
                        ++ attrs
               )


renderContainer : (a -> Html msg) -> List a -> Html msg
renderContainer mapper list =
    list
        |> List.map mapper
        |> panel []
