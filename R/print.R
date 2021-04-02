#' Print icecream messages
#'
#' The printing logic depends on how the `ic()` function has been called and what user options are
#' set.
#'
#' @param ctx A list containing all the information needed to produce the console message. See
#'   [ic_get_context()] and [ic()] itself for details of how this is constructed and what's in it.
#'
#' @return The function returns its final output string invisibly.
#'
#' @keywords internal
ic_print <- function(ctx) {
  # This breaks down into two parts:
  #
  # 1. Formatting the context (source file, location, environment and calling function). Depending
  #    where `ic()` was called from we may have nothing except an environment. We also need to take
  #    into account the various options for printing.
  # 2. Formatting the input and output. Again, we may not have any input or output depending on how
  #    `ic()` is being used.

  context_string <- NULL
  expression_string <- NULL

  # First, are we printing a file:line or environment?
  if (is.null(ctx$filename)) {
    context_string <- glue::glue("in {ctx$env}")
  } else {
    context_string <- glue::glue("at {{.path {ctx$file}}}:{{.val {ctx$line}}}")
  }

  # Next, are we printing a calling function?
  if (!is.null(ctx$called_from_fn)) {
    context_string <- glue::glue("{{.fn {ctx$called_from_fn}}} {context_string}")
  }

  # Formatting result
  if (!is.null(ctx$expression) && !is.null(ctx$value)) {
    # We want to print a one-line summary for complex objects like lists and data frames.
    #
    # TODO: Taking the first line of output from `str()` is a quick way of getting this but it
    #       doesn't produce great output (try passing in a `lm()` object - ugly). It would be nice
    #       to fix this at some point.
    str_res <- trimws(utils::capture.output(utils::str(ctx$value)))[[1L]]
    expression_string <- glue::glue("{{.var {ctx$expression}}}: {str_res}")
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
