library(ggplot2)

base_plot <- function() ggplot(mtcars, aes(mpg, wt)) + geom_point()
tmp_png   <- function() tempfile(fileext = ".png")

# ---- Constructor -------------------------------------------------------------

test_that("ggsave_snap() is identical to ggsnap()", {
  expect_identical(ggsnap, ggsave_snap)
})

test_that("ggsnap() errors if plot is passed via ...", {
  expect_error(
    ggsnap("file.png", plot = base_plot()),
    "`plot` cannot be passed"
  )
})

# ---- Argument passthrough (mocked) --------------------------------------------
#
# These tests mock ggplot2::ggsave() to inspect exactly what arguments it is
# called with, rather than inferring forwarding indirectly (e.g. from file
# size or ggsave's own validation behaviour). This decouples the tests from
# ggsave's internals and from ggsnap's internal storage representation.

test_that("ggsnap forwards filename, plot, and all named arguments to ggsave", {
  captured <- NULL
  testthat::local_mocked_bindings(
    call_ggsave = function(...) { captured <<- list(...); invisible("mocked") }
  )

  p <- base_plot()
  p + ggsnap("file.png", width = 6, height = 4, units = "cm", dpi = 150)

  expect_equal(captured$filename, "file.png")
  expect_equal(captured$width,  6)
  expect_equal(captured$height, 4)
  expect_equal(captured$units,  "cm")
  expect_equal(captured$dpi,    150)

  expect_s3_class(captured$plot, "gg")
  expect_equal(captured$plot$mapping, p$mapping)
})

test_that("ggsnap forwards arbitrary extra arguments via ... to ggsave", {
  captured <- NULL
  testthat::local_mocked_bindings(
    call_ggsave = function(...) { captured <<- list(...); invisible("mocked") }
  )

  base_plot() +
    ggsnap(
      "file.png",
      device = "png", path = "/tmp", scale = 2,
      limitsize = FALSE, bg = "white"
    )

  expect_equal(captured$device,    "png")
  expect_equal(captured$path,      "/tmp")
  expect_equal(captured$scale,     2)
  expect_equal(captured$limitsize, FALSE)
  expect_equal(captured$bg,        "white")
})

# ---- End-to-end behaviour ------------------------------------------------------

test_that("ggsnap saves the same image that ggsave would produce", {
  p <- base_plot()

  f <- tmp_png()
  p + ggsnap(f, width = 4, height = 3, dpi = 72)

  f_expected <- tmp_png()
  ggsave(f_expected, p, width = 4, height = 3, dpi = 72)

  expect_images_equal(f, f_expected)
})

test_that("ggsnap with no arguments matches ggsave with no arguments (default behaviour)", {
  p <- base_plot()

  f <- tmp_png()
  suppressMessages(p + ggsnap(f))

  f_expected <- tmp_png()
  suppressMessages(ggsave(f_expected, p))

  expect_images_equal(f, f_expected)
})

test_that("ggsnap returns the ggplot object so the chain can continue", {
  f <- tmp_png()
  p <- suppressMessages(base_plot() + ggsnap(f) + theme_minimal())
  expect_s3_class(p, "gg")
  expect_true(inherits(p$theme, "theme"))
})

test_that("multiple snaps in one chain capture genuinely different plot states", {
  f1 <- tmp_png(); f2 <- tmp_png()
  base_plot() +
    ggsnap(f1, width = 4, height = 3, dpi = 72) +
    theme_minimal() +
    ggsnap(f2, width = 4, height = 3, dpi = 72)

  expect_true(file.exists(f1))
  expect_true(file.exists(f2))

  expect_images_not_equal(f1, f2)
})

# ---- Discoverability / aliases --------------------------------------------------

test_that("ggsnap::ggsnap() works via namespace prefix and matches ggsave output", {
  p <- ggplot(mtcars, aes(mpg, wt)) + geom_point()

  f <- tmp_png()
  p + ggsnap::ggsnap(f, width = 4, height = 3, dpi = 72)

  f_expected <- tmp_png()
  ggsave(f_expected, p, width = 4, height = 3, dpi = 72)

  expect_images_equal(f, f_expected)
})

# ---- Compatibility ---------------------------------------------------------------

test_that("+ still dispatches correctly to a representative set of ggplot2 object types", {
  # base_plot() itself relies on + (ggplot() + geom_point()), so if + were
  # completely broken almost every test in this file would already fail.
  # This test instead exercises a sample of the different ggplot_add()
  # dispatch targets ggplot2 defines, to catch a regression that breaks
  # dispatch for one specific class (e.g. themes or scales) without
  # breaking layers in general.
  p <- base_plot() +
    geom_smooth(method = "lm", se = FALSE) +     # Layer
    scale_x_continuous(limits = c(10, 35)) +     # Scale
    coord_cartesian(ylim = c(1, 6)) +             # Coord
    facet_wrap(~cyl) +                            # Facet
    labs(title = "Test", x = "MPG") +             # labels (list)
    theme_minimal()                               # theme

  expect_s3_class(p, "gg")
  expect_equal(p$labels$title, "Test")
  expect_equal(p$labels$x, "MPG")
  expect_true(inherits(p$theme, "theme"))
  expect_true(inherits(p$coordinates, "Coord"))
  expect_true(inherits(p$facet, "Facet"))
  expect_length(p$layers, 2)  # geom_point() + geom_smooth()
})
