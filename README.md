# messinian_biol_impact

Supplementary code for _The biodiversity impact of the Mediterranean salt giant_  
Project webpage: [REMARE project](https://sites.google.com/view/kagiadi/projects/remare)

## Authors

__Niklas Hohmann__  (creator and maintainer of repository)  
Utrecht University  
email: n.h.hohmann [at] uu.nl  
Web page: [www.uu.nl/staff/NHohmann](https://www.uu.nl/staff/NHHohmann)  
ORCID: [0000-0003-1559-1838](https://orcid.org/0000-0003-1559-1838)

__Konstantina Agiadi__ (principal investigator)  
University of Vienna  
email: konstantina.agiadi [at] univie.ac.at  
Web page: [sites.google.com/view/kagiadi](https://sites.google.com/view/kagiadi)  
ORCID: [0000-0001-8073-559X](https://orcid.org/0000-0001-8073-559X)  

## Requirements

Base R (version >= 4) and the RStudio IDE.

## Reproducing Results

In the RStudio IDE, open the file _messinian_biol_impact.Rproj_. This opens the RProject of the same name, and installs the `renv` package (if not already installed). Then, run

```R
renv::restore()
```

in the console to install all dependencies required for the analysis. Next, run

```R
source("code/download_data.R)
```

do download the database from Zenodo. Then, run

```R
source("code/analysis.R)
```

to run the analysis and produce the figures. This will generate all figures in the _figs/_ folder, and generate the variables `sr_change_whole`, `sr_change_reg`, `sr_change_time`, and `eco_ind_median` in the workspace.

## Repository structure

* _code_ : folder for R scripts
  * _analysis.R_ : R script for main analysis
  * _download_data.R_ : script to download raw data from Zenodo
  * _helper_functions.R_ : utility functions for analysis
* _data_ : folder for raw data. Initially empty, will be filled with data from Zenodo once _download_data.R_ is run
* _figs_ : folder for figures. Initially empty, will be filled with figures ofter _analysis.R_ is run
* _renv_ : folder for `renv` package
* _.Rprofile_ : R session settings
* _.gitignore_ : untracked files
* _LICENSE_ : Apache 2.0 license text
* _README.md_ : README file with instructions for reproducibility
* _messinian_biol_impact.Rproj_ : RProject file
* _renv.lock_ : lock file for `renv` package

## License

Apache 2.0, see LICENSE file for full text.

## Funding

This work was supported by the Austrian Science Fund (FWF) project “Late Miocene Mediterranean Marine Ecosystem Crisis” (2022–2026), Project no. V 986, [DOI 10.55776/V986](https://www.doi.org/10.55776/V986) (PI: K.Agiadi).
