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
  ctx <- list(
    filename = NULL,
    line = NULL,
    env = NULL,
    called_from_fn = NULL
  )

  # If there is no source_ref then we are almost certainly dealing with a function that was created
  # in the global environment.
  if (!is.null(source_ref)) {
    source_file <- attr(source_ref, "srcfile")
    ctx$filename <- basename(source_file$filename)
    ctx$line <- source_ref[[1L]]

    if (ctx$filename == "") {
      ctx$filename <- NULL
    }
  }

  # We also want to obtain details of the function that called `ic()`. Here we capture and deparse
  # the call to obtain the function name as a string.
  caller_fn <- try(sys.calls()[[sys.nframe() - 2]], silent = TRUE)
  ctx$called_from_fn <- if (inherits(caller_fn, "try-error")) NULL else deparse(caller_fn[[1L]])

  # If `ic()` was called from another function we want to know which environment it lives in
  # (probably namespace:somapackage). In the event that `ic()` was invoked directly in some
  # environment we want to know which one (probably R_GlobalEnv).
  if (!inherits(caller_fn, "try-error")) {
    e <- environment(sys.function(-2))
  } else {
    e <- sys.frame(-2)
  }

  if (is.environment(e)) {
    ctx$env <- glue::glue("<env: {rlang::env_label(e)}>")
  }

  ctx
}
