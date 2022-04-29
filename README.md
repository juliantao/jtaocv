# Personal LaTex CV conforming to ASU FSE format

* Most of the lists are imported from csv data files using the *datatool*
package to control the formats. This makes it easy to update the CV by simply
add/delete/revise the csv files and then recomplie the tex file. So your tex
file is much cleaner and you do not need to worry about formating the fields
anymore.

* Macros are created to annotate authors using different symbols. This was
a pain when I was maintaining my CV using a word processor. With the *biblatex*
package, you can easily add an annotation field to assign roles for authors that
you want to highlight. This may seem a tedious process. But if you use vim or
zotero to manage your bib files, this can be done very efficiently.


Credits: I used the beautiful and professional template originally created by Prof. Robert Hyndman [robjhyndman](https://github.com/robjhyndman/CV) as a starting point.
I made some changes on the paper size, and bib treatment. In my version, I use keyword to sort publications, instead of categories. I also made the CV more modular by using the *datatool* package.


I also referred to the blog post by Prof. Kasper Hansen on [Formatting your bibliography in Latex](http://www.hansenlab.org/cv_bibliography_tex)

