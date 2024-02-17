library(withr)

# TODO: Testing things like correct environment detection are tricky because of the way testthat
#       works. Need to add some more checks for correct identification of source file and env.

test_that("`ic_enable()` and `ic_disable()` work", {
  with_options(list(icecream.enabled = TRUE), {
    expect_message(ic(1))
    ic_disable()
    expect_message(ic(1), NA)
    ic_enable()
    expect_message(ic(1))
  })
})

test_that("`with_ic_enable()` and `with_ic_disable()` work", {
  with_options(list(icecream.enabled = TRUE), {
    expect_message(ic(1))
    expect_message(with_ic_disable(ic(1)), NA)
    ic_disable()
    expect_message(with_ic_enable(ic(1)))
  })
})

test_that("`ic()` prints summaries for complex objects", {
  expect_message(ic(iris), regexp = "data\\.frame")
  expect_message(ic(complex(100)), regexp = "cplx \\[1:100\\] 0\\+0i 0\\+0i 0\\+0i")
  expect_message(ic(integer(100)), regexp = "int \\[1:100\\] 0 0 0 0 0 0 0 0 0 0")
})

test_that("`ic()` returns inputs unchanged", {
  suppressMessages({
    expect_equal(ic(mean(1:100)), mean(1:100))
    expect_equal(ic(iris), iris)
    expect_equal(ic(TRUE), TRUE)
    expect_equal(ic(list(a = 1, b = 2)), list(a = 1, b = 2))
  })
})

test_that("`ic()` returns input invisibly", {
  suppressMessages({
    expect_invisible(ic(mean(1:100)))
    expect_invisible(ic(iris), iris)
    expect_invisible(ic(TRUE), TRUE)
    expect_invisible(ic(list(a = 1, b = 2)))
  })
})

test_that("`ic()` without arguments returns nothing invisibly", {
  suppressMessages({
    expect_null(ic())
    expect_invisible(ic())
  })
})

test_that("setting prefixes works", {
  with_options(list(icecream.prefix = "HELLO"), {
    expect_message(ic(1), regexp = "HELLO")
  })
})


test_that("function environment is correctly identified", {
  f <- function() {
    ic()
    1
  }

  # Remove the srcref to ensure we fall back on the environment
  f <- utils::removeSource(f)

  # Make sure the env name shows up in the output
  environment(f) <- .GlobalEnv
  expect_message(f(), regexp = "env: global")

  e <- new.env()
  attr(e, "name") <- "icecream_van"
  environment(f) <- e
  expect_message(f(), regexp = "env: icecream_van")
})


test_that("source file is correctly identified", {
  temp <- tempfile(pattern = "my_name_is_inigo_montoya", fileext = ".R")
  cat("f <- function() {ic(); 1}", file = temp)
  on.exit(unlink(temp))
  source(temp, keep.source = TRUE)
  expect_message(f(), regexp = "my_name_is_inigo_montoya")
})

test_that("invalid glue input is handled cleanly", {
  expect_message(ic("{"), regexp = "\\{")
  expect_message(ic("{}"), regexp = "\\{\\}")
})

test_that("JSON input is handled cleanly", {
  expect_message(ic("{'a': 1}"), regexp = "\\{'a': 1\\}")
})
