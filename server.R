library(shiny)
require(pixelgram)

shinyServer(function(input, output, session) {

    pg <- pixelgram::pixelgram()

    updateAln <- reactive({

        aln.formats <- c("fasta", "clustal", "phylip", "msf", "mase")

        validate(
	    need(
(input$alnFormat==1 & grepl("fas|fst", input$alnFile$name, ignore.case=T)) | 
(input$alnFormat==2 & grepl("cl", input$alnFile$name, ignore.case=T)) | 
(input$alnFormat==3 & grepl("phy", input$alnFile$name, ignore.case=T)) | 
(input$alnFormat==4 & grepl("msf", input$alnFile$name, ignore.case=T)) | 
(input$alnFormat==5 & grepl("mas", input$alnFile$name, ignore.case=T)),
        paste0("Sorry but your alignment file name must contain '", 
            aln.formats[as.numeric(input$alnFormat)], 
#            input$alnFormat, 
	    "' to ensure it is formatted as you intend."))
    )

        pixelgram::set.aln.file(pg, 
	    input$alnFile$datapath, 
	    input$alnType,
            aln.formats[as.numeric(input$alnFormat)], 
	    input$pngs2o)
    })

    updateTre <- reactive({
        validate(
            need(input$alnFile$datapath, 
                 "Please specify an alignment file."),
            need(c(input$treFile$datapath, 
                   (input$createTree & input$alnType=="codon")),
                 "Please specify a tree file or 'Build NJ tree from codon alignment'."),
            need(is.numeric(input$pointSize), 
                 "Please specify a numeric point size."),
            need(input$pointSize > 0, 
                 "Please specify a positive point size.")
	)

#        if (!is.null(input$treFile$datapath))
            pixelgram::set.tre.file(updateAln(), input$treFile$datapath)
#        else return (pg)
    })

    output$myPixgramPlot <- renderPlot({

        # unset the checkbox if any conditions are true:
        if (input$createTree & 
            (!is.null(input$treFile$datapath) | input$alnType == 'aa'))
            updateCheckboxInput(session, input$createTree, value=F)

#    if (input$tippch)
#        tippch.parser <- pixelgram::create.timepoint.parser(input$tipcol.delimType, input$tipcol.fieldNumb)

#    if (input$tipcol)
#        tippch.parser <- pixelgram::create.timepoint.parser(input$tippch.delimType, input$tippch.fieldNumb)

#        pg <- updateAln()
        pg <- updateTre()

        par(mar=c(0,0,0,0), oma=c(0,0,0,0), cex=input$pointSize/12)

        plot(pg, #updateAln(updateTre()), 
            xform_type = input$xformType,
            show_tree = !input$hideTree,
            xform_master = input$xformMaster,
            show_tip_label = input$labelTips,
            raster_width = input$pixelWidth/100)
    })

    output$downloadFile <- downloadHandler(

        filename = function() {
            paste0("pixelgram-", gsub(" ", "_", Sys.Date()), "-",
                   input$outfileLayout, ".", input$outfileFormat) },

        content = function(file) {

            owd <- setwd(tempdir())
            on.exit(setwd(owd))
            tmpfile <- tempfile()#fileext=input$outfileFormat)
            cat ( "\n", tmpfile, "\n", "i am", system("whoami"), "\n")

            if (input$outfileFormat == "png") {

                my.width = 8
		my.height = 8

		if (input$outfileLayout == "landscape")
		    my.width=10.5
	        else if (input$outfileLayout == "portrait")
		    my.height=10.5

                png(file=tmpfile, width=my.width*72, height=my.height*72, 
		    pointsize=input$pointSize)

            } else if (input$outfileFormat == "svg") {

                my.width = 8
                my.height = 8

                if (input$outfileLayout == "landscape")
		    my.width=10.5
	        else if (input$outfileLayout == "portrait")
		    my.height=10.5

                svg(file=tmpfile, width=my.width, height=my.height, onefile=T,
		    pointsize=input$pointSize)

            } else if (input$outfileFormat == "eps") {

                switch(input$outfileLayout,
                    landscape = ps.options("paper"="us", "horizontal"=T,
                        "title"=tmpfile, "height"=8.5, "width"=11),
                    portrait = ps.options("paper"="us", "horizontal"=F,
                        "title"=tmpfile, "height"=11, "width"=8.5),
                    square = ps.options("paper"="special", 
                        "title"=tmpfile, "height"=8, "width"=8))

#		contentType = "application/postscript"

                postscript(file=tmpfile)

            } else if (input$outfileFormat == "pdf") {

                switch(input$outfileLayout,
                    landscape = pdf.options("compress"=F, "paper"="USr", 
                        "title"=tmpfile, "height"=8.5, "width"=11, 
			"useDingbats"=F, "pointsize"=input$pointSize),
                    portrait = pdf.options("compress"=F, "paper"="US", 
                        "title"=tmpfile, "height"=11, "width"=8.5, 
			"useDingbats"=F, "pointsize"=input$pointSize),
                    square = pdf.options("compress"=F, "paper"="special", 
                        "title"=tmpfile, "height"=8, "width"=8, 
			"useDingbats"=F, "pointsize"=input$pointSize))

#		contentType = "application/pdf"
		pdf(file=tmpfile)

            } else { stop("ERROR: Unrecognized output file format") }

            par(mar=c(0,0,0,0), oma=c(0,0,0,0))

            plot(updateTre(),
		xform_type = input$xformType, 
		show_tree = !input$hideTree, 
		xform_master = input$xformMaster,
		show_tip_label = input$labelTips, 
		raster_width = input$pixelWidth/100)

            dev.off()

        file.rename(tmpfile, file)
    } #,

# does this add filename suffixes?
#    contentType = ifelse(input$outfileFormat == "pdf", 
#        "application/pdf", 
#	ifelse(input$outfileFormat == "eps", 
#            "application/postscript",
#            ifelse(input$outfileFormat == "png",
#		"image/png",
#		"image/svg+xml")))

#    if (input$outfileFormat == "pdf") {
#        contentType = "application/pdf"
#    } else if (input$outfileFormat == "eps") {
#        contentType = "application/postscript" }
#    else if (input$outfileFormat == "png") {
#        contentType = "image/png" }
#    else if (input$outfileFormat == "svg") {
#        contentType = "image/svg+xml"
#    }
)})
