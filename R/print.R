#' Print icecream messages
#'
#' The printing logic depends on how the `ic()` function has been called and what user options are
#' set.
#'
#' @param context An object returned by `ic_get_context()`. A context in which `ic()` was called. If
#' missing (default value), no context is included in the ic message.
#' @param deparsed_exprs A list of deparsed expressions (if present) on which `ic()` was called. If
#'   missing (default value), only evaluation context is printed.
#' @param expr_vals A list with the result of evaluating `deparsed_exprs`. If the argument is missing
#' (default value), this argument should also be missing.
#' @inheritParams ic
#'
#' @return The function is called for its side effect (printing to the console) but it also returns
#'   its output string, invisibly.
#'
#' @keywords internal
ic_print <- function(prefix, context = rlang::missing_arg(), deparsed_exprs = rlang::missing_arg(), expr_vals = rlang::missing_arg(), peeking.function, max.lines) {
  # If context should be included, the argument is non-missing
  context_str <- if (!rlang::is_missing(context)) ic_construct_context_str(context) else ""

  # If expression should be included, deparsed expression and value are non-missing
  expression_str <- if (!rlang::is_missing(value)) ic_construct_expression_str(deparsed_exprs, expr_vals, peeking.function, max.lines) else ""

  # If both are non-empty strings, we need to add a separator
  sep_str <- if (nchar(context_str) > 0 & nchar(expression_str) > 0) " | " else ""

  output <- glue::glue("{prefix} {context_str}{sep_str}{expression_str}")

  cli::cli_alert_info(output) # TODO: This is where a custom print/display function would be used
  invisible(output)
}

#' Construct part of printed string
#'
#' Helper functions when constructing final string for output of `ic()`.
#'
#' @return A part of final string value.
#'
#' @name construct-str
#'
#' @keywords internal
NULL

#' @describeIn construct-str Construct context string.
#'
#' @param context An object returned by `ic_get_context()`.
ic_construct_context_str <- function(context) {
  context_str <- context[["loc"]]

  # Next, are we printing a calling function?
  if (!is.null(context[["parent_ref"]])) {
    parent_ref <- rlang::expr_deparse(context[["parent_ref"]])

    # {{.fn {}}} is additional formatting info for cli
    context_str <- glue::glue("{{.fn {context[['parent_ref']]}}} in {context_str}")
  }

  return(context_str)
}


#' @describeIn construct-str Construct expression string.
#'
#' @inheritParams ic_print
ic_construct_expression_str <- function(deparsed_exprs, expr_vals, peeking.function, max.lines) {
  # We want to print a one-line summary for complex objects like lists and data frames.
  value_str <- purrr::map_chr(expr_vals, ic_peek, peeking.function = peeking.function, max.lines = max.lines)
  expression_str <- glue::glue_collapse(
    glue::glue("{{.var {deparsed_exprs}}}: {value_str}"),
    sep = ", "
  )

  # {{.var {}}} is additional formatting info for cli
  return(glue::glue("{{.var {expression_str}}}: {str_res}"))
}