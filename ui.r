# Define sidebar for inputs -----------------------------------------------

sidebar <- dashboardSidebar(
  
  # -- Gene filtering --
  # Search form for symbols
  sidebarSearchForm(label = "search symbol (Myod1)", "geneInput", "searchButton"),
  
  # Search form for ontology
  sidebarSearchForm(label = "search ontology (axon)", "GO", "searchButton"),
  
  # -- Muscle filtering --
  checkboxGroupInput("muscles","muscle type", inline = FALSE,
                     choices = tissueList,
                     selected = c('atria', 'left ventricle',
                                  'total aorta', 'right ventricle',
                                  'soleus', 
                                  # 'thoracic aorta', 
                                  # 'abdominal aorta', 
                                  'diaphragm',
                                  'eye', 'EDL', 'FDB', 
                                  # 'masseter', 'tongue'
                                  'plantaris')),
  
  # Conditional for advanced filtering options.
  checkboxInput("adv", "advanced filtering", value = FALSE),
  conditionalPanel(
    condition = "input.adv == true",
    
    # -- Expression filtering. --
    HTML("<div style = 'padding-left:1em; color:#00b3dd; font-weight:bold'>
      expression level </div>"),
    fluidRow(column(6,
                    numericInput("minExprVal", "min:", 0,
                                 min = 0, max = maxInit)),
             column(6,
                    numericInput("maxExprVal", "max:", 
                                 value = maxInit, min = 0, max = maxInit))),
    
    # -- fold change. --
    HTML("<div style = 'padding-left:1em; color:#00b3dd; font-weight:bold'> fold change </div>"),
    helpText(em(HTML("<div style= 'font-size:10pt; padding-left:1em'> 
        Filters by the increase in expression, 
                         relative to a single muscle tissue</div>"))),
    radioButtons("ref", label = "reference tissue:", 
                 choices = c('none',tissueList), selected = "none"),
    sliderInput("foldChange", label=NULL, min = 1.0, max = 21, value = 1, step = 0.5, width="100%"),
    
    # -- q-value. --
    HTML("<div style = 'padding-left:1em; color:#00b3dd; font-weight:bold'>
      q value </div>"),
    fluidRow(column(6,
                    numericInput("qVal", "maximum q value:", 0,
                                 min = 0, max = 1, value = 1)))
  ),
  
  # -- Sidebar icons --
  sidebarMenu(
    # Setting id makes input$tabs give the tabName of currently-selected tab
    id = "tabs",
    menuItemOutput("minExprInput"),
    menuItemOutput("maxExprInput"),
    menuItem("plot", tabName = "plot", icon = icon("bar-chart")),
    menuItem("table", tabName = "table", icon = icon("table")),
    menuItem("volcano plot", tabName = "volcano", icon = icon("ellipsis-v")),
    menuItem("heat map", tabName = "heatMap", icon = icon("th", lib = "glyphicon")),
    # menuItem("PCA", tabName = "PCA", icon = icon("arrows")),
    # menuItem("compare genes", tabName = "compare", icon = icon("line-chart")), 
    menuItem("code", tabName = "code", icon = icon("code"))
  )
)



# Header ------------------------------------------------------------------
header <- dashboardHeader(
  title = "MuscleDB",
  # -- Message bar --
  dropdownMenu(type = "messages", badgeStatus = NULL, icon = icon("question-circle"),
               messageItem("Muscle Transcriptome Atlas",
                           "about the database",
                           icon = icon("bar-chart"),
                           href="https://muscle-transcriptome-atlas.shinyapps.io/how-to/"
               ),
               messageItem("Need help getting started?",
                           "click here", icon = icon("question-circle"),
                           href="https://muscle-transcriptome-atlas.shinyapps.io/how-to/"
               ),
               messageItem("Website code and data scripts",
                           "find the code on Github", icon = icon("code"),
                           href = "https://github.com/flaneuse/muscle-transcriptome")
  )
)



# Body --------------------------------------------------------------------

body <- dashboardBody(
  
  # -- Import custom CSS --
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "customStyle.css")),
  
  # -- Each tab --
  tabItems(
    
    # -- Basic plot -- 
    tabItem(tabName = "plot", 
            fluidRow(h5("MuscleDB is a database containing RNAseq expression
                        levels for 10 different muscle tissues.")),
            fluidRow(h6("Explore the database by filtering the data on the toolbar 
                        at the left and with different visualizations on the bottom left. 
                        Need help getting started? See our help page.")),
            plotOutput("plot2"),
            plotOutput("plot1")),
    
    
    # -- Full table with mini-stats. --
    tabItem(tabName = "table",
            
            # fluidRow(pageruiInput('pager', page_current = 1, pages_total = 1)),
            # valueBoxes of min, max, avg.
            fluidRow(
              infoBoxOutput("maxExpr", width = 4),
              infoBoxOutput("avgExpr", width = 4),
              # infoBoxOutput("minExpr", width = 4),
              
              # Download data button
              column(1,
                     downloadButton('downloadTable', label = NULL, 
                                    class = 'btn btn-lg active btn-inverted hover btn-inverted'),
                     h5(""))),
            #           actionButton("saveRowsTable", "save rows",
            #                        icon = NULL)
            #     infoBox("dwndTable", downloadLink('downloadTable'), icon = icon("download"), width = 1)
            
            
            # Main table
            fluidRow(
              div(dataTableOutput("table"), style = "font-size:80%")),
            
            # Summary stats @ bottom of table
            fluidRow(
              box(title = "Summary Statistics", solidHeader = TRUE, status = 'primary', width = 12,
                  dataTableOutput("summaryTable")))),
    
    
    # -- Volcano plot --
    tabItem(tabName = "volcano", 
            fluidRow(h4('Select two tissues to compare.')),
            fluidRow(column(4, uiOutput('m1')),
                     column(4, uiOutput('m2'))),
            fluidRow(plotOutput("volcanoPlot")),
            fluidRow(column(10, dataTableOutput("volcanoTable")),
                     column(1, 
                            fluidRow(br()),
                            fluidRow(br()),
                            fluidRow(br()),
                            fluidRow(br()),
                            # fluidRow(actionButton('saveVolcano', 'save selected rows')),
                            fluidRow(br())))),
                            # fluidRow(downloadButton('csvVolcano', 'save to .csv'))))),    
    # -- PCA --
    tabItem(tabName = "PCA", 
            fluidRow(column(5,
                            plotOutput("pcaPlot"),
                            dataTableOutput("PCAload")),
                     column(7,infoBoxOutput("PCAstats")))),
    # h5("disclaimer; PCA loadings; % variance; brush; save --> table / graph / --> input")),
    
    
    # -- Heat map --
    tabItem(tabName = "heatMap", 
            fluidRow(column(7,
                            d3heatmapOutput("heatmap",
                                            width = 500,
                                            height = 550)),
                     column(5,
                            selectInput("scaleHeat", label = "heat map scaling",
                                        choices = c("none" = "none", "by row" = "row", 
                                                    "by column" = "col", "log" = "log")),
                            checkboxInput("orderHeat", label = "group genes by similarity?", value = FALSE)
                     ))),
    
    # -- Code --
    tabItem(tabName = "code",
            source("abtCode.R", local = TRUE))
  ))



# Dashboard definition (main call) ----------------------------------------

dashboardPage(
  title = "MuscleDB: A muscle transcriptome atlas",  
  header,
  sidebar,
  body
)