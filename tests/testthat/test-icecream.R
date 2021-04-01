test_that("`ic.enable()` and `ic.disable()` work", {
  old.opt <- getOption("icecream.enabled")

  options(icecream.enabled = TRUE)

  expect_message(ic(1), regexp = "i ic| `1`: num 1")

  ic_disable()

  expect_message(ic(1), NA)

  ic_enable()

  expect_message(ic(1), regexp = "i ic| `1`: num 1")

  options(icecream.enabled = old.opt)
})

test_that("`ic()` prints nice summaries for complex objects", {
  expect_message(ic(iris), regexp = "data\\.frame")
  expect_message(ic(complex(100)), regexp = "cplx \\[1:100\\] 0\\+0i 0\\+0i 0\\+0i")
  expect_message(ic(integer(100)), regexp = "int \\[1:100\\] 0 0 0 0 0 0 0 0 0 0")
  # expect_message(ic(lm(data = iris, formula = as.numeric(Species) ~ .))) # This could be better
})
