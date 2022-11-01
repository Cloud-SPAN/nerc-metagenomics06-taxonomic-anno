# This is an R script
# Lines starting with a hash are comments. They are not executed as 
# commands

# To run a command, put your cursor on the line you want to run
# and do CTRL-ENTER. You can also use the 'Run' button to run a command.
# The command is executed in the console (below) and any output 
# will appear there
# the > in the console is the prompt. 


# load packages needed
library("phyloseq")
library("tidyverse")
# The output from these commands will be:
### ── Attaching packages ──────────────────────────────────────── tidyverse 1.3.2 ──
### ✔ ggplot2 3.3.6      ✔ purrr   0.3.4 
### ✔ tibble  3.1.8      ✔ dplyr   1.0.10
### ✔ tidyr   1.2.1      ✔ stringr 1.4.1 
### ✔ readr   2.1.3      ✔ forcats 0.5.2 
### ── Conflicts ─────────────────────────────────────────── tidyverse_conflicts() ──
### ✖ dplyr::filter() masks stats::filter()
### ✖ dplyr::lag()    masks stats::lag()

# You don't need to worry about the Conflicts

#################################################################
#               Diversity Tackled With R                        #
#################################################################
# Now import the data in metagenome.biom into R using the 
# import_biom() function from phyloseq
biom_metagenome <- import_biom("metagenome.biom")
# This command produces no output in the console but created a
# special class of R object which is defined by the `phloseq` 
# package and called it `biom_metagenome`. Click on the object 
# name, biom_metagenome, in the Environment pane (top right).  
# This will open a view of the object in the same pane as your script.

# A phyloseq object is a special object in R. It has five parts, called
# 'slots' which you can see listed in the object view. These are `otu_table`,
# `tax_table`, `sam_data`, `phy_tree` and `refseq`. In our case, 
# `sam_data`, `phy_tree` and `refseq` are empty. The useful data are
# in otu_table` and `tax_table`.

# print the biom_metagenome object
biom_metagenome
# this will give the following output:
### phyloseq-class experiment-level object
### otu_table()   OTU Table:         [ 5905 taxa and 2 samples ]
### tax_table()   Taxonomy Table:    [ 5905 taxa by 7 taxonomic ranks ]

# The line starting otu_table tells us we have two samples -
# these are ERR2935805 and JP4D - with a total of 5905 taxa. 
# The tax_table again tells us how many taxa wwe have. The seven ranks
# indicates that we have some identifications down to species level. 
# The taxonomic ranks are from the classification system of taxa from
# the most general (kingdom) to the most specific (species): kingdom/domain,
# phylum, class, order, family, genus, species.

# We can view the otu_table with:
View(biom_metagenome@tax_table)
# This will open a view of the table in the same pane as your script.

# This table has the OTU identity in the row names and the samples in the 
# columns. The values in the columns are the abundance of that OYU in that
# sample.

# k__ kingdom/domain (note a letter, two underscores)
# p__ phylum
# c__ class
# o__ order
# f__ family
# g__ genus
# s__ species

# note we have some taxa that we can't get to species level, 
# some we can't get to genus level and some we can't get to 
# family level.

# To make downstream analysis easier for us we will remove the prefix
# (e.g. f__) on each item. This contains information about the rank 
# of the assigned taxonomy, we don’t want to lose this information 
# so will and instead rename the header of each column of the DataFrame
# to contain this information.
# To remove unnecessary characters we are going to use command substring().
# This command is useful to extract or replace characters in a vector. 
# To use the command, we have to indicate the vector (x) followed by the
# first element to replace or extract (first) and the last element to 
# be replaced (last). For instance: substring (x, first, last). If a 
# last position is not used it will be set to the end of the string.
# The prefix for each item in biom_metagenome is made up of a letter 
# an two underscores, for example: o__Bacillales. In this case “Bacillales”
# starts at position 4 with an B. So to remove the unnecessary characters 
# we will use the following code:
  
biom_metagenome@tax_table <- substring(biom_metagenome@tax_table, 4)

# check it worked
View(biom_metagenome@tax_table)

# Let's change the names too
colnames(biom_metagenome@tax_table) <- c("Kingdom",
                                         "Phylum", 
                                         "Class", 
                                         "Order", 
                                         "Family", 
                                         "Genus", 
                                         "Species")

# check it worked
View(biom_metagenome@tax_table)

# How many OTUs are in each kingdome? We can find out by combining
# some commands. 
# We need to 
# - turn the tax_table into a data frame (a useful data structure in R)
# - group by the Kingdom column
# - summarise by counting the number of rows for each Kingdom
# This can be achieved with the following command:
biom_metagenome@tax_table %>% 
  data.frame() %>% 
  group_by(Kingdom) %>% 
  summarise(n = length(Kingdom)) 

### # A tibble: 4 × 2
### Kingdom       n
### <chr>     <int>
### 1 Archaea      67
### 2 Bacteria   5808
### 3 Eukaryota     1
### 4 Viruses      29
 
# Most things are bacteria.

# We can explore how many phlya we have and how many OTU there are in each
# phlya in a similar way. This time we will use View() to see the whole 
# table because it won't all print to the console. We need to 
# - turn the tax_table into a data frame (a useful data structure in R)
# - group by the Phylum column
# - summarise by counting the number of rows for each phylum
# - viewing the result
# This can be achieved with the following command:
biom_metagenome@tax_table %>% 
  data.frame() %>% 
  group_by(Phylum) %>% 
  summarise(n = length(Phylum)) %>% 
  View()
# This shows us a table with a phylum, and the number times it 
# appeared, in each row. The number of phyla is given by the 
# number of rows in this table.  By defualt, the table is sorted
# alphabetically by phylum. We can sort by frequency by clicking
# on the 'n' column. There are 2743 Proteobacteria and 1050 
# Actinobacteria for example.


# Exercise 2
# Adapt the code to explore how many Orders we have and how many 
# OTU there are in each order.
# a) How many orders are there?
# b) What is the most common order?
# c) How many OTUs did not get down to order level?




#################################

# Plot alpha diversity
# We want to explore the bacterial diversity of our sample so 
# we will subset the bacteria

bac_biom_metagenome <- subset_taxa(biom_metagenome, Kingdom == "Bacteria")

# Now let’s look at some statistics of our bacterial metagenomes:
bac_biom_metagenome
### phyloseq-class experiment-level object
### otu_table()   OTU Table:         [ 5808 taxa and 2 samples ]
### tax_table()   Taxonomy Table:    [ 5808 taxa by 7 taxonomic ranks ]

# `phyloseq` includes a function called sample_sums() that can be used to
# count the number of OTUs in each sample
sample_sums(biom_metagenome)

summary(biom_metagenome@otu_table)

# The median in sample ERR2935805 is 1, meaning many of OTU occur only 
# once and the maximum is very high so at least one OUT is very abundant.

# The `plot_richness()` command will give us a visual representation of 
# the diversity inside the samples (i.e. α diversity): 
plot_richness(physeq = biom_metagenome,
              measures = c("Observed","Chao1","Shannon"))


# Each of these metrics can give insight of the distribution of the OTUs inside
# our samples. For example Chao1 diversity index gives more weight to singletons
# and doubletons observed in our samples, while the Shannon is a measure of 
# species richness and species evenness with more weigth on richness.
# 

# Use the following to open the manual page for plot_richness
?plot_richness


#################################################################
#              Taxonomic Analysis with R                        #
#################################################################



