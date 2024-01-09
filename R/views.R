library(shiny)
library(tidyverse)

source('R/rsid.R')

rsid_meta <- function(rsid, meta, freq, wiki) {
  tryCatch({
    chr <- ifelse(!is.null(wiki$snp['Chromosome']), wiki$snp['Chromosome'], ifelse(!is.null(meta$chr), meta$chr, ''))
    pos <- ifelse(!is.null(wiki$snp['position']), paste0(':', wiki$snp['position']), ifelse(!is.null(meta$pos), paste0(':', meta$pos), ''))
    assem <- ifelse(!is.null(wiki$snp['Assembly']), paste0(' (', wiki$snp['Assembly'], ')'), '')
    
    gene <- ifelse(meta$gene != ' - ', meta$gene, ifelse(!is.null(wiki$snp['Gene']), wiki$snp['Gene'], ' - '))
    
    ref <- ifelse(!is.null(freq$ref_al[[1]]), freq$ref_al[[1]], '')
    alt <- ifelse(!is.null(freq$alt_al[[1]]), freq$alt_al[[1]], '')
    
    geno1 <- ifelse(!is.null(wiki$genotype), paste0(colnames(wiki$genotype)[[1]] %>% str_replace('Rs', 'rs'), ' - ', wiki$genotype['summary', 1]), ' - ')
    geno2 <- ifelse(!is.null(wiki$genotype), paste0(colnames(wiki$genotype)[[2]] %>% str_replace('Rs', 'rs'), ' - ', wiki$genotype['summary', 2]), ' - ')
    geno3 <- ifelse(!is.null(wiki$genotype), paste0(colnames(wiki$genotype)[[3]] %>% str_replace('Rs', 'rs'), ' - ', wiki$genotype['summary', 3]), ' - ')
    
    summary <- ifelse(!is.null(wiki$summary), wiki$summary, ' - ')
    
    div(
      class = 'card',
      div(
        class = 'card-header',
        style = 'text-align:center;',
        h5(style = 'margin:0;', rsid),
      ),
      tags$ul(
        class = 'list-group list-group-flush',
        style = 'font-size:13px;',
        tags$li(
          class = 'list-group-item',
          div(
            class = 'row',
            div(
              class = 'col-xxl-4 col-3',
              p(strong('Position: ')),
            ),
            div(
              class = 'col-xxl-8 col-9',
              p(paste0('chr', chr, pos, assem)),
            )
          ),
          div(
            class = 'row',
            div(
              class = 'col-xxl-4 col-3',
              p(strong('Gene: ')),
            ),
            div(
              class = 'col-xxl-8 col-9',
              p(gene),
            )
          ),
          div(
            class = 'row',
            div(
              class = 'col-xxl-4 col-3',
              p(strong('Ref Allele: ')),
            ),
            div(
              class = 'col-xxl-8 col-9',
              p(ref, HTML('&nbsp'), icon(style = 'color:#1f77b4;', 'fas fa-square')),
            )
          ),
          div(
            class = 'row',
            div(
              class = 'col-xxl-4 col-3',
              p(style = 'margin:0;', strong('Alt Allele: ')),
            ),
            div(
              class = 'col-xxl-8 col-9',
              p(style = 'margin:0;', alt, HTML('&nbsp'), icon(style = 'color:#ff7f0e;', 'fas fa-square')),
            )
          ),
        ),
        tags$li(
          class = 'list-group-item',
          div(
            class = 'row',
            div(
              class = 'col-xxl-4 col-3',
              p(strong('Genotype 1: ')),
            ),
            div(
              class = 'col-xxl-8 col-9',
              p(geno1),
            )
          ),
          div(
            class = 'row',
            div(
              class = 'col-xxl-4 col-3',
              p(strong('Genotype 2: ')),
            ),
            div(
              class = 'col-xxl-8 col-9',
              p(geno2),
            )
          ),
          div(
            class = 'row',
            div(
              class = 'col-xxl-4 col-3',
              p(style = 'margin:0;', strong('Genotype 3: ')),
            ),
            div(
              class = 'col-xxl-8 col-9',
              p(style = 'margin:0;', geno3),
            )
          ),
        ),
        tags$li(
          class = 'list-group-item',
          div(
            class = 'row',
            div(
              class = 'col-xxl-4 col-3',
              p(strong('Summary: ')),
            ),
            div(
              class = 'col-xxl-8 col-9',
              p(summary)
            )
          )
        )
      )
    )
  },
  warning = function(w) {
    print(w)
    rsid_error(rsid)
  },
  error = function(e) {
    print(e)
    rsid_error(rsid)
  })
}

rsid_error <- function(rsid) {
  div(
    class = 'card',
    div(
      class = 'card-header',
      style = 'text-align:center;',
      h5(style = 'margin:0;', rsid),
    ),
    tags$ul(
      class = 'list-group list-group-flush',
      style = 'font-size:13px;',
      tags$li(
        class = 'list-group-item',
        div(
          class = 'row',
          div(
            class = 'col-xxl-4 col-3',
            p(strong('Gene: ')),
          ),
          div(
            class = 'col-xxl-8 col-9',
            p(''),
          )
        ),
        div(
          class = 'row',
          div(
            class = 'col-xxl-4 col-3',
            p(strong('Gene: ')),
          ),
          div(
            class = 'col-xxl-8 col-9',
            p(''),
          )
        ),
        div(
          class = 'row',
          div(
            class = 'col-xxl-4 col-3',
            p(strong('Ref Allele: ')),
          ),
          div(
            class = 'col-xxl-8 col-9',
            p(''),
          )
        ),
        div(
          class = 'row',
          div(
            class = 'col-xxl-4 col-3',
            p(style = 'margin:0;', strong('Alt Allele: ')),
          ),
          div(
            class = 'col-xxl-8 col-9',
            p(style = 'margin:0;', ''),
          )
        ),
      ),
      tags$li(
        class = 'list-group-item',
        div(
          class = 'row',
          div(
            class = 'col-xxl-4 col-3',
            p(strong('Genotype 1: ')),
          ),
          div(
            class = 'col-xxl-8 col-9',
            p(''),
          )
        ),
        div(
          class = 'row',
          div(
            class = 'col-xxl-4 col-3',
            p(strong('Genotype 2: ')),
          ),
          div(
            class = 'col-xxl-8 col-9',
            p(''),
          )
        ),
        div(
          class = 'row',
          div(
            class = 'col-xxl-4 col-3',
            p(style = 'margin:0;', strong('Genotype 3: ')),
          ),
          div(
            class = 'col-xxl-8 col-9',
            p(style = 'margin:0;', ''),
          )
        ),
      ),
      tags$li(
        class = 'list-group-item',
        div(
          class = 'row',
          div(
            class = 'col-xxl-4 col-3',
            p(strong('Summary: ')),
          ),
          div(
            class = 'col-xxl-8 col-9',
            p('')
          )
        )
      )
    )
  )
}
