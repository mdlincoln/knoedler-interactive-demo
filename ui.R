
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

shinyUI(fluidPage(

  sidebarLayout(
    sidebarPanel(fluidRow(uiOutput("newdata_inputs"))),
    mainPanel(
      h2("Predicted chance of profit or loss"),
      plotOutput("prediction_probability"),
      h2("Similar types of sales"),
      tableOutput("similar_records")
    )
  )))
