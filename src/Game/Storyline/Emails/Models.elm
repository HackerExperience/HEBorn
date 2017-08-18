module Game.Storyline.Emails.Models exposing (..)


type alias ID =
    String


type alias Contact =
    {}


type alias Contacts =
    Dict Email Contact


initialModel : Model
initialModel =
    []
