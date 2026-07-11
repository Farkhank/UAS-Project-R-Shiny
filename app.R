  # --- LOGIKA PLOT DINAMIS ---
  output$dynamic_plots <- renderUI({
    req(input$var_x)
    plot_output_list <- lapply(seq_along(input$var_x), function(i) {
      plotname <- paste0("plot_", i)
      box(title = paste("Pengaruh Faktor:", input$var_x[i]),
          status = "info", solidHeader = TRUE, width = 6,
          plotOutput(plotname, height = 350))
    })
    do.call(tagList, plot_output_list)
  })
  observe({
    req(input$var_x)
    for (i in seq_along(input$var_x)) {
      local({
        my_i <- i
        plotname <- paste0("plot_", my_i)
        
        output[[plotname]] <- renderPlot({
          req(model_data(), input$var_y, input$var_x)
          req(my_i <= length(input$var_x))
          
          mdf <- model_data()
          x_col <- input$var_x[my_i]
          
          ggplot(mdf, aes(x = .data[[x_col]], y = .data[[input$var_y]], fill = .data[[x_col]])) +
            geom_boxplot(alpha = 0.8, outlier.colour = "red", outlier.size = 3) +
            theme_minimal(base_size = 14) +
            labs(x = x_col, y = input$var_y, title = paste("Distribusi", input$var_y, "berdasarkan", x_col)) +
            theme(legend.position = "none") +
            scale_fill_brewer(palette = "Set2")
        })
      })
    }
  })
