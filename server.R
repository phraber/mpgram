library(shiny)
require(pixgramr)

shinyServer(function(input, output, session) {

    pg <- pixgramr::pixgram()
    # disable the checkbox if any conditions are true:

    output$myPixgramPlot <- renderPlot({

        if (!is.null(input$treFile$datapath) | input$alnType == 'aa')
            updateCheckboxInput(session, input$createTree, value=F)

        if (is.null(pg$aas) & is.null(pg$nts) & !is.null(input$alnFile$datapath))
            pg <- pixgramr::set.aln.file(pg, input$alnFile$datapath, input$alnType)

        if (is.null(pg$tre) & !is.null(input$treFile$datapath))
            pg <- pixgramr::set.tre.file(pg, input$treFile$datapath)

        if ((!is.null(pg$aas) | !is.null(pg$nts)) & 
            (!is.null(pg$tre) | input$createTree))

            par(mar=c(0,0,0,0), oma=c(0,0,0,0))

            pg <- plot(pg, xform_type=input$xformType, 
                       xform_master=input$xformMaster,
                       show_tip_label=input$labelTips,
                       raster_width=input$pixelWidth/100)
    })
})
