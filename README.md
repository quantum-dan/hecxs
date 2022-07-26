# hecxs
An R script for plotting HEC-RAS cross-sections in ggplot (for manuscript figures and such).

The script has three functions: `plot.xs`, `parse.geo`, and `parse.geolist`.  The core functionality
is provided by the first, and the other two are utility functions.

## `plot.xs`

This is the core functionality, which actually plots out the cross-sections.  The required arguments
are the cross-section data (`xs`) and the unit label (`unit`, e.g. "m" or "ft").  `xs` should be a
data frame containing ID, Station, Elevation, with the latter two being numeric columns in the same
units specified by `unit`.

The optional arguments `write`, `width`, and `height` specify saving the plot as a PNG.  By default
(`write=NULL`), the plot is just returned, not saved.  If a string is specified instead, then the
plot is also written to that path as a PNG with the dimensions (in pixels) given by `width` and `height`.
The default dimensions are suitable for a 300-dpi, 6.5x4-in figure.

## `parse.geo` and `parse.geolist`

These two functions are convenience functions for parsing data into a suitable format for the `xs` argument
to `plot.xs`.  They are built around copy-pasting geometry data from HEC-RAS directly into the R console as
a string.  Such an action results in tab-delimited rows of station, elevation.

`parse.geo` simply parses this input, `hecstr`, directly into a data frame.  The second required argument,
`id`, is the cross-section ID and is included as the `ID` column of the output.

`parse.geolist` wraps `parse.geo` for convenient use with multiple cross-sections.  The argument `glist`
is a list of lists, with each sublist containing `string` (corresponding to `hecstr` above) and `id`.
The function simply maps over these and provides them as arguments to `parse.geo`, returning a single
data frame containing all gages and suitable for direct input into `plot.xs`.

Both functions have the optional argument `convert.dir` (-1, 0, or 1), which specifies unit conversions.
This argument is used as as an exponent of 3.28, used to multiply both numeric columns.  Thus, the default
of 0 performs no conversion (the factor becomes 1); `convert.dir=1` converts from meters to feet (factor=3.28);
and `convert.dir=-1` converts from feet to meters (factor=1/3.28).

## Dependencies

The only dependency is `tidyverse`, which the script loads in full as it uses several associated libraries.

The script was tested with R 4.1.2 x86_64 on Windows 10 in RStudio using tidyverse 1.3.1.