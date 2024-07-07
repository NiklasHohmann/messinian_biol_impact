#### load data ####
cat("Running analysis, this might take a few minutes\n")
cat("Loading database\n")
messinian_db <- read.csv(file = "data/messinianDB.csv")

#### fix seed ####
set.seed(1)
cat("Sourcing helper functions\n")
#### Loading helper function ####
source("code/helper_functions.R")

#### Clean data ####
cat("Cleaning data\n")
remove_occ = grepl("Considered reworked", messinian_db$Notes, useBytes = TRUE) | grepl("Collected from deposits known as \"Livelli ad Aturia", messinian_db$Notes, useBytes = TRUE)
messinian_db = messinian_db[!remove_occ,]

#### Replace invalid tax names with NA ####
messinian_db$Species.name = replace(messinian_db$Species.name, messinian_db$Species.name == "sp.", NA)
messinian_db$Genus.name = replace(messinian_db$Genus.name, messinian_db$Genus.name == "indet.", NA)
messinian_db = messinian_db[ !messinian_db$Family == "indet.",  ]

#### Unique species names ####
sp = paste0(messinian_db$Genus.name, messinian_db$Species.name)
sp = sp[!is.na(messinian_db$Species.name) & ! is.na(messinian_db$Genus.name)]
unique_species = length(unique(sp))

#### Constants ####
timebins <- unique(messinian_db$Age)[c(3, 1, 2)] # sorted from old to young
regions <- unique(messinian_db$region.new)
group.names <- unique(messinian_db$group.name)
group.names.ext = c(group.names, "all groups")
regions.ext = c(regions, "whole basin")
eco_index_names = c("soerensen", "simpson", "nestedness")
noOfRep = 10000 # number of repetitions for subsampling

#### Species richness in subregions ####
## determine subsampling size for all regions for comparability
cat("Determining species richness in subregions\n")
subsampleTo = Inf
for (ti in timebins){
  wMed = get_from_db("all groups", "Western Mediterranean", ti)
  eMed = get_from_db("all groups", "Eastern Mediterranean", ti)
  PPNA = get_from_db("all groups", "Po Plain-Northern Adriatic", ti)
  subsampleTo = min(subsampleTo, ceiling(0.8 * (min(c(length(wMed), length(eMed), length(PPNA))))))
}

sr_median_reg = matrix(data = NA,
                       nrow = length(regions),
                       ncol = length(timebins),
                       dimnames = list("regions" = regions,
                                       "timebin" = timebins))

for (ti in timebins){
  wMed = get_from_db("all groups", "Western Mediterranean", ti)
  eMed = get_from_db("all groups", "Eastern Mediterranean", ti)
  PPNA = get_from_db("all groups", "Po Plain-Northern Adriatic", ti)
  wMed_sr = rarefyTaxRichness(wMed, subsampleTo, noOfRep)
  eMed_sr = rarefyTaxRichness(eMed, subsampleTo, noOfRep)
  PPNA_sr = rarefyTaxRichness(PPNA, subsampleTo, noOfRep)
  sr_median_reg["Western Mediterranean", ti] = median(wMed_sr)
  sr_median_reg["Eastern Mediterranean", ti] = median(eMed_sr)
  sr_median_reg["Po Plain-Northern Adriatic", ti] = median(PPNA_sr)
  file_name = paste0("figs/", ti, "_sr.pdf")
  main = paste0("Species richness in ", ti)
  ylim = c(0, 800) #max(max(wMed_sr), max(eMed_sr), max(PPNA_sr)))
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

#### East-west gradient in species richness ####
cat("Determining east-west gradient in species richness\n")
n = Inf
for (time in timebins){
  for (reg in regions[c(1,3)]){
    n = min(length(get_from_db("all groups", reg, time)), n)
  }
}
subsampleTo = ceiling(0.8 * n)
grad_list = list()

for (ti in timebins){
  wMed = get_from_db("all groups", "Western Mediterranean", ti)
  eMed = get_from_db("all groups", "Eastern Mediterranean", ti)
  grad_list[[ti]] = rarefyTaxGradient(wMed, eMed, subsampleTo, noOfRep) #  determine west-east richness gradient
}
file_name = "figs/W-E gradient species richness.pdf"
main = "West-East gradient in species richness"
ylab = paste0("Gradient in species richness, subsamples to ", subsampleTo, " occurrences")
pdf(file = file_name)
boxplot(grad_list,
        ylab = ylab,
        main = main,
        ylim = range(grad_list))
dev.off()

to_grad_test = wilcox.test(grad_list[["Tortonian"]], alternative = "less")
mes_grad_test = wilcox.test(grad_list[["pre-evaporitic Messinian"]], alternative = "less")
zan_grad_test = wilcox.test(grad_list[["Zanclean"]], alternative = "greater")

#### Species richness in the whole basin ####
cat("Determining species richness in whole basin\n")
# extract species names
Tor = get_from_db(group = "all groups", basin = "whole basin", timeslice = "Tortonian" )
Mes = get_from_db(group = "all groups", basin = "whole basin", timeslice = "pre-evaporitic Messinian" )
Zan = get_from_db(group = "all groups", basin = "whole basin", timeslice = "Zanclean" )
# define subsampling size (80 % of smallest sample)
subsampleTo = ceiling(0.8 * (min(c(length(Tor), length(Mes), length(Zan)))))
# subsample noOfRep times
Tor_sr = rarefyTaxRichness(mySample = Tor, subsampleTo = subsampleTo, noOfRep = noOfRep)
Mes_sr = rarefyTaxRichness(mySample = Mes, subsampleTo = subsampleTo, noOfRep = noOfRep)
Zan_sr = rarefyTaxRichness(mySample = Zan, subsampleTo = subsampleTo, noOfRep = noOfRep)
sr_median = c("Tor"= median(Tor_sr), "Mes" = median(Mes_sr), "Zan" = median(Zan_sr))
# make figure
file_name = paste0("figs/sr_through_time_whole_basin.pdf")
main = paste0("Species Richness whole basin")
ylim = c(0, max(c(Tor_sr, Mes_sr, Zan_sr)))
ylab = paste0("Species richness \n subsampled to ",  subsampleTo, " Occurrences")
pdf(file = file_name)
boxplot(list( "Tortonian" = Tor_sr,
              "Messinian" = Mes_sr,
              "Zanclean" =  Zan_sr),
        ylim = ylim,
        ylab = ylab,
        main = main)
dev.off()

# test: diversity already decreased before the salinity crisis
tor_mes_test = wilcox.test(Tor_sr, Mes_sr, alternative = "greater")
mes_zan_test = wilcox.test(Mes_sr, Zan_sr, alternative = "less")


#### Ecological indices ####
cat("Determining ecological indices\n")
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
  file_name = paste0("figs/", ind,"_whole_basin.pdf")
  pdf(file = file_name)
  main = paste0(ind, " for all groups, whole basin")
  ylab = paste0(ind, "\n subsampled to ",  subsampleTo, " Occurrences")
  boxplot(list("T vs. M" = TM[[ind]],
               "M vs. Z" = MZ[[ind]],
               "T vs. Z" = TZ[[ind]]),
          ylim = c(0,1),
          main = main,
          ylab = ylab,
          mar = c(5,5,1,1))
  dev.off()
}


#### Extract percentages  ####
cat("Extracting percentages \n")
# change in species richness between different time slices
sr_change_time = matrix(data = NA,
                        nrow = length(regions.ext),
                        ncol = length(time_comp_names),
                        dimnames = list("region" = regions.ext,
                                        "time_comp" = time_comp_names))

for (reg in regions){
  sr_change_time[reg, "T vs. M"] = 100 * (1 - sr_median_reg["Tortonian"]/sr_median_reg[reg,"pre-evaporitic Messinian"])
  sr_change_time[reg, "M vs. Z"] = 100 * (1 - sr_median_reg[reg,"pre-evaporitic Messinian"]/sr_median_reg[reg,"Zanclean"])
  sr_change_time[reg, "T vs. Z"] = 100 * (1 - sr_median_reg[reg,"Tortonian"]/sr_median_reg[reg,"Zanclean"])
}

# sr_median_reg
# change in species richness between different regions
reg_comp = c("WvsE", "WvsP", "EvsP")
sr_change_reg = matrix(data = NA,
                       nrow = length(timebins),
                       ncol = length(reg_comp),
                       dimnames = list("timeslice" = timebins,
                                       "reg_comp" = reg_comp))
for (ti in timebins){
  sr_change_reg[ti, "WvsE"] = 100 *(1 - sr_median_reg["Western Mediterranean",ti]/sr_median_reg["Eastern Mediterranean",ti])
  sr_change_reg[ti, "WvsP"] = 100 *(1 - sr_median_reg["Western Mediterranean",ti]/sr_median_reg["Po Plain-Northern Adriatic",ti])
  sr_change_reg[ti, "EvsP"] = 100 *(1 - sr_median_reg["Eastern Mediterranean",ti]/sr_median_reg["Po Plain-Northern Adriatic",ti])
}

sr_change_whole = c("T vs. M" = 100 * (1- sr_median["Tor"]/sr_median["Mes"]),
                    "M vs. Z" = 100 * (1- sr_median["Mes"]/sr_median["Zan"]),
                    "T vs. Z" = 100 * (1- sr_median["Tor"]/sr_median["Zan"]))

# IQR in change in species richness
quantile(100 * (1-Tor_sr/Mes_sr))
quantile(100 * (1-Mes_sr/Zan_sr))

## IQR in soerensen index
quantile(100 *TM[["soerensen"]])
quantile(100 * MZ[["soerensen"]])
# 
# eco_ind_median

cat("Done! \n")
cat("Outputs are in the folder \"figs\" and the variables sr_change_whole, sr_change_reg, sr_change_time, and eco_ind_median.")