#' Report on the incoming queue at CRAN
#'
#' Summarizes the current state of the incoming queue at CRAN. A shorter alias is provided by
#' function \code{ciw}.
#'
#' @param folder A character variable correponding to one (or more) of the existing directories
#' at the \code{incoming} directory at CRAN, or a meta value. The default value is \sQuote{auto}
#' to designate the combination of \sQuote{pending}, \sQuote{recheck}, \sQuote{inspect} and
#' \sQuote{pretest}. See also below for \code{known_folders}.
#' @param check A logical variable with a default of \sQuote{TRUE} indicating that the value
#' of \sQuote{folder} should be check against a list of known values. Using \sQuote{FALSE}
#' allows new values, or different combinations not supported by default.
#' @param sort A logical variable with a default of \sQuote{TRUE} indicating that the overall
#' result be sorted by column \sQuote{Age}.
#' @param ping A logical variable with a default of \sQuote{TRUE} indicating that network
#' connectivity should be checked first.
#' @return A \sQuote{data.table} object with first column \sQuote{folder} as well as columns
#' for package name, upload time and size.
#' @examples
#' incoming()
incoming <- function(folder=c("auto", known_folders), check = TRUE, sort = TRUE, ping = TRUE) {
    if (check) {
        folder <- match.arg(folder)
        if (folder == "auto") folder <- c("pending", "recheck", "inspect", "pretest", "waiting")
    }

    url <- "https://cran.r-project.org/incoming"

    .is_connected <- function(site) { 	     # this is borrowed from dang::isConnected()
        uoc <- function(site) {
            con <- url(site)                 # need to assign so that we can close
            open(con)                        # in case of success we have a connection
            close(con)                       # ... so we need to clean up
        }
        suppressWarnings(!inherits(try(uoc(site), silent=TRUE), "try-error"))
    }
    if (ping && !.is_connected(url)) {
        message("** No results as no connectivity to CRAN. **")
        return(data.table())
    }

    ## use curl for parallel reads which requires a 'global' list object and callbacks
    results <- list()
    .success <- function(x) results <<- append(results, list(x))
    .failure <- function(str) cat(paste("Failed request: ", str, "\n"), file = stderr())
    for (fldr in folder) {
        curl::multi_add(curl::new_handle(url = file.path(url, fldr)),
                        done = .success,
                        fail = .failure)
    }
    res <- curl::multi_run() 	# run multiple calls, 'results' filled as callback result

    tz <- Sys.getenv("TZ", "UTC")
    now <- Sys.time()

    .transform_one_folder <- function(obj) { # worker function to transform obj returned by curl
        folder <- basename(obj[["url"]])     # url is the actual URL called, we recover folder from it
        if (obj[["status_code"]] == 200) {
            txt <- rawToChar(obj[["content"]])   # content is the payload, by curl convention raw bytes
            tab <- XML::readHTMLTable(txt)[[1]]  # extract the per-folder directory listing table
        } else {
            tab <- data.table(V1=character(), Name=character(), Description=character(),
                              `Last modified`=as.POSIXct(double()), Size=character())
        }
        dir <- data.table::data.table(Folder=folder, tab) 	# and now some data.table munging
        data.table::setnames(dir, "Last modified", "Time")
        dir <- dir[is.na(Name) == FALSE & Name != "Parent Directory", ]
        dir <- dir[, let(V1 = NULL,
                         Time = as.POSIXct(Time, tz="Europe/Vienna"),
                         Description = NULL)]
        dir <- dir[order(-Time), Time := as.POSIXct(format(Time, tz=tz))]
        dir <- dir[, Age := round(difftime(now, Time, units="hours"), 2)]
        dir
    }

    res <- rbindlist(lapply(results, .transform_one_folder))
    if (sort && nrow(res) > 0) res <- res[order(Age)]

    res
}

#' @rdname incoming
ciw <- incoming

#' @rdname incoming
#' @format \code{known_folders} is an unexported global state variable with a simple vector of
#' the (currently) known directory names \dQuote{archive}, \dQuote{inspect}, \dQuote{newbies},
#' \dQuote{pending}, \dQuote{pretest}, \dQuote{publish}, \dQuote{recheck}, \dQuote{waiting},
#' \dQuote{BA}, \dQuote{KH}, \dQuote{KL}, \dQuote{UL}, and \dQuote{VW}.
known_folders <- c("archive", "inspect", "newbies", "pending", "pretest", "publish",
                   "recheck", "waiting", "BA", "KH", "KL", "UL", "VW")

utils::globalVariables(c("Name", "Time", "Age"))
