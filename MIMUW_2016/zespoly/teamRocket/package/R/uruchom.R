#' Uruchom aplikację shiny dla konkretynych danych i wyznaczników
#' 
#' @param dane tabela zawierajaca wyniki matur i wartości
#' wyznaczników dla poszczególnych uczniów. dla każdego ucznia jest
#' też id jego szkoły, skrót nazwy gminy i nazwa szkoły (patrz ?matura.2015)
#' @param lista.wyznacznikow lista wyznaczników które mają być
#' przedstawione na wykresach. typu c("nazwa.kolumny", "opis.wyznacznika")
#' gdzie nazwa.kolumny to kolumna w tabeli dane
#' @export
uruchom <- function(dane, lista.wyznacznikow){
  shiny::shinyApp(ui = maturiser.ui,
                  server = maturiser.server(dane, lista.wyznacznikow))
}
