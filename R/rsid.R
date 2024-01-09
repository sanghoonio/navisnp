library(tidyverse)
library(data.table)
library(httr)
library(SNPediaR)

# get rsid data from myvariant.info ----
get_rsid <- function(rsid) {
  query_url <- paste0('https://myvariant.info/v1/variant?id=', rsid, '&fields=dbsnp,gnomad_exome,snpedia&size=1') %>% URLencode()
  res <- GET(query_url) %>% 
    content(as = 'parsed')
  
  if (is.null(res$error)) {
    ## if res is list, reassign res to first element ----
    if (is.null(res$dbsnp) & is.null(res$gnomad_exome) & is.null(res$snpedia)) {
      res <- res[[1]]
    }
    
    ## get metdata from dbsnp, gnomad exome, snpedia ----
    metadata <- list(
      chr = res$dbsnp$chrom,
      pos = res$gnomad_exome$pos, 
      gene = paste0(res$dbsnp$gene$symbol, ' - ', res$dbsnp$gene$name), 
      alt = res$dbsnp$alt, 
      ref = res$dbsnp$ref,
      summary = res$snpedia$text
    )
    
    if (!is.null(res$gnomad_exome)) {
      af_rows <- names(res$gnomad_exome$af) %>% str_replace('af_', '')
      af_rows[1] <- 'all'
      
      ### predefine default gnomad exome group data ----
      pop_df <- data.frame(
        id = c('tot', 'oth', 'afr', 'ami', 'amr', 'eas', 'fin', 'eur', 'nfe', 'sas', 'mde', 
               'asj', 'uniform', 'sas_non_consang', 'consanguineous', 'exac', 'bgr', 
               'deu', 'est', 'esp', 'gbr', 'nwe', 'seu', 'ita', 'swe', 'chn', 'kor', 
               'hkg', 'sgp', 'twn', 'jpn', 'oea', 'oeu', 'onf', 'unk'),
        
        name = c('Total', 'Other', 'African-American/African', 'Amish', 'Latino', 'East Asian', 
                 'Finnish', 'European', 'Non-Finnish European', 'South Asian', 
                 'Middle Eastern', 'Ashkenazi Jewish', 'Uniform', 'South Asian (F < 0.05)', 
                 'South Asian (F > 0.05)', 'ExAC', 'Bulgarian (Eastern European)', 
                 'German', 'Estonian', 'Spanish', 'British', 'North-Western European', 
                 'Southern European', 'Italian', 'Swedish', 'Chinese', 'Korean', 
                 'Hong Kong', 'Singaporean', 'Taiwanese', 'Japanese', 'Other East Asian', 
                 'Other European', 'Other Non-Finnish European', 'Unknown'),
        
        lat = c(0, 0, -5.6159, 40.8304, 2.0922, 35, 64, 50, 51, 20.3034, 22.5937, 31.5, 0, 20.3034, 20.3034, 0, 43, 42, 58.5952, 40.3130, 52.6963, 52.6963, 40.5137, 43.8345, 60.2398, 60, 36.9147, 22.3, 1.3, 23.9661, 35.8890, 14.9447, 25, 39.9097, 0),
        long = c(0, 0, 23.9881, -77.9114, -65.4944, 105, 26, 10, 10, 77.7800, 44.7111, 34.8, 0, 77.7800, 77.7800, 0, 25, 10, 25.0136, -3.8484, -1.7376, -1.7376, 15.7478, 11.4383, 15.1313, 18, 128.0649, 114, 103.8, 120.8786, 138.2392, 105.6051, -95, -3.1002, 0)
        )
      
      ### get allele freq data ----
      freq <- data.frame(
        ac = do.call(c, res$gnomad_exome$ac),
        an = do.call(c, res$gnomad_exome$an)
      ) %>% 
        mutate(
          id = af_rows,
          tot = an,
          alt = ac/an,
          ref = 1 - ac/an,
          alt_al = res$gnomad_exome$alt,
          ref_al = res$gnomad_exome$ref,
        ) %>% 
        select(id, tot, alt, ref, alt_al, ref_al) %>% 
        `rownames<-`(1:nrow(.)) %>% 
        filter(!(grepl('male', id))) %>% 
        mutate(id = id %>% str_replace('.+_', '')) %>% 
        merge(pop_df, by = 'id', all.x = TRUE) %>% 
        filter(!(id %in% c('all', 'oth', 'uniform', 'aas', 'sas_non_consang', 'consanguineous', 'exac', 'unk')))
    } else {
      ### get allele freq data from alfa ----
      freq <- get_alfa(rsid)
    }
    
    list(meta = metadata, freq = freq)
  } else {
    NULL
  }
  
}

# get allele freq data from alfa ----
get_alfa <- function(rsid) {
  query_url <- paste0('https://api.ncbi.nlm.nih.gov/variation/v0/refsnp/', gsub('\\D+', '', rsid), '/frequency') %>% URLencode()
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
      lat = c(0, 0, 30.1765, -1.7657, 20.5937, 31.7213, -14.2350, 18.9711, 35.5690, 34.4619, -4.8405, 51.5099),
      long = c(0, 0, 108.6734, 24.1159, 78.9629, 62.2291, -51.9253, -72.2852, -93.3825, 110.7011, 23.9563, -0.1180)
    )
    
    if (all(sapply(res$results[[1]]$counts[[1]]$allele_counts, function(x) {x[[1]][[1]]}) == 0)) {
      alt_index <- 2
    } else {
      alt_index <- 1
    }
    
    do.call(rbind, res$results[[1]]$counts[[1]]$allele_counts) %>% 
      as.data.frame() %>% 
      select(alt_index, ncol(.)) %>% 
      mutate(
        alt_al = colnames(.)[[1]],
        ref_al = colnames(.)[[2]]
      ) %>% 
      setnames(c('alt_ac', 'ref_ac', 'alt_al', 'ref_al')) %>% 
      mutate(
        across(c('ref_ac', 'alt_ac'), as.numeric),
        tot = ref_ac + alt_ac,
        ref = ref_ac / tot,
        alt = alt_ac / tot,
        sample_id = rownames(.)
      ) %>% 
      merge(ref, by = 'sample_id', all.x = TRUE) %>% 
      filter(!(id %in% c('tot', 'oth', 'afr', 'aas')))
  } else {
    NULL
  }
}

# get rsid data from snpedia ----
get_wiki <- function(rsid) {
  rsid <- rsid %>% trimws()
  snp <- getPages(titles = rsid, limit = 1)
  
  if (!is.null(snp[[1]])) {
    snp_raw <- unlist(strsplit(snp[[1]], split = '\n'))
    summary <- snp_raw[[which(snp_raw == '}}')[[1]] + 1]] %>% str_replace_all('\\[\\[|\\]\\]', '') %>% trimws()
    summary <- ifelse(nchar(summary) >= 100, summary, ' - ')
    
    snp_data <- extractSnpTags(snp[[1]])
    genotypes <- paste0(rsid, snp_data[c('geno1', 'geno2', 'geno3')])
    
    genotype_raw <- getPages(titles = genotypes, limit = 3) 
    
    if (any(sapply(genotype_raw, is.null))) {
      genotype_data <- NULL
    } else {
      genotype_data <- genotype_raw %>% sapply(extractGenotypeTags)
    }
    
    list(snp = snp_data, genotype = genotype_data, summary = summary)
  } else {
    NULL
  }
}
