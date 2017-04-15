module Router.Router exposing (Route(..), parseLocation)

import Navigation exposing (Location)
import UrlParser exposing (Parser, parseHash, oneOf, map, top, s)


type Route
    = RouteHome
    | RouteNotFound


route : Parser (Route -> a) a
route =
    oneOf
        [ map RouteHome top
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash route location) of
        Just route ->
            route

        Nothing ->
            RouteNotFound
