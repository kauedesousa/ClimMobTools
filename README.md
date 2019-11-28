
ClimMobTools
============

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/ClimMobTools)](https://cran.r-project.org/package=ClimMobTools) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/agrobioinfoservices/ClimMobTools?branch=master&svg=true)](https://ci.appveyor.com/project/kauedesousa/ClimMobTools) [![Build Status](https://travis-ci.org/agrobioinfoservices/ClimMobTools.svg?branch=master)](https://travis-ci.org/agrobioinfoservices/ClimMobTools) [![codecov](https://codecov.io/gh/agrobioinfoservices/ClimMobTools/master.svg)](https://codecov.io/github/agrobioinfoservices/ClimMobTools?branch=master) [![GPLv3 license](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.r-project.org/Licenses/GPL-3) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) [![Downloads](https://cranlogs.r-pkg.org/badges/ClimMobTools)](https://cran.r-project.org/package=ClimMobTools) <!-- badges: end -->

*ClimMobTools*: Toolkit for the 'ClimMob' platform in R <img align="right" src="man/figures/logo.png">
======================================================================================================

Announcement
------------

Several functions of **ClimMobTools** are migrating to the new package [gosset](https://github.com/agrobioinfoservices/gosset%5D). ClimMobTools will keep only the functions exclusively related to the [ClimMob](https://climmob.net/) platform. Other functions are transferred to **gosset** to provide a better environment for data handling, analysis and visualization not only to 'tricot' data, but metadata in general. Retained functions are `getDataCM`, `getProjectCM`, `randomise` and `seed_need`. We apologize for any issue caused due to this migration, and we are happy to discuss this via the [issues](https://github.com/agrobioinfoservices/ClimMobTools/issues) section.

Overview
--------

**ClimMobTools** the API for the 'ClimMob' platform in R. [ClimMob](https://climmob.net/) is an open source software for crowdsourcing citizen science in agriculture. Developed by van Etten et al. (2019) for the rapid assessment of on-farm evaluation trails in small-scale agriculture. Tricot turns the research paradigm on its head; instead of a few researchers designing complicated trials to compare several technologies in search of the best solutions, it enables many farmers to carry out reasonably simple experiments that taken together can offer even more information.

Installation
------------

The package may be installed from CRAN via

``` r
install.packages("ClimMobTools")
```

The development version can be installed via

``` r
library("devtools")

devtools::install_github("agrobioinfoservices/ClimMobTools")
```

Going further
-------------

The full functionality of **ClimMobTools** is illustrated in the package vignette. The vignette can be found on the [package website](https://agrobioinfoservices.github.io/ClimMobTools/) or from within `R` once the package has been installed, e.g. via

``` r
vignette("Overview", package = "ClimMobTools")
```

Contribution
------------

You are welcome to contribute to this project. Please read our [contribution guide lines](CONTRIBUTING.md).

Code of Conduct
---------------

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
