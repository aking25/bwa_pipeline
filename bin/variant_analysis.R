#!/usr/bin/env Rscript

library(tidyverse)
library(ggrepel)

args = commandArgs(trailingOnly=TRUE)

metadata_path <- args[1]

variants <- list.files(pattern="*.tsv") %>%
    map_dfr(~
        read_tsv(.x, col_types = cols(
                         REGION = col_character(),
                         POS = col_double(),
                         REF = col_character(),
                         ALT = col_character(),
                         REF_DP = col_double(),
                         REF_RV = col_double(),
                         REF_QUAL = col_double(),
                         ALT_DP = col_double(),
                         ALT_RV = col_double(),
                         ALT_QUAL = col_double(),
                         ALT_FREQ = col_double(),
                         TOTAL_DP = col_double(),
                         PVAL = col_double(),
                         PASS = col_logical(),
                         GFF_FEATURE = col_character(),
                         REF_CODON = col_character(),
                         REF_AA = col_character(),
                         ALT_CODON = col_character(),
                         ALT_AA = col_character()
                     )) %>%
            mutate(
                Name = basename(.x)
            )%>% mutate(across(.fns = as.character))
    ) %>%
  type_convert()
variants <- variants %>% 
    mutate(name = str_replace(Name, "\\..*","")) %>%
    select(-Name)
variants %>% write_tsv("./variants.tsv")
metadata <- read_csv(metadata_path)

merged <- inner_join(variants, metadata, by=c("name" = "SAMPLE_ID"))
merged %>% write_tsv("./merged.tsv")
filtered_merged <- merged %>%
    filter(ALT_FREQ >= 0.05 & ALT_FREQ <= 0.95)

uniq_filtered_merged <- filtered_merged %>%
    group_by(name, POS, ALT) %>%
    group_modify(~{
        .x %>%
            head(1)
    })

merged_n_metrics <- uniq_filtered_merged %>%
    filter(COVERAGE >= 90) %>%
    group_by(name, AVG_DEPTH, mapped, unmapped, COVERAGE, trimmed_pct) %>%
    count()

merged_n_metrics %>%
    ggplot(aes(n)) + geom_histogram(bins=200) + theme_bw() + geom_vline(aes(xintercept = median(n)), color="red") + geom_vline(aes(xintercept = quantile(n, 0.25) - 1.5 * IQR(n)), color="red", linetype="dotted") + geom_vline(aes(xintercept = quantile(n, 0.75) + 1.5 * IQR(n)), color="red", linetype="dotted")
ggsave("./n_distribution.pdf", w = 7.5, h =5)

merged_n_metrics %>%
    ungroup() %>%
    write_tsv("./samples_n_variants.tsv")


merged_n_metrics %>%
    ungroup() %>%
    filter(n >= quantile(n, 0.75) + 1.5 * IQR(n) & COVERAGE >= 95) %>%
    write_tsv("./excluded_samples.tsv")

merged_n_metrics %>%
    ungroup() %>%
    mutate(
        map_pct = mapped/(mapped+unmapped),
        label = ifelse(n >= quantile(n, 0.75) + 1.5 * IQR(n), name, NA)
    ) %>%
    ggplot(aes(COVERAGE, n, color = map_pct)) + geom_point() + scale_fill_gradient(trans="log") + geom_text_repel(aes(label = label)) + theme_bw() + geom_hline(aes(yintercept = median(n)), color="red") + geom_hline(aes(yintercept = quantile(n, 0.25) - 1.5 * IQR(n)), color="red", linetype="dotted") + geom_hline(aes(yintercept = quantile(n, 0.75) + 1.5 * IQR(n)), color="red", linetype="dotted")
ggsave("./coverage_vs_n.pdf", w= 15, h = 10)
