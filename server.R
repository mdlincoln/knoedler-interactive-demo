
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(ggplot2)
library(dplyr)
library(purrr)
library(randomForest)

shinyServer(function(input, output) {

  factor_input <- function(df, cname) {
    selectInput(cname, label = cname, choices = as.character(unique(df[[cname]])))
  }

  numeric_input <- function(df, cname) {
    sliderInput(cname, label = cname, min = min(df[[cname]]), max = max(df[[cname]]), value = median(df[[cname]]))
  }

  output$newdata_inputs <- renderUI({
    vartypes <- map(kmodel$train_data, class)

    map2(vartypes, names(vartypes), function(x, y) {
      input_function <- switch(x,
                             "factor" = factor_input,
                             "numeric" = numeric_input)
      input_function(kmodel$train_data, y)
    })
  })

  create_newdata <- reactive({
    data.frame(

    )
  })

  prediction_res <- reactive({

  })

})
