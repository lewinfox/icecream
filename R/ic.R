#' User-friendly debug statements
#'
#' @param x An expression, or nothing
#'
#' @return If `x` is an expression, returns the result of evaluating `x`. If `x` is missing nothing
#'   is returned.
#'
#' @examples
#' f <- function(x) x < 0
#'
#' ic(f(1))
#'
#' ic(f(-1))
#'
#' @importFrom rlang enquo quo_is_missing trace_back quo_get_expr caller_fn caller_env expr_deparse eval_tidy fn_env env_label maybe_missing
#' @importFrom glue glue
#' @export
ic <- function(x) {
  # Capture the input to allow us to work with the expression and value separately
  q <- enquo(x)

  # The behaviour of the function changes depending on whether input is provided or not.
  missing_input <- quo_is_missing(q)

  # In the event that icecream is totally disabled we will just return the input.
  if (getOption("icecream.enabled")) {
    trace <- trace_back()
    num_calls <- length(trace$calls)

    parent_ref <-  if (num_calls > 1) trace$calls[[num_calls - 1]][[1]] else NULL
    ref <- attr(trace$calls[[num_calls]], "srcref")
    loc <- src_loc(ref)

    # Case when location of file is unavailable
    if (nchar(loc) == 0) {
      # Probs want to look at environments
      caller <- caller_fn()
      caller_env <- if (is.null(caller)) caller_env() else fn_env(caller)

      loc <- env_label(caller_env)
      loc <- glue("<env: {loc}>")
    }

    # If we have inputs then we want the expression and value to be included in the context object
    # as well.
    if (!missing_input) {
      deparsed_expression <- expr_deparse(quo_get_expr(q))
      x <- eval_tidy(q)
      ic_print(loc, parent_ref, deparsed_expression, x)
      invisible(x)
    } else {
      ic_print(loc, parent_ref)
      invisible()
    }
  } else if (!missing_input) x
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
#'
#' @return Returns the old value of the option, invisibly.
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
