module Game.Shared exposing (..)


type alias IP =
    -- REVIEW: Wouldn't it be better to call it ServerAddr or NetAddr or HostAddr?
    String


type alias ID =
    String


type alias ServerUser =
    String


localhost : IP
localhost =
    "localhost"


root : ServerUser
root =
    "root"
