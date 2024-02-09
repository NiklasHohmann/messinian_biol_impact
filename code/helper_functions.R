get_from_db=function(group, basin, timeslice, taxLevel = "species"){
  #'
  #' @title extract occurrence from Messinian database
  #' 
  #' @description
  #' returns a vector of taxon names from the Messinian DB on the specified taxonomic level, region, and time slice
  #' 
  #' 
  #' @param taxLevel "species","genus" or "family". Taxonomic level to extract
  #' @param group character, element of _group.names_ or "all groups". Taxonomic groups to retreive
  #' @param basin character, element of _regions_ or "whole basin". From which area occurrences are selected
  #' @param timeslice character, element of _timebins_ or "all timeslices". Time interval of interest
  #' 
  #' @returns character vector of taxon names on the specified taxonomic level
  
  #### groups 
  stopifnot(group %in% c('all groups',group.names))
  if (group=='all groups'){
    groupIndex=rep(TRUE,length(messinian_db$group.name))
  }
  else{
    groupIndex=messinian_db$group.name==group
  }
  #### timeslices
  stopifnot(timeslice %in% c('all timeslices', timebins))
  if (timeslice == "all timeslices"){
    timesliceIndex=rep(TRUE,length(messinian_db$Age))
  }
  else {
    timesliceIndex=messinian_db$Age==timeslice
  }
  #### basisn
  stopifnot(basin %in% c("whole basin",regions))
  if (basin =="whole basin"){
    basinIndex=rep(TRUE,length(messinian_db$region.new))
  }
  else {
    basinIndex=messinian_db$region.new==basin
  }
  
  #### taxonomic level 
  stopifnot(taxLevel %in% c("species","genus","family"))
  if (taxLevel=="species"){
    taxIndex=!is.na(messinian_db$Species.name) & !is.na(messinian_db$Genus.name) & !is.na(messinian_db$Family)
    occ=paste(messinian_db$Genus.name, messinian_db$Species.name, sep=' ')
    occ=occ[taxIndex ==TRUE & basinIndex==TRUE & timesliceIndex==TRUE & groupIndex==TRUE]
  }
  if (taxLevel=="genus"){
    taxIndex=!is.na(messinian_db$Genus.name)  & !is.na(messinian_db$Family)
    occ=messinian_db$Genus.name
    occ=occ[taxIndex ==TRUE & basinIndex==TRUE & timesliceIndex==TRUE & groupIndex==TRUE]
  }
  
  if (taxLevel=="family"){
    taxIndex=!is.na(messinian_db$Family)
    occ=messinian_db$Family
    occ=occ[taxIndex ==TRUE & basinIndex==TRUE & timesliceIndex==TRUE & groupIndex==TRUE]
  }
  return(occ)
}


rarefyTaxRichness=function(mySample, subsampleTo,noOfRep){
  #'
  #' @title rarefy taxonomic richness
  #' 
  #' @description
  #' rarefies a vector of taxon names to a specific sample size
  #' 
  #' @param mySample vector of taxonomic names
  #' @param subsampleTo integer, nomber of occurrences to target for subsampling. Must be larger than length(mySample)
  #' @param noOfRep integer, number of subsampling repetitions
  #' 
  #' @returns integer vector of length noOfRep, containing tax richnesses at each repetition
  stopifnot(length(mySample)>=subsampleTo)
  stopifnot(!is.na(mySample))
  taxRichness=sapply(seq_len(noOfRep), function(x) length(unique(sample(mySample,size=subsampleTo,replace=FALSE))))
  return(taxRichness)
}