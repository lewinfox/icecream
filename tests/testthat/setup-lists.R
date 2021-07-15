unnamed_list <- list(
  sample.int(70, size = 8),
  sample(letters, size = 4),
  logical()
)
partially_named_list <- setNames(unnamed_list, c("first", NA, "last"))
named_list <- setNames(unnamed_list, c("first", "2.", "last"))

all_lists <- list(
  unnamed_list,
  partially_named_list,
  named_list
)