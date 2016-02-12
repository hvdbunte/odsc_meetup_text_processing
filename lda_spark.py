# Snippet 1: config

from pyspark import SparkConf, SparkContext

from pyspark.mllib.linalg import Vectors
from pyspark.mllib.clustering import LDA, LDAModel

import string, datetime, json, re
from stop_words import get_stop_words
import numpy as np

from nltk.tokenize import RegexpTokenizer, word_tokenize
from nltk.stem import WordNetLemmatizer


num_topics = 64

# Make Context Config & Connection
conf = (SparkConf()
    .setMaster('local[6]')
    .setAppName('LDA Test')
)
sc = SparkContext(conf = conf)

# Load Base data
raw_data = sc.textFile("/Users/frankdevans/Downloads/fulltext_all.txt")


#-------------------------------------------------------------------------------
# Snippet 2: wrangle


# Clean Raw Data
def clean_tokenize(s):
    tokenizer = RegexpTokenizer(r'\w+')
    tokens = tokenizer.tokenize(s.lower())
    sw = set(get_stop_words('english'))
    lemma = WordNetLemmatizer()
    clean = [lemma.lemmatize(token) for token in tokens if
        re.search('[a-zA-Z]', token) and
        len(token) > 3 and
        token not in sw
    ]
    return clean


clean = (raw_data
    .map(lambda x: x.split('|'))
    .filter(lambda (id, title, text): id != 'record_id')
    .map(lambda (id, title, text): (id, text))
    .map(lambda (id, text): (id, clean_tokenize(text)))
    .cache()
)
num_docs = clean.count()


#-------------------------------------------------------------------------------
# Snippet 3: build references


# Build Document Frequency Reference
docfreq_keep = (clean
    .flatMap(lambda (id, tokens): list(set(tokens)))
    .map(lambda word: (word, 1))
    .groupByKey()
    .mapValues(sum)
    .map(lambda (word, docnum): (word, float(docnum) / num_docs))
    .filter(lambda (word, docfreq): (docfreq > 0.01) and (docfreq < 0.5))
    .map(lambda (word, docfreq): word)
    .collect()
)
docfreq_list = sc.broadcast(set(docfreq_keep))


# Build Unique Token Index
unique_tokens = (clean
    .flatMap(lambda (id, tokens): tokens)
    .map(lambda word: (word, 1))
    .filter(lambda (word, num): word in docfreq_list.value)
    .groupByKey()
    .mapValues(sum)
    .map(lambda (word, num): (num, word))
    .sortByKey()
    .map(lambda (num, word): word)
    .top(25000)
)
unique_set = sc.broadcast(set(unique_tokens))
unique = sc.broadcast(unique_tokens)


#-------------------------------------------------------------------------------
# Sippet 4: index vectors


def word_index_vector(tokens):
    term_freq = {}
    for i in tokens:
        if i not in unique_set.value:
            continue
        if i not in term_freq:
            term_freq[i] = 0
        term_freq[i] += 1

    tf = np.zeros(len(unique.value))
    for word in term_freq:
        idx = unique.value.index(word)
        tf[idx] = float(term_freq[word])

    tfv = Vectors.dense(tf)
    return tfv


# Convert Documents to Index Vectors
tf_matrix = (clean
    .map(lambda (id, tokens): word_index_vector(tokens))
    .zipWithIndex()
    .map(lambda (tok_vec, zID): [zID, tok_vec])
    .cache()
) # Exit: [zID, DenseVector()]


# Preserve record_id
id_index = (clean
    .map(lambda (id, tokens): id)
    .zipWithIndex()
    .map(lambda (id, zID): (zID, id))
)


#-------------------------------------------------------------------------------
# Snippet 5: model


# LDA Model
lda_model = LDA.train(
    rdd = tf_matrix,
    k = num_topics,
    maxIterations = 50,
    seed = 1300,
    optimizer = 'em'
)
topics_matrix = sc.broadcast(lda_model.topicsMatrix())


# Document Topics
doc_topics = (tf_matrix
    .map(lambda (zID, dv): (zID, dv.dot(topics_matrix.value)))
    .map(lambda (zID, res): (zID, res * (1 / np.sum(res))))
    .join(id_index)
    .map(lambda (zID, (res, doc_id)): (doc_id, list(res)))
)

# Topic Terms
def get_topic_terms():
    topics = lda_model.topicsMatrix()
    topic_terms = {}
    for i in range(len(unique_tokens)):
        term = unique_tokens[i]
        topic_terms[term] = list(topics[i,])
    return topic_terms


#-------------------------------------------------------------------------------
# Snippet 6: output object


# Build Output Object
output = {}
output['num_topics'] = num_topics
output['num_docs'] = num_docs
output['num_terms'] = len(unique_tokens)
output['doc_topics'] = doc_topics.collectAsMap()
output['topic_terms'] = get_topic_terms()

file_name = "lda_lemma_k{num_topics}_d{num_docs}_t{num_terms}.json".format(
    num_topics = num_topics,
    num_docs = num_docs,
    num_terms = len(unique_tokens)
)
with open('./output/' + file_name, 'w') as f:
    f.write(json.dumps(output))


#-------------------------------------------------------------------------------
# Snippet 7: output example JSON
