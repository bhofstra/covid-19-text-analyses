Latest update: 2020-04-07

Disclaimer
----------

This is work in progress and I will try to update and improve on the
fly!

Code
----

**covid-19.R** contains the code to scrape the data and it will extract
metadata and PDFs on Covid-19 articles from bio/med/aRxiv. Will improve
and annotate along the way (improve where needed!). Extracted metadata
of the arXiv papers is based on selected substrings related to Covid-19
(see code, e.g., ncov, covid-19, and so forth).

-   For arXiv used the “aRxiv” packages for R using a set of substring
    queries.
-   ForbioRxiv and medRxic I built a scraper that (thus far) grabs
    slightly less metadata than those mentioned above (see code, likely
    to be improved simply).
-   (medRxiv conveniently curates and posted the Covid-19 collection on
    a dedicatedp page with medRxiv and bioRxiv papers from which I pull
    those data.)

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
    PDFs](https://stanford.box.com/v/arxiv-covid-19-20200407). Match on
    rownumber or
-   [medRxiv and bioRxic Covid-2019
    PDFs](https://stanford.box.com/v/med-bio-rxiv-covid-19-20200407).
-   You can match PDF to metadata with doi.

Usage
-----

Please use as needed, but credit the data and coding collection effort
by referencing to this Git. Use only for academic and educational
purposes. The author hereby disclaims any and all representations,
warranties, and responsibility with respect to these data and code.
Copyright for the papers in the repositories is with the respective
authors. Reliance on these data and code for medical advice or in
commerce is strictly prohibited.
