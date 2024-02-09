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
noOfRep = 10000 # number of repetitions for subsampling

for (ti in timebins){
  wMed = get_from_db("all groups", "Western Mediterranean", ti)
  eMed = get_from_db("all groups", "Eastern Mediterranean", ti)
  PPNA = get_from_db("all groups", "Po Plain-Northern Adriatic", ti)
  subsampleTo = ceiling(0.8 * (min(c(length(wMed), length(eMed), length(PPNA)))))
  wMed_sr = rarefyTaxRichness(wMed, subsampleTo, noOfRep)
  eMed_sr = rarefyTaxRichness(eMed, subsampleTo, noOfRep)
  PPNA_sr = rarefyTaxRichness(PPNA, subsampleTo, noOfRep)
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
