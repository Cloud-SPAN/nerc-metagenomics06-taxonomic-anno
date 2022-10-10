---
title: "Diversity Tackled With R "
teaching: 40
exercises: 10
questions:
- "How can I obtain the abundance of the reads?"
- "How can I use R to explore diversity?"
- "What are α and β diversity? What are the metrics used to measure these?"
objectives:
- "Use R packages for analysing metagenome diversity."  
- "Generate a `phyloseq` object for performing diversiy analysis."
- "Explain α and β diversity."
keypoints:
- "The `phyloseq` package be used to compute alpha diversity  from an abundance table."  
- "The `ggplot` package can be used visualise abundance "
math: yes
---

Once we know the taxonomic composition of our metagenomic sequencing data we can characterise them by their diversity.

## What is diversity?
Species diversity is the number of species in a system and the relative abundance of each of those species. It can be defined on three different scales (Whittaker, 1960).

1. the total species diversity in an ecosystem known as **gamma (γ) diversity**
2. average diversity at a local site, known as **alpha (α) diversity**
3. the difference in diversity between local sites, known as **beta (β) diversity**

A metagenome can be considered a local site. In this episode we will calculate α diversity (that within a metagenome) and β diversity (that between metagenomes).   

### Alpha (α) diversity
The simplest measure of α diversity is the number of species, or species **richness**. However, most indices of α diversity take into account both the number of species and their relative abundances, or species **evenness**. Different diversity indices weight these two components differently.


| α Diversity Index |  Description | Calculation | Where |
|-------------------|--------------|-------------|-------|
| Shannon (H)       | Estimation of species richness and species evenness. More weigth on richness.  | $$H = - \sum_{i=1}^{S} p_{i} \ln{p_{i}}$$ | $$S$$ is the number of OTUs and $$p_{i}$$ is the proportion of the community represented by OTU|
| Simpson's (D)     |Estimation of species richness and species evenness. More weigth on evenness.  | $$D = \frac{1}{\sum_{i=1}^{S} p_{i}^{2}}$$| $$S$$ is Total number of the species in the community and $$p_{i}$$ is the proportion of community represented by OTU i |  
| Chao1           | Abundance based on species represented by a single individual (singletons) and two individuals (doubletons). | $$S_{chao1} = S_{Obs} + \frac{F_{1} \times (F_{1} - 1)}{2 \times (F_{2} + 1)}$$ |$$F_{1}$$ and $$F_{2}$$ are the counts of singletons and doubletons respectively and $$S_{chao1}=S_{Obs}$$ is the number of observed species|


<a href="{{ page.root }}/fig/03-07-01.png">
  <img src="{{ page.root }}/fig/03-07-01.png" alt="Diagram to demonstratealpha diversity. Three lakes are shown, A, B and C. In lake A, we have three fishes, each one of a different species. In lake B, we have two fishes each one of a different species.And in lake C we have four fishes, each one of different species." />
</a>
<em> Figure 1. Alpha diversity represented by fish in a pond. Here, alpha diversity is measured in the simplest way using species richness. </em>

###  Beta (β) diversity
β diversity measures how different two or more communities are in their richness, evenness or both.

| β Diversity Index |  Description |
|-------------------|--------------|
| Bray–Curtis dissimilarity  | The compositional _dissimilarity_ between two metagenomes, based on counts in each metagenome. Ranges from 0 (the two metagenomes have the same species composition) to 1 (the two metagenomes do not share any species). Bray–Curtis dissimilarity emphasises abundance.|
| Jaccard distance   | Also ranges from 0 (the two metagenomes have the same species) to 1 (the two metagenomes do not share any species) but is based on the presence or absence of species only. This means it emphasises richness.  |
| UniFrac           | Differs from the Bray-Curtis dissimilarity and Jaccard distance by including the relatedness between tax in a metagenome. Measures the phylogentic distance between metagenomes as the proportion of unshared phylogentic tree branches. Weighted-Unifrac takes into account the relative abundance of taxa shared between samples; unweighted-Unifrac only considers presence or absence.|

Figure 2 shows α and the β diversity for three lakes. The most simple way to calculate the β diversity is to calculate the number of species that are unique in two lakes. For example, the number of species in Lake A (the α diversity) is 3 and 1 of these is also found in Lake C; the number of species in Lake C is 2 and 1 of these is also in Lake A. The β diversity between A and C is calculated as (3 - 1) + (2 - 1) = 3


<a href="{{ page.root }}/fig/03-07-02.png">
  <img src="{{ page.root }}/fig/03-07-02.png" alt="Alpha and Beta diversity diagram: Each lake has a different number of species. The number of species in Lake A (the α diversity) is 3 and 1 of these is also found in Lake C; the number of species in Lake C is 2 and 1 of these is also in Lake A. The β diversity between A and C is calculated as (3 - 1) + (2 - 1) = 3. The number of species in Lake B (the α diversity) is 3 and 2 of these is also found in Lake A; the number of species in Lake A is 3 and 2 of these is also in Lake B. The β diversity between A and B is calculated as (3 - 2) + (3 - 2) = 2" />
</a>
<em> Figure 2. Alpha and Beta diversity represented by fishes in a pond.<em/>


> ## Exercise 1:
> In the next picture there are two lakes with different fish species:
> <a href="{{ page.root }}/fig/03-07-01e.png">
>   <img src="{{ page.root }}/fig/03-07-01e.png" alt="In lake A, we have four different species, two of these species have 3 specimens each one. This lake also have two specimens of another species and only one specimen of the other specie. We got nine fishes total. On the other hand, lake B has only three different species, the most populated species has five specimens and we have only one specimen of the other two species. We got seven species total in lake B " />
> </a>
> Which of the options below is true:
> 1. α diversity of A = 4, α diversity of B = 3, β diversity between A and B = 1
> 2. α diversity of A = 4, α diversity of B = 3, β diversity between A and B = 5
> 3. α diversity of A = 9, α diversity of B = 7, β diversity between A and B= 16
>
> Please, paste your result on the collaborative document provided by instructors.
>   
>
>> ## Solution
>> Answer: 2. α diversity of A = 4, α diversity of B = 3, β diversity between A and B = 5
>> The number of species in Lake A (the α diversity) is 4 and 1 of these is also found in Lake B; the number of species in Lake B is 3 and 1 of these is also in Lake A. The β diversity between A and C is calculated as (4 - 1) + (3 - 1) = 5.
> {: .solution}
{: .challenge}

## How do we calculate diversity from metagenomic samples?

There are 2 steps to need to calculate the diversity of our samples.

1. Create a Biological Observation Matrix, BIOM table, from the Kraken output. A BIOM table is an matrix of counts with samples in the columns and taxa in the rows. The values in the matrix are the counts of that taxa in that sample.
2. Analyse the BIOM table to generate diversity indices and relative abundance plots.

### Create a BIOM table
We will use a command-line program called [`kraken-biom`](https://github.com/smdabdoub/kraken-biom) to convert our Kraken output into a BIOM table. `kraken-biom` takes the `.report` output of Kraken and creates a BIOM table in [`.biom`](https://biom-format.org/) format.

Move in to your `taxonomy` folder
~~~
 cd ~/cs_course/analysis/taxonomy
~~~~
{: .bash}

List the files
~~~
 ls -l
~~~~
{: .bash}

~~~
-rw-rw-r-- 1 csuser csuser 3935007137 Oct  9 09:16 ERR2935805.kraken
-rw-rw-r-- 1 csuser csuser     424101 Oct  9 09:16 ERR2935805.report
~~~
{: .output}

As we saw in the previous episode, `.kraken` and `.report` are the output files generated by Kraken.


`kraken-biom` has many options which you can see with the help command. However, we only need to specify an output format `--fmt` of `json` to use the file in the next step.

> ## `kraken-biom -h` output
> ~~~
> usage: kraken-biom [-h] [--max {D,P,C,O,F,G,S}] [--min {D,P,C,O,F,G,S}] [-o OUTPUT_FP] [--otu_fp OTU_FP] [--fmt {hdf5,json,tsv}] [--gzip] [--version] [-v]
>                    kraken_reports [kraken_reports ...]
>                         Set the output format of the BIOM table. Default is HDF5.
> Create BIOM-format tables (http://biom-format.org) from Kraken output  BIOM (v2.x) files are internally compressed by default, so this option is not needed when
> (http://ccb.jhu.edu/software/kraken/).mt hdf5.
>   --version             show program's version number and exit
> The program takes as input, one or more files output from the kraken-report
> tool. Each file is parsed and the counts for each OTU (operational taxonomic
> unit) are recorded, along with database ID (e.g. NCBI), and lineage. The
> extracted data are then stored in a BIOM table where each count is linked
> to the Sample and OTU it belongs to. Sample IDs are extracted from the input
> filenames (everything up to the '.').
>
> OTUs are defined by the --max and --min arguments. By default these are
> set to Order and Species respectively. This means that counts assigned
> directly to an Order, Family, or Genus are recorded under the associated
> OTU ID, and counts assigned at or below the Species level are assigned to
> the OTU ID for the species. Setting a minimum rank below Species is not yet
> available.
>
> The BIOM format currently has two major versions. Version 1.0 uses the
> JSON (JavaScript Object Notation) format as a base. Version 2.x uses the
> HDF5 (Hierarchical Data Format v5) as a base. The output format can be
> specified with the --fmt option. Note that a tab-separated (tsv) output
> format is also available. The resulting file will not contain most of the
> metadata, but can be opened by spreadsheet programs.
>
> Version 2 of the BIOM format is used by default for output, but requires the
> Python library 'h5py'. If the library is not installed, kraken-biom will
> automatically switch to using version 1.0. Note that the output can
> optionally be compressed with gzip (--gzip) for version 1.0 and TSV files.
> Version 2 files are automatically compressed.
>
> Usage examples
> --------------
> 1. Basic usage with default parameters:
>
> $ kraken-biom.py S1.txt S2.txt
>
>   This produces a compressed BIOM 2.1 file: table.biom
>
> 2. BIOM v1.0 output:
>
> $ kraken-biom.py S1.txt S2.txt --fmt json
>
>   Produces a BIOM 1.0 file: table.biom
>
> 3. Compressed TSV output:
>
> $ kraken-biom.py S1.txt S2.txt --fmt tsv --gzip -o table.tsv
>
>   Produces a TSV file: table.tsv.gz
>
> 4. Change the max and min OTU levels to Class and Genus:
>
> $ kraken-biom.py S1.txt S2.txt --max C --min G
>
> Program arguments
> -----------------
>
> positional arguments:
>   kraken_reports        Results files from the kraken-report tool.
>
> optional arguments:
>   -h, --help            show this help message and exit
>   --max {D,P,C,O,F,G,S}
>                         Assigned reads will be recorded only if they are at or below max rank. Default: O.
>   --min {D,P,C,O,F,G,S}
>                         Reads assigned at and below min rank will be recorded as being assigned to the min rank level. Default: S.
>   -o OUTPUT_FP, --output_fp OUTPUT_FP
>                         Path to the BIOM-format file. By default, the table will be in the HDF5 BIOM 2.x format. Users can output to a different format using the --fmt
>                         option. The output can also be gzipped using the --gzip option. Default path is: ./table.biom
>   --otu_fp OTU_FP       Create a file containing just the (NCBI) OTU IDs for use with a service such as phyloT (http://phylot.biobyte.de/) to generate a phylogenetic tree
>                         for use in downstream analysis such as UniFrac, iTol (itol.embl.de), or PhyloToAST (phylotoast.org).
>   --fmt {hdf5,json,tsv}
>                         Set the output format of the BIOM table. Default is HDF5.
>   --gzip                Compress the output BIOM table with gzip. HDF5 BIOM (v2.x) files are internally compressed by default, so this option is not needed when
>                         specifying --fmt hdf5.
>   --version             show program's version number and exit
>   -v, --verbose         Prints status messages during program execution.
> ~~~
> {: .output}
{: .solution}

With the next command, we are going to create a table in [Biom](https://biom-format.org/) format called `ERR2935805.biom` from our Kraken report, `ERR2935805.report`.


~~~
 kraken-biom ERR2935805.report --fmt json -o ERR2935805.biom
~~~
{: .bash}

If we list the files in our `taxonomy` folder, we will see that the `ERR2935805.biom` file has been created.
~~~
 ls -l
~~~
{: .bash}
~~~
-rw-rw-r-- 1 csuser csuser 3935007137 Oct  9 09:16 ERR2935805.kraken
-rw-rw-r-- 1 csuser csuser     424101 Oct  9 09:16 ERR2935805.report
-rw-rw-r-- 1 csuser csuser     741259 Oct  9 10:22 ERR2935805.biom
~~~
{: .output}

###  Analyse the BIOM table  

We will be using an `R` package called [`phyloseq`](https://joey711.github.io/phyloseq/) to analyse our metagenome. Other software for analyses of diversity include [Qiime2](https://qiime2.org/), [MEGAN](https://www.wsi.uni-tuebingen.de/lehrstuehle/algorithms-in-bioinformatics/software/megan6/) and the `R` package [`Vegan`](https://vegandevs.github.io/vegan/)

We will be using command line R ???

More here about how we're running this. Rstudio cloud or command line R?


~~~
> install.libraries()
~~~
{: .language-r}  

Once the libraries are installed, we must make them available for this R session. Now load the libraries (a process needed every time we begin a new work
in R and we are going to use them):

~~~
> library("phyloseq")
> library("ggplot2")
> library("readr")
> library("patchwork") # Not needed?
~~~
{: .language-r}


### Load data with the number of reads per OTU and taxonomic labels for each OTU  

First we tell R in which directory we are working.
~~~
> setwd("~/dc_workshop/taxonomy/") # Not needed?
~~~
{: .language-r}

Let's procced to create the phyloseq object with the `import_biom` command:
~~~
> biom_metagenome <- import_biom("ERR2935805.biom")
~~~
{: .language-r}

Now, we can inspect the result by asking what class is the object created, and
doing a close inspection of some of its content:
~~~
> class(biom_metagenome)
~~~
{: .language-r}
~~~
[1] "phyloseq"
attr("package")
[1] "phyloseq"
~~~
{: .output}

The "class" command indicates that we already have our phyloseq object.
Let's try to access the data that is stored inside our `biom_metagenome` object. Since a phyloseq object
is a special object in R, we need to use the operator `@` to explore the subsections of data inside `biom_metagenome`.
If we type `biom_metagenome@` five options are displayed;  `otu_table`, `tax_table`, `sam_data`, `phy_tree` and `refseq`. We will first look at `otu_table` and `tax_table`.

~~~
> View(biom_metagenome@tax_table)
~~~
{: .language-r}

<img src="{{ page.root }}/fig/03_02_phyloseq_taxtab.png" alt="A table where the taxonomic
identification information of all OTUs is displayed. Each row represent one
OTU and the columns its identification at different levels in the taxonomic taxonomic classification ranks, begging with Kingdom until we reach Species
in the seventh column " />
<em> Figure 3. Table of the OTU data from our `biom_metagenome` object. <em/>

Next, let's get rid of some of the unnecesary characters
in the OTUs identificator and put names to the taxonomic ranks:

To remove unnecessary characters in `.Data` (matrix), we are going to use command `substring()`. This command is useful to extract or replace characters in a vector. To use the command, we have to indicate the vector (x) followed by the first element to replace or extract (first) and the last element to be replaced (last). For instance: `substring (x, first, last)`. `substring()` is a "flexible" command, especially to select characters of different lengths as in our case. Therefore, it is not necessary to indicate "last", so it will take the last position of the character by default. Considering that a matrix is a arrangement of vectors, we can use this command. Each character in `.Data` is preceded by 3 spaces occupied by a letter and two underscores, for example: `o__Rhodobacterales`. In this case "Rodobacterales" starts at position 4 with an R. So to remove the unnecessary characteres we will use the following code:

~~~
> biom_metagenome@tax_table@.Data <- substring(biom_metagenome@tax_table@.Data, 4)
> colnames(biom_metagenome@tax_table@.Data)<- c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")
~~~
{: .language-r}

<a href="{{ page.root }}/fig/03-07-04.png">
  <img src="{{ page.root }}/fig/03-07-04.png" alt="The same table we saw in Figure
  3 but with informative names in each of the columns. Now, we can see which of
  the columns are associated with which taxonomic classification rank" />
</a>
<em> Figure 4. Table of the OTU data from our `biom_metagenome` object. With corrections. <em/>

To explore how many phyla we have, we are going to use a command name `unique()`. Let's try what result
we obtain with the next code:
~~~
> unique(biom_metagenome@tax_table@.Data[,"Phylum"])
~~~
{: .language-r}
~~~
 [1] "Proteobacteria"              "Actinobacteria"              "Firmicutes"                 
 [4] "Cyanobacteria"               "Deinococcus-Thermus"         "Chloroflexi"                
 [7] "Armatimonadetes"             "Bacteroidetes"               "Chlorobi"                   
[10] "Gemmatimonadetes"            "Planctomycetes"              "Verrucomicrobia"            
[13] "Lentisphaerae"               "Kiritimatiellaeota"          "Chlamydiae"                 
[16] "Acidobacteria"               "Spirochaetes"                "Synergistetes"              
[19] "Nitrospirae"                 "Tenericutes"                 "Coprothermobacterota"       
[22] "Ignavibacteriae"             "Candidatus Cloacimonetes"    "Fibrobacteres"              
[25] "Fusobacteria"                "Thermotogae"                 "Aquificae"                  
[28] "Thermodesulfobacteria"       "Deferribacteres"             "Chrysiogenetes"             
[31] "Calditrichaeota"             "Elusimicrobia"               "Caldiserica"                
[34] "Candidatus Saccharibacteria" "Dictyoglomi"
~~~
{: .output}

This is useful, but what we need to do if we need to know how many of our OTUs have been assigned to the phylum
Firmicutes?. Let´s use the command `sum()` to ask R:
~~~
> sum(biom_metagenome@tax_table@.Data[,"Phylum"] == "Firmicutes")
~~~
{: .language-r}
~~~
[1] 580
~~~
{: .output}

> ## Exercise 2: Explore a phylum
>
> Go into groups and choose one phylum that is interesting for your
> group, and use the learned code to find out how many OTUs have been assigned to
> your chosen phylum and what are the unique names of the genera inside it.
> がんばれ! (ganbate; *good luck*):
>> ## Solution
>> Change the name of a new phylum wherever it is needed to get the result.
>> As an example, here is the solution for Proteobacteria:
>> ~~~
>> sum(biom_metagenome@tax_table@.Data[,"Phylum"] == "Proteobacteria")
>> ~~~
>> {: .language-r}
>> ~~~
>> [1] 1949
>> ~~~
>> {: .output}
>> ~~~
>> unique(biom_metagenome@tax_table@.Data[biom_metagenome@tax_table@.Data[,"Phylum"] == "Proteobacteria", "Genus"])
>> ~~~
>> {: .language-r}
>>
> {: .solution}
{: .challenge}


> ## Phyloseq objects
> Finally, we can review our object and see that all datasets (i.e. JC1A, JP4D, and JP41) are in the object.
> If you look at our Phyloseq object, you will see that there are more data types
> that we can use to build our object(`?phyloseq()`), such as a phylogenetic tree and metadata
> concerning our samples. These are optional, so we will use our basic
> phyloseq object for now, composed of the abundances of specific OTUs and the
> names of those OTUs.  
{: .callout}


## Plot alpha diversity

We want to know how is the bacterial diversity, so we will prune all of the
non-bacterial organisms in our metagenome. To do this we will make a subset
of all bacterial groups and save them.
~~~
> biom_metagenome <- subset_taxa(biom_metagenome, Kingdom == "Bacteria")
~~~
{: .language-r}

Now let's look at some statistics of our metagenomes:

~~~
> biom_metagenome
~~~
{: .language-r}
~~~
phyloseq-class experiment-level object
otu_table()   OTU Table:         [ 4024 taxa and 3 samples ]
tax_table()   Taxonomy Table:    [ 4024 taxa by 7 taxonomic ranks ]
~~~
{: .output}
~~~
> sample_sums(biom_metagenome)
~~~
{: .language-r}
~~~
  JC1A   JP4D   JP41
 18412 149590  76589
~~~
{: .output}

~~~
> summary(biom_metagenome@otu_table@.Data)
~~~
{: .language-r}
~~~
      JC1A              JP4D              JP41        
 Min.   :  0.000   Min.   :   0.00   Min.   :   0.00  
 1st Qu.:  0.000   1st Qu.:   3.00   1st Qu.:   1.00  
 Median :  0.000   Median :   7.00   Median :   5.00  
 Mean   :  4.575   Mean   :  37.17   Mean   :  19.03  
 3rd Qu.:  2.000   3rd Qu.:  21.00   3rd Qu.:  14.00  
 Max.   :399.000   Max.   :6551.00   Max.   :1994.00  
~~~
{: .output}

By the output of the `sample_sums()` command we can see how many reads there are
in the library. Also, the Max, Min and Mean output on `summary()` can give us an
idea of the evenness. Nevertheless, to have a more visual representation of the
diversity inside the samples (i.e. α diversity) we can now look at a ggplot2
graph created using Phyloseq:

~~~
> plot_richness(physeq = biom_metagenome,
              measures = c("Observed","Chao1","Shannon"))
~~~
{: .language-r}

<a href="{{ page.root }}/fig/03-07-05.png">
  <img src="{{ page.root }}/fig/03-07-05.png" alt="A figure divided in three
  sections. Each of these sections represent a diferent alpha diversity index.
  Inside this sections, each point represent the value assigned on this index to
  the three different samples. We can see how the different indexes gives
  different values to the same sample." />
</a>
<em> Figure 5. Alpha diversity indexes for both samples. <em/>

Each of these metrics can give insight of the distribution of the OTUs inside
our samples. For example Chao1 diversity index gives more weight to singletons
and doubletons observed in our samples, while Shannon is a entropy index
remarking the impossiblity of taking two reads out of the metagenome "bag"
and that these two will belong to the same OTU.


> ## Exercise 3:
> While using the help provided explore these options available for the function in `plot_richness()`:
> 1. `nrow`
> 2. `sortby`
> 3. `title`
>
> Use these options to generate new figures that show you
> other ways to present the data.
>
>> ## Solution
>> The code and the plot using the three options will look as follows:
>> The "title" option adds a title to the figure.
>> ~~~
>> > plot_richness(physeq = biom_metagenome,
>>              title = "Alpha diversity indexes for both samples in Cuatro Cienegas",
>>              measures = c("Observed","Chao1","Shannon"))
>> ~~~
>> {: .language-r}
>>
>> <a href="{{ page.root }}/fig//TitleFlag.png">
>> <img src="{{ page.root }}/fig//TitleFlag.png" alt="Alpha diversity indexes for both samples with title" />
>> </a>
>>
>> The "nrow" option arranges the graphics horizontally.
>> ~~~
>> > plot_richness(physeq = biom_metagenome,
>>              title = "Alpha diversity indexes for both samples in Cuatro Cienegas",
>>              measures = c("Observed","Chao1","Shannon"),
>>              nrow=3)
>> ~~~
>> {: .language-r}
>>  
>> <a href="{{ page.root }}/fig//NrowFlag.png">
>> <img src="{{ page.root }}/fig//NrowFlag.png" alt="Alpha diversity indexes for both samples horizontal with title" />
>> </a>
>>
>> The "sortby" option orders the samples from least to greatest diversity depending on the parameter. In this case, it is ordered by "Shannon" and tells us that the JP4D sample has the lowest diversity and the JP41 sample the highest.
>> ~~~
>> > plot_richness(physeq = biom_metagenome,
>>              title = "Alpha diversity indexes for both samples in Cuatro Cienegas",
>>              measures = c("Observed","Chao1","Shannon"),
>>              sortby = "Shannon")
>> ~~~
>> {: .language-r}
>>
>> <a href="{{ page.root }}/fig//SortbyFlag.png">
>> <img src="{{ page.root }}/fig//SortbyFlag.png" alt="Alpha diversity indexes for both samples with title sort by Shannon" />
>> </a>
>>
>>
>>  Considering the above mentioned, together with the 3 graphs, we can say that the samples JP41 and JP4D present a high diversity with respect to the JC1A, but that the diversity of the sample JP41 is mainly given by singletons or doubletons, instead, the diversity of JP4D is given by species in much greater abundance. Although because the values of H (Shannon) above 3 are considered to have a lot of diversity.
>>
>  {: .solution}
{: .challenge}  


> ## Discussion
>
> How much can the α diversity can be changed by eliminating the singletons
> and doubletons?
{: .discussion}

## Reading
Tuomisto, H. A consistent terminology for quantifying species diversity? Yes, it does exist. Oecologia 164, 853–860 (2010). [https://doi.org/10.1007/s00442-010-1812-0](https://doi.org/10.1007/s00442-010-1812-0)

Whittaker, R. H. (1960) Vegetation of the Siskiyou Mountains, Oregon and California. Ecological Monographs, 30, 279–338

{% include links.md %}
