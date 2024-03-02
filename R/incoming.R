#' Report on the incoming queue at CRAN
#'
#' Summarizes the current state of the incoming queue at CRAN
#'
#' @param folder A character variable correponding to one (or more) of the existing directories
#' at the \code{incoming} directory at CRAN, or a meta value. The default value is \sQuote{auto}
#' to designate the combination of \sQuote{pending}, \sQuote{recheck}, \sQuote{inspect} and
#' \sQuote{pretest}
#' @param check A logical variable with a default of \sQuote{TRUE} indicating that the value
#' of \sQuote{folder} should be check against a list of known values. Using \sQuote{FALSE}
#' allows new values, or different combinations not supported by default.
#' @param sort A logical variable with a default of \sQuote{TRUE} indicating that the overall
#' result be sorted by column \sQuote{Age}.
#' @return A \sQuote{data.table} object with first column \sQuote{folder} as well as columns
#' for package name, upload time and size.
#' @examples
#' \dontrun{
#' incoming()
#' }
incoming <- function(folder=c("auto", "archive", "inspect", "newbies", "pending", "pretest", "publish",
                              "recheck", "waiting", "BA", "KH", "KL", "UL", "VW"),
                     check = TRUE, sort = TRUE) {
    if (check) {
        folder <- match.arg(folder)
        if (folder == "auto") folder <- c("pending", "recheck", "inspect", "pretest", "waiting")
    }
    tz <- Sys.getenv("TZ", "UTC")
    now <- Sys.time()
    .read_one_folder <- function(folder) {
        dirread <- curl::curl_fetch_memory(file.path("https://cran.r-project.org/incoming", folder))
        dirtxt <- rawToChar(dirread[["content"]])
        dir <- data.table::data.table(Folder=folder, XML::readHTMLTable(dirtxt)[[1]])
        setnames(dir, "Last modified", "Time")
        dir <- dir[is.na(Name) == FALSE & Name != "Parent Directory", ]
        dir <- dir[, let(V1 = NULL,
                         Time = as.POSIXct(Time, tz="Europe/Vienna"),
                         Description = NULL)][order(-Time)]
        dir <- dir[, Time := as.POSIXct(format(Time, tz=tz))]
        dir <- dir[, Age := round(difftime(now, Time, units="hours"), 2)]
        dir
    }
    mccdef <- if (Sys.info()[["sysname"]] == "Windows") 1L else 2L   # see ?parallel::mclapply
    rl <- parallel::mclapply(folder, .read_one_folder, mc.cores = getOption("mc.cores", mccdef))

    res <- rbindlist(rl)
    if (sort) res <- res[order(Age)]

    res
}

utils::globalVariables(c("Name", "Time", "Age"))
