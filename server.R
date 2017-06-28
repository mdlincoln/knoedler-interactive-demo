
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(ggplot2)
library(dplyr)
library(purrr)
library(forcats)
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
    initial_df <- data.frame(
      genre = input$genre,
      is_firsttime_seller = input$is_firsttime_seller,
      is_major_seller = input$is_major_seller,
      is_firsttime_buyer = input$is_firsttime_buyer,
      is_major_buyer = input$is_major_buyer,
      is_old_master = input$is_old_master,
      deflated_purch_amount = input$deflated_purch_amount,
      is_jointly_owned = input$is_jointly_owned,
      buyer_type = input$buyer_type,
      seller_type = input$seller_type,
      owner_shared_nationality = input$owner_shared_nationality,
      seller_artist_shared_nationality = input$seller_artist_shared_nationality,
      buyer_artist_shared_nationality = input$buyer_artist_shared_nationality,
      artist_is_alive = input$artist_is_alive,
      time_in_stock = input$time_in_stock
    )

    refactored_df <- map2_df(initial_df, kmodel$train_data, function(x, y) {
      if (is.factor(y)) {
        fct_expand(x, levels(y))
      } else {
        x
      }
    })

    refactored_df
  })

  prediction_res <- reactive({
    str(create_newdata())
    predict(kmodel$rf, newdata = create_newdata(), type = "prob")
  })

  output$prediction_probability <- renderText({
    prediction_res()
  })

})
