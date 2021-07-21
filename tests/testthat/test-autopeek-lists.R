library(checkmate)
library(glue)

test_that("`ic_autopeek()` has specific format for lists", {
  purrr::walk(
    list(
      unnamed_list, partially_named_list, named_list, long_list,
      long_list_2
    ),
    ~ expect_output(
      ic_autopeek(.x),
      pattern = "^list \\[\\d+\\]: (?:\\$[^:]+: .+ \\[\\d+\\](?:, )?)+(?:\\.{3})?$"
    )
  )
})

# header tests ----
test_that("`ic_autopeek()` prints correct list length", {
  expect_output(
    ic_autopeek(unnamed_list),
    pattern = glue("^list \\[{length(unnamed_list)}\\]:")
  )
})

# element names tests ----
test_that("`ic_autopeek()` prints indices for unnamed lists", {
  #> list [3]: $1: int [8], $2: chr [4], $3: lgl [0]
  expect_output(
    ic_autopeek(unnamed_list),
    pattern = glue_collapse(glue("\\${seq_along(unnamed_list)}:.*"))
  )
})

test_that("`ic_autopeek()` prints names for named lists", {
  #> list [3]: $'first': int [8], $'2.': chr [4], $'last': lgl [0]
  expect_output(
    ic_autopeek(named_list),
    pattern = glue_collapse(glue("\\$'{names(named_list)}':.*"))
  )
})

test_that("`ic_autopeek()` mixes names and indices for partially named lists", {
  #> list [3]: $'first': int [8], $2: chr [4], $'last': lgl [0]
  list_names <- ifelse(
    is.na(names(partially_named_list)),
    seq_along(partially_named_list),
    glue("'{names(partially_named_list)}'")
  )
  expect_output(
    ic_autopeek(partially_named_list),
    pattern = glue_collapse(glue("\\${list_names}:.*"))
  )
})

# element description tests ----
test_that("`ic_autopeek()` contains vector abbreviations", {
  purrr::walk(
    list(unnamed_list, partially_named_list, named_list),
    ~ expect_output(
      ic_autopeek(.x),
      pattern = glue_collapse(glue("{purrr::map_chr(.x, vctrs::vec_ptype_abbr)}.*"))
    )
  )
})

test_that("`ic_autopeek()` displays element lengths", {
  purrr::walk(
    list(unnamed_list, partially_named_list, named_list),
    ~ expect_output(
      ic_autopeek(.x),
      pattern = glue_collapse(glue("\\[{lengths(.x)}\\].*"))
    )
  )
})

# max length tests ----
test_that("`ic_autopeek()` truncates description with three dots", {
  purrr::walk(
    list(long_list, long_list_2),
    ~ {
      trunc_summary <- capture.output(ic_autopeek(.x, max_summary_length = 70))
      expect_string(
        trunc_summary,
        pattern = "\\.{3}$",
      )
      expect_lte(nchar(trunc_summary), 70)
    }
  )
})

test_that("`ic_autopeek()` doesn't truncate in the middle of a summary", {
  purrr::walk(
    list(long_list, long_list_2),
    ~ expect_output(
      ic_autopeek(.x, max_summary_length = 70),
      pattern = "(?:\\$[^:]+: .+ \\[\\d+\\], )+\\.{3}$"
    )
  )
})

test_that("`ic_autopeek()` prints only header and '...' when the first element has too wide description already", {
  purrr::walk(
    list(long_list, long_list_2),
    ~ expect_output(
      ic_autopeek(.x, max_summary_length = 10),
      fixed = glue("list [{length(.x)}]: ...")
    )
  )
})
