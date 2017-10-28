library(dplyr)
library(tidyr)
library(shiny)
library(shinydashboard)
library(DT)
library(d3heatmap)
library(ggvis)
library(ggplot2)
# library(dtplyr)
library(data.table)




# Import in the Muscle Transcriptome database -----------------------------

# Set the initial view to be the Myod1 gene, to save on processing time.
initGene = 'Myod1'

data = readRDS('data/rat-expr.rds')

initData = data %>% filter(shortName %like% initGene)

glimpse(initData)

GOs = readRDS("data/rat-ontology.rds")

# Set the maximum of the expression, for the limits on the expr widget.
maxInit = max(data$expr)

# List of tissues
tissueList = list("EDL (female)" = "EDL (female)", 
                  "soleus (female)" = "soleus (female)", 
                  "EDL (male)" = "EDL (male)",
                  "soleus (male)" = "soleus (male)")

allTissues = c('soleus (female)',
               'EDL (female)', 
               'soleus (male)',
               'EDL (male)')

selTissues = c('soleus (female)',
                 'EDL (female)', 
                 'soleus (male)',
                 'EDL (male)')


# greys -------------------------------------------------------------------
grey10K = "#E6E7E8"
grey40K = "#a7a9ac"
grey50K = "#939598"
grey60K = "#808285"
grey90K = "#414042"
