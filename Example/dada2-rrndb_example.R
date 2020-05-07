###---------------------------------------###
#-   Extract rrnDB 16S rRNA copy number   - #
###---------------------------------------###

# Example code

#----------#
# PACKAGES #
#----------#
library(dada2)
library(DECIPHER); packageVersion("DECIPHER")
library(parallel)
library(pbapply)

#-----------#
# FUNCTIONS #
#-----------#
source("./Functions/dada2.rrndb.R")
source("./Functions/dada2_match_rrndb.R")

#--------------------------------------------------------------------------------------------------#
# rrnDB is based on RDP or NCBI
# NCBI database is not supported by DADA2 (there is no training set to download option)
# If taxonomy was assigend using different database re-assign with RDP

# Follow DADA2 tutorial until "Remove chimeras"
# https://benjjneb.github.io/dada2/tutorial.html

# object needed: output of `removeBimeraDenovo()`
seqtab.nochim <- readRDS("./Objects/nochim_seqtab.rds")

#-------------------#
#- Assign Taxonomy -#
#-------------------#

# Option 1: ##
#- DADA2 `assignTaxonomy`
tax <- assignTaxonomy(seqtab.nochim, "./DB/rdp_train_set_16.fa.gz", multithread = TRUE)
saveRDS(tax, "./Objects/taxtab_rdp_v16_2018.rds")
#tax <- readRDS("./Objects/taxtab_rdp_v16_2018.rds")

# If desired assign species
#tax <- addSpecies(tax, "../DADA2/DB/rdp_species_assignment_16.fa.gz")
#saveRDS(tax, "./Objects/taxtabspecies_rdp_v16_2018.rds")

## Option 2: ##
#- Assign with DECIPHER
dna <- DNAStringSet(getSequences(seqtab.nochim)) # Create a DNAStringSet from the ASVs
load("../DADA2/DB/RDP_v16-mod_March2018.RData") # CHANGE TO THE PATH OF YOUR TRAINING SET
ids <- IdTaxa(dna, trainingSet, strand="top", processors=NULL, verbose=FALSE) # use all processors
ranks <- c("domain", "phylum", "class", "order", "family", "genus", "species") # ranks of interest
# Convert the output object of class "Taxa" to a matrix analogous to the output from assignTaxonomy
taxid <- t(sapply(ids, function(x) {
  m <- match(ranks, x$rank)
  taxa <- x$taxon[m]
  taxa[startsWith(taxa, "unclassified_")] <- NA
  taxa
}))
colnames(taxid) <- ranks; rownames(taxid) <- getSequences(seqtab.nochim)

saveRDS(taxid, "./Objects/taxtab_idtaxa_rdp_v16_2018.rds")
#taxsp <- readRDS("./Objects/taxtabspecies_rdp_v16_2018.rds")

#-----------------#
#- Prepare rrnDB -#
#-----------------#
# read in rrnDB data base
# download *_pantaxa_stats_RDP.tsv.gz
# at https://rrndb.umms.med.umich.edu/static/download/
rrndb <- read.table("./rrnDB/rrnDB-5.6_pantaxa_stats_RDP.tsv",
                    sep = "\t", header = T, stringsAsFactors = F)

# check if rank names match
levels(factor(rrndb$rank))
colnames(taxsp)

# if not, unify rank names
# include "species" at the end of the vector if you have assigned your ASVs until species level
colnames(taxsp) <- c("domain", "phylum", "class", "order", "family", "genus") # "species"

# select only necessary columns of rrnDB
rrndb <- rrndb[,c("rank", "name", "mean")]

#------------------#
#- Match to rrnDB -#
#------------------#
## Optional: ##
#- If you have many ASVs, parallel computing is advisable
#- Asssign cores for parallel computing
numCores <- detectCores() # 24
cl <- makeCluster(numCores-4) # don't use all cores

# run function to extract 16S rRNA copy number
# the function extracts the finest phylogenetic rank that is available and tries to find a match in rrnDB
# if there is no match, it will jump one rank higher and tries to find another match
# it jumps to higher ranks until it finds a match in rrnDB

# the function adds following columns to your taxonomy table:
# class.rank: The rank where a match to rrnDB was found (e.g. genus, family etc)
# copy.nunber: Number of 16S copy numbers of the classified rank

# convert matrix to data frame as the function adds numbers to the matrix
taxsp <- as.data.frame(taxsp, stringsAsFactors = F)

# run matching function
tax.withcopynum <- dada2_match_rrndb(taxsp, rrndb, .parallel = T)
# non-parallel version:
# tax.withcopynum <- dada2_match_rrndb(taxsp, rrndb)
saveRDS(tax.withcopynum, "./Objects/tax_idtaxa_rdp_v16_2018_withcopynumbers.rds")

# stop parallel cluster
stopCluster(cl)
