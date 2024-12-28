
<!-- README.md is generated from README.Rmd. Please edit that file -->

# API for the lotto numbers of the german lottery (1955-2025)

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)

## Background

This repo provides the german lotto numbers from 1955 - today in one
single file. All people who are interested in data analysis or just to
“calculate” their chances to win the lottery are invited to use the
data.

Two JSON files are give: Choose the one you can work with :-)

## Data analysis examples

The data provided is a JSON file and readable by all modern software
languages. In the following two examples are shown (R and Python).

### R

The package [dplyr](https://dplyr.tidyverse.org/) is able to analyze the
data very quickly with R.

In the next chunk, all data are read, filtered (just taking the lotto
numbers) and grouped by the values and counted the number of appearance.
We can see, that lotto number 6 is the most frequent number.

``` r
data <- jsonlite::fromJSON("https://johannesfriedrich.github.io/LottoNumberArchive/Lottonumbers_tidy_complete.json")

lottonumbers_count <- data |> 
  dplyr::filter(variable == "Lottozahl") |> 
  dplyr::group_by(value) |> 
  dplyr::summarise(count = dplyr::n())
```

``` r
lottonumbers_count |> 
  dplyr::arrange(dplyr::desc(count)) |>  
  dplyr::top_n(5)
## Selecting by count
## # A tibble: 6 × 2
##   value count
##   <int> <int>
## 1     6   658
## 2    49   645
## 3    33   631
## 4    32   630
## 5    26   628
## 6    31   628
```

Now we want to summarise all numbers from 1-49 and their appearance.

``` r
library(ggplot2)

ggplot(lottonumbers_count, aes(value, count)) +
  geom_bar(stat = "identity") +
  labs(x = "Lottonumber", title = "Lottonumbers in Germany since 1955")
```

<img src="README_figs/README-unnamed-chunk-3-1.png" width="672" style="display: block; margin: auto;" />

Since 2001 in the german lottery a number called “Zusatzzahl” was
introduced. Every Wednesday and Saturday the number chosen. The
following graph shows the distribution of the Zusatzzahl.

``` r
superzahl <- data |>  
  dplyr::filter(variable == "Superzahl") |> 
  dplyr::mutate(date = lubridate::dmy(date),
         Day = weekdays(date),
         year = lubridate::year(date)) |> 
  dplyr::filter(year >= 2001) |> 
  dplyr::group_by(value, Day) |>  
  dplyr::summarise(count = dplyr::n())
## `summarise()` has grouped output by 'value'. You can override using the
## `.groups` argument.
```

``` r

ggplot(superzahl, aes(value, count, fill = Day)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_x_continuous(breaks = c(0:9)) +
  labs(x = "Zusatzzahl", title = "Zusatzzahl since 2001")
```

<img src="README_figs/README-unnamed-chunk-5-1.png" width="672" style="display: block; margin: auto;" />

What were the numbers most chosen in 2024?

``` r
data |>  
  dplyr::filter(variable == "Lottozahl") |> 
  dplyr::mutate(date = lubridate::dmy(date),
         year = lubridate::year(date)) |>
  dplyr::filter(year == 2024) |> 
  dplyr::group_by(value) |>  
  dplyr::summarise(count = dplyr::n()) |> 
  dplyr::slice_max(count, n = 5)
## # A tibble: 6 × 2
##   value count
##   <int> <int>
## 1     8    24
## 2     5    22
## 3     9    22
## 4    40    22
## 5    10    18
## 6    30    18
```

### Python

In python the module [pandas](http://pandas.pydata.org) is very handy to
analyse data. In the following the same analysis as shown above will be
executed.

``` python
import pandas as pd

data = pd.read_json("https://johannesfriedrich.github.io/LottoNumberArchive/Lottonumbers_tidy_complete.json", convert_dates = False)

res = data[data.variable == "Lottozahl"].groupby("value")["value"].count().sort_values(ascending = False)

print(res.head(5))
## value
## 6     658
## 49    645
## 33    631
## 32    630
## 31    628
## Name: value, dtype: int64
```
