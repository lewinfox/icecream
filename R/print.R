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
ic_print <- function(loc, parent_ref, deparsed_expression = rlang::missing_arg(), value = rlang::missing_arg()) {
  # TODO: I'm not certain at this stage that we will never get a zero-char `loc` passed in. There is
  #       probably a better way of handling this, but for now this will do.
  context_string <- if (nchar(loc) == 0) "<unknown>" else loc

  # Next, are we printing a calling function?
  if (!is.null(parent_ref)) {
    parent_ref <- rlang::expr_deparse(parent_ref)
    context_string <- glue::glue("{{.fn {parent_ref}}} in {context_string}")
  }

  expression_string <- NULL

  # Formatting result
  if (!rlang::is_missing(deparsed_expression)) {
    # We want to print a one-line summary for complex objects like lists and data frames.
    str_res <- ic_peek(value)
    expression_string <- glue::glue("{{.var {deparsed_expression}}}: {str_res}")
  }

  # We need to check what options are set to decide what to print - whether to include the context
  # or not.
  prefix <- getOption("icecream.prefix", "ic|")
  output <- if (!is.null(expression_string)) {
    if (getOption("icecream.always.include.context")) {
      glue::glue("{context_string} | {expression_string}")
    } else {
      expression_string
    }
  } else {
    context_string
  }
  output <- paste(prefix, output)

  cli::cli_alert_info(output) # TODO: This is where a custom print/display function would be used
  invisible(output)
}
