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

    parent_ref <- if (num_calls > 1) trace$calls[[num_calls - 1]][[1]] else NULL
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

#' `with_ic_enable()` and `with_ic_disable()`
#'
#' These functions let you evaluate an expression with either `ic()` enabled or
#' disabled without afftecting if `ic()` is enabled globally.
#'
#' @name ic-single-use
#'
#' @param expr an  expression containing the `ic()`` function.
#'
#' @return the result of evaluating the expression with the `ic()` function
#'   enabled (for `with_ic_enable()`) or disabled (for `with_ic_disable()`).
#'   After returning this result the `ic()` function will remain what it was
#'   before this function ran.
#'
#' @examples
#' ic_enable()
#' fun <- function(x) {
#'   ic(x*100)
#' }
#'
#' fun(2)                          #returns i ic| `x * 100`: num 200
#' with_ic_disable(fun(2))         #returns [1] 200
#' fun(4)                          #returns i ic| `x * 100`: num 400
#'
#' ic_disable()
#' fun2 <- function(x) {
#'   x/100
#' }
#'
#' fun2(300)                       #returns [1] 3
#' ic(fun2(300))                   #returns [1] 3
#' with_ic_enable(fun2(300))       #returns [1] 3
#' with_ic_enable(ic(fun2(300)))   #returns i ic| `fun2(300)`: num 3
#' fun2(500)                       #returns [1] 5
#'
NULL

#' @describeIn  ic-single-use evaluates the expression with `ic()` enabled.
#' @export
with_ic_enable <- function(expr) {
  withr::with_options(list(icecream.enabled = TRUE), expr)
}

#' @describeIn ic-single-use evaluates the expression with `ic()` disabled.
#' @export
with_ic_disable <- function(expr) {
  withr::with_options(list(icecream.enabled = FALSE), expr)
}

