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
      # --- TAB 1: HALAMAN UTAMA ---
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
      
      # --- TAB 2: UNGGAH DATA ---
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
