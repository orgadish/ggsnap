
# ggsnap

Save a ggplot2 plot using `+` instead of breaking out of the pipe for a
separate `ggsave()` call.

``` r
library(ggplot2)
library(ggsnap)

mtcars |>
  ggplot(aes(mpg, wt)) +
  geom_point() +
  labs(title = "Cars") +
  ggsnap("cars.png", width = 6, height = 4)
```

No more splitting a plot-building chain into an assignment plus a
separate `ggsave()` call:

``` r
# Without ggsnap
p <- mtcars |>
  ggplot(aes(mpg, wt)) +
  geom_point() +
  labs(title = "Cars")
ggsave("cars.png", p, width = 6, height = 4)

# With ggsnap
mtcars |>
  ggplot(aes(mpg, wt)) +
  geom_point() +
  labs(title = "Cars") +
  ggsnap("cars.png", width = 6, height = 4)
```

`ggsnap()` accepts the same arguments as
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html),
and `ggsave_snap()` is provided as an alias for discoverability.

## Installation

``` r
# Install from CRAN
install.packages("ggsnap")

# Install latest development version
remotes::install_github("orgadish/ggsnap")
```

## Multiple snapshots

Since the plot is returned invisibly, `ggsnap()` can also be called more
than once in a chain, to save intermediate states:

``` r
mtcars |>
  ggplot(aes(mpg, wt)) +
  geom_point() +
  ggsnap("base.png") +
  theme_minimal() +
  ggsnap("minimal.png")
```
