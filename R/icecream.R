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
  q <- rlang::enquo(x)
  missing_input <- rlang::quo_is_missing(q)
  if (isFALSE(getOption("icecream.enabled"))) {
    if (!missing_input) {
      return(x)
    }
    return(invisible())
  }
  ctx <- ic_get_context()
  # If `x` is missing we want to print the filename, line number and parent function
  if (missing_input) {
    # We want to find out where `ic()` was called from (file and line number) and print this info.
    # In the event that the function that called `ic()` was not defined in a file then we will
    # display the environment it lives in instead.
    #
    # This code is adapted from the source of `traceback()`.
    tb <- .traceback(1)
    xi <- tb[[1]]
    srcref <- attr(xi, "srcref")
    if (is.null(srcref)) {
      rlang::abort("Could not find source reference", "icecream-error")
    }
    srcfile <- attr(srcref, "srcfile")
    src_info <- list(
      line = srcref[1L],
      file = basename(srcfile$filename)
    )
    caller_fn <- try(sys.calls()[[sys.nframe() - 1]], silent = TRUE)
    if (inherits(caller_fn, "try-error")) {
      rlang::abort(
        "`ic()` can only be called with no arguments from within another function",
        "icecream-error"
      )
    }
    src_info$fn <- caller_fn
    prefix <- getOption("icecream.prefix", "ic|")
    if (src_info$file == "") {
      # If the function is defined globally then it will not have a sourceref and we will print the
      # environment instead
      caller_ref <- sys.function(-1)
      ge <- utils::capture.output(environment(caller_ref))
      cli::cli_alert_info("{prefix} {ge}: {.fn {src_info$fn[[1L]]}}")
    } else {
      cli::cli_alert_info(
        "{prefix} {.path {src_info$file}}:{.val {src_info$line}} in {.fn {src_info$fn[[1L]]}}"
      )
    }
    return(invisible())
  }
  # Otherwise capture the expression, evaluate and print.
  ex <- deparse(rlang::quo_get_expr(q))
  res <- rlang::eval_tidy(q)
  prefix <- getOption("icecream.prefix", "ic|")
  str_res <- trimws(utils::capture.output(utils::str(res))) # For nicer printing of complex objects
  if (length(str_res) > 1) {
    str_res <- str_res[[1L]]
  }
  cli::cli_alert_info("{prefix} {.var {ex}}: {str_res}")
  res
}

#' Enable or disable `ic()`
#'
#' These functions enable or disable the `ic()` function. While disabled `ic()` will do nothing
#' except evaluate and return its input.
#'
#' These are just convenience wrappers for `options(icecream.enabled = TRUE/FALSE)` used to align
#' the API with the [Python version](https://github.com/gruns/icecream#miscellaneous).
#'
#' @name enable-disable
NULL

#' @describeIn enable-disable Enable `ic()`.
#' @export
ic_enable <- function() {
  old_value <- getOption("icecream.enabled")
  options(icecream.enabled = TRUE)
  invisible(old_value)
}

#' @describeIn enable-disable Disable `ic()`.
#' @export
ic_disable <- function() {
  old_value <- getOption("icecream.enabled")
  options(icecream.enabled = FALSE)
  invisible(old_value)
}
