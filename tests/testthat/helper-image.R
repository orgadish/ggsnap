# Compares two image files pixel-for-pixel and fails the test if they differ.
expect_images_equal <- function(
    actual_path,
    expected_path,
    actual_arg   = rlang::caller_arg(actual_path),
    expected_arg = rlang::caller_arg(expected_path)) {

  testthat::skip_if_not_installed("png")

  testthat::expect(
    file.exists(actual_path),
    glue::glue("{actual_arg} does not exist")
  )
  testthat::expect(
    file.exists(expected_path),
    glue::glue("{expected_arg} does not exist")
  )

  img_actual   <- png::readPNG(actual_path)
  img_expected <- png::readPNG(expected_path)

  testthat::expect(
    identical(dim(img_actual), dim(img_expected)),
    glue::glue(
      "{actual_arg} has dimensions {paste(dim(img_actual), collapse = 'x')}, ",
      "but {expected_arg} has dimensions {paste(dim(img_expected), collapse = 'x')}"
    )
  )

  testthat::expect(
    identical(img_actual, img_expected),
    glue::glue("{actual_arg} is not pixel-identical to {expected_arg}")
  )

}

# Compares two image files pixel-for-pixel and fails the test if they are the
# same.
expect_images_not_equal <- function(
    path1,
    path2,
    path1_arg = rlang::caller_arg(path1),
    path2_arg = rlang::caller_arg(path2)) {

  testthat::skip_if_not_installed("png")

  testthat::expect(
    file.exists(path1),
    glue::glue("{path1_arg} does not exist")
  )
  testthat::expect(
    file.exists(path2),
    glue::glue("{path2_arg} does not exist")
  )

  img1   <- png::readPNG(path1)
  img2 <- png::readPNG(path2)

  testthat::expect(
    !identical(img1, img2),
    glue::glue("{path1_arg} is not pixel-identical to {path2_arg}")
  )
}
