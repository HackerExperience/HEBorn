module Apps.LogViewer.View exposing (view)

import Dict
import Date exposing (fromTime)
import Date.Format as DateFormat exposing (format)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Css.Common exposing (elasticClass)
import Game.Shared exposing (..)
import Game.Models exposing (GameModel)
import Game.Servers.Logs.Models as Logs exposing (..)
import Apps.LogViewer.Messages exposing (Msg(..))
import Apps.LogViewer.Models exposing (..)
import Apps.LogViewer.Menu.View exposing (menuView, menuNormalEntry, menuEditingEntry, menuFilter)
import Apps.LogViewer.Style exposing (Classes(..))


{ id, class, classList } =
    Html.CssHelpers.withNamespace "logvw"


isEntryExpanded : LogViewer -> StdData -> Bool
isEntryExpanded app log =
    List.member log.id app.expanded


isEntryEditing : LogViewer -> StdData -> Bool
isEntryEditing app log =
    Dict.member log.id app.editing


renderAddr : IP -> List (Html Msg)
renderAddr addr =
    if (isLocalHost addr) then
        [ span [ class [ IcoHome, ColorLocal ] ] []
        , text " "
        , span [ class [ IdLocal, ColorLocal ] ] [ text addr ]
        ]
    else
        [ span [ class [ IcoCrosshair, ColorRemote ] ] []
        , text " "
        , span [ class [ IdMe, ColorRemote ] ] [ text addr ]
        ]


renderUser : ServerUser -> List (Html Msg)
renderUser user =
    if (user == root) then
        [ span [ class [ IcoUser, ColorRoot ] ] []
        , text " "
        , span [ class [ IdRoot, ColorRoot ] ] [ text user ]
        ]
    else
        [ span [ class [ IcoUser ] ] []
        , text " "
        , span [] [ text user ]
        ]


renderFile : FileName -> List (Html Msg)
renderFile fileName =
    [ span [] [ text fileName ] ]


renderButton : Logs.ID -> Classes -> List (Html Msg)
renderButton logID btn =
    [ text " "
    , span
        ([ class [ btn, BottomButton ] ]
            ++ (case btn of
                    BtnEdit ->
                        [ onClick (EnterEditing logID) ]

                    BtnApply ->
                        [ onClick (ApplyEditing logID) ]

                    BtnCancel ->
                        [ onClick (LeaveEditing logID) ]

                    _ ->
                        []
               )
        )
        []
    ]


renderButtons : Logs.ID -> List Classes -> List (Html Msg)
renderButtons logID btns =
    btns
        |> List.map (renderButton logID)
        |> List.concat
        |> List.tail
        |> Maybe.withDefault []


renderFlag : Classes -> List (Html Msg)
renderFlag flag =
    [ text " "
    , span [ class [ flag ] ] []
    ]


renderFlags : List Classes -> List (Html Msg)
renderFlags =
    List.map renderFlag
        >> List.concat
        >> List.tail
        >> Maybe.withDefault []


renderMsg : SmartContent -> Html Msg
renderMsg msg =
    div [ class [ EData ] ]
        (case msg of
            LoginLocal addr user ->
                (renderAddr addr)
                    ++ [ span [] [ text " logged in as " ] ]
                    ++ (renderUser user)

            LoginRemote dest ->
                [ span [] [ text "Logged into " ] ]
                    ++ (renderAddr dest)

            Connection actor src dest ->
                (renderAddr actor)
                    ++ [ span [] [ text " bounced connection from " ] ]
                    ++ (renderAddr src)
                    ++ [ span [] [ text " to " ] ]
                    ++ (renderAddr dest)

            DownloadBy fileName destIP ->
                [ span [] [ text "File " ] ]
                    ++ (renderFile fileName)
                    ++ [ span [] [ text " downloaded by " ] ]
                    ++ renderAddr destIP

            DownloadFrom fileName srcIP ->
                [ span [] [ text "File " ] ]
                    ++ (renderFile fileName)
                    ++ [ span [] [ text " downloaded from " ] ]
                    ++ (renderAddr srcIP)

            Invalid msg ->
                [ span [] [ text "Corrupted: " ]
                , span [] [ text msg ]
                ]
        )


renderMiniMsg : SmartContent -> Html Msg
renderMiniMsg msg =
    (case msg of
        Connection actor src dest ->
            div [ class [ EData ] ]
                (renderAddr actor
                    ++ [ span [] [ text " bounced connection from " ]
                       , span [ class [ IcoCrosshair, ColorRemote ] ] []
                       , text " "
                       , span [ class [ IdMe, ColorRemote ] ] [ text src ]
                       , span [] [ text " to ..." ]
                       ]
                )

        _ ->
            renderMsg msg
    )


renderEditing : Logs.ID -> String -> Html Msg
renderEditing logID src =
    input
        [ class [ EData, BoxifyMe ]
        , value src
        , onInput (UpdateEditing logID)
        ]
        []


renderTopActions : StdData -> Html Msg
renderTopActions entry =
    div [ class [ ETActMini ] ]
        -- TODO: Catch the flags for real
        (renderFlags [ BtnUser, BtnEdit, BtnLock ])


renderBottomActions : LogViewer -> StdData -> Html Msg
renderBottomActions app entry =
    div [ class [ EAct ] ]
        (renderButtons
            entry.id
            (if (isEntryEditing app entry) then
                [ BtnApply, BtnCancel ]
             else if (isEntryExpanded app entry) then
                case entry.status of
                    StatusNormal ->
                        [ BtnLock, BtnView, BtnEdit, BtnDelete ]

                    Cryptographed ->
                        [ BtnView, BtnUnlock ]
             else
                []
            )
        )


renderEntryToggler : Logs.ID -> Html Msg
renderEntryToggler logID =
    div
        [ class [ CasedBtnExpand, EToggler ]
        , onClick (ToogleLog logID)
        ]
        []


renderData : LogViewer -> StdData -> Html Msg
renderData app entry =
    case (Dict.get entry.id app.editing) of
        Just x ->
            renderEditing entry.id x

        Nothing ->
            if (isEntryExpanded app entry) then
                renderMsg entry.smart
            else
                renderMiniMsg entry.smart


renderBottom : LogViewer -> StdData -> Html Msg
renderBottom app entry =
    if (isEntryEditing app entry) then
        div
            [ class [ EBottom ] ]
            [ renderBottomActions app entry ]
    else if (isEntryExpanded app entry) then
        div
            [ class [ EBottom, EntryExpanded ] ]
            [ renderBottomActions app entry
            , renderEntryToggler entry.id
            ]
    else
        div
            [ class [ EBottom ] ]
            [ div [ class [ EAct ] ] []
            , renderEntryToggler entry.id
            ]


menuInclude : LogViewer -> StdData -> List (Attribute Msg)
menuInclude app entry =
    if (isEntryEditing app entry) then
        [ menuEditingEntry entry.id ]
    else
        case entry.status of
            StatusNormal ->
                [ menuNormalEntry entry.id ]

            _ ->
                []


getLogDateString : StdData -> String
getLogDateString log =
    DateFormat.format
        "%d/%m/%Y - %H:%M:%S"
        (Date.fromTime log.timestamp)


renderEntry : LogViewer -> StdData -> Html Msg
renderEntry app entry =
    div
        ([ class
            (if (isEntryExpanded app entry) then
                [ Entry, EntryExpanded ]
             else
                [ Entry ]
            )
         ]
            ++ (menuInclude app entry)
        )
        ([ div [ class [ ETop ] ]
            [ div [] [ entry |> getLogDateString |> text ]
            , div [ elasticClass ] []
            , renderTopActions entry
            ]
         , renderData app entry
         , renderBottom app entry
         ]
        )


renderEntryList : LogViewer -> List StdData -> List (Html Msg)
renderEntryList app =
    List.map (renderEntry app)


view : GameModel -> Model -> Html Msg
view game ({ app } as model) =
    div [ menuFilter ]
        ([ menuView model
         , div [ class [ HeaderBar ] ]
            [ div [ class [ ETAct ] ]
                [ span [ class [ BtnUser ] ] []
                , text " "
                , span [ class [ BtnEdit ] ] []
                , text " "
                , span [ class [ BtnView ] ] []
                ]
            , div [ class [ ETFilter ] ]
                [ div [ class [ BtnFilter ] ] []
                , div [ class [ ETFBar ] ]
                    [ input
                        [ placeholder "Search..."
                        , value app.filtering
                        , onInput UpdateFilter
                        ]
                        []
                    ]
                ]
            ]
         ]
            ++ (getLogs app game.servers
                    |> applyFilter app
                    |> renderEntryList app
               )
        )
