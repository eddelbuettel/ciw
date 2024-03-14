
## ciw -- CRAN Incoming Watcher

[![CI](https://github.com/eddelbuettel/ciw/actions/workflows/ci.yaml/badge.svg)](https://github.com/eddelbuettel/ciw/actions/workflows/ci.yaml)
[![License](https://eddelbuettel.github.io/badges/GPL2+.svg)](https://www.gnu.org/licenses/gpl-2.0.html)
[![CRAN](https://www.r-pkg.org/badges/version/ciw)](https://cran.r-project.org/package=ciw)
[![r-universe](https://eddelbuettel.r-universe.dev/badges/ciw)](https://eddelbuettel.r-universe.dev/ciw)
[![Dependencies](https://tinyverse.netlify.com/badge/ciw)](https://cran.r-project.org/package=ciw)
[![Last Commit](https://img.shields.io/github/last-commit/eddelbuettel/ciw)](https://github.com/eddelbuettel/ciw)

### Example

![](https://eddelbuettel.github.io/images/2024-02-29/ciw.r_demo_2024-02-29_11-48.gif)

### Motivation

The `incoming/` directories at [CRAN][cran] can be perused from a webbrowser, have long had a
dedicated [watcher dashboard page](https://r-hub.github.io/cransays/articles/dashboard.html), and
are accessible via the [foghorn][foghorn] package.

Yet I was looking for something both quicker, and simpler, and easier to manipulate.  After taking a
quick look at this, I quickly had a working sketch of what is now the
[incoming()](https://github.com/eddelbuettel/ciw/blob/master/R/incoming.R) function here.  Adding a
[command-line wrapper for
littler](https://github.com/eddelbuettel/littler/blob/master/inst/examples/ciw.r) was equally quick,
and provides what is shown in the gif above.

### Installation

The package is on [CRAN][cran] and can be installed via a simple `install.packages("ciw")`.
Alternatively you can install it from here or from [r-universe][r-universe ciw].

To also run `ciw.r` you need to either install [littler][littler] or just fetch the script (and
maybe tweak it for `Rscript` use of [docopt][docopt]).

### Author

Dirk Eddelbuettel

### License

GPL (>= 2)

[cran]: https://cran.r-project.org
[foghorn]: https://cran.r-project.org/package=foghorn
[littler]: https://cran.r-project.org/package=littler
[remotes]: https://cran.r-project.org/package=remotes
[docopt]: https://cran.r-project.org/package=docopt
[r-universe ciw]: https://eddelbuettel.r-universe.dev/ciw
