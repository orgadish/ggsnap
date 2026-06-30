#' @keywords internal
"_PACKAGE"

#' Save a ggplot2 plot using the `+` operator
#'
#' @description
#' `ggsnap()` saves a ggplot2 plot to disk inside a `+` chain, rather than
#' requiring a separate [ggplot2::ggsave()] call. It accepts the same arguments
#' as [ggplot2::ggsave()].
#'
#' The plot is returned invisibly so the chain can continue — meaning
#' `ggsnap()` can be used multiple times in a single chain to capture
#' intermediate states.
#'
#' `ggsave_snap()` is an alias provided for discoverability.
#'
#' @inheritParams ggplot2::ggsave
#' @inheritDotParams ggplot2::ggsave -plot -width -height
#'
#' @return The ggplot object, invisibly.
#'
#' @examples
#' \dontrun{
#' # Single use
#' mtcars |>
#'   ggplot(aes(mpg, wt)) +
#'   geom_point() +
#'   ggsnap("mygraph.png", width = 6, height = 4)
#'
#' # Two snapshots capturing before and after changing the theme.
#' mtcars |>
#'   ggplot(aes(mpg, wt)) +
#'   geom_point() +
#'   labs(title = "Cars") +
#'   ggsnap("base.png") +
#'   theme_minimal() +
#'   ggsnap("minimal.png")
#' }
#'
#' @export
ggsnap <- function(
    filename,
    width  = NA,
    height = NA,
    units  = c("in", "cm", "mm", "px"),
    dpi    = 300,
    ...) {
  dots <- list(...)

  if ("plot" %in% names(dots)) {
    stop(
      "`plot` cannot be passed to `ggsnap()`: the plot is supplied automatically ",
      "by the `+` chain. Did you mean `ggplot2::ggsave()`?",
      call. = FALSE
    )
  }
  structure(
    list(
      filename = filename,
      width    = width,
      height   = height,
      units    = match.arg(units),
      dpi      = dpi,
      dots     = dots
    ),
    class = c("ggsnap", "gg")
  )
}

#' @rdname ggsnap
#' @export
ggsave_snap <- ggsnap

# Internal wrapper around ggplot2::ggsave() to allow mocking in tests, since
# testthat's documentation discourages mocking another package's function
# directly via, e.g. `local_mocked_bindings(..., .package = "ggplot2")`,
# since that patches the binding for *all* callers of ggplot2::ggsave.
# See https://testthat.r-lib.org/reference/local_mocked_bindings.html
call_ggsave <- function(...) {
  ggplot2::ggsave(...)
}

#' @importFrom ggplot2 ggplot_add
#' @export
#' @method ggplot_add ggsnap
ggplot_add.ggsnap <- function(object, plot, ...) {
  do.call(
    call_ggsave,
    c(
      list(
        filename = object$filename,
        plot     = plot,
        width    = object$width,
        height   = object$height,
        units    = object$units,
        dpi      = object$dpi
      ),
      object$dots
    )
  )
  invisible(plot)
}
