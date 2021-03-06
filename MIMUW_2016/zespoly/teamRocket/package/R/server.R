#library(ggplot2)
#library(shiny)
#library(dplyr)

pobierz.nazwy.gmin <- function(ramka) {
  sort(ramka$gmina_szkoly)
}

pobierz.szkoly <- function(ramka) {
  ramka %>% dplyr::select(id_szkoly, nazwa_szkoly, gmina_szkoly) %>%
    dplyr::distinct(id_szkoly) %>% dplyr::arrange(nazwa_szkoly)
}

szkoly.z.gminy <- function(lista.szkol, gmina) {
      sort(dplyr::filter(lista.szkol, gmina_szkoly == gmina)$nazwa_szkoly)
 }

pobierz.id.szkoly <- function(lista.szkol, szkola) {
  wiersz <- lista.szkol %>% dplyr::filter(nazwa_szkoly == szkola) %>% utils::head(1)
  wiersz$id_szkoly
}

pobierz.opisy.wyznacznikow <- function(wyznaczniki) {
  opisy <- c()
  for (w in wyznaczniki)
    opisy <- c(opisy, w[[2]])
  opisy
}

pobierz.wyznacznik <- function(wyznaczniki, opis) {
  for (w in wyznaczniki)
    if (w[[2]] == opis)
      return(w[[1]])
}

#'Serwer aplikacji shiny
#'@param matury tabela zawierająca wyniki matur i wyliczonych wyznaczników
#'@param wyznaczniki lista par postaci ("nazwa_kolumny", "opis_wyznacznika")
#'Wymienione wyznaczniki zostaną przedstawione w aplikacji
maturiser.server <- function(matury, wyznaczniki) {
  # Dzięki temu zabiegowi dane te będą dla serwera "stałymi globalnymi"
  ilosc.wyznacznikow <- length(wyznaczniki)
  gminy <- pobierz.nazwy.gmin(matury)
  szkoly <- pobierz.szkoly(matury)
  opisy.wyznacznikow <- pobierz.opisy.wyznacznikow(wyznaczniki)
  
  shiny::shinyServer(function(input, output) {

    output$gmina <- shiny::renderUI({
      shiny::selectInput(inputId = "gmina",
                  label = "Wybierz gminę",
                  choices = gminy)
    })
   
    output$szkola <- shiny::renderUI({
      szk.gm <- szkoly.z.gminy(szkoly, input$gmina)
      shiny::selectInput(inputId = "szkola", 
                  label = "Wybierz szkołę",
                  choices = szk.gm)
    })
    
    output$wyznacznik <- shiny::renderUI({
        shiny::selectInput(inputId = "wyznacznik", 
                  label = "Wybierz wyznacznik",
                  choices = opisy.wyznacznikow,
                  width = "100%")
                  #selected = dplyr::first(opisy.wyznacznikow))
    })
    
    output$wykres <- shiny::renderPlot(
      if (is.null(input$szkola) | input$szkola != "")
        generuj.wykres(matury,
                     pobierz.wyznacznik(wyznaczniki, input$wyznacznik),
                     pobierz.id.szkoly(matury, input$szkola),
                     input$wyznacznik)
    )
    
    output$instrukcja <- shiny::renderText(
      if (is.null(input$szkola) | input$szkola == "")
        '<p style="color:green; font-size:16px;">Obsługa aplikacji jest niezwykle prosta!</p><br/><p style="color:green; font-size:16px;">W panelu bocznym wybierz <b>gminę</b> oraz interesującą Cię <b>szkołę</b>. Następnie wybierz <b>wyznacznik</b> - kryterium, ze względu na które chcesz porównać wyniki maturalne uczniów wybranej placówki. Możliwe jest filtrowanie gmin/szkół/wyznaczników poprzez wpisywanie części nazw w polach wyboru.</p><br/><p style="color:green; font-size:16px;">Przed Twoimi oczami ukaże się piękny histogram - wykres przedstawiający liczbę uczniów, dla których wyznacznik ma wartość przedstawioną na osi x.</p>'
    )
  })
}
