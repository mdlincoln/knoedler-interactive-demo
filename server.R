
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

shinyServer(function(input, output) {

  factor_input <- function(df, cname) {
    selectInput(cname, label = cname, choices = as.character(unique(df[[cname]])))
  }

  numeric_input <- function(df, cname) {
    sliderInput(cname, label = cname, min = 0, max = quantile(df[[cname]], 0.90), value = median(df[[cname]]))
  }

  output$newdata_inputs <- renderUI({
    vartypes <- kmodel$train_data %>%
      select(genre, deflated_purch_amount, time_in_stock, buyer_type, is_old_master) %>%
      map_chr(class)

    map2(vartypes, names(vartypes), function(x, y) {
      input_function <- switch(x,
                             "factor" = factor_input,
                             "numeric" = numeric_input)
      input_function(kmodel$train_data, y)
    })
  })

  create_newdata <- reactive({
    # fct_mode <- function(f) {
    #   as.character(fct_count(f, sort = TRUE)[[1]][1])
    # }

    initial_df <- data.frame(
      genre = input$genre,
      is_firsttime_seller = first(kmodel$train_data$is_firsttime_seller),
      is_major_seller = first(kmodel$train_data$is_major_seller),
      is_firsttime_buyer = first(kmodel$train_data$is_firsttime_buyer),
      is_major_buyer = first(kmodel$train_data$is_major_buyer),
      is_old_master = input$is_old_master,
      deflated_purch_amount = input$deflated_purch_amount,
      is_jointly_owned = first(kmodel$train_data$is_jointly_owned),
      buyer_type = input$buyer_type,
      seller_type = first(kmodel$train_data$seller_type),
      owner_shared_nationality = first(kmodel$train_data$owner_shared_nationality),
      seller_artist_shared_nationality = first(kmodel$train_data$seller_artist_shared_nationality),
      buyer_artist_shared_nationality = first(kmodel$train_data$buyer_artist_shared_nationality),
      artist_is_alive = first(kmodel$train_data$artist_is_alive),
      time_in_stock = input$time_in_stock
    )

    str(initial_df)

    refactored_df <- map2_df(initial_df, kmodel$train_data, function(x, y) {
      if (is.factor(y)) {
        factor(x, levels = levels(y))
      } else {
        x
      }
    })

    refactored_df
  })

  prediction_res <- reactive({
    predict(kmodel$rf, newdata = create_newdata(), type = "prob")
  })

  output$prediction_probability <- renderPlot({
    prediction_res() %>%
      as.data.frame() %>%
      gather(prediction, probability, gain:loss) %>%
      ggplot(aes(x = prediction, y = probability, fill = prediction)) +
      scale_fill_manual(values = c("gain" = "green", "loss" = "red")) +
      geom_bar(stat = "identity") +
      geom_hline(yintercept = 0.5, linetype = 2) +
      geom_text(aes(label = probability), vjust = -1) +
      ylim(0, 1) +
      theme(legend.position = "none")
  })

   distances <- reactive({
    ref_vec <- log(as.vector(data.matrix(create_newdata()))) * modelimp
    ref_distances <- apply(log(kmatrix), 1, function(k) sqrt(sum(k * modelimp - ref_vec)^2))
    joined_data <- kmodel$train_data %>%
      mutate(
        distances = ref_distances,
        ids = row_number()) %>%
      arrange(distances) %>%
      slice(1:5)

    kexemplar %>%
      slice(joined_data$ids) %>%
      select(knoedler_number, artist, purch_amount, purch_currency, seller, buyer, sale_year, profit_percent)
  })

  output$similar_records <- renderTable({
    distances()
  })

  output$hypothetical_description <- renderText({
    paste0(
      "A ", input$genre, " painting, originally purcahsed for ", input$deflated_purch_amount, " US dollars (in 1900 terms) and sold to a ", input$buyer_type, " ", input$time_in_stock, " days after coming into Knoedler's stock.")
  })

})
