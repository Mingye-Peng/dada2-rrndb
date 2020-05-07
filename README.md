# Match DADA2 output to rrnDB

## Desription

This repository hosts two customs functions to match the taxonomy output of DADA2 to the rrnDB database.
The aim of this function is not to correct the abundance of each ASV with their potential number of 16S copies, 
but to extract the number of 16S copy number as a trait for downstream analyses.

## Preparation
To run the function, you need to have:

* a sequence table where chimeras have already been removed (please follow the [DADA2 tutorial](https://benjjneb.github.io/dada2/tutorial.html) until this step)
* a taxonomy table that has been assigned with a database that is supported by rrnDB (NCBI or RDP)

If you have assigned your taxnomy table based on SILVA or any other database please re-assign the taxnonomy with RDP.

Accordingly, download the appropriate rrnDB database [here](https://rrndb.umms.med.umich.edu/static/download/) and 
unzip it before running the code.

## Dependencies
The function uses following packages:

* `parallel`
* `pbapply`

Make sure to install and load these packages prior to running the function.

If you need to assign the taxonomy make sure to do so either with:

* `DADA2` or
* `DECIPHER`

## Functions

There are two functions to achieve the desired output:

1. `dada2.rrndb`
   A function that first reduces the phylogenetic level to the rank that has been succesfully assigned. Then it
   extracts the finest phylogenetic rank that is available and tries to find a match in rrnDB. If there is no match,
   it will jump one rank higher and tries to find another match. It jumps to higher ranks until it finds a match in rrnDB.
2. `dada2_match_rrndb`
   This is the function that you will be actually using, as `dada2.rrndb` is part of this function. This function applies the
   above defined function by row by using `apply()`. To be precise, it actually uses the `pbapply()` function to allow the
   user to see a progress bar.
   
   Arguments:
   * `tax`: Taxonomy table as `data.frame`
   * `rrndb`: rrnDNB database as `data.frame`
   * `.parallel = F`: Switch to parallel computing if desired.
   
   If you are planning to use parallel computing, define your cluster (package: `parallel`) beforehand with:
   
   ```
   numCores <- detectCores() # 24
   cl <- makeCluster(numCores)
   ```
   Make sure to close the cluster after running `dada2_match_rrndb`.
   ```
   # stop parallel cluster
   stopCluster(cl)
   ```

## Output
`dada2_match_rrndb` adds the following columns to your taxonomy table:

* `class.rank`: The rank where a match to rrnDB was found (e.g. genus, family etc)
* `copy.nunber`: Number of 16S copy numbers of the classified rank

---

A working R script is given in the [*Example*](https://github.com/masumistadler/dada2-rrndb/tree/master/Example) folder.
