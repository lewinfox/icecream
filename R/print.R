#' Print icecream messages
#'
#' The printing logic depends on how the `ic()` function has been called and what user options are
#' set.
#'
#' @param loc String detailing function definition location, which may be a source ref (file, line
#'   number and character index) or an environment.
#' @param parent_ref The calling function.
#' @param deparsed_expression The deparsed expression (if present) on which `ic()` was called. If
#'   missing (default value), only evaluation context is printed.
#' @param value The result of evaluating `deparsed_expression`. If expression is missing (default
#' value), this argument should also be missing.
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

ic_construct_context_str <- function(context) {
  context_str <- context[["loc"]]

  # Next, are we printing a calling function?
  if (!is.null(context[["parent_ref"]])) {
    parent_ref <- rlang::expr_deparse(context[["parent_ref"]])
    context_str <- glue::glue("{{.fn {context[['parent_ref']]}}} in {context_str}")
  }

  return(context_str)
}

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