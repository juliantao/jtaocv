# Personal Quarto CV conforming to ASU FSE format

I use the following resources/steps to prepare my CV:

1. Use Quarto markdown to prepare the CV
1. Use a customized quarto extension based on a `LaTex` template, originally developed by [Prof. Robert Hyndman](https://github.com/robjhyndman/CV). New macros for `biblatex` package were created to annotate authors using the symbols required by ASU FSE. 
1. Use Zotero to manage my publications. I use the `Better BibLatex` plugin and use the `Extra` field to define the author annotations, `tex.author+an: 1=phd; 2=corresponding`. This will create a line of `author+an = {1=phd; 2=corresponding}` in the `bib` entry. With the macros defined in the `LaTex` template, symbols corresponding to each annotation type will be added to the authors' names. I also turn on the `automatic export` function so that whenever there is a change to my publication collection, the `bib` file is automatically updated. 
1. Use `csv` files as the source for various lists
1. Use `R` to prepare tables and to calculate various statistics such as paper numbers, grant amount, etc. 
1. Use virtual environment to enhance the reproducibility. Note that older version of `r` packages `RefManageR` and `bibtex` were needed to correctly parse the annotation data.

```r 
install.packages("devtools")
require("devtools")
install_version("RefManageR", "1.3.0")
install_version("bibtex", "0.4.2.3")
```

Thanks go to Prof. Robert Hyndman for the beautiful and professional CV template as well as the handy helper R functions. 
I also referred to the blog post by Prof. Kasper Hansen on [Formatting your bibliography in LaTex](http://www.hansenlab.org/cv_bibliography_tex)

