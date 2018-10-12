port module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as D
import Json.Encode as E
import Page.Home as Home
import Page.Inner as Inner
import Url
import Url.Parser as Parser exposing ((</>), s)


-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }



-- MODEL


type Page
    = Home Home.Model
    | Inner Inner.Model
    | NotFound


type alias Model =
    { key : Nav.Key, page : Page }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    route url { key = key, page = NotFound }



-- UPDATE


type Msg
    = HomeMsg Home.Msg
    | InnerMsg Inner.Msg
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        HomeMsg msg_ ->
            case model.page of
                Home model_ ->
                    routeHome model (Home.update msg_ model_)

                _ ->
                    ( model, Cmd.none )

        InnerMsg msg_ ->
            case model.page of
                Inner model_ ->
                    routeInner model (Inner.update msg_ model_)

                _ ->
                    ( model, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            route url model



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        Inner model_ ->
            Sub.map InnerMsg <| Inner.subscriptions model_

        _ ->
            Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    case model.page of
        Home model_ ->
            { title = "Home"
            , body = [ Html.map HomeMsg <| Home.view model_ ]
            }

        Inner model_ ->
            { title = "Inner"
            , body = [ Html.map InnerMsg <| Inner.view model_ ]
            }

        NotFound ->
            { title = "Not Found", body = [ div [] [] ] }



-- ROUTER


route : Url.Url -> Model -> ( Model, Cmd Msg )
route url model =
    let
        parser =
            Parser.oneOf
                [ Parser.map (routeHome model Home.init) Parser.top
                , Parser.map (routeInner model Inner.init) (s "inner")
                ]
    in
        case Parser.parse parser url of
            Just action ->
                action

            Nothing ->
                ( { model | page = NotFound }, Cmd.none )


routeHome : Model -> ( Home.Model, Cmd Home.Msg ) -> ( Model, Cmd Msg )
routeHome model ( model_, cmds ) =
    ( { model | page = Home model_ }, Cmd.map HomeMsg cmds )


routeInner : Model -> ( Inner.Model, Cmd Inner.Msg ) -> ( Model, Cmd Msg )
routeInner model ( model_, cmds ) =
    ( { model | page = Inner model_ }, Cmd.map InnerMsg cmds )
