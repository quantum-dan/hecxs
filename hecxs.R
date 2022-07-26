# Written beginning July 26, 2022 by Daniel Philippus for the Los Angeles River
# Environmental Flows Project at the Colorado School of Mines.
#
# This script processes HEC-RAS channel geometry to generate manuscript/report-
# friendly cross-section plots.
#
# The plot.xs function takes a data frame containing ID, Station, Elevation
# and generates plots of the cross-section geometry, faceted by ID.  It can
# optionally save the plot as a PNG.
#
# The parse.geo function takes a string of HEC-RAS geometry data (from copy-
# pasting the cross section) and generates a suitable data frame.

library(tidyverse)

parse.geo <- function(hecstr, id, convert.dir=0) {
  # Parse copy-pasted HEC-RAS data into a cross-section data frame.
  # With a direct copy-paste into the R console, the HEC-RAS data is
  # in tab-delimited rows of station-elevation.
  #
  # hecstr: copy-pasted string
  # id: input for ID column
  # convert.dir: "direction" of unit conversion; 0 (default) = no conversion,
  #               1 = metric to imperial, -1 = imperial to metric.
  #               This value is actually the exponent of 3.28 used for conversion,
  #               i.e. x' = x * 3.28^convert.dir.
  cfac <- 3.28^convert.dir
  strsplit(hecstr, "\n")[[1]] %>%
    strsplit("\t") %>%
    map_dfr(
      ~tibble(ID=id,
              Station=as.numeric(.x[1])*cfac,
              Elevation=as.numeric(.x[2])*cfac)
    ) %>%
    drop_na
}

parse.geolist <- function(glist, convert.dir=0) {
  # Map parse.geo across a list of {string, id}.  convert.dir is the
  # same as the argument to parse.geo.
  map_dfr(glist,
          function(ls) {
            parse.geo(
              ls$string,
              ls$id,
              convert.dir
            )
          })
}

plot.xs <- function(xs, unit, write=NULL, width=1950, height=1200) {
  # Plot cross-sections.  The plot is faceted by ID.
  #
  # xs: a data frame containing cross-section data as ID, Station, Elevation
  # unit: unit label for axes (e.g. "m", "ft")
  # write: if specified, save as a PNG to that path
  # width, height: PNG dimensions in px; the defaults are suitable for a
  #                 300dpi, 6.5x4 inch image.
  unit <- paste0("(", unit, ")")
  plt <- xs %>%
    ggplot() +
    aes(x=Station, y=Elevation) +
    geom_line(size=2) +
    facet_wrap(~ID, scales="free") +
    theme_bw(base_size = 48) +
    labs(
      x=paste("Station", unit),
      y=paste("Elevation", unit)
    )
  
  if (!is.null(write)) {
    png(write, width=width, height=height)
    print(plt)
    dev.off()
  }
  
  plt
}