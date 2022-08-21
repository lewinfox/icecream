#' User-friendly debug statements
#'
#' @param ... Any number of expressions, possibly also 0 expressions.
#' @param prefix A prefix to use at the start of the icecream message.
#' @param peeking_function A function to use to transform `x` to string.
#' @param max_lines A number of lines that the output will be truncated to.
#' @param always_include_context A logical value. Whether or not to include context when no `x` is provided.
#'
#' @details Function is primarily called for its side effects. It does not change the value of expression
#' (or expressions) passed to it, but it prints them with their values to the screen. All named parameters
#' have corresponding options which are their default values. For details, see [`icecream`].
#'
#' @return If `...` is missing, nothing is returned. If `...` is a single expression, returns the result
#'     of evaluating it. If `...` contains multiple expressions, it returns list with their values in an
#'     according order.
#'
#' @examples
#' ic()
#'
#' f <- function(x) x < 0
#'
#' ic(f(1))
#'
#' ic(f(-1))
#'
#' ic(f(12), sum(1:5), 5)
#'
#' @export
ic <- function(...,
               prefix = get_opt("icecream.prefix", "icecream_prefix"),
               peeking_function = get_opt("icecream.peeking.function", "icecream_peeking_function"),
               max_lines = get_opt("icecream.max.lines", "icecream_max_lines"),
               always_include_context = get_opt("icecream.always.include.context", "icecream_always_include_context")
               ) {
  # Capture the input to allow us to work with the expression and value separately
  quosures <- rlang::enquos(...)

  # The behaviour of the function changes depending on whether input is provided or not.
  missing_input <- (length(quosures) == 0)

  if (missing_input) {
    # If icecream is enabled, for missing input we will print the context
    if (get_opt("icecream.enabled", "icecream_enabled"))
      ic_print_only_context(prefix)

    # In the event that icecream is totally disabled we will just return invisibly.
    return(invisible())
  } else {
    # If icecream is enabled, we need to evaluate quosure and print the value
    if (get_opt("icecream.enabled", "icecream_enabled")) {
      x <- ic_evaluate_and_print(quosures, prefix, peeking_function, max_lines, always_include_context)
    } else {
      x <- simplify_single(list(...))
    }

    # We return the value invisibly, evaluating it if needed
    return(invisible(x))
  }
}

#' Print only context when no value is provided
#'
#' @inheritParams ic
#'
#' @return The same as [`ic_print`]
#'
#' @keywords internal
ic_print_only_context <- function(prefix) {
  context <- ic_get_context()
  ic_print(prefix = prefix, context = context)
}

#' Evaluate expressions and print them with value
#'
#' @param quosures A vector of quosures, contains expressions to be evaluated.
#' @inheritParams ic
#'
#' @return Evaluated value of expression `quosures`.
#'
#' @keywords internal
ic_evaluate_and_print <- function(quosures, prefix, peeking_function, max_lines, always_include_context) {
  deparsed_exprs <- purrr::map(quosures, ~ rlang::expr_deparse(rlang::quo_get_expr(.x)))
  expr_vals <- purrr::map(quosures, rlang::eval_tidy)

  # We are removing the names of expression (which are empty strings unless provided with a name)
  # TODO: discuss what to do if an expression is named
  names(expr_vals) <- NULL

  if (always_include_context) {
    context <- ic_get_context()
    ic_print(prefix, context, deparsed_exprs, expr_vals, peeking_function, max_lines)
  } else {
    ic_print(prefix, deparsed_exprs = deparsed_exprs, expr_vals = expr_vals, peeking_function = peeking_function, max_lines = max_lines)
  }

  # If there was only one expression, unlist it
  return(simplify_single(expr_vals))
}

#' Extract call stack from the trace
#'
#' This operation is extracted as a separate function because it contains checking for
#' rlang function due to compatibility issue.
#'
#' @param trace A stack trace resulting from calling [rlang::trace_back()].
#'
#' @return A call stack, list of function calls.
#'
#' @keywords internal
ic_extract_call_stack <- function(trace) {
  # In rlang 1.0.0 `calls` became `call`. See https://github.com/lewinfox/icecream/issues/8
  #
  # TODO: Deprecate at some point?
  if (utils::packageVersion("rlang") < "1.0.0") {
    call_stack <- trace$calls
  } else {
    call_stack <- trace$call
  }
}

#' Get context of evaluation of `ic()` call
#'
#' @param nest_level An integer. Number of calls to skip in call stack. Calls need to be skipped
#' because `ic()` and other internal functions add calls to the stack, which are not of our
#' interest. Default value of 3 corresponds to three skips:
#' `ic()` > `ic_evaluate_and_print()`/`ic_print_only_context()` > `ic_get_context()`
#'
#' @return A list of two objects: `loc` containing name of the file where `ic()` is called
#' with line and row number if available, or environment of where the calling function definition
#' is if not available; `parent_ref` containing function in which the `ic()` is called if available,
#' `NULL` otherwise.
#'
#' @keywords internal
ic_get_context <- function(nest_level = 3) {
  trace <- rlang::trace_back()
  call_stack <- ic_extract_call_stack(trace)
  num_calls <- length(call_stack)

  # If num_calls is higher than nest_level, then the function that we are interested in (ic)
  # was called from env directly
  parent_ref <- if (num_calls > nest_level) call_stack[[num_calls - nest_level]][[1]] else NULL

  # We want to look at where the function of interest (ic) was called, so we need to get
  # srcref of call at the last call minus (nest_level - 1) levels
  ref <- attr(call_stack[[num_calls - nest_level + 1]], "srcref")
  loc <- src_loc(ref)

  # Case when location of file is unavailable
  if (nchar(loc) == 0) {
    # Probs want to look at environments
    caller <- rlang::caller_fn(nest_level)
    caller_env <- if (is.null(caller)) rlang::caller_env(nest_level) else rlang::fn_env(caller)

    loc <- rlang::env_label(caller_env)
    loc <- glue::glue("<env: {loc}>")
  }

  return(list(loc = loc, parent_ref = parent_ref))
}

#' Enable or disable `ic()`
#'
#' These functions enable or disable the `ic()` function. While disabled `ic()` will do nothing
#' except evaluate and return its input.
#'
#' These are just convenience wrappers for `options(icecream_enabled = TRUE/FALSE)` used to align
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
  if (is.null(old_value)) {
    old_value <- getOption("icecream_enabled")
    options(icecream_enabled = TRUE)
  } else {
    options(icecream.enabled = TRUE)
  }
  invisible(old_value)
}

#' @describeIn enable-disable Disable `ic()`.
#' @export
ic_disable <- function() {
  old_value <- getOption("icecream.enabled")
  if (is.null(old_value)) {
    old_value <- getOption("icecream_enabled")
    options(icecream_enabled = FALSE)
  } else {
    options(icecream.enabled = FALSE)
  }
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
  withr::with_options(list(icecream_enabled = TRUE, icecream.enabled = TRUE), expr)
}

#' @describeIn ic-single-use evaluates the expression with `ic()` disabled.
#' @export
with_ic_disable <- function(expr) {
  withr::with_options(list(icecream_enabled = FALSE, icecream.enabled = FALSE), expr)
}
