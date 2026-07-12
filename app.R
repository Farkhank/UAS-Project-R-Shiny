library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)

# ==========================================
# 1. UI (User Interface)
# ==========================================
ui <- dashboardPage(
  skin = "blue", 
  dashboardHeader(title = "Allstar Stats App"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Halaman Utama", tabName = "home", icon = icon("home")),
      menuItem("Unggah & Atur Data", tabName = "upload", icon = icon("file-upload")),
      menuItem("Visualisasi Data", tabName = "visualisasi", icon = icon("chart-bar")),
      menuItem("Uji ANOVA", tabName = "anova", icon = icon("table")),
      menuItem("Uji Tukey HSD", tabName = "tukey", icon = icon("list-alt"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # TAB 1: HALAMAN UTAMA
      tabItem(tabName = "home",
              fluidRow(
                box(
                  width = 12, status = "primary", solidHeader = FALSE,
                  style = "text-align: center; padding: 40px; background-color: #fafafa; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);",
                  
                  tags$h1("Anova & Tukey App", 
                          style = "font-weight: 800; color: #2c3e50; font-size: 42px; margin-bottom: 5px; letter-spacing: 1px;"),
                  tags$h3("By Allstar Kelompok", 
                          style = "font-weight: 400; color: #3c8dbc; font-style: italic; margin-top: 0; margin-bottom: 25px;"),
                  
                  tags$hr(style = "border-top: 3px solid #3c8dbc; width: 150px; margin: 0 auto 25px auto;"),
                  
                  p("Selamat datang di aplikasi platform analisis statistika interaktif. Aplikasi ini dirancang khusus untuk membantu Anda menguji perbedaan rata-rata antar kelompok menggunakan Analisis Varians (ANOVA) dan Uji Lanjut Tukey HSD secara cepat, akurat, dan mudah dipahami.",
                    style = "font-size: 17px; max-width: 850px; margin: 0 auto; color: #555; line-height: 1.6;")
                )
              ),
              
              fluidRow(
                valueBox(
                  "1. Masukkan CSV", "Unggah file data Anda di tab kedua menggunakan format koma atau titik koma.", 
                  icon = icon("cloud-upload-alt"), color = "blue", width = 4
                ),
                valueBox(
                  "2. Atur Variabel", "Tentukan kolom Faktor (X) (bisa lebih dari satu) dan kolom Numerik (Y).", 
                  icon = icon("sliders-h"), color = "yellow", width = 4
                ),
                valueBox(
                  "3. Interpretasi", "Sistem otomatis memproses Grafik Boxplot, Tabel Uji, beserta kesimpulannya di tab terpisah.", 
                  icon = icon("chart-bar"), color = "green", width = 4
                )
              )
      ),
      
      # TAB 2: UNGGAH DATA
      tabItem(tabName = "upload",
              fluidRow(
                box(
                  title = "1. Pengaturan File CSV", status = "primary", solidHeader = TRUE, width = 3,
                  fileInput("file1", "Pilih File CSV",
                            multiple = FALSE,
                            accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
                  tags$hr(),
                  checkboxInput("header", "Baris Pertama adalah Header", TRUE),
                  radioButtons("sep", "Karakter Pemisah (Separator)",
                               choices = c("Koma (,)" = ",", "Titik Koma (;)" = ";", "Tab" = "\t"),
                               selected = ","),
                  radioButtons("quote", "Tanda Kutip (Quote)",
                               choices = c("Tidak Ada" = "", "Kutip Ganda (\")" = '"', "Kutip Tunggal (')" = "'"),
                               selected = '"')
                ),
                
                box(
                  title = "2. Pemilihan Variabel", status = "warning", solidHeader = TRUE, width = 4,
                  p("Pilih variabel dan jenis analisis model:"),
                  uiOutput("select_vars"),
                  tags$hr(),
                  radioButtons("model_type", "Tipe Model ANOVA (Khusus >1 Variabel X):",
                               choices = c("Efek Utama Saja (+)" = "additive", 
                                           "Dengan Efek Interaksi (*)" = "interaction"),
                               selected = "additive")
                ),
                
                box(
                  title = "Pratinjau Isi File", status = "success", solidHeader = TRUE, width = 5,
                  radioButtons("disp", "Tampilan:", choices = c("Head", "All"), inline = TRUE),
                  div(style = 'overflow-x: scroll; overflow-y: scroll; max-height: 350px;', tableOutput("contents"))
                )
              )
      ),
      
      # TAB 3: VISUALISASI DATA
      tabItem(tabName = "visualisasi",
              fluidRow(
                box(
                  title = "Visualisasi Distribusi Data (Boxplot)", status = "primary", solidHeader = TRUE, width = 12,
                  p("Grafik di bawah ini menunjukkan distribusi variabel numerik (Y) berdasarkan masing-masing variabel faktor (X) yang Anda pilih secara terpisah agar terlihat jelas."),
                  uiOutput("dynamic_plots") 
                )
              )
      ),
      
      # TAB 4: UJI ANOVA
      tabItem(tabName = "anova",
              fluidRow(
                box(
                  title = "Hasil Keluaran Uji ANOVA", status = "danger", solidHeader = TRUE, width = 6,
                  verbatimTextOutput("anova_out")
                ),
                box(
                  title = "Interpretasi Hasil ANOVA", status = "success", solidHeader = TRUE, width = 6,
                  htmlOutput("interpretasi_anova")
                )
              )
      ),
      
      # TAB 5: UJI TUKEY HSD
      tabItem(tabName = "tukey",
              fluidRow(
                box(
                  title = "Hasil Keluaran Uji Tukey HSD", status = "warning", solidHeader = TRUE, width = 12,
                  verbatimTextOutput("tukey_out")
                )
              ),
              fluidRow(
                box(
                  title = "Interpretasi Pasangan Signifikan (Tukey)", status = "success", solidHeader = TRUE, width = 12,
                  htmlOutput("interpretasi_tukey")
                )
              )
      )
    )
  )
)

# ==========================================
# 2. Server
# ==========================================
server <- function(input, output, session) {
#Ini buat nanti input data
  # Membaca Data dari File
  data_input <- reactive({
    req(input$file1)
    tryCatch({
      read.csv(input$file1$datapath, header = input$header, sep = input$sep, quote = input$quote)
    }, error = function(e) {
      stop(safeError(e))
    })
  })
  # Menampilkan Pratinjau Tabel
  output$contents <- renderTable({
    df <- data_input()
    req(df)
    if(input$disp == "Head") return(head(df)) else return(df)
  })
  # Menu Dropdown Variabel
  output$select_vars <- renderUI({
    req(df <- data_input())
    tagList(
      selectInput("var_x", "Variabel Faktor (Kategori / X):", choices = names(df), multiple = TRUE),
      selectInput("var_y", "Variabel Respon (Numerik / Y):", choices = names(df))
    )
  })
  # Persiapan Data (Konversi Tipe Data)
  model_data <- reactive({
    req(input$var_x, input$var_y)
    df <- data_input()
    req(df)
    kolom_pilihan <- c(input$var_x, input$var_y)
    req(all(kolom_pilihan %in% names(df))) 
    sub_df <- df[, kolom_pilihan, drop = FALSE]
    sub_df <- na.omit(sub_df)
    for(kolom in input$var_x) {
      sub_df[[kolom]] <- as.factor(sub_df[[kolom]])
    }
    sub_df[[input$var_y]] <- as.numeric(sub_df[[input$var_y]])
    return(sub_df)
  })

 # Pembuatan Model ANOVA
  anova_model <- reactive({
    req(input$var_x, input$var_y)
    mdf <- model_data()
    req(mdf)
    # Deteksi pilihan model interaksi atau tidak
    pemisah <- ifelse(input$model_type == "additive", " + ", " * ")
    x_vars_kombinasi <- paste(input$var_x, collapse = pemisah)
    rumus_anova <- paste(input$var_y, "~", x_vars_kombinasi)
    tryCatch({
      aov(as.formula(rumus_anova), data = mdf)
    }, error = function(e) {
      return(NULL)
    })
  })
  #OUTPUT & INTERPRETASI ANOVA
  output$anova_out <- renderPrint({
    model <- anova_model()
    if(is.null(model)) {
      cat("Model ANOVA tidak dapat diproses.\nPastikan tipe data benar dan sampel cukup untuk variabel yang dipilih.")
    } else {
      summary(model)
    }
  })
  output$interpretasi_anova <- renderUI({
    model <- anova_model()
    if(is.null(model)) {
      return(HTML("<div style='color:red;'><b>Gagal memproses interpretasi.</b> Silakan periksa kembali konfigurasi variabel Anda.</div>"))
    }
    anova_summary <- summary(model)
    nama_baris <- rownames(anova_summary[[1]])
    
    hasil_teks <- "<div style='font-size: 15px; line-height: 1.8;'>"
    hasil_teks <- paste0(hasil_teks, "Berdasarkan pengujian <b>ANOVA</b> di samping, diperoleh keputusan:<br><br><ul>")
    
    for(i in 1:(length(nama_baris)-1)) {
      p_value <- anova_summary[[1]][["Pr(>F)"]][i]
      nama_var <- trimws(nama_baris[i])
      if(!is.na(p_value)) {
        if (p_value < 0.05) {
          keputusan <- paste0("<span style='color: #27ae60; font-weight: bold;'>SIGNIFIKAN</span> (p < 0.05). Artinya, terbukti secara nyata terdapat perbedaan rata-rata variabel <b>", input$var_y, "</b> pada faktor <b>", nama_var, "</b>.")
        } else {
          keputusan <- paste0("<span style='color: #e74c3c; font-weight: bold;'>TIDAK SIGNIFIKAN</span> (p &ge; 0.05). Artinya, tidak terdapat perbedaan rata-rata <b>", input$var_y, "</b> yang nyata pada faktor <b>", nama_var, "</b>.")
        }
        hasil_teks <- paste0(hasil_teks, "<li>Faktor <b>", nama_var, "</b> (P-Value: ", format.pval(p_value, digits = 4, eps = 0.05), ") &rarr; ", keputusan, "</li><br>")
      }
    }
    hasil_teks <- paste0(hasil_teks, "</ul></div>")
    HTML(hasil_teks)
  })

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
  #Ini buat uji Tukey
  # --- Membuat Model Tukey ---
  tukey_data <- reactive({
    req(input$var_x, input$var_y)
    mdf <- model_data()
    req(mdf)
    # Membuat ulang model di dalam blok reaktif Tukey untuk mengatasi isu scoping
    pemisah <- ifelse(input$model_type == "additive", " + ", " * ")
    x_vars_kombinasi <- paste(input$var_x, collapse = pemisah)
    rumus_tukey <- paste(input$var_y, "~", x_vars_kombinasi)
    tryCatch({
      model_tukey <- aov(as.formula(rumus_tukey), data = mdf)
      TukeyHSD(model_tukey)
    }, error = function(e) {
      return(e$message) # Menangkap error asli dari R
    })
  })
  output$tukey_out <- renderPrint({
    t_data <- tukey_data()
    if(is.character(t_data)) {
      cat("GAGAL MEMPROSES UJI TUKEY.\n")
      cat("Alasan dari sistem R:\n", t_data, "\n\n")
      cat("Solusi:\n1. Pastikan variabel X yang dipilih adalah data kategori (bukan angka unik semua).\n2. Jika menggunakan lebih dari 1 variabel X, coba ganti tipe model ke 'Efek Utama Saja (+)'.")
    } else {
      print(t_data)
    }
  })
  output$interpretasi_tukey <- renderUI({
    t_data <- tukey_data()
    
    if(is.character(t_data) || is.null(t_data)) {
      return(HTML("<div style='color:#c0392b; background-color:#f9ebea; padding:15px; border-radius:5px;'><b>Tukey HSD Terhenti:</b> Tidak dapat memproses interpretasi karena terjadi kesalahan pada perhitungan struktur data Anda. Silakan cek tabel uji di atas untuk melihat penyebabnya.</div>"))
    }
    
    hasil_teks <- "<div style='font-size: 15px; line-height: 1.6;'>"
    hasil_teks <- paste0(hasil_teks, "<p>Uji Lanjut Tukey HSD mengevaluasi perbandingan berpasangan. Pasangan kelompok dinyatakan berbeda secara signifikan apabila nilai <code>p adj</code> < 0.05.</p>")
    
    for(faktor in names(t_data)) {
      hasil_teks <- paste0(hasil_teks, "<h4 style='color: #2980b9; margin-top: 20px; border-bottom: 2px solid #2980b9; padding-bottom: 5px;'><b>Faktor/Interaksi: ", faktor, "</b></h4>")
      
      tabel_faktor <- as.data.frame(t_data[[faktor]])
      # Ekstraksi kebal missing value (NA)
      pasangan_signifikan <- rownames(tabel_faktor)[which(tabel_faktor[["p adj"]] < 0.05)]
      
      if(length(pasangan_signifikan) > 0) {
        hasil_teks <- paste0(hasil_teks, "<p>Berikut adalah pasangan kelompok yang memiliki perbedaan nilai rata-rata secara <b>signifikan</b>:</p><ul>")
        for(psg in pasangan_signifikan) {
          p_val <- tabel_faktor[psg, "p adj"]
          hasil_teks <- paste0(hasil_teks, "<li>Pasangan kelompok <b>", psg, "</b> (Nilai p-adj: ", format.pval(p_val, digits = 4, eps = 0.001), ")</li>")
        }
        hasil_teks <- paste0(hasil_teks, "</ul>")
      } else {
        hasil_teks <- paste0(hasil_teks, "<p style='color: #7f8c8d; font-style: italic;'>Tidak ada satu pun pasangan kelompok yang memiliki perbedaan rata-rata signifikan pada faktor ini.</p>")
      }
    }
    hasil_teks <- paste0(hasil_teks, "</div>")
    HTML(hasil_teks)
  })
}

# 3. Jalankan Aplikasi
shinyApp(ui, server)
