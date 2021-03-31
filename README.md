
<!-- README.md is generated from README.Rmd. Please edit that file -->

# icecream

<!-- badges: start -->

<!-- badges: end -->

Ported from [gruns/icecream](https://github.com/gruns/icecream).

## Installation

You can install from GitHub with:

``` r
devtools::install_github("lewinfox/icecream")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(icecream)

is_negative <- function(x) x < 0

ic(is_negative(1))
#> ℹ ic| `is_negative(1)`: logi FALSE
#> [1] FALSE
```
