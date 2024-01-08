library(tidyverse)
library(data.table)
library(httr)

base_url <- 'https://api.ncbi.nlm.nih.gov/variation/v0'

get_rsid <- function(rsid) {
  query_url <- paste0('https://myvariant.info/v1/variant?id=', rsid, '&fields=dbsnp,gnomad_exome,snpedia&size=1') %>% URLencode()
  res <- GET(query_url) %>% 
    content(as = 'parsed')
  
  if (is.null(res$error)) {
    if (is.null(res$dbsnp) & is.null(res$gnomad_exome) & is.null(res$snpedia)) {
      res <- res[[1]]
    }
      
    metadata <- c(
      paste0('chr', res$dbsnp$chrom, ':', res$gnomad_exome$pos), 
      paste0(res$dbsnp$gene$symbol, ' - ', res$dbsnp$gene$name), 
      res$dbsnp$alt, 
      res$dbsnp$ref,
      res$snpedia$text
    )
    
    if (is.null(res$gnomad_exome)) {
      freq <- get_freq(rsid)
    } else {
      af_rows <- names(res$gnomad_exome$af) %>% str_replace('af_', '')
      af_rows[1] <- 'all'
      
      id <- c('all', 'oth', 'afr', 'ami', 'amr', 'eas', 'fin', 'eur', 'nfe', 'sas', 'mde', 
              'asj', 'uniform', 'sas_non_consang', 'consanguineous', 'exac', 'bgr', 
              'deu', 'est', 'esp', 'gbr', 'nwe', 'seu', 'ita', 'swe', 'chn', 'kor', 
              'hkg', 'sgp', 'twn', 'jpn', 'oea', 'oeu', 'onf', 'unk')
      
      name <- c('All', 'Other', 'African-American/African', 'Amish', 'Latino', 'East Asian', 
                'Finnish', 'European', 'Non-Finnish European', 'South Asian', 
                'Middle Eastern', 'Ashkenazi Jewish', 'Uniform', 'South Asian (F < 0.05)', 
                'South Asian (F > 0.05)', 'ExAC', 'Bulgarian (Eastern European)', 
                'German', 'Estonian', 'Spanish', 'British', 'North-Western European', 
                'Southern European', 'Italian', 'Swedish', 'Chinese', 'Korean', 
                'Hong Kong', 'Singaporean', 'Taiwanese', 'Japanese', 'Other East Asian', 
                'Other European', 'Other Non-Finnish European', 'Unknown')
      
      lat <- c(0, 0, -15, 40, -30, 35, 64, 50, 51, 25, 30, 31.5, 0, 25, 25, 0, 43, 42, 60, 58, 40, 51, 40, 42, 41, 60, 35, 22.3, 1.3, 1.3, 25, 24, 25, 38, 0)
      long <- c(0, 0, 30, -86, -60, 105, 26, 10, 10, 80, 45, 34.8, 0, 78, 78, 0, 25, 10, 10, 25, 10, -0.13, 10, 12, 12, 18, 135, 114, 103.8, 121, 138, 120, -95, 9, 0)
      
      pop_df <- data.frame(id, name, lat, long)
      
      freq <- data.frame(
        ac = do.call(c, res$gnomad_exome$ac),
        an = do.call(c, res$gnomad_exome$an)
      ) %>% 
        mutate(
          id = af_rows,
          alt = ac/an,
          ref = 1 - ac/an
        ) %>% 
        select(id, alt, ref) %>% 
        `rownames<-`(1:nrow(.)) %>% 
        filter(!(grepl('male', id))) %>% 
        mutate(id = id %>% str_replace('.+_', '')) %>% 
        merge(pop_df, by = 'id', all.x = TRUE)
    }
    
    list(meta = metadata, freq = freq)
  } else {
    NULL
  }
  
}

get_freq <- function(rsid) {
  query_url <- paste0(base_url, '/refsnp/', gsub('\\D+', '', rsid), '/frequency') %>% URLencode()
  res <- GET(query_url) %>% 
    content(as = 'parsed')
  
  if (length(res$results[[1]]$counts[[1]]$allele_counts) > 0) {
    ref <- data.frame(
      sample_id = c('SAMN11605645', 'SAMN10492705', 'SAMN10492704', 'SAMN10492703', 
                  'SAMN10492702', 'SAMN10492701', 'SAMN10492700', 'SAMN10492699', 
                  'SAMN10492698', 'SAMN10492697', 'SAMN10492696', 'SAMN10492695'),
      name = c('Other', 'Total', 'Asian', 'African', 'South Asian', 'Other Asian',
               'Latin American 2', 'Latin American 1', 'African American', 'East Asian',
               'African Others', 'European'),
      id = c('oth', 'tot', 'aas', 'afr', 'sas', 'oas', 'la2', 'la1', 'afa', 'eas','afo', 'eur'),
      lat = c(0, 0, 30.1765, -1.7657, 20.5937, 29.9061, -14.2350, 18.9711, 35.5690, 32.0162, -4.8405, 51.5099),
      long = c(0, 0, 108.6734, 24.1159, 78.9629, 53.8587, -51.9253, -72.2852, -93.3825, 117.1813, 23.9563, -0.1180)
    )
    
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
      merge(ref, by = 'sample_id', all.x = TRUE)
  } else {
    NULL
  }
}

t <- get_freq('rs17822931')
tt <- get_rsid('rs17822931')
ttt <- get_rsid('rs53576')
