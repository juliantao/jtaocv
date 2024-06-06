# Original Author: Rob J Hyndman
# Modified by Julian Tao
# Function to produce very basic table, no lines or headings
# Changes made: default longtables, also activiate booktable by default to eliminate the bottom rule

baretable <- function(tbl, digits = 0,
                      include.colnames = FALSE, include.rownames = FALSE,
                      size = getOption("xtable.size", NULL),
                      add.to.row = getOption("xtable.add.to.row", NULL),
                      longtable = TRUE,
                      booktabs = TRUE,
                      ...) {
  xtable::xtable(tbl, digits = digits, ...) |>
    print(
      include.colnames = include.colnames,
      include.rownames = include.rownames,
      booktabs = booktabs,
      comment = FALSE,
      tabular.environment = if_else(longtable, "longtable", "tabular"),
      floating = FALSE,
      size = size,
      add.to.row = add.to.row,
      sanitize.text.function = function(x) {
        x
      }
    )
}

# Return dollars in pretty manner.
# Similar to prettyNum but with $ sign and working for numbers greater than 1e7
dollars <- function(x) {
  out <- paste0("\\$", sprintf("%.0f", x))
  paste0(gsub(
    "^0+\\.", ".",
    unname(prettyNum(out, ",", preserve.width = "none", scientific = FALSE))
  ))
}

# Generate biblatex section from BibEntry list
# Optionally add citation numbers from Google Scholar
# To allow citation numbers to be added, we need to
# generate a new bib file on the fly
# If rewrite = FALSE, only create section and let user
# add bibliography file in the yaml

add_bib_section <- function(x, sorting = "ynt", show_cites = FALSE, rewrite = TRUE, ...) {
  # Sort references as required
  x <- sort(x, sorting = sorting)
  # Rewrite bib file with relevant references
  if (rewrite) {
    # Generate random keys in order to avoid clashes with any other bib files
    keys <- sort(replicate(length(x), paste0(sample(c(letters, 0:9), 5, replace = TRUE), collapse = "")))
    names(x) <- keys
    # Add cites?
    if (show_cites) {
      cites <- x |>
        as.data.frame() |>
        mutate(
          key = keys,
          title = stringr::str_replace_all(title, "[{}]", "")
        ) |>
        fuzzyjoin::stringdist_left_join(
          get_scholar_cites() |> select(title, n_citations),
          by = "title", ignore_case = TRUE, distance_col = "dist"
        ) |>
        rename(title = title.x) |>
        # When there are multiple matches, choose the one with largest citations
        # This happens, for example, when a book review has the same title as the book
        # and the book is much more highly cited than its review
        group_by(title) |>
        slice_max(n_citations) |>
        ungroup() |>
        # Put back in original order after grouping operation
        arrange(key) |>
        # Add note column
        mutate(note = paste0("\\emph{[Citations: ", n_citations, "]}.")) |>
        pull(note)
      # Add cites to bib list
      if (length(cites) != length(x)) {
        stop("Can't find all citations")
      }
      for (i in seq_along(x)) {
        x[[i]]$addendum <- cites[i]
      }
    }
    # Create new bib file with x
    WriteBib(x, file = "temp.bib", append = TRUE)
  } else {
    keys <- names(x)
  }
  # Now add refsection
  cat("\\begin{refsection}")
  cat(paste0("\\nocite{", keys, "}"))
  cat("\\printbibliography[heading=none]")
  cat("\\end{refsection}")
}

# Change all bib references to a new type
# This is to allow non-standard types in bib file
# but need to change them to a standard type
# so RefManageR can handle them

change_bibtype <- function(x, newtype) {
  purrr::map(x, function(u) {
    attributes(u)$bibtype <- newtype
    return(u)
  }) |>
    as.BibEntry()
}

# Get Google scholar citations for JTao
get_scholar_cites <- function() {
  # Check if this has been run in the last day
  if (fs::file_exists(here::here("gspapers.rds"))) {
    gspapers <- readRDS(here::here("gspapers.rds"))
    info <- fs::file_info(here::here("gspapers.rds"))
    recent_run <- (Sys.Date() == anytime::anydate(info$modification_time))
  } else {
    recent_run <- FALSE
  }
  # If not run recently, grab all citation info from G Scholar
  if (!recent_run) {
    # Need to load in lots of 100 to avoid connection issues
    gspapers <- list()
    complete <- FALSE
    while (!complete) {
      k <- length(gspapers)
      gspapers[[k + 1]] <- gcite_url(
        url = "https://scholar.google.com/citations?hl=en&user=Dq4lhi4AAAAJ",
        cstart = k * 100,
        pagesize = 100
      ) |>
        gcite_papers()
      if (NROW(gspapers[[k + 1]]) < 100) {
        complete <- TRUE
      }
    }
    gspapers <- bind_rows(gspapers) |>
      as_tibble()
    # Save for next time
    saveRDS(gspapers, "gspapers.rds")
  }
  return(gspapers)
}

# Remove any temporary bib file
if (fs::file_exists("temp.bib")) {
  fs::file_delete("temp.bib")
}
