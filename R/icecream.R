#' User-friendly debug statements
#'
#' @param x An expression, or nothing
#'
#' @return If `x` is an expression, returns the result of evaluating `x`. If `x` is missing nothing
#'   is returned.
#'
#' @export
#'
#' @examples
#' f <- function(x) x < 0
#'
#' ic(f(1))
#'
#' ic(f(-1))
ic <- function(x) {
  # If `x` is missing we want to print the filename, line number and parent function
  if (missing(x)) {
    src_info <- get_source_info()
    caller_fn <- try(sys.calls()[[sys.nframe() - 1]], silent = TRUE)
    if (inherits(caller_fn, "try-error")) {
      rlang::abort("`ic()` can only be called with no arguments from within another function", "icecream-error")
    }
    src_info$fn <- caller_fn
    prefix <- getOption("icecream.alert.prefix", "ic|")
    if (src_info$file == "") {
      # If the function is defined globally then it will not have a sourceref and we will print the
      # environment instead
      caller_ref <- sys.function(-1)
      ge <- capture.output(environment(caller_ref))
      cli::cli_alert_info("{prefix} {ge}: {.fn {src_info$fn}}")
    } else {
      cli::cli_alert_info("{prefix} {.path {src_info$file}}:{.val {src_info$line}} in {.fn {src_info$fn}}")
    }
    return(invisible())
  }
  # Otherwise capture the expression, evaluate and print.
  q <- rlang::enquo(x)
  ex <- deparse(rlang::quo_get_expr(q))
  res <- rlang::eval_tidy(q)
  prefix <- getOption("icecream.alert.prefix", "ic|")
  str_res <- trimws(capture.output(str(res)))
  if (length(str_res) > 1) {
    str_res <- str_res[[1L]]
  }
  cli::cli_alert_info("{prefix} {.var {ex}}: {str_res}")
  res
}

#' Retrieve source information from the call stack
#'
#' This is adapted from the source code for [traceback()].
#'
#' @return A list containing the source file and line from which the parent function of
#'   `get_source_info()` was called.
#'
#' @keywords internal
get_source_info <- function() {
  n <- length(x <- .traceback(2))
  if (n == 0L) {
    cli::cli_alert_warning("Could not retrive source information")
  } else {
    for (i in 1L:n) {
      xi <- x[[i]]
      label <- paste0(n - i + 1L, ": ")
      m <- length(xi)
      srcref <- attr(xi, "srcref")
      if (!is.null(srcref)) {
        srcfile <- attr(srcref, "srcfile")
        line <- srcref[1L]
        filename <- basename(srcfile$filename)
        return(list(line = line, file = filename))
      }
    }
  }
}
