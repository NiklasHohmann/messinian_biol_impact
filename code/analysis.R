#### load data ####
messinian_db <- read.csv(file = "data/messinianDB.csv")

#### Loading helper function ####
source("code/helper_functions.R")

#### Replace invalid tax names with NA ####
messinian_db$Species.name = replace(messinian_db$Species.name, messinian_db$Species.name == "sp.", NA)
messinian_db$Genus.name = replace(messinian_db$Genus.name, messinian_db$Genus.name == "indet.", NA)
messinian_db = messinian_db[ !messinian_db$Family == "indet.",  ]

#### Constants ####
timebins <- unique(messinian_db$Age)[c(3, 1, 2)] # sorted from old to young
regions <- unique(messinian_db$region.new)
group.names <- unique(messinian_db$group.name)
group.names.ext = c(group.names, "all groups")
regions.ext = c(regions, "whole basin")
eco_index_names = c("soerensen", "simpson", "nestedness")
noOfRep = 10000 # number of repetitions for subsampling

## determine subsampling size for all regions for comparability
subsampleTo = Inf
for (ti in timebins){
  wMed = get_from_db("all groups", "Western Mediterranean", ti)
  eMed = get_from_db("all groups", "Eastern Mediterranean", ti)
  PPNA = get_from_db("all groups", "Po Plain-Northern Adriatic", ti)
  subsampleTo = min(subsampleTo, ceiling(0.8 * (min(c(length(wMed), length(eMed), length(PPNA))))))
}

sr_median_reg = matrix(data = NA,
                       nrow = length(regions.ext),
                       ncol = length(timebins),
                       dimnames = list("regions" = regions.ext,
                                       "timebin" = timebins))

for (ti in timebins){
  wMed = get_from_db("all groups", "Western Mediterranean", ti)
  eMed = get_from_db("all groups", "Eastern Mediterranean", ti)
  PPNA = get_from_db("all groups", "Po Plain-Northern Adriatic", ti)
  tot = get_from_db("all groups", "whole basin", ti)
  wMed_sr = rarefyTaxRichness(wMed, subsampleTo, noOfRep)
  eMed_sr = rarefyTaxRichness(eMed, subsampleTo, noOfRep)
  PPNA_sr = rarefyTaxRichness(PPNA, subsampleTo, noOfRep)
  tot_sr = rarefyTaxRichness(tot, subsampleTo, noOfRep)
  sr_median_reg["Western Mediterranean", ti] = median(wMed_sr)
  sr_median_reg["Eastern Mediterranean", ti] = median(eMed_sr)
  sr_median_reg["Po Plain-Northern Adriatic", ti] = median(PPNA_sr)
  sr_median_reg["whole basin", ti] = median(tot_sr)
  file_name = paste0("figs/", ti, "_sr.pdf")
  main = paste0("Species richness in ", ti)
  ylim = c(0, max(max(wMed_sr), max(eMed_sr), max(PPNA_sr)))
  ylab = paste0("Species richenss \n subsampled to ", subsampleTo, " occurrences")
  pdf(file = file_name)
  boxplot(x = list("wMed" = wMed_sr,
                   "PPOA" = PPNA_sr,
                   "eMed" = eMed_sr),
          ylim = ylim,
          ylab = ylab,
          main = main)
  dev.off()
  
}

#### Ecological indices ####
time_comp_names = c("T vs. M", "M vs. Z", "T vs. Z")
eco_ind_median = matrix(data = NA,
                       nrow = length(eco_index_names),
                       ncol = length(time_comp_names),
                       dimnames = list("index" = eco_index_names,
                                       "timebins" = time_comp_names))


Tor = get_from_db(group = "all groups", basin = "whole basin", timeslice = "Tortonian" )
Mes = get_from_db(group = "all groups", basin = "whole basin", timeslice = "pre-evaporitic Messinian" )
Zan = get_from_db(group = "all groups", basin = "whole basin", timeslice = "Zanclean" )
subsampleTo = ceiling(0.8 * (min(c(length(Tor), length(Mes), length(Zan)))))
TM = rarefyEcoIndexes(Tor, Mes, subsampleTo, noOfRep)
MZ = rarefyEcoIndexes(Mes, Zan, subsampleTo, noOfRep)
TZ = rarefyEcoIndexes(Tor, Zan, subsampleTo, noOfRep)
for (ind in eco_index_names){
  eco_ind_median[ind,  "T vs. M"] = 100 * median(TM[[ind]])
  eco_ind_median[ind, "M vs. Z"] = 100 * median(MZ[[ind]])
  eco_ind_median[ind,  "T vs. Z"] = 100 * median(TZ[[ind]])
}


## Extract percentages 
sr_median_reg
100 *(1 - sr_median_reg["Western Mediterranean","Zanclean"]/sr_median_reg["Eastern Mediterranean","Zanclean"])
100 *(1 - sr_median_reg["Western Mediterranean","Tortonian"]/sr_median_reg["Eastern Mediterranean","Tortonian"])


100 *(1 - sr_median_reg["whole basin","Tortonian"]/sr_median_reg["whole basin","pre-evaporitic Messinian"])
100 *(1 - sr_median_reg["whole basin","pre-evaporitic Messinian"]/sr_median_reg["whole basin","Zanclean"])

eco_ind_median
