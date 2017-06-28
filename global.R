library(shiny)
library(ggplot2)
library(dplyr)
library(purrr)
library(forcats)
library(randomForest)
library(GPIdata)
library(DT)


kmodel <- readRDS("kmodel.rds")

kmatrix <- data.matrix(kmodel$train_data)
