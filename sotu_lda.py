# Snippet 1: config


import json, re

import numpy as np

from stop_words import safe_get_stop_words
from nltk.tokenize import RegexpTokenizer, word_tokenize
from nltk.stem import WordNetLemmatizer

from sklearn.feature_extraction.text import CountVectorizer
import lda


#-------------------------------------------------------------------------------
# Snippet 2: wrangle1



def assemble_stopwords(languages = ['english'], user_defined = []):
    '''
    Supported Languages
        Arabic Catalan Danish Dutch
        English Finnish French German
        Hungarian Italian Norwegian Portuguese
        Romanian Russian Spanish Swedish
        Turkish Ukrainian
    '''
    sw = []
    if len(user_defined) > 0:
        sw += user_defined
    for i in languages:
        sw += safe_get_stop_words(i)
    return set(sw)

def clean_tokenize(s, stop_words):
    tokenizer = RegexpTokenizer(r'\w+')
    tokens = tokenizer.tokenize(s.lower())
    lemma = WordNetLemmatizer()
    clean = [lemma.lemmatize(token) for token in tokens if
        len(token) > 2 and
        not re.search('^\d+$', token) and  # scrub numbers if whole token
        token not in stop_words
    ]
    return clean


#-------------------------------------------------------------------------------
# Snippet 3: wrangle2


def load_clean_sotu(file_name):
    # Load Data
    with open(file_name, 'r') as f:
        sotu_raw = json.loads(f.read())

    # scrub non SOTU Join Session speeches
    exclude_files = [
        u'1963-Johnson.txt', u'1965-Johnson-2.txt',
        u'1991-Bush-2.txt', u'2001-GWBush-2.txt'
    ]
    sotu = []
    for i in sotu_raw:
        if i['file_name'] not in exclude_files:
            sotu.append(i)

    # Clean Documents
    sw = assemble_stopwords(user_defined = ['applause', 'mr', '10th','11th'])
    for i in sotu:
        i['tokens'] = clean_tokenize(s = i['content'], stop_words = sw)

    return sotu


#-------------------------------------------------------------------------------
# Snippet 4: model


def build_lda_model(doc_text, doc_ids, lda_topics, max_df = 0.5, min_df = 0.05):
    # Build document vectors
    vec = CountVectorizer(
        analyzer = 'word',
        ngram_range = (1, 3),
        max_df = max_df,
        min_df = min_df
    )
    dtm = vec.fit_transform(doc_text)
    terms = vec.get_feature_names()
    n_terms = len(terms)
    n_docs = len(doc_ids)

    # Build LDA Model
    lda_model = lda.LDA(
        n_topics = lda_topics,
        n_iter = 2500,
        alpha = 0.1,
        eta = 0.01,
        random_state = 1300,
        refresh = 100
    )
    lda_model.fit(dtm)


#-------------------------------------------------------------------------------
# Snippet 5: extract


    # Build Output Object
    output = {}
    output['num_topics'] = lda_topics
    output['log_likelihood'] = lda_model.loglikelihood()

    output['terms'] = []
    for (topic_id, topic_dist) in enumerate(lda_model.topic_word_):
        s_index = np.argsort(topic_dist)
        term_order = n_terms - np.arange(n_terms).take(s_index.argsort())
        for n in range(n_terms):
            output['terms'].append({
                'topic_id': topic_id,
                'term': terms[n],
                'rank': term_order[n],
                'beta': topic_dist[n]
            })

    output['docs'] = []
    for (topic_id, doc_dist) in enumerate(lda_model.doc_topic_.swapaxes(0,1)):
        for n in range(n_docs):
            output['docs'].append({
                'topic_id': topic_id,
                'doc_id': doc_ids[n],
                'gamma': doc_dist[n]
            })

    return output


#-------------------------------------------------------------------------------
# Snippet 6: pipeline


def pipeline(data, lda_topics):
    sotu_ids = [i['year'] for i in data]
    sotu_text = [' '.join(i['tokens']) for i in data]

    mod = build_lda_model(
        doc_text = sotu_text,
        doc_ids = sotu_ids,
        lda_topics = lda_topics
    )

    out_file = './data/lda_models/lda_out_k{k}_test.json'.format(k = lda_topics)
    with open(out_file, 'w') as f:
        f.write(json.dumps(mod))

    return


sotu = load_clean_sotu(file_name = './data/sotu_parsed.json')
for i in range(1, 12):
    pipeline(sotu, i)
