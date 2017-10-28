
# Prep data for initial full version of muscleDB --------------------------

# In late October 2017, rat expression data was run through ExpressionDB file prep.
# However, the rest of the expressionDB code has performance issues with larger datasets,
# presumably due to filterExpr.R functions.
# Therefore, data avg's, SEs, q values, and ontology terms are being reshaped into the previous format 

# need to have columns with: transcript, id, tissue, expr, lb, ub, q's, gene, GO, geneLink, transcriptLink, shortName



# setup -------------------------------------------------------------------
library(tidyverse)
library(stringr)

# import data -------------------------------------------------------------

rats = readRDS('~/Documents/GitHub/muscleDB-rat-1.0/prep/rat_db.rds')

rats = rats %>% 
  separate(transcript, sep = " \\(", into = c('name1', 'name2'), remove = FALSE) %>% 
  rename(comboName = transcript) %>% 
  mutate(id = row_number(), 
         transcriptLink = url,
         geneLink = url,
         name2 = str_replace_all(name2, '\\)', ''),
         shortName = name1, 
         gene = ifelse(is.na(name2), NA, name1),
         transcript = ifelse(is.na(name2), name1, name2),
         lb = expr - sem,
         ub = expr + sem) %>% 
  select(transcript, id, tissue, expr, lb, ub, gene, GO, geneLink, transcriptLink, shortName, dplyr::contains('_q')) %>% 
  rowwise() %>% 
  mutate(GO = ifelse(is.null(GO), NA, paste(GO, collapse = " | ")),
         tissue = case_when(tissue == "Female_EDL" ~"EDL (female)", 
                             tissue == "Female_SOL" ~ "soleus (female)", 
                             tissue == "Male_EDL" ~ "EDL (male)", 
                             tissue == "Male_SOL" ~ "soleus (male)",
                             TRUE ~ NA_character_))
                                                                         

saveRDS(rats, file = 'data/rat-expr.rds')


ont = readRDS('~/Documents/GitHub/muscleDB-rat-1.0/prep/rat_go_terms.rds')

saveRDS(ont, file = 'data/rat-ontology.rds')
