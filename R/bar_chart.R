#' Bar Chart
#'
#' Easily create a bar chart
#'
#' @author Thomas Neitmann
#'
#' @param data Dataset to use for the bar chart
#' @param x \code{character} or \code{factor} column of \code{data}
#' @param y \code{numeric} column of \code{data} representing the bar length
#' @param facet \code{character} or \code{factor} column of \code{data} defining
#'        the faceting groups
#' @param ... Additional arguments passed to \code{aes()}
#' @param bar_color \code{character}. The color of the bars
#' @param highlight \code{character}. One or more value(s) of \code{x} that
#'        should be highlighted in the plot
#' @param sort \code{logical}. Should the data be sorted before plotting?
#' @param horizontal \code{logical}. Should the plot be oriented horizontally?
#' @param limit \code{numeric}. If a value for \code{limit} is provided only the
#'        top \code{limit} records will be displayed
#' @param threshold \code{numeric}. If a value for threshold is provided only
#'        records with \code{y > threshold} will be displayed
#'
#' @details
#' Both \code{limit} and \code{threshold} only work when \code{sort = TRUE}.
#' Attempting to use them when \code{sort = FALSE} will result in an error.
#' Furthermore, only \code{limit} or \code{threshold} can be used at a time.
#' Providing a value for both \code{limit} and \code{threshold} will result in
#' an error as well.
#'
#' \code{column_chart()} is a shortcut for \code{bar_chart()} with
#' \code{horizontal = FALSE} and \code{sort = FALSE} if \code{x} is
#' \code{numeric}.
#'
#' @return An object of class \code{ggplot}
#'
#' @examples
#' data(biomedicalrevenue)
#' revenue2018 <- biomedicalrevenue[biomedicalrevenue$year == 2018, ]
#' revenue_roche <- biomedicalrevenue[biomedicalrevenue$company == "Roche", ]
#'
#' ## By default bar_chart() creates a horizontal and sorted plot
#' bar_chart(revenue2018, company, revenue)
#'
#' ## Create a vertical, non-sorted bar chart
#' bar_chart(revenue_roche, year, revenue, horizontal = FALSE, sort = FALSE)
#'
#' ## column_chart() is a shortcut for the above
#' column_chart(revenue_roche, year, revenue)
#'
#' ## Limit the number of bars to the top 10
#' bar_chart(revenue2018, company, revenue, limit = 10)
#'
#' ## Display only companies with revenue > 40B.
#' bar_chart(revenue2018, company, revenue, threshold = 40)
#'
#' ## Change the bar color
#' bar_chart(revenue2018, company, revenue, bar_color = "purple")
#'
#' ## Highlight a single bar
#' bar_chart(revenue2018, company, revenue, limit = 10, highlight = "Roche")
#'
#' ## Use facets to show the top 10 companies over the years
#' bar_chart(biomedicalrevenue, company, revenue, facet = year, limit = 10)
#'
#' @import ggplot2
#' @importFrom magrittr %>%
#' @export
bar_chart <- function(data, x, y, facet = NULL, ..., bar_color = "#1F77B4",
                      highlight = NULL, sort = TRUE, horizontal = TRUE,
                      limit = NULL, threshold = NULL) {

  x <- rlang::enquo(x)
  y <- rlang::enquo(y)
  facet <- rlang::enquo(facet)
  has_facet <- !rlang::quo_is_null(facet)
  dots <- rlang::enquos(...)
  has_fill <- "fill" %in% names(dots)

  data <- pre_process_data(
    data = data, x = !!x, y = !!y,
    facet = !!facet,
    highlight = highlight,
    highlight_color = bar_color,
    sort = sort,
    limit = limit,
    threshold = threshold
  )

  .geom_col <- quote(geom_col(width = .75))
  if (has_fill) {
    .geom_col$position <- "dodge"
  } else if (!is.null(highlight)) {
    .geom_col$mapping <- quote(aes(fill = .color))
  } else {
    .geom_col$fill <- quote(bar_color)
  }

  p <- ggplot(data, aes(!!x, !!y, ...)) +
    eval(.geom_col) +
    theme_discrete_chart(horizontal)

  post_process_plot(
    plot = p,
    is_sorted = sort,
    horizontal = horizontal,
    facet = !!facet,
    fill = has_fill,
    highlight = highlight,
    color = bar_color
  )
}

#' @rdname bar_chart
#' @export
column_chart <- function(data, x, y, facet = NULL, ..., bar_color = "#1F77B4",
                         highlight = NULL, sort = NULL, horizontal = FALSE,
                         limit = NULL, threshold = NULL) {
  if (is.null(sort)) {
    sort <- !is.numeric(dplyr::pull(data, {{x}}))
  }

  bar_chart(
    data = data,
    x = {{x}},
    y = {{y}},
    facet = {{facet}},
    ...,
    bar_color = bar_color,
    highlight = highlight,
    sort = sort,
    horizontal = horizontal,
    limit = limit,
    threshold = threshold
  )
}
