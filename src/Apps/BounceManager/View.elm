module Apps.BounceManager.View exposing (view)

import Dict
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (..)
import Html.CssHelpers
import Utils.Html.Events exposing (onClickWithPrevDef, onClickWithStopProp)
import Game.Account.Database.Models as Database exposing (HackedServers)
import Game.Account.Bounces.Models as Bounces exposing (Bounce)
import Game.Account.Bounces.Shared as Bounces
import Game.Meta.Types.Network as Network
import UI.Layouts.VerticalSticked exposing (verticalSticked)
import UI.Layouts.VerticalList exposing (..)
import UI.Widgets.HorizontalTabs exposing (hzTabs)
import UI.Widgets.Modal exposing (modalOk, modalOkCancel)
import UI.Entries.Toogable exposing (toogableEntry)
import UI.Widgets.HorizontalBtnPanel exposing (horizontalBtnPanel)
import Apps.BounceManager.Config exposing (..)
import Apps.BounceManager.Messages exposing (..)
import Apps.BounceManager.Models exposing (..)
import Apps.BounceManager.Resources exposing (Classes(..), prefix)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view config ({ selected } as model) =
    let
        viewData =
            case selected of
                TabManage ->
                    lazy2 viewTabManage config model

                TabBuild bounceInfo ->
                    lazy3 viewTabBuild config bounceInfo model

        tabs_ =
            tabs model.selectedBounce

        viewTabs =
            hzTabs (compareTabs selected) viewTabLabel (GoTab >> config.toMsg) tabs_
    in
        verticalSticked (Just [ viewTabs ]) [ viewData ] Nothing


tabs : Maybe ( Maybe Bounces.ID, Bounce ) -> List MainTab
tabs selectedBounce =
    case selectedBounce of
        Just bounce ->
            [ TabManage, TabBuild bounce ]

        Nothing ->
            [ TabManage ]


compareTabs : MainTab -> MainTab -> Bool
compareTabs =
    (==)


viewTabLabel : Bool -> MainTab -> ( List (Attribute msg), List (Html msg) )
viewTabLabel _ tab =
    tab
        |> tabToString
        |> text
        |> List.singleton
        |> (,) []


viewTabManage : Config msg -> Model -> Html msg
viewTabManage ({ toMsg, bounces } as config) model =
    if Dict.isEmpty bounces then
        div [ class [ Super, Manage, Empty ] ]
            [ button
                [ class [ MiddleButton ]
                , ( Nothing, Bounces.emptyBounce )
                    |> TabBuild
                    |> GoTab
                    |> toMsg
                    |> onClickWithStopProp
                ]
                [ text "Click here to create a new bounce" ]
            ]
    else
        bounces
            |> Dict.toList
            |> List.map (viewBounce config model)
            |> verticalList []
            |> List.singleton
            |> (++) [ modalHandler config model ]
            |> div [ class [ Super ] ]


viewTabBuild :
    Config msg
    -> ( Maybe Bounces.ID, Bounce )
    -> Model
    -> Html msg
viewTabBuild ({ database, bounces, toMsg } as config) ( id, bounce ) model =
    let
        saveButton =
            if model.anyChange then
                button
                    [ ForSave ( id, bounce )
                        |> Just
                        |> SetModal
                        |> toMsg
                        |> onClickWithStopProp
                    ]
                    [ text "Save" ]
            else
                text ""

        name_ =
            renderName
                config
                model.renaming
                model.selectedBounce
                model.bounceNameBuffer
                |> flip (::) [ renderNameButtons config model ]
    in
        div [ class [ Super, Builder ] ]
            [ renderNameField config model name_
            , div [ class [ Building ] ]
                [ lazy2 modalHandler config model
                , lazy2 renderLeftBox config model
                , lazy2 renderRightBox config model
                ]
            , div [ class [ Buttons ] ]
                [ button
                    [ ForReset ( id, bounce )
                        |> Just
                        |> SetModal
                        |> toMsg
                        |> onClickWithStopProp
                    ]
                    [ text "Reset" ]
                , saveButton
                ]
            ]


renderNameField : Config msg -> Model -> List (Html msg) -> Html msg
renderNameField { toMsg } model content =
    if model.renaming then
        Html.form
            [ class [ Name ]
            , action "javascript:void(0)"
            , onSubmit (toMsg <| ApplyNameChangings)
            ]
            content
    else
        div
            [ class [ Name ]
            ]
            content


isEntryExpanded : Bounces.ID -> Model -> Bool
isEntryExpanded id model =
    List.member id model.expanded


modalHandler : Config msg -> Model -> Html msg
modalHandler ({ toMsg, batchMsg } as config) model =
    let
        name =
            case model.bounceNameBuffer of
                Just name ->
                    name

                Nothing ->
                    case model.selectedBounce of
                        Just ( _, bounce ) ->
                            bounce.name

                        Nothing ->
                            "Untitled Bounce"
    in
        case model.modal of
            Just (ForReset ( id, bounce )) ->
                modalOkCancel (Just "Bounce Manager")
                    "Do you really want to reset this bounce?"
                    (batchMsg
                        [ toMsg <| Reset ( id, bounce )
                        , toMsg <| SetModal Nothing
                        ]
                    )
                    (toMsg <| SetModal Nothing)

            Just (ForSave ( id, bounce )) ->
                modalOkCancel (Just "Bounce Manager")
                    ("Do you really want to save " ++ name)
                    (batchMsg
                        [ toMsg <| Save ( id, bounce )
                        , toMsg <| SetModal Nothing
                        ]
                    )
                    (toMsg <| SetModal Nothing)

            Just (ForEditWithoutSave id) ->
                modalOkCancel (Just "Are you sure?")
                    ("Continue without save " ++ name)
                    (batchMsg
                        [ toMsg <| Edit id
                        , toMsg <| SetModal Nothing
                        ]
                    )
                    (toMsg <| SetModal Nothing)

            Just (ForError error) ->
                renderErrorModal config error

            Just ForSaveSucessful ->
                modalOk (Just "Bounce Manager")
                    ("Save Sucessfully!")
                    (toMsg <| SetModal Nothing)

            Nothing ->
                text ""


renderErrorModal : Config msg -> Error -> Html msg
renderErrorModal config error =
    case error of
        CreateError error ->
            renderCreateErrorModal config error

        UpdateError error ->
            renderUpdateErrorModal config error

        RemoveError error ->
            renderRemoveErrorModal config error


renderCreateErrorModal : Config msg -> Bounces.CreateError -> Html msg
renderCreateErrorModal { toMsg, batchMsg } error =
    let
        msg =
            case error of
                Bounces.CreateBadRequest ->
                    "Bad Request"

                Bounces.CreateUnknown ->
                    "Unknown Error"
    in
        modalOk (Just "Error")
            msg
            (toMsg <| SetModal Nothing)


renderUpdateErrorModal : Config msg -> Bounces.UpdateError -> Html msg
renderUpdateErrorModal { toMsg, batchMsg } error =
    let
        msg =
            case error of
                Bounces.UpdateBadRequest ->
                    "Bad Request"

                Bounces.UpdateUnknown ->
                    "Unknown Error"
    in
        modalOk (Just "Error")
            msg
            (toMsg <| SetModal Nothing)


renderRemoveErrorModal : Config msg -> Bounces.RemoveError -> Html msg
renderRemoveErrorModal { toMsg, batchMsg } error =
    let
        msg =
            case error of
                Bounces.RemoveBadRequest ->
                    "Bad Request"

                Bounces.RemoveUnknown ->
                    "Unknown Error"
    in
        modalOk (Just "Error")
            msg
            (toMsg <| SetModal Nothing)


renderLeftBox : Config msg -> Model -> Html msg
renderLeftBox config model =
    div [ class [ Servers ] ]
        [ renderFilter config model
        , renderAvailableServers config model
        ]


renderRightBox :
    Config msg
    -> Model
    -> Html msg
renderRightBox config model =
    div
        [ class [ Build ]
        , onClickWithPrevDef <| config.toMsg <| ClearSelection
        ]
        (renderEntries config model)


renderAvailableServers :
    Config msg
    -> Model
    -> Html msg
renderAvailableServers ({ database } as config) model =
    (Database.getHackedServers database)
        |> Dict.filter (\k _ -> not <| List.member k model.path)
        |> Dict.foldl (renderAvailableServer config model) ( [], 0 )
        |> Tuple.first
        |> verticalList [ class [ ServerList ] ]


renderFilter : Config msg -> Model -> Html msg
renderFilter config model =
    div [ class [ FilterBox ] ] []


renderAvailableServer :
    Config msg
    -> Model
    -> Network.NIP
    -> Database.HackedServer
    -> ( List (Html msg), Int )
    -> ( List (Html msg), Int )
renderAvailableServer ({ toMsg } as config) model nip server ( acc, c ) =
    let
        label =
            server.label
                |> Maybe.withDefault (Network.render nip)
                |> (++) "Label: "
                |> text

        ip =
            nip
                |> Network.render
                |> (++) "IP: "
                |> text

        attr selectCondition highlightCondition nip pos =
            attrServer
                config
                selectCondition
                highlightCondition
                nip
                c
                pos
                model.path

        attr_ =
            case model.selection of
                Just (SelectingServer nip_) ->
                    attr (nip == nip_) False nip c

                Just (SelectingSlot num) ->
                    attr False True nip num

                Just (SelectingEntry num) ->
                    attr False False nip c

                Nothing ->
                    attr False False nip c

        servers =
            div attr_ [ label, br [] [], ip ]
    in
        ( servers :: acc, c + 1 )


renderEntries :
    Config msg
    -> Model
    -> List (Html msg)
renderEntries ({ database } as config) model =
    let
        hackedServers =
            Database.getHackedServers database
    in
        model.path
            |> List.foldr (renderEntry config hackedServers model) ( [], 0 )
            |> Tuple.first
            |> ul [ class [ BounceMap ] ]
            |> List.singleton


renderEntry :
    Config msg
    -> Database.HackedServers
    -> Model
    -> Network.NIP
    -> ( List (Html msg), Int )
    -> ( List (Html msg), Int )
renderEntry config hackedServers model nip ( acc, c ) =
    let
        entry_ =
            li
                [ class [ BounceMember ] ]
                (entry config hackedServers nip c model)

        acu =
            acc
                |> (::) (slot config c model)
                |> (++) (List.singleton entry_)
    in
        ( acu, c + 1 )



-- slot : Every line that unites servers on the map bounce


slot : Config msg -> Int -> Model -> Html msg
slot ({ toMsg } as config) c model =
    let
        attr selectCondition nip =
            attrSlot config selectCondition nip c

        bounceSlot selectCondition nip =
            li (attr selectCondition nip) []
    in
        case model.selection of
            Just (SelectingSlot num) ->
                bounceSlot (num == c) Nothing

            Just (SelectingEntry num) ->
                bounceSlot False Nothing

            Just (SelectingServer nip) ->
                bounceSlot False (Just nip)

            Nothing ->
                bounceSlot False Nothing



-- entry : Every node on the bounce map


entry :
    Config msg
    -> Database.HackedServers
    -> Network.NIP
    -> Int
    -> Model
    -> List (Html msg)
entry ({ toMsg, database } as config) hackedServers nip c model =
    let
        server =
            Database.getHackedServer nip hackedServers

        label_ =
            server
                |> Maybe.andThen Database.getHackedServerLabel
                |> Maybe.withDefault (Network.render nip)
                |> text

        attr selectCondition highlightCondition =
            attrEntry config selectCondition highlightCondition nip

        bounceNode selectCondition highlightCondition =
            [ span (attr selectCondition highlightCondition) [ text "● " ]
            , span [] [ label_ ]
            , renderMoveMenu config nip c model
            ]
    in
        case model.selection of
            Just (SelectingEntry nip_) ->
                bounceNode (nip_ == nip) False

            Just (SelectingSlot num) ->
                bounceNode False False

            Just (SelectingServer nip_) ->
                bounceNode False False

            Nothing ->
                bounceNode False False


renderMoveMenu : Config msg -> Network.NIP -> Int -> Model -> Html msg
renderMoveMenu { toMsg } nip pos model =
    let
        canMoveUp =
            pos < ((List.length model.path) - 1)

        canMoveDown =
            pos > 0

        moveUpBtn =
            if canMoveUp then
                button [ onClickWithStopProp <| toMsg <| MoveNode nip (pos + 1) ] [ text "/\\" ]
            else
                text ""

        moveDownBtn =
            if canMoveDown then
                button [ onClickWithStopProp <| toMsg <| MoveNode nip (pos - 1) ] [ text "\\/" ]
            else
                text ""

        removeBtn =
            button [ onClickWithStopProp <| toMsg <| RemoveNode nip ] [ text "X" ]

        buttons =
            [ moveUpBtn
            , moveDownBtn
            , removeBtn
            ]
    in
        case model.selection of
            Just (SelectingEntry nip_) ->
                if (nip_ == nip) then
                    --Hora do Show P****!!!!
                    span [ class [ MoveMenu, Show ] ] buttons
                else
                    span [ class [ MoveMenu ] ] buttons

            _ ->
                span [ class [ MoveMenu ] ] buttons


viewBouncePath : List Network.NIP -> Html msg
viewBouncePath ips =
    ips
        |> List.map (Tuple.second >> text)
        |> List.intersperse (text " > ")
        |> span []


viewBounce : Config msg -> Model -> ( Bounces.ID, Bounce ) -> Html msg
viewBounce ({ toMsg } as config) model ( id, bounce ) =
    let
        painel =
            if expanded then
                div
                    [ class [ BottomButtons ]
                    ]
                    [ horizontalBtnPanel (btnsNormal config id model) ]
            else
                text ""

        data =
            [ div
                [ class [ DataBox ] ]
                [ text ("Name: " ++ bounce.name)
                , br [] []
                , text "Path: "
                , viewBouncePath bounce.path
                , br [] []
                , painel
                ]
            ]

        expanded =
            isEntryExpanded id model

        toggleMsg =
            toMsg <| ToggleExpand id
    in
        toogableEntry True [ class [ BounceEntry ] ] toggleMsg expanded data


btnsNormal :
    Config msg
    -> Bounces.ID
    -> Model
    -> List ( Attribute msg, msg )
btnsNormal { toMsg } bounceId model =
    let
        onEditMsg =
            if model.anyChange then
                toMsg <| SetModal <| Just (ForEditWithoutSave bounceId)
            else
                toMsg <| Edit bounceId

        onDeleteMsg =
            toMsg <| Delete (Just bounceId)

        buttons =
            [ ( class [ BtnEdit, BottomButton ], onEditMsg )
            , ( class [ BtnDelete, BottomButton ], onDeleteMsg )
            ]
    in
        buttons


renderEditing : Config msg -> String -> Html msg
renderEditing { toMsg } src =
    input
        [ class [ BoxifyMe ]
        , value src
        , onInput (UpdateEditing >> toMsg)
        ]
        []


renderName :
    Config msg
    -> Bool
    -> Maybe ( Maybe Bounces.ID, Bounce )
    -> Maybe String
    -> Html msg
renderName config renaming bounceInfo bounceNameBuffer =
    case bounceInfo of
        Just ( _, bounce ) ->
            if renaming then
                bounceNameBuffer
                    |> Maybe.withDefault bounce.name
                    |> renderEditing config
            else
                bounceNameBuffer
                    |> Maybe.withDefault bounce.name
                    |> text

        Nothing ->
            text "Untitled"


renderNameButtons : Config msg -> Model -> Html msg
renderNameButtons { toMsg } model =
    let
        bounceId =
            case model.selected of
                TabManage ->
                    Nothing

                TabBuild bounceInfo ->
                    (Tuple.first bounceInfo)
    in
        if model.renaming then
            div [ class [ Buttons ] ]
                [ button
                    [ onClickWithStopProp <| toMsg ApplyNameChangings ]
                    [ text "Apply" ]
                , button
                    [ onClickWithStopProp <| toMsg ToggleNameEdit ]
                    [ text "Cancel" ]
                ]
        else
            div [ class [ Buttons ] ]
                [ button
                    [ onClickWithStopProp <| toMsg ToggleNameEdit ]
                    [ text "Edit" ]
                , button
                    [ onClickWithStopProp <| toMsg <| Delete bounceId ]
                    [ text "Delete" ]
                ]


selected : Bool -> List Classes -> List Classes
selected condition list =
    if condition then
        Selected :: list
    else
        list


highlight : Bool -> List Classes -> List Classes
highlight condition list =
    if condition then
        Highlight :: list
    else
        list


actionServer :
    Config msg
    -> Network.NIP
    -> Int
    -> List (Attribute msg)
    -> List (Attribute msg)
actionServer ({ toMsg } as config) nip pos list =
    AddNode nip pos
        |> toMsg
        |> onClickWithStopProp
        |> flip (::) list


selectServer :
    Config msg
    -> Bool
    -> Network.NIP
    -> Int
    -> List (Attribute msg)
    -> List (Attribute msg)
selectServer { toMsg } condition nip pos list =
    if condition then
        AddNode nip pos
            |> toMsg
            |> onClickWithStopProp
            |> flip (::) list
    else
        SelectServer nip
            |> toMsg
            |> onClickWithStopProp
            |> flip (::) list


actionEntry :
    Config msg
    -> Network.NIP
    -> List (Attribute msg)
    -> List (Attribute msg)
actionEntry { toMsg } nip list =
    SelectEntry nip
        |> toMsg
        |> onClickWithStopProp
        |> flip (::) list


actionSlot :
    Config msg
    -> Network.NIP
    -> Int
    -> List (Attribute msg)
    -> List (Attribute msg)
actionSlot { toMsg } nip pos list =
    AddNode nip pos
        |> toMsg
        |> onClickWithStopProp
        |> flip (::) list


selectSlot : Config msg -> Int -> List (Attribute msg) -> List (Attribute msg)
selectSlot { toMsg } pos list =
    SelectSlot pos
        |> toMsg
        |> onClickWithStopProp
        |> flip (::) list


attribute_ : Classes -> Bool -> Bool -> List (Attribute msg)
attribute_ class_ selectCondition highlightCondition =
    List.singleton class_
        |> (selected selectCondition)
        |> (highlight highlightCondition)
        |> class
        |> List.singleton


attrServer :
    Config msg
    -> Bool
    -> Bool
    -> Network.NIP
    -> Int
    -> Int
    -> List Network.NIP
    -> List (Attribute msg)
attrServer config selectCondition highlightCondition nip pos1 pos2 path =
    if List.isEmpty path then
        attribute_ HackedServer selectCondition highlightCondition
            |> actionServer config nip pos1
    else
        attribute_ HackedServer selectCondition highlightCondition
            |> selectServer config highlightCondition nip pos2


attrEntry : Config msg -> Bool -> Bool -> Network.NIP -> List (Attribute msg)
attrEntry config selectCondition highlightCondition nip =
    attribute_ BounceNode selectCondition highlightCondition
        |> actionEntry config nip


attrSlot : Config msg -> Bool -> Maybe Network.NIP -> Int -> List (Attribute msg)
attrSlot config selectCondition nip pos =
    case nip of
        Just nip ->
            attribute_ Slot selectCondition True
                |> actionSlot config nip pos

        Nothing ->
            attribute_ Slot selectCondition False
                |> selectSlot config pos
