Latest update: 2020-03-17

Disclaimer
----------

This is work in progress and I will try to update/improve on the fly/

Code
----

Code to extract metadata and PDFs on Covid-19 articles. Will improve and
annotate along the way (improve where needed!). Extracted metadata of
arXiv papers is based on selected substrings related to Covid-19 (see
code, e.g., ncov, covid-19, and so forth). Titles speak for itself for
now.

-   For arXiv aI used the “aRxiv” packages for R using a set of
    substring queries.

-   For medRxiv (bio and med) I built a scraper that (thus far) grabs
    slightly less metadata than those mentioned above (see code).

-   medRxiv conveniently curated and posted the Covid-19 collection on a
    dedicated URL together with bioRxiv papers. This leads to duplicates
    between the medRxiv (containing both bioRxic and medRxiv) and
    bioRxiv collection I collected earlier.

Continuation medRxiv?
---------------------

Will most likely continue with the medRxiv collection as it contains two
curated corpora and does not rely on substring searches. Will keep
everything online for now, but just a fyi. I marked which medRxiv corpus
is actually “med” or “bio” in the pdfs.

Text Analyses
-------------

Perform some text analyses and generate word counts, topics, concept
co-occurrences, and so forth. Work in progress.

Data
----

Metadata (e.g., abstracts, titles, authors, etc.) for Covid-19 related
repository publications from biorXiv, arXiv, and medRxiv (but read above
because there migh be duplicates in the latter).

-   arXiv metadata: contains metadata parsed via substring search with
    the arxiv package in R.
-   medRxiv metadata: contains metadata collected via scraper built for
    medRxiv curated Covid-19 papers. This contains *both* bio- and
    medRxiv.
-   biorXiv metadata: contains metadata parsed via substring search with
    the biorxiv pckage in R. (!won’t continue this one!)

Zip
---

Zip file contains all extracted full text PDFs of the files mentioned in
the metadata. Zips can be found here:

-   [arXiv Covid-2019
    PDFs](https://stanford.box.com/v/arxiv-covid-19-20200316). Match on
    rownumber or

-   [medRxiv Covid-2019
    PDFs](https://stanford.box.com/v/medrxiv-covid-19-20200317).
    Contains bio and medRxiv pdfs (as marked in the names). You can
    match with metadata on pdf name and doi in metadata:
    `trimws(sub('.*\\/', '', huh[i,3]))`

-   [biorXiv Covid-2019
    PDFs](https://stanford.box.com/v/biorxiv-covid-19-20200316) (!Won’t
    continue this!)

Usage
-----

Please use as needed, but credit the data and coding collection effort
by referencing to this Git. Use only for academic and educational
purposes. The author hereby disclaims any and all representations,
warranties, and responsibility with respect to these data and code.
Copyright for the papers in the repositories is with the respective
authors. Reliance on these data and code for medical advice or in
commerce is strictly prohibited.
