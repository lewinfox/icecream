## Test environments

GitHub Actions using `usethis::use_github_actions_check_standard()`

-   MacOS X 12.6.9 (release)
-   Windows Server 2022 10.0.20348 (release)
-   Ubuntu 22.04.3 (oldrel-1, release, devel)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Undeclared xref NOTE

[CRAN Package Check results](https://cran.r-project.org/web/checks/check_results_icecream.html) show 
"Undeclared package `tibble` in Rd xrefs". This is a `@seealso` in `peek.R:23` - `icecream` doesn't 
use `tibble`.
