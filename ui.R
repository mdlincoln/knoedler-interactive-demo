
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

shinyUI(fluidPage(
  titlePanel("What would Knoedler do?"),
  sidebarLayout(
    sidebarPanel(
      p("Create a hypothetical transaction by tweaking these settings"),
      fluidRow(uiOutput("newdata_inputs"))
    ),
    mainPanel(
      textOutput("hypothetical_description"),
      h2("Predicted chance of profit or loss"),
      plotOutput("prediction_probability"),
      h2("Similar sales from the actual stockbooks"),
      tableOutput("similar_records")
    )
  )))
