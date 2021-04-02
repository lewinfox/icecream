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
  }

  # We also want to obtain details of the function that called `ic()`. Here we capture and deparse
  # the call to obtain the function name as a string.
  caller_fn <- try(sys.calls()[[sys.nframe() - 2]], silent = TRUE)
  caller_fn_name <- if (inherits(caller_fn, "try-error")) NULL else as.character(caller_fn[[1L]])

  # Capture thencalling function's environment, jumping two steps up the stack again to skip
  # `ic_get_context()` and `ic()`
  env <- parent.frame(2)

  list(
    filename = filename,
    line = line,
    env = env,
    called_from = caller_fn_name
  )
}
