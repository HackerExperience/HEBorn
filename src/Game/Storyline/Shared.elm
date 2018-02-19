module Game.Storyline.Shared exposing (..)


type alias PastEmails =
    Dict Time PastEmail


type PastEmail
    = FromContact Reply
    | FromPlayer Reply


type Reply
    = AboutThat
    | BackThanks
    | DLaydMuch1
    | DlaydMuch2
    | DlaydMuch3
    | DlaydMuch4
    | DownloadCracker1 SomeIP
    | Downloaded
    | HellYeah
    | NastyVirus1
    | NastyVirus2
    | NastyVirus3
    | NastyVirus4
    | NastyVirus5
    | Noice
    | NothingNow
    | Punks1
    | Punks2
    | Punks3 SomeIP
    | WatchIADoing
    | Welcome
    | YeahRight


type alias SomeIP =
    String


type Objective
    = DownloadCracker
    | VirusInquiry
    | CleanUp
    | Grandmadness


type Step
    = Tutorial_SetupPC
    | Tutorial_DownloadCracker


type Quest
    = Tutorial


type alias About =
    { nick : String
    , picture : String
    }
