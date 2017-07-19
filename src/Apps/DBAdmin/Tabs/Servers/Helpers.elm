module Apps.DBAdmin.Tabs.Servers.Helpers exposing (..)

import Dict exposing (Dict)
import Game.Account.Database.Models exposing (..)
import Game.Network.Types as Network exposing (NIP)
import Apps.DBAdmin.Models exposing (..)


catchDataWhenFiltering : List String -> HackedServer -> Maybe HackedServer
catchDataWhenFiltering filterCache item =
    if (List.member (Network.toString item.nip) filterCache) then
        Just item
    else
        Nothing


applyFilter : DBAdmin -> List HackedServer -> List HackedServer
applyFilter app itens =
    if ((String.length app.servers.filterText) > 0) then
        List.filterMap
            (catchDataWhenFiltering app.servers.filterCache)
            itens
    else
        itens


toggleExpand : String -> DBAdmin -> DBAdmin
toggleExpand itemId app =
    let
        servers =
            app.servers

        servers_ =
            { servers
                | expanded =
                    if (isEntryExpanded app itemId) then
                        List.filter ((/=) itemId) servers.expanded
                    else
                        itemId :: servers.expanded
            }
    in
        { app | servers = servers_ }


enterEditing : String -> Database -> DBAdmin -> DBAdmin
enterEditing itemId database app =
    let
        items =
            database.servers

        item =
            items
                |> List.filter ((.nip) >> Tuple.second >> ((==) itemId))
                |> List.head

        app_ =
            item
                |> Maybe.map
                    (\item ->
                        let
                            edit_ =
                                EditingTexts ( item.nick, Maybe.withDefault "" item.notes )
                        in
                            updateEditing (Network.toString item.nip) edit_ app
                    )
    in
        Maybe.withDefault app app_


enterSelectingVirus : String -> Database -> DBAdmin -> DBAdmin
enterSelectingVirus itemId database app =
    let
        items =
            database.servers

        item =
            items
                |> List.filter ((.nip) >> Tuple.second >> ((==) itemId))
                |> List.head

        app_ =
            item
                |> Maybe.map
                    (\item ->
                        let
                            edit_ =
                                item.activeVirus
                                    |> Maybe.map Tuple.first
                                    |> SelectingVirus
                        in
                            updateEditing (Network.toString item.nip) edit_ app
                    )
    in
        Maybe.withDefault app app_


updateEditing : String -> EditingServers -> DBAdmin -> DBAdmin
updateEditing itemId value app =
    let
        editing_ =
            Dict.insert itemId value app.serversEditing
    in
        { app | serversEditing = editing_ }


updateSelectingVirus : String -> String -> DBAdmin -> DBAdmin
updateSelectingVirus virusId itemId app =
    let
        edit_ =
            SelectingVirus (Just virusId)
    in
        updateEditing itemId edit_ app


leaveEditing : String -> DBAdmin -> DBAdmin
leaveEditing itemId app =
    let
        editing_ =
            Dict.filter (\k _ -> k /= itemId) app.serversEditing
    in
        { app | serversEditing = editing_ }


updateTextFilter : String -> Database -> DBAdmin -> DBAdmin
updateTextFilter newFilter database app =
    let
        filterMapFunc item =
            let
                has =
                    [ Tuple.second item.nip
                    , item.password
                    , item.nick
                    , Maybe.withDefault "" item.notes
                    ]
                        |> List.filter (String.contains newFilter)
                        |> List.isEmpty
                        |> not
            in
                if has then
                    Just (Network.toString item.nip)
                else
                    Nothing

        newFilterCache =
            List.filterMap filterMapFunc database.servers

        servers =
            app.servers

        servers_ =
            { servers
                | filterText = newFilter
                , filterCache = newFilterCache
            }
    in
        { app | servers = servers_ }
