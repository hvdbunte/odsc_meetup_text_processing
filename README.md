## odsc_meetup_text_processing
Example code from ODSC Meetup presentation on Text Mining with R, Python, &amp; Spark. The meetup occurred on Feb. 10, 2016 in Boston, MA. The slides from the presentation are [available](http://www.slideshare.net/frankdevans/text-modeling-with-r-python-and-spark).



#### Section 1: Text Clustering with R

`sotu_cluster.R`: this script is the principal script for the entire workflow. This is a presentation version of the script meant to show the main aspects of the workflow.  For a more complete version of the subject matter of this project see the final writeup on [RPubs](http://rpubs.com/frankdevans/sotu_cluster), or check out the full code repo on the [project](https://github.com/frankdevans/sotu_cluster).


#### Section 2: Topic Modeling with Python
This project was originally written about in the subject matter domain for the Exaptive [blog](http://www.exaptive.com/blog/topic-modeling-the-state-of-the-union).

`sotu_parsed.json`: clean version of the raw data, file used by python script for presented analysis. Data is stored as JSON array of objects.

`sotu_lda.py`: main python script with algorithmic components, this is the script that was snippeted for presentation.

`sotu_lda_viz.R`: R code used to build visualization layer for presentation.


#### Section 3: Topic Modeling with Spark
`lda_spark.py`: PySpark code shown during presentation, provides entire processing pipeline as demonstrated.

`lda_spark_output.json`: notation example of the extracted data format from LDA model shown, this was also shown during presentation.
