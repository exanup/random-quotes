module Main exposing (Author, Content, Model(..), Msg(..), Quote, Source, authorDecoder, contentDecoder, defaultQuote, getRandomQuote, init, main, quoteDecoder, quotesDecoder, sourceDecoder, subscriptions, update, view, viewAuthor, viewQuote, viewSource)

import Browser
import Html exposing (Html, blockquote, button, cite, div, footer, h1, span, text)
import Html.Attributes exposing (class, id, title)
import Html.Events exposing (onClick)
import Http
import Json.Decode as D



---- PROGRAM ----


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



---- MODEL ----


type alias Author =
    String


type alias Content =
    String


type alias Source =
    Maybe String


type alias Quote =
    { content : Content
    , author : Author
    , source : Source
    }


defaultQuote =
    Quote
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere erat a ante."
        "Someone famous"
        Nothing


type Model
    = Failure
    | Loading Quote
    | Success Quote


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading defaultQuote, getRandomQuote )



---- UPDATE ----


type Msg
    = GotQuotes (Result Http.Error (List Quote))
    | LoadNextQuote


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadNextQuote ->
            ( Loading defaultQuote, getRandomQuote )

        GotQuotes result ->
            case result of
                Ok quotes ->
                    ( Success (List.head quotes |> Maybe.withDefault defaultQuote), Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



---- VIEW ----


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "row mx-lg-3 mt-md-5 mt-sm-3 mt-1" ]
            [ div [ class "col-sm-7 text-sm-left text-center" ]
                [ h1 [ class "text-success" ]
                    [ span [ class "font-khula" ]
                        [ text "Random " ]
                    , span [ class "font-heebo" ]
                        [ text "Quotes" ]
                    ]
                ]
            , div [ class "col-sm-5 text-sm-right text-center" ]
                [ button [ onClick LoadNextQuote, class "btn btn-outline-success font-heebo font-weight-bold" ]
                    [ span [ class "d-none d-md-inline" ]
                        [ text "Get another " ]
                    , span [ class "d-md-none" ]
                        [ text "Refresh " ]
                    , span [ class "d-none d-md-inline" ]
                        [ text "awesome " ]
                    , text "quote"
                    ]
                ]
            ]
        , div [ class "row mt-md-5 mt-2" ]
            [ div [ class "col-md-2 text-center text-md-right" ]
                [ span [ class "text-success d-none d-lg-inline", id "big-quotation-mark" ]
                    [ text "“" ]
                ]
            , div [ class "col-md" ]
                [ blockquote [ class "blockquote" ]
                    [ div [ class "mb-5 text-center text-md-left", id "quote-content" ]
                        [ viewQuote model ]
                    , footer [ class "blockquote-footer text-right" ]
                        [ span []
                            [ viewAuthor model ]
                        , cite [ title "Source Title" ]
                            [ viewSource model ]
                        ]
                    ]
                ]
            , div [ class "col-md-2 text-center text-md-left" ]
                [ div [ id "tweet-container" ]
                    []
                ]
            ]
        ]


viewQuote : Model -> Html Msg
viewQuote model =
    case model of
        Failure ->
            text "(Failed fetching data!)"

        Loading quote ->
            text quote.content

        Success quote ->
            text quote.content


viewAuthor : Model -> Html Msg
viewAuthor model =
    case model of
        Failure ->
            text "Someone famous"

        Loading quote ->
            text <| " " ++ quote.author

        Success quote ->
            text <| " " ++ quote.author


viewSource : Model -> Html Msg
viewSource model =
    case model of
        Failure ->
            text ""

        Loading quote ->
            case quote.source of
                Just source ->
                    text <| " (" ++ source ++ ")"

                Nothing ->
                    text ""

        Success quote ->
            case quote.source of
                Just source ->
                    text <| " (" ++ source ++ ")"

                Nothing ->
                    text ""



-- HTTP


getRandomQuote : Cmd Msg
getRandomQuote =
    Http.get
        { url = "https://quotesondesign.com/wp-json/posts?filter[orderby]=rand&filter[posts_per_page]=1"
        , expect = Http.expectJson GotQuotes quotesDecoder
        }


quotesDecoder : D.Decoder (List Quote)
quotesDecoder =
    D.list quoteDecoder


quoteDecoder : D.Decoder Quote
quoteDecoder =
    D.map3 Quote
        contentDecoder
        authorDecoder
        sourceDecoder


authorDecoder : D.Decoder Author
authorDecoder =
    D.field "title" D.string


contentDecoder : D.Decoder Content
contentDecoder =
    D.field "content" D.string


sourceDecoder : D.Decoder Source
sourceDecoder =
    D.maybe (D.field "custom_meta" (D.field "Source" D.string))
