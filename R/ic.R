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
  # Capture the input to allow us to work with the expression and value separately
  q <- rlang::enquo(x)

  # The behaviour of the function changes depending on whether input is provided or not.
  missing_input <- rlang::quo_is_missing(q)

  # In the event that icecream is totally disabled we will just return the input.
  #
  # TODO: This triggers evaluation of the input. Is this a problem?
  if (isFALSE(getOption("icecream.enabled"))) {
    if (!missing_input) {
      return(x)
    }
    return(invisible())
  }

  # We need to extract the context of the call (which file and line was it called from, or which
  # environment) in order to construct the message to print. See `ic_print()` for the formatting
  # part.
  ctx <- ic_get_context()

  # If we have inputs then we will want the expression and value to be included in the context
  # object as well.
  if (!missing_input) {
    ctx$expression <- deparse(rlang::quo_get_expr(q))
    ctx$value <- rlang::eval_tidy(q)
  }

  # Print the output!
  ic_print(ctx)

  # Return the result
  if (!missing_input) {
    return(ctx$value)
  }
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
