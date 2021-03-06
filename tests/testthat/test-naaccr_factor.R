library(testthat)
library(naaccr)


context("naaccr_factor")

test_that("naaccr_factor converts the input to a factor", {
  races <- sprintf("%02d", 1:99)
  race_factor <- naaccr_factor(races, "race4")
  expect_is(race_factor, "factor")
  expect_equal(length(race_factor), length(races))
  expect_true(is.na(race_factor[99L]))

  countries <- list(
    code = c("ZZA", "ZZU", "XNI", "FRA"),
    name = c("Asia, NOS", "unknown", "North American Islands", "France")
  )
  country_factor <- naaccr_factor(
    countries[["code"]], "addrAtDxCountry", keep_unknown = TRUE
  )
  expect_identical(as.character(country_factor), countries[["name"]])
})

test_that("naaccr_factor warns for non-fields", {
  expect_warning(naaccr_factor("a", "foo"))
})

test_that("Users can keep or omit unknowns from levels", {
  no_unknown  <- naaccr_factor("9", "laterality", keep_unknown = FALSE)
  expect_true(is.na(no_unknown))
  expect_false("unknown" %in% levels(no_unknown))
  has_unknown <- naaccr_factor("9", "laterality", keep_unknown = TRUE)
  expect_false(is.na(has_unknown))
  expect_true("unknown" %in% levels(has_unknown))
})

test_that("split_sentineled returns a data.frame of the values and flags", {
  values <- c(sprintf("%02d", 0:50), "X1", "X7", "X9", 51:99)
  result <- split_sentineled(values, "numberOfCoresExamined")
  expect_is(result, "data.frame")
  expect_identical(dim(result), c(length(values), 2L))
  expect_named(result, c("numberOfCoresExamined", "numberOfCoresExaminedFlag"))
  expect_is(result[["numberOfCoresExamined"]], "numeric")
  expect_is(result[["numberOfCoresExaminedFlag"]], "factor")
  missing_value <- is.na(result[["numberOfCoresExamined"]])
  missing_flag  <- is.na(result[["numberOfCoresExaminedFlag"]])
  expect_true(all(missing_value | missing_flag))
})

test_that("split_sentineled returns double-NA for invalid codes with warning", {
  expect_warning(result <- split_sentineled("QQ", "gleasonScoreClinical"))
  expect_true(is.na(result[["gleasonScoreClinical"]]))
  expect_true(is.na(result[["gleasonScoreClinicalFlag"]]))
})

test_that("All required code/sentinel schemes exist", {
  specified_schemes <- unique(naaccr:::field_code_scheme[["scheme"]])
  defined_schemes   <- unique(naaccr:::field_codes[["scheme"]])
  undefined <- setdiff(specified_schemes, defined_schemes)
  expect_identical(
    undefined, character(0),
    info = paste("Undefined schemes:", paste0(undefined, collapse = ", "))
  )

  specified_schemes <- unique(naaccr:::field_sentinel_scheme[["scheme"]])
  defined_schemes   <- unique(naaccr:::field_sentinels[["scheme"]])
  undefined <- setdiff(specified_schemes, defined_schemes)
  expect_identical(
    undefined, character(0),
    info = paste("Undefined schemes:", paste0(undefined, collapse = ", "))
  )
})

test_that("No unused code/sentinel schemes exist", {
  specified_schemes <- unique(naaccr:::field_code_scheme[["scheme"]])
  defined_schemes   <- unique(naaccr:::field_codes[["scheme"]])
  unused <- setdiff(defined_schemes, specified_schemes)
  expect_identical(
    unused, character(0),
    info = paste("Unused schemes:", paste0(unused, collapse = ", "))
  )

  specified_schemes <- unique(naaccr:::field_sentinel_scheme[["scheme"]])
  defined_schemes   <- unique(naaccr:::field_sentinels[["scheme"]])
  unused <- setdiff(defined_schemes, specified_schemes)
  expect_identical(
    unused, character(0),
    info = paste("Unused schemes:", paste0(unused, collapse = ", "))
  )
})
