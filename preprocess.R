# Setup
library(dplyr)
library(RefManageR)
library(gcite)
source("functions.R")

# Google scholar stats
jtcite <- gcite_citation_index(
  gcite_url("https://scholar.google.com/citations?hl=en&user=Dq4lhi4AAAAJ")
)

# Read files
jtpubs <- ReadBib("./data/jtpubs.bib", check = FALSE)
jttalks <- readr::read_csv("./data/jttalks.csv")
jtteaching <- readr::read_csv("./data/jtteaching.csv")
jtoutreach <- readr::read_csv("./data/jtoutreach.csv")
jtstudents <- readr::read_csv("./data/jtstudents.csv")
jtstdawards <- readr::read_csv("./data/jtstdawards.csv")
jtreviews <- readr::read_csv("./data/jtreviews.csv")
jteditorial <- readr::read_csv("./data/jteditorial.csv")
jtgrants <- readr::read_csv("./data/jtgrants.csv")
jtorgconfs <- readr::read_csv("./data/jtorgconfs.csv")
jtmember <- readr::read_csv("./data/jtmember.csv")
jtcommittee <- readr::read_csv("./data/jtcommittee.csv")
jthonors <- readr::read_csv("./data/jthonors.csv")
jtunivserv <- readr::read_csv("./data/jtunivserv.csv")

# allstudents data
allstudents <- jtstudents |>
  arrange(-Start) |>
  mutate(
    Start = as.character(Start),
    End = as.character(End),
    End = tidyr::replace_na(End, ""),
    Note = as.character(Note),
    Note = tidyr::replace_na(Note, ""),
    Years = if_else(End == Start,
      as.character(Start),
      paste(Start, "--", End, sep = "")
    ),
    TopicNotes = if_else(Note == "",
      Topic,
      paste(Topic, ", \\emph{", Note, "}", sep = "")
    )
  )

# all teaching data

allteaching <- jtteaching |>
  mutate(
    CourseTitle = paste(Department, "-", Course, " ", Title, sep = ""),
    TermYear = paste(Year, " ", Term, sep = ""),
    JTevaluation = paste(Instructor, "/", College, sep = "")
  )

# allgrants data
allgrants <- jtgrants |>
  mutate(
    Start = as.character(Start),
    Start = tidyr::replace_na(Start, ""),
    End = as.character(End),
    End = tidyr::replace_na(End, ""),
    Co = tidyr::replace_na(Co, ""),
    Share = as.character(Share),
    Period = paste0(Start, ifelse(is.na(End), "", paste0("--", End))),
    People = if_else(Co == "",
      paste("PI: ", PI, sep = ""),
      paste("PI: ", PI, "; Co-PI: ", Co, sep = ""),
    ),
    Entry = paste(People, ". ``", Title, "''. ",
      "\\emph{", Agency, "}. ",
      "Share: ", Share, "\\%.",
      sep = ""
    ),
    Amount = dollars(Amount)
  )


# Set up vector of all bibtypes
bibtype <- as_tibble(jtpubs) |> pull(bibtype)
pubyear <- as_tibble(jtpubs) |> pull(date)

# countpub
npub <- jtpubs |>
  as_tibble() |>
  filter(!(bibtype %in% c(
    "Patent",
    "Unpublished",
    "Thesis",
    "Book",
    "Online"
  ))) |>
  NROW()

nabstract <- jtpubs |>
  as_tibble() |>
  filter(bibtype == "Abstract") |>
  NROW()

narticle <- jtpubs |>
  as_tibble() |>
  filter(bibtype == "Article") |>
  NROW()

nasujournal <- jtpubs |>
  as_tibble() |>
  filter(bibtype == "Article", date > 2018) |>
  NROW()

npub_editorial <- jtpubs |>
  as_tibble() |>
  filter(bibtype == "Editorial") |>
  NROW()

nunpublished <- jtpubs |>
  as_tibble() |>
  filter(bibtype == "Unpublished") |>
  NROW()

nreport <- jtpubs |>
  as_tibble() |>
  filter(bibtype == "Report") |>
  NROW()

nproceeding <- jtpubs |>
  as_tibble() |>
  filter(bibtype == "InProceedings") |>
  NROW()

nbook <- jtpubs |>
  as_tibble() |>
  filter(bibtype == "Book") |>
  NROW()

nchapter <- jtpubs |>
  as_tibble() |>
  filter(bibtype == "Chapter") |>
  NROW()

ninvitechapter <- jtpubs |>
  as_tibble() |>
  filter(bibtype == "InvitedChapter") |>
  NROW()

ninvitejournal <- 1

ninviteconf <- 3

nproceeding_nonref <- 0

npatent <- jtpubs |>
  as_tibble() |>
  filter(bibtype == "Patent") |>
  NROW()

# Count talk
ntalk <- jttalks |>
  as_tibble() |>
  NROW()

ntalk_internal <- jttalks |>
  filter(Note == "Internal") |>
  as_tibble() |>
  NROW()

ntalk_external <- jttalks |>
  as_tibble() |>
  filter(Note == "External") |>
  NROW()

# Count presentations

npresent_peer <- jtpubs |>
  as_tibble() |>
  filter(entrysubtype %in% c("podium", "poster")) |>
  NROW()

npresent_student <- jtpubs |>
  as_tibble() |>
  filter(grepl("phd, present", `author+an`)) |>
  NROW()

npresent_non_peer <- 0

# Count conference organization services


nconf_participated <- jtorgconfs |>
  as_tibble() |>
  NROW()

nconf_chair <- jtorgconfs |>
  filter(Type == "conf_chair") |>
  as_tibble() |>
  NROW()

nconf_committee <- jtorgconfs |>
  filter(Type == "conf_committee") |>
  as_tibble() |>
  NROW()

nconf_session_org <- jtorgconfs |>
  filter(Type == "conf_session_org") |>
  as_tibble() |>
  NROW()

nconf_session_chair <- jtorgconfs |>
  filter(Type == "conf_session_chair") |>
  as_tibble() |>
  NROW()

# Count University  services

ncommittee_university <- jtunivserv |>
  filter(Type == "committee_university") |>
  as_tibble() |>
  NROW()

ncommittee_school <- jtunivserv |>
  filter(Type == "committee_school") |>
  as_tibble() |>
  NROW()

ncommittee_unit <- jtunivserv |>
  filter(Type == "committee_unit") |>
  as_tibble() |>
  NROW()

ncommittee_search_chair <- jtunivserv |>
  filter(Type == "committee_search_chair") |>
  as_tibble() |>
  NROW()

nprogram_leader <- jtunivserv |>
  filter(Type == "program_leader") |>
  as_tibble() |>
  NROW()

# Count professional committee  services

ncommittee_profession <- jtcommittee |>
  as_tibble() |>
  NROW()

# Count review services

nreview_journal <- jtreviews |>
  filter(Type == "journal") |>
  as_tibble() |>
  NROW()

nreview_conf <- jtreviews |>
  filter(Type == "conference") |>
  as_tibble() |>
  NROW()

nreview_agency <- jtreviews |>
  filter(Type == "agency") |>
  as_tibble() |>
  NROW()

# Count editorial service

neditorial_editor <- jteditorial |>
  filter(Type == "editorial_editor") |>
  as_tibble() |>
  NROW()

neditorial_board <- jteditorial |>
  filter(Type == "editorial_board") |>
  as_tibble() |>
  NROW()

# Count outreach services

noutreach <- jtoutreach |>
  as_tibble() |>
  NROW()

# Count students

nstudent_academia <- 0

npostdoc <- allstudents |>
  filter(Degree == "PostDoc") |>
  as_tibble() |>
  NROW()

nphd_graduated <- allstudents |>
  filter(Degree == "PhD", End != "", MyRole != "Thesis Committee Member") |>
  as_tibble() |>
  NROW()

nphd_current <- allstudents |>
  filter(Degree == "PhD", End == "", MyRole != "Thesis Committee Member") |>
  as_tibble() |>
  NROW()

nms_graduated <- allstudents |>
  filter(Degree == "MS", End != "", MyRole != "Thesis Committee Member") |>
  as_tibble() |>
  NROW()

nms_current <- allstudents |>
  filter(Degree == "MS", End == "", MyRole != "Thesis Committee Member") |>
  as_tibble() |>
  NROW()

nura <- allstudents |>
  filter(Degree == "URA") |>
  as_tibble() |>
  NROW()

nhsra <- allstudents |>
  filter(Degree == "HSRA") |>
  as_tibble() |>
  NROW()

nmsra <- allstudents |>
  filter(Degree == "MSRA") |>
  as_tibble() |>
  NROW()

nstaward <- jtstdawards |>
  as_tibble() |>
  NROW()

# Count Teaching

nteaching_under_time <- allteaching |>
  filter(Course < 500) |>
  as_tibble() |>
  NROW()

nteaching_grad_time <- allteaching |>
  filter(Course > 500) |>
  as_tibble() |>
  NROW()

nteaching_under <- allteaching |>
  filter(Course < 500) |>
  pull(Course) |>
  unique() |>
  length()

nteaching_grad <- allteaching |>
  filter(Course > 500) |>
  pull(Course) |>
  unique() |>
  length()


nteaching_under_score <- allteaching |>
  filter(Course < 500) |>
  pull(Instructor) |>
  mean(na.rm = TRUE) |>
  round(digits = 2)

nteaching_grad_score <- allteaching |>
  filter(Course > 500) |>
  pull(Instructor) |>
  mean(na.rm = TRUE) |>
  round(digits = 2)

# Count grant amount

sumgrants <- jtgrants |>
  filter(Status != "Pending") |>
  pull(Amount) |>
  sum(na.rm = TRUE) |>
  dollars()

sumpending <- jtgrants |>
  filter(Status == "Pending") |>
  pull(Amount) |>
  sum(na.rm = TRUE) |>
  dollars()

sumtao <- jtgrants |>
  filter(Status != "Pending") |>
  mutate(TaoShare = Amount * Share / 100) |>
  pull(TaoShare) |>
  sum(na.rm = TRUE) |>
  dollars()

sumtaopi <- jtgrants |>
  filter(Status != "Pending", PI == "Julian Tao") |>
  pull(Amount) |>
  sum(na.rm = TRUE) |>
  dollars()


sumasu <- jtgrants |>
  filter(Status != "Pending", Status != "Deferred", Start >= 2018) |>
  pull(Amount) |>
  sum(na.rm = TRUE) |>
  dollars()

sumasutao <- jtgrants |>
  filter(Status != "Pending", Status != "Deferred", Start >= 2018) |>
  mutate(TaoShare = Amount * Share / 100) |>
  pull(TaoShare) |>
  sum(na.rm = TRUE) |>
  dollars()
