library(shiny)
library(shinydashboard)

# Tampilan utama aplikasi
ui <- dashboardPage(
  skin = "blue", 
  dashboardHeader(title = "Allstar Stats App"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Halaman Utama", tabName = "home", icon = icon("home")),
      menuItem("Unggah & Atur Data", tabName = "upload", icon = icon("file-upload")),
      menuItem("Analisis Data", tabName = "analisis", icon = icon("chart-line")) # Menu analisis
    )
  ),
  
  dashboardBody(
    tabItems(
      # Bagian halaman awal
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
      ),
      
      # Bagian untuk unggah dan cek data
      tabItem(tabName = "upload",
              fluidRow(
                box(
                  title = "1. Pengaturan File CSV", status = "primary", solidHeader = TRUE, width = 4,
                  fileInput("file1", "Pilih File CSV",
                            multiple = FALSE,
                            accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
                  tags$hr(),
                  checkboxInput("header", "Baris Pertama adalah Header", TRUE),
                  radioButtons("sep", "Karakter Pemisah (Separator)",
                               choices = c("Koma (,)" = ",", "Titik Koma (;)" = ";", "Tab" = "\t"),
                               selected = ","),
                  tags$hr(),
                  radioButtons("disp", "Tampilan Pratinjau Data",
                               choices = c("Beberapa Baris Awal (Head)" = "head", "Semua Data (All)" = "all"),
                               selected = "head")
                ),
                
                box(
                  title = "2. Pemilihan Variabel", status = "warning", solidHeader = TRUE, width = 3,
                  p("Pilih variabel setelah file berhasil diunggah:"),
                  uiOutput("select_vars")
                ),
                
                box(
                  title = "Pratinjau Isi File", status = "success", solidHeader = TRUE, width = 5,
                  div(style = 'overflow-x: scroll;', tableOutput("contents"))
                )
              )
      ),
      
      # Halaman untuk hasil analisis
      tabItem(tabName = "analisis",
              fluidRow(
                box(
                  title = "Visualisasi Grafik (Kosong)", status = "primary", solidHeader = TRUE, width = 12,
                  div(style = "text-align: center; padding: 60px 0; color: #999;",
                      icon("chart-line", class = "fa-3x"),
                      tags$h4("Grafik/Boxplot akan ditampilkan di sini setelah data diproses.")
                  )
                )
              ),
              fluidRow(
                box(
                  title = "Anova", status = "danger", solidHeader = TRUE, width = 6,
                  div(style = "padding: 20px 0; color: #999; font-style: italic;",
                      "Belum ada data analisis untuk ditampilkan."
                  )
                ),
                box(
                  title = "Uji Tukey", status = "warning", solidHeader = TRUE, width = 6,
                  div(style = "padding: 20px 0; color: #999; font-style: italic;",
                      "Belum ada data analisis untuk ditampilkan."
                  )
                )
              ),
              fluidRow(
                box(
                  title = "Interpretasi & Kesimpulan (Kosong)", status = "success", solidHeader = TRUE, width = 12,
                  p("Kesimpulan otomatis atau narasi akademis dari model statistik akan muncul di bagian ini.", 
                    style = "color: #999; font-style: italic; margin: 10px 0;")
                )
              )
      )
    )
  )
)

# Bagian proses data
server <- function(input, output, session) {
  
  # Ambil data dari file yang diunggah
  data_input <- reactive({
    req(input$file1)
    tryCatch({
      read.csv(input$file1$datapath, header = input$header, sep = input$sep, quote = input$quote)
    }, error = function(e) {
      stop(safeError(e))
    })
  })
  
  # Tampilkan isi data sesuai pilihan pengguna
  output$contents <- renderTable({
    df <- data_input()
    if(input$disp == "head") return(head(df)) else return(df)
  })
  
  # Pilihan variabel menyesuaikan nama kolom data
  output$select_vars <- renderUI({
    req(df <- data_input())
    tagList(
      selectInput("var_x", "Variabel Faktor (Kategori / X):", choices = names(df), multiple = TRUE),
      selectInput("var_y", "Variabel Respon (Numerik / Y):", choices = names(df))
    )
  })
}

# Menjalankan aplikasi
shinyApp(ui, server)
