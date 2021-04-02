test_that("`ic_enable()` and `ic_disable()` work", {
  old.opt <- getOption("icecream.enabled")
  options(icecream.enabled = TRUE)
  expect_message(ic(1))
  ic_disable()
  expect_message(ic(1), NA)
  ic_enable()
  expect_message(ic(1))
  options(icecream.enabled = old.opt)
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
    # This is testing that it doesn't return anything when called with no arguments. May be a better
    # way of doing it...
    expect_length(ic(), 0)
  })
})

test_that("setting prefixes works", {
  old.prefix <- getOption("icecream.prefix")
  options(icecream.prefix = "HELLO")
  expect_message(ic(1), regexp = "HELLO")
  options(icecream.prefix = old.prefix)
})
