module Apps.Browser.Pages.Models
    exposing
        ( Model(..)
        , initialModel
        , getSite
        , getUrl
        , getTitle
        )

import Game.Web.Types as Web
import Apps.Browser.Pages.NotFound.Models as PageNotFound
import Apps.Browser.Pages.Default.Models as PageDefault


type Model
    = BlankModel
    | NotFoundModel PageNotFound.Model
    | UnknownModel
    | HomeModel
    | CustomModel
    | DefaultModel PageDefault.Model
    | ProfileModel
    | DirectoryModel
    | DownloadCenterModel
    | ISPModel
    | BankModel
    | StoreModel
    | BTCModel
    | FBIModel
    | NewsModel
    | BithubModel


type alias Meta =
    { url : String, title : String }


initialModel : Web.Site -> Model
initialModel ({ type_, meta } as site) =
    case ( type_, meta ) of
        ( Web.Blank, _ ) ->
            BlankModel

        ( Web.Unknown, _ ) ->
            UnknownModel

        ( Web.NotFound, _ ) ->
            site
                |> PageNotFound.initialModel
                |> NotFoundModel

        ( Web.Default, Just (Web.DefaultMeta meta) ) ->
            site
                |> PageDefault.initialModel
                |> DefaultModel

        _ ->
            UnknownModel


getTitle : Model -> String
getTitle model =
    case model of
        NotFoundModel model ->
            PageNotFound.getTitle model

        UnknownModel ->
            "Loading..."

        _ ->
            "New Tab"


getUrl : Model -> String
getUrl model =
    let
        site =
            getSite model
    in
        site.url


getSite : Model -> Web.Site
getSite model =
    case model of
        NotFoundModel model ->
            PageNotFound.getSite model

        BlankModel ->
            { type_ = Web.Blank
            , url = "about:blank"
            , meta = Nothing
            }

        _ ->
            { type_ = Web.Unknown
            , url = ""
            , meta = Nothing
            }
