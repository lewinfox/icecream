#' Print icecream messages
#'
#' The printing logic depends on how the `ic()` function has been called and what user options are
#' set.
#'
#' @param loc String detailing function definition location, which may be a source ref (file, line
#'   number and character index) or an environment.
#' @param parent_ref The calling function.
#' @param expression The deparsed expression (if present) on which `ic()` was called.
#' @param value The result of evaluating `expression`.
#'
#' @return The function is called for its side effect (printing to the console) but it also returns
#'   its output string, invisibly.
#'
#' @keywords internal
ic_print <- function(loc, parent_ref, expression, value) {

  context_string <- loc
  expression_string <- NULL

  # Next, are we printing a calling function?
  if (!is.null(parent_ref)) {
    parent_ref <- deparse(parent_ref)
    context_string <- glue::glue("{{.fn {parent_ref}}} in {context_string}")
  }

  # Formatting result
  if (!is.null(expression) && !is.null(value)) {
    # We want to print a one-line summary for complex objects like lists and data frames.
    #
    # TODO: Taking the first line of output from `str()` is a quick way of getting this but it
    #       doesn't produce great output (try passing in a `lm()` object - ugly). It would be nice
    #       to fix this at some point.
    str_res <- trimws(utils::capture.output(utils::str(value)))[[1L]]
    expression_string <- glue::glue("{{.var {expression}}}: {str_res}")
  }

  # We need to check what options are set to decide what to print - whether to include the context
  # or not.
  if (!is.null(expression_string)) {
    if (getOption("icecream.include.context")) {
      output <- glue::glue("{context_string} | {expression_string}")
    } else {
      output <- expression_string
    }
  } else {
    output <- context_string
  }

  prefix <- getOption("icecream.prefix", "ic|")
  output <- paste(prefix, output)
  cli::cli_alert_info(output)
  invisible(output)
}
