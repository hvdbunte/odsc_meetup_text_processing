library(jsonlite)
library(dplyr)
library(tidyr)
library(ggplot2)
library(RColorBrewer)
library(wordcloud)


palette <- brewer.pal(4, 'Set1')
mod <- fromJSON(txt = './data/lda_models/lda_out_k4.json')


top_terms <- tbl_df(mod$terms) %>%
    arrange(desc(beta)) %>%
    select(-(rank)) %>%
    group_by(topic_id) %>%
    mutate(rank = row_number(desc(beta))) %>%
    ungroup() %>%
    filter(rank <= 5) %>%
    select(-(beta)) %>%
    spread(data = ., key = rank, value = term) %>%
    unite(data = ., col = 'terms', -topic_id, sep = ', ')


tbl_df(mod$docs) %>%
    inner_join(y = top_terms, by = 'topic_id') %>%
    ggplot(data = .) +
    geom_line(mapping = aes(x = doc_id, y = gamma, colour = terms), size = 1.5) +
    scale_color_brewer(palette = 'Set1') +
    theme_classic() +
    theme(legend.position = 'none',
          legend.title = element_blank()) +
    labs(title = 'State of the Union Topics by Year',
         x = '',
         y = 'Percent Strength of Topic Model in SOTU Address')

top_terms

#ggsave(filename = './plots/topic_model_k4_nolegend.png')


# Annotated with Presidents
tbl_df(mod$docs) %>%
    inner_join(y = top_terms, by = 'topic_id') %>%
    ggplot(data = .) +
    geom_line(mapping = aes(x = doc_id, y = gamma, colour = terms), size = 1.5) +
    annotate(geom = 'segment', x = 1945, y = 0.01, xend = 1945, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 1945, y = 0, label = 'Truman', color = 'grey') +
    annotate(geom = 'segment', x = 1953, y = 0.01, xend = 1953, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 1953, y = 0, label = 'Eisenhower', color = 'grey') +
    annotate(geom = 'segment', x = 1961, y = 0.01, xend = 1961, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 1961, y = 0, label = 'Kennedy', color = 'grey') +
    annotate(geom = 'segment', x = 1964, y = 0.01, xend = 1964, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 1964, y = -0.02, label = 'Johnson', color = 'grey') +
    annotate(geom = 'segment', x = 1970, y = 0.01, xend = 1970, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 1970, y = 0, label = 'Nixon', color = 'grey') +
    annotate(geom = 'segment', x = 1975, y = 0.01, xend = 1975, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 1975, y = 0, label = 'Ford', color = 'grey') +
    annotate(geom = 'segment', x = 1978, y = 0.01, xend = 1978, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 1978, y = -0.02, label = 'Carter', color = 'grey') +
    annotate(geom = 'segment', x = 1981, y = 0.01, xend = 1981, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 1981, y = 0, label = 'Reagan', color = 'grey') +
    annotate(geom = 'segment', x = 1989, y = 0.01, xend = 1989, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 1989, y = 0, label = 'Bush', color = 'grey') +
    annotate(geom = 'segment', x = 1993, y = 0.01, xend = 1993, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 1993, y = 0, label = 'Clinton', color = 'grey') +
    annotate(geom = 'segment', x = 2001, y = 0.01, xend = 2001, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 2001, y = 0, label = 'Bush', color = 'grey') +
    annotate(geom = 'segment', x = 2009, y = 0.01, xend = 2009, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 2009, y = 0, label = 'Obama', color = 'grey') +
    scale_color_brewer(palette = 'Set1') +
    theme_classic() +
    theme(legend.position = 'none',
          legend.title = element_blank()) +
    labs(title = 'State of the Union Topics by Year',
         x = '',
         y = 'Percent Strength of Topic Model in SOTU Address')

#ggsave(filename = './plots/topic_model_k4_annotated_nolegend.png')



# Annotated with Presidents, Modern only
tbl_df(mod$docs) %>%
    filter(topic_id %in% c(1, 2)) %>%
    inner_join(y = top_terms, by = 'topic_id') %>%
    ggplot(data = .) +
    geom_line(mapping = aes(x = doc_id, y = gamma, colour = terms), size = 1.5) +
    annotate(geom = 'segment', x = 1945, y = 0.01, xend = 1945, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 1945, y = 0, label = 'Truman', color = 'grey') +
    annotate(geom = 'segment', x = 1953, y = 0.01, xend = 1953, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 1953, y = 0, label = 'Eisenhower', color = 'grey') +
    annotate(geom = 'segment', x = 1961, y = 0.01, xend = 1961, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 1961, y = 0, label = 'Kennedy', color = 'grey') +
    annotate(geom = 'segment', x = 1964, y = 0.01, xend = 1964, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 1964, y = -0.02, label = 'Johnson', color = 'grey') +
    annotate(geom = 'segment', x = 1970, y = 0.01, xend = 1970, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 1970, y = 0, label = 'Nixon', color = 'grey') +
    annotate(geom = 'segment', x = 1975, y = 0.01, xend = 1975, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 1975, y = 0, label = 'Ford', color = 'grey') +
    annotate(geom = 'segment', x = 1978, y = 0.01, xend = 1978, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 1978, y = -0.02, label = 'Carter', color = 'grey') +
    annotate(geom = 'segment', x = 1981, y = 0.01, xend = 1981, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 1981, y = 0, label = 'Reagan', color = 'grey') +
    annotate(geom = 'segment', x = 1989, y = 0.01, xend = 1989, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 1989, y = 0, label = 'Bush', color = 'grey') +
    annotate(geom = 'segment', x = 1993, y = 0.01, xend = 1993, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 1993, y = 0, label = 'Clinton', color = 'grey') +
    annotate(geom = 'segment', x = 2001, y = 0.01, xend = 2001, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 2001, y = 0, label = 'Bush', color = 'grey') +
    annotate(geom = 'segment', x = 2009, y = 0.01, xend = 2009, yend = 1, size = 1, color = 'grey', alpha = 0.5) +
    annotate(geom = 'text', x = 2009, y = 0, label = 'Obama', color = 'grey') +
    scale_color_manual(values = c(palette[1],palette[4])) +
    theme_classic() +
    theme(legend.position = 'none',
          legend.title = element_blank()) +
    labs(title = 'State of the Union Topics by Year: Modern Partisanship',
         x = '',
         y = 'Percent Strength of Topic Model in SOTU Address')

ggsave(filename = './plots/modern_annotated.png', width = 12.6, height = 6.6, dpi = 400)





# Wordcloud
wc <- tbl_df(mod$terms) %>%
    arrange(desc(beta)) %>%
    select(-(rank)) %>%
    group_by(topic_id) %>%
    mutate(rank = dense_rank(desc(beta))) %>%
    ungroup() %>%
    filter(rank <= 15) %>%
    filter(topic_id == 3)

#png(filename = './plots/wc_k4_tX.png')
wordcloud(words = wc$term, freq = wc$beta, rot.per = 0.0, colors = palette[2])
#dev.off()




# TV Effect
tv <- read.table(file = './data/tv_stats.txt', header = TRUE, sep = '|')

ggplot(data = tv) +
    geom_line(mapping = aes(x = year, y = pct_tv)) +
    geom_line(mapping = aes(x = year, y = pct_cable)) +
    geom_line(mapping = aes(x = year, y = pct_internet))

# Standard TV
tbl_df(mod$docs) %>%
    filter(topic_id %in% c(3, 0)) %>%
    inner_join(y = top_terms, by = 'topic_id') %>%
    ggplot(data = .) +
    geom_line(data = tv, mapping = aes(x = year, y = pct_tv), size = 1.25, linetype = 'dashed') +
    annotate(geom = 'text', x = 2000, y = 0.95, label = '% Households with TV') +
    geom_line(mapping = aes(x = doc_id, y = gamma, colour = terms), size = 1.5) +
    scale_color_manual(values = c(palette[2],palette[3])) +
    theme_classic() +
    theme(legend.position = 'none',
          legend.title = element_blank()) +
    labs(title = 'State of the Union Topics by Year with TV Effect',
         x = '',
         y = 'Percent Strength of Topic Model in SOTU Address')

#ggsave(filename = './plots/tv_effect_nolegend.png')


# Cable TV
tbl_df(mod$docs) %>%
    filter(topic_id %in% c(1, 2)) %>%
    inner_join(y = top_terms, by = 'topic_id') %>%
    ggplot(data = .) +
    geom_line(data = tv, mapping = aes(x = year, y = pct_tv), size = 1.25, linetype = 'dashed') +
    annotate(geom = 'text', x = 2000, y = 0.92, label = '% Households\nw/ TV') +
    geom_line(data = tv, mapping = aes(x = year, y = pct_cable), size = 1.25, linetype = 'dashed') +
    annotate(geom = 'text', x = 2008, y = 0.72, label = '% Households\nw/ Cable TV') +
    geom_line(mapping = aes(x = doc_id, y = gamma, colour = terms), size = 1.5) +
    scale_color_manual(values = c(palette[1],palette[4])) +
    theme_classic() +
    theme(legend.position = 'none',
          legend.title = element_blank()) +
    labs(title = 'State of the Union Topics by Year with Cable TV & Partisan Split',
         x = '',
         y = 'Percent Strength of Topic Model in SOTU Address')

#ggsave(filename = './plots/cable_effect_nolegend.png')


# Cable TV/ Internet
tbl_df(mod$docs) %>%
    filter(topic_id %in% c(1, 2)) %>%
    inner_join(y = top_terms, by = 'topic_id') %>%
    ggplot(data = .) +
    geom_line(data = tv, mapping = aes(x = year, y = pct_tv), size = 1.25, linetype = 'dashed') +
    annotate(geom = 'text', x = 2000, y = 0.92, label = '% Households\nw/ TV') +
    geom_line(data = tv, mapping = aes(x = year, y = pct_cable), size = 1.25, linetype = 'dashed') +
    annotate(geom = 'text', x = 1995, y = 0.72, label = '% Households\nw/ Cable TV') +
    geom_line(data = tv, mapping = aes(x = year, y = pct_internet), size = 1.25, linetype = 'dashed') +
    annotate(geom = 'text', x = 2010, y = 0.65, label = '% Households\nw/ Internet') +
    geom_line(mapping = aes(x = doc_id, y = gamma, colour = terms), size = 1.5) +
    scale_color_manual(values = c(palette[1],palette[4])) +
    theme_classic() +
    theme(legend.position = 'none',
          legend.title = element_blank()) +
    labs(title = 'State of the Union Topics by Year with Cable/Internet & Partisan Split',
         x = '',
         y = 'Percent Strength of Topic Model in SOTU Address')

#ggsave(filename = './plots/cable_internet_effect_nolegend.png')
























# Log Likelihood
get_loglik_models <- function() {
    model_files <- list.files(path = './data/lda_models/', full.names = TRUE)
    collector = data_frame()
    for (i in 1:length(model_files)) {
        temp <- fromJSON(txt = model_files[i])
        collector <- bind_rows(collector, data_frame(num_topics = temp$num_topics, log_likelihood = temp$log_likelihood))
    }
    return(collector)
}

logs <- get_loglik_models()
ggplot(data = logs) +
    geom_line(mapping = aes(x = num_topics, y = log_likelihood), size = 1.5)








# Test Ranks
mod <- fromJSON(txt = './data/lda_models/lda_out_k5_test.json')
tbl_df(mod$terms) %>%
    arrange(desc(beta)) %>%
    filter(topic_id == 0)












