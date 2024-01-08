library(tidyverse)
library(data.table)
library(httr)

base_url <- 'https://api.ncbi.nlm.nih.gov/variation/v0'

get_rsid <- function(rsid) {
  query_url <- paste0('https://myvariant.info/v1/variant?id=', rsid, '&fields=dbsnp,gnomad_exome,snpedia&size=1') %>% URLencode()
  res <- GET(query_url) %>% 
    content(as = 'parsed')
}

get_freq <- function(rsid) {
  query_url <- paste0(base_url, '/refsnp/', gsub('\\D+', '', rsid), '/frequency') %>% URLencode()
  res <- GET(query_url) %>% 
    content(as = 'parsed')
  
  if (length(res$results[[1]]$counts[[1]]$allele_counts) > 0) {
    do.call(rbind, res$results[[1]]$counts[[1]]$allele_counts) %>% 
      as.data.frame() %>% 
      select(1, ncol(.)) %>% 
      setnames(c('alt', 'ref')) %>% 
      mutate(
        across(c('ref', 'alt'), as.numeric),
        tot = ref + alt,
        ref_af = ref / tot,
        alt_af = alt / tot,
        sample_id = rownames(.)
      ) %>% 
      get_subs()
  } else {
    NULL
  }
}

get_subs <- function(df) {
  ref <- data.frame(
    sample_id = c('SAMN11605645', 'SAMN10492705', 'SAMN10492704', 'SAMN10492703', 
                     'SAMN10492702', 'SAMN10492701', 'SAMN10492700', 'SAMN10492699', 
                     'SAMN10492698', 'SAMN10492697', 'SAMN10492696', 'SAMN10492695'),
    full_name = c('Other', 'Total', 'Asian', 'African', 'South Asian', 'Other Asian',
                    'Latin American 2', 'Latin American 1', 'African American', 'East Asian',
                    'African Others', 'European'),
    short_name = c('oth', 'tot', 'aas', 'afr', 'sas', 'oas', 'la2', 'la1', 'afa', 'eas','afo', 'eur'),
    lat = c(0, 0, 30.1765, -1.7657, 20.5937, 29.9061, -14.2350, 18.9711, 35.5690, 32.0162, -4.8405, 51.5099),
    long = c(0, 0, 108.6734, 24.1159, 78.9629, 53.8587, -51.9253, -72.2852, -93.3825, 117.1813, 23.9563, -0.1180)
  )
  
  merge(df, ref, by = 'sample_id', all.x = TRUE)
}

# t <- get_rsid(2249358)
# tt <- get_rsid(17822931)
# ttt <- get_rsid(234523498759238)
