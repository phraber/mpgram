
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
aln.types <- c('aa', 'nt', 'codon') # for friendly radio buttons

xform.types <- c(0:3)

names(xform.types) <- c('None', 
                        'Changes from master sequence', 
                        'Mutations from master sequence', 
                        'Charge changes from master sequence')

names(aln.types) <- c("Amino acids", "Nucleotides", "Codons")

shinyUI(fluidPage(

  # Application title
  titlePanel("Pixgram Maker"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
        fileInput("alnFile", "Alignment File"),
        radioButtons("alnType", "Alignment Type", aln.types),
        fileInput("treFile", "Tree File"),
        checkboxInput("createTree", "Create NJ tree from nucleotide sequences", value=F),
        checkboxInput("labelTips", "Show Tree Tip Labels", value=T),
        radioButtons("xformType", "Transformation Type", xform.types),
        checkboxInput("xformMaster", "Transform Master Sequence", value=F),
        sliderInput("pixelWidth",
                    "Proportionate Width of Pixel View, %",
                    min = 25,
                    max = 425,
                    value = 100),
        submitButton("Update View")
    ),
    # Show results
    mainPanel(
      plotOutput("myPixgramPlot")
    )
  )
))
