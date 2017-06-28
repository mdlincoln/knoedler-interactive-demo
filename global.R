library(shiny)
library(tidyverse)
library(forcats)
library(randomForest)
library(GPIdata)
library(DT)


kmodel <- readRDS("kmodel.rds")
modelimp <- kmodel$rf$importance[,4]
kexemplar <- readRDS("k_exemplar.rds")

kmatrix <- data.matrix(kmodel$train_data)
