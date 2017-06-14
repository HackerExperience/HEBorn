module Driver.Websocket.Channels exposing (Channel(..), getAddress)


type Channel
    = AccountChannel
    | RequestsChannel
    | ServerChannel


getAddress : Channel -> Maybe String -> String
getAddress channel topic =
    -- this function doesn't feel right, but it works
    let
        head =
            getAddressHead channel
    in
        case topic of
            Just topic ->
                -- we could add a check here to avoid
                -- adding context to heads ending with `:`
                head ++ topic

            Nothing ->
                head



-- internals


getAddressHead : Channel -> String
getAddressHead channel =
    case channel of
        AccountChannel ->
            "account:"

        ServerChannel ->
            "server:"

        RequestsChannel ->
            "requests"
