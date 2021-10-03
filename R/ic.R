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
#' @export
ic <- function(x) {
  # Capture the input to allow us to work with the expression and value separately
  q <- rlang::enquo(x)

  # The behaviour of the function changes depending on whether input is provided or not.
  missing_input <- rlang::quo_is_missing(q)

  # In the event that icecream is totally disabled we will just return the input.
  if (getOption("icecream.enabled")) {
    trace <- rlang::trace_back()

    # In rlang 1.0.0 `calls` became `call`. See https://github.com/lewinfox/icecream/issues/8
    #
    # TODO: Deprecate at some point?
    if (utils::packageVersion("rlang") < "1.0.0") {
      call_stack <- trace$calls
    } else {
      call_stack <- trace$call
    }

    num_calls <- length(call_stack)

    parent_ref <- if (num_calls > 1) call_stack[[num_calls - 1]][[1]] else NULL
    ref <- attr(call_stack[[num_calls]], "srcref")
    loc <- src_loc(ref)

    # Case when location of file is unavailable
    if (nchar(loc) == 0) {
      # Probs want to look at environments
      caller <- rlang::caller_fn()
      caller_env <- if (is.null(caller)) rlang::caller_env() else rlang::fn_env(caller)

      loc <- rlang::env_label(caller_env)
      loc <- glue::glue("<env: {loc}>")
    }

    # If we have inputs then we want the expression and value to be included in the context object
    # as well.
    if (!missing_input) {
      deparsed_expression <- rlang::expr_deparse(rlang::quo_get_expr(q))
      x <- rlang::eval_tidy(q)
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

#' Temporarily enable or disable `ic()`
#'
#' These functions let you evaluate an expression with either `ic()` enabled or disabled without
#' affecting if `ic()` is enabled globally.
#'
#' @name ic-single-use
#'
#' @param expr An expression containing the `ic()` function.
#'
#' @return Returns the result of evaluating the expression.
#'
#' @examples
#' ic_enable()
#'
#' fun <- function(x) {
#'   ic(x * 100)
#' }
#'
#' fun(2)
#'
#' with_ic_disable(fun(2))
#'
#' fun(4)
#'
#' ic_disable()
#'
#' fun(1)
#'
#' with_ic_enable(fun(1))
NULL

#' @describeIn ic-single-use evaluates the expression with `ic()` enabled.
#' @export
with_ic_enable <- function(expr) {
  withr::with_options(list(icecream.enabled = TRUE), expr)
}

#' @describeIn ic-single-use evaluates the expression with `ic()` disabled.
#' @export
with_ic_disable <- function(expr) {
  withr::with_options(list(icecream.enabled = FALSE), expr)
}
