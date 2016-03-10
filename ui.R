library(shiny)

aln.type <- c('aa', 'nt', 'codon') # for friendly radio buttons
names(aln.type) <- c("Amino acids", "Nucleotides", "Codons")

aln.formats <- c(1:5)
names(aln.formats) <- c("fasta", "clustal", "phylip", "msf", "mase")

xform.types <- c(0:3)
names(xform.types) <- c('None', 
                        'Changes from master sequence', 
                        'Mutations from master sequence', 
                        'Charge changes from master sequence')

outfile.layouts <- c("landscape", "portrait", "square")
outfile.types <- c("pdf", "eps", "png") #"svg"

shinyUI(

    fluidPage(

        #includeCSS("hiv-de.css"),

        tags$head(
        #    tags$link(rel="stylesheet", type="text/css", href="hiv-de.css")
        ),

        titlePanel("PixelGram: Pairs a Pixel plot of your alignment with a tree drawn as phyloGram, one row per sequence"),

#   tabsetPanel(type="tabs", id="tabets", 
#       tabPanel("Options",

        fluidRow(
            column(width=4, tags$div(class="paramtablehead", 'Alignment'),
                tags$table(class="paramtable", 
                    tags$tr(
                        tags$td(

                            fileInput("alnFile", "Alignment File"),

                            radioButtons("alnType", "Sequence Type", aln.type),

                            radioButtons("alnFormat", "Alignment Format", 
                                aln.formats, inline=T),

                            conditionalPanel("input.alnType != 'nt'",
                                checkboxInput("pngs2o", 
                                    "Map PNG asparagines to 'O' ", 
                                    value=T)
                            )
                        )
                    )
                )
            ), # end of column

            column(width=4, tags$div(class="paramtablehead", 'Phylogeny'),
                tags$table(class="paramtable", 
                    tags$tr(
                        tags$td(

                            fileInput("treFile", "Newick-Formatted Tree File"),

                            conditionalPanel("input.alnType=='codon'",
                                checkboxInput("createTree", 
                                    "Build NJ tree from codon alignment", 
                                    value=F)
                            ),

                            checkboxInput("hideTree", "Hide Tree", value=F),

                            conditionalPanel("input.hideTree==false",
                                checkboxInput("labelTips", 
                                    "Show Tree Tip Labels", value=T)),

                            conditionalPanel("input.labelTips==true && input.hideTree==false",
				numericInput("pointSize",
                                        "Point Size",
                                        min = 0,
                                        max = 48,
                                        value = 12, width="25%")),

                            sliderInput("pixelWidth",
                                        "Proportionate Width of Pixel View, %",
                                        min = 10,
                                        max = 400,
                                        value = 100)
                        ) # </td>
                    ) # </tr>
                ) # end of table
            ), # end of column

            column(width=4,

                tags$div(class="paramtablehead", 'Output'),
                    tags$table(class="paramtable", 
                        tags$tr(
                            tags$td(

                                radioButtons("xformType", 
                                    "Transformation Type", xform.types),

                                conditionalPanel("input.xformType > 0",
                                    checkboxInput("xformMaster", 
                                        "Transform Master Sequence", value=F)
                                ),

                                radioButtons("outfileLayout", 
                                    "Layout in Download File", 
                                    outfile.layouts, inline=T),

                                radioButtons("outfileFormat", 
                                    "Download File Format", 
                                    outfile.types, inline=T),

                                downloadButton('downloadFile', 'Download')
                        ) #</td>
                    ) # </tr>
                ) # end of table
            ) # end of column
        ), # end of row

#tabPanel("Advanced",
#),
        fluidRow( 
            column(width=12, # hr(),
                tags$div(class="paramtablehead", 'Result'),
                plotOutput("myPixgramPlot", width="100%", height=800)
            )
        )
    )
)
