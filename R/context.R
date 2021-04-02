#' Get the context from which `ic()` was called
#'
#' Captures the context (source file location / environment and calling function) from which `ic()`
#' was called and returns a list of information needed to construct printed output.
#'
#' @return A list containing the filaname, line number, environment and function name from which
#'   the call to `ic()` was made. Any attributes that do not apply (for example, filename and line
#'   number for functions defined in the global environment) will be NULL.
#'
#' @keywords internal
ic_get_context <- function() {
  # First we capture the current call stack, skipping the first two entries so the first entry in
  # the list will be the call to `ic()` as this is where we find the source reference.
  stack <- .traceback(2)
  ic_call <- stack[[1]]

  # If that entry has a `srcref` attribute then we are working with a function that was `source()`d
  # which means we can get a filename and line number for the `ic()` call.
  source_ref <- attr(ic_call, "srcref")

  # If we can't obtain source code info we still want to include that information in the returned
  # object so we will create some placeholder variables
  source_file <- NULL
  line <- NULL
  filename <- NULL

  # If there is no source_ref then we are almost certainly dealing with a function that was created
  # in the global environment.
  if (!is.null(source_ref)) {
    source_file <- attr(source_ref, "srcfile")
    line <- source_ref[[1L]]
    filename <- basename(source_file$filename)
    if (filename == "") {
      filename <- NULL
    }
  }

  # We also want to obtain details of the function that called `ic()`. Here we capture and deparse
  # the call to obtain the function name as a string.
  caller_fn <- try(sys.calls()[[sys.nframe() - 2]], silent = TRUE)
  caller_fn_name <- if (inherits(caller_fn, "try-error")) NULL else deparse(caller_fn[[1L]])

  # Capture the calling function's environment, jumping two steps up the stack again to skip
  # `ic_get_context()` and `ic()`
  e <- environment(sys.function(-2))
  env <- glue::glue("<env: {rlang::env_label(e)}>")

  list(
    filename = filename,
    line = line,
    env = env,
    called_from_fn = caller_fn_name
  )
}

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
