#' Define custom fields for NAACCR records
#'
#' Create a \code{record_format} object, which is used to read NAACCR records.
#'
#' To define registry-specific fields in addition to the standard fields, create
#' a \code{record_format} object for the registry-specific fields and combine it
#' with one of the formats provided with the package using \code{rbind}.
#'
#' @param name Item name appropriate for a \code{data.frame} column name.
#' @param item NAACCR item number.
#' @param start_col First column of the field in a fixed-width record.
#' @param end_col Last column of the field in a fixed-width record.
#' @param type Name of the column class.
#' @param alignment Alignment of the field in fixed-width files. Either
#'   \code{"left"} (default) or \code{"right"}.
#' @param padding Single-character strings to use for padding in fixed-width
#'   files.
#' @param name_literal (Optional) Item name in plain language.
#' @param x Object to be coerced to a \code{record_format}, usually a
#'   \code{data.frame} or \code{list}.
#' @param ... Other arguments passed to \code{record_format}.
#'
#' @return An object of class \code{"record_format"} which has the following
#'   columns:
#'   \describe{
#'     \item{\code{name}}{
#'       (\code{character}) XML field name.
#'     }
#'     \item{\code{item}}{
#'       (\code{integer}) Field item number.
#'     }
#'     \item{\code{start_col}}{
#'       (\code{integer}) First column of the field in a fixed-width text file.
#'     }
#'     \item{\code{end_col}}{
#'       (\code{integer}) Last column of the field in a fixed-width text file.
#'     }
#'     \item{\code{type}}{
#'       (\code{character}) R class for the column vector.
#'     }
#'     \item{\code{alignment}}{
#'       (\code{character}) Alignment of the field's values in a fixed-width
#'       text file.
#'     }
#'     \item{\code{padding}}{
#'       (\code{character}) String used for padding field values in a
#'       fixed-width text file.
#'     }
#'     \item{\code{name_literal}}{
#'       (\code{character}) Field name in plain language.
#'     }
#'   }
#'
#' @examples
#'   my_fields <- record_format(
#'     name      = c("foo", "bar"),
#'     item      = c(2163, 1180),
#'     start_col = c(975, 1381),
#'     end_col   = c(975, 1435),
#'     type      = c("numeric", "character")
#'   )
#'   my_format <- rbind(naaccr_format_16, my_fields)
#' @import data.table
#' @export
record_format <- function(name,
                          item,
                          start_col,
                          end_col,
                          type,
                          alignment    = "left",
                          padding      = " ",
                          name_literal = NULL) {
  # Allow 0-row formats, because why not?
  n_rows <- max(
    length(name), length(item), length(start_col), length(end_col),
    length(type), length(name_literal)
  )
  if (n_rows == 0L) {
    alignment    <- character(0L)
    padding      <- character(0L)
    name_literal <- character(0L)
  } else if (is.null(name_literal)) {
    name_literal <- NA_character_
  }
  # Check for valid values
  alignment <- as.character(alignment)
  not_left_right <- !(alignment %in% c("left", "right"))
  if (any(not_left_right, na.rm = TRUE)) {
    stop("'alignment' must only contain values of \"left\" or \"right\"")
  }
  padding   <- as.character(padding)
  padding_width <- nchar(padding)
  if (any(padding_width > 1L, na.rm = TRUE)) {
    stop("'padding' must only contain single-character values")
  }
  # Create the format
  record_format <- data.table(
    name         = as.character(name),
    item         = as.integer(item),
    start_col    = as.integer(start_col),
    end_col      = as.integer(end_col),
    type         = as.character(type),
    alignment    = as.character(alignment),
    padding      = as.character(padding),
    name_literal = as.character(name_literal)
  )
  setattr(record_format, "class", c("record_format", class(record_format)))
  record_format
}


#' @inheritParams record_format
#' @rdname record_format
as.record_format <- function(x, ...) {
  if (inherits(x, "record_format")) {
    return(x)
  }
  xlist <- as.list(x)
  xlist <- utils::modifyList(xlist, list(...), keep.null = TRUE)
  call_args <- args(record_format)
  arg_names <- names(as.list(call_args))
  arg_names <- arg_names[nzchar(arg_names)]
  do.call(record_format, xlist[arg_names])
}


#' @noRd
rbind.record_format <- function(..., stringsAsFactors = FALSE) {
  combined <- rbindlist(list(...))
  as.record_format(combined)
}


#' Field definitions from all NAACCR format versions
#'
#' A \code{data.table} object defining the fields for each version of NAACCR's
#' fixed-width record file format.
#'
#' @description See \code{\link{record_format}}.
#'
#' @rdname naaccr_format
"naaccr_format_12"

#' @rdname naaccr_format
"naaccr_format_13"

#' @rdname naaccr_format
"naaccr_format_14"

#' @rdname naaccr_format
"naaccr_format_15"

#' @rdname naaccr_format
"naaccr_format_16"

#' @rdname naaccr_format
"naaccr_format_18"
