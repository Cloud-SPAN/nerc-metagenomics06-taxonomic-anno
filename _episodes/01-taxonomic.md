---
title: "Taxonomic Assignment"
teaching: 30
exercises: 15
questions:
- "How can I assign a taxonomy to my contigs?"
- "How can I visualise these assignments?"
objectives:
- "Understand how taxonomic assignment works."
- "Use kraken2 to assign taxonomies to reads and contigs."
- "Visualize taxonomic annotations in dataset."

keypoints:
- "Taxonomy can only be assigned by comparing against a database with genome annotations. These are not exhaustive and so many things will remain unannotated depending on the samples you are analysing."
- "Taxonomic assignment can be done using Kraken2."
- "Krona and Pavian are web based tools that can be used to visualize the assigned taxa."
---
## What is taxonomic assignment?

Taxonomic assignment is the process of assigning a sequence, in this case a MAG, which is a bin containing contigs, to a specific taxon.
You may see these referred to as Operational Taxonomic Units (OTUs), particularly if you are dealing with amplicon sequences.

These assignments are done by comparing our sequence to a database. These searches can be done in many different ways, and against a variety of databases. There are many programs for doing taxonomic mapping, almost all of them follows one of the next strategies:  

1. BLAST: Using BLAST or DIAMOND, these mappers search for the most likely hit for each sequence within a database of genomes (i.e. mapping). This strategy is slow.    

2. K-mers: A genome database is broken into pieces of length k, so as to be able to search for unique pieces by taxonomic group, from lowest common ancestor (LCA), passing through phylum to species. Then, the algorithm breaks the query sequence (reads, contigs) into pieces of length k, looks for where these are placed within the tree and make the classification with the most probable position.  
<img align="centre" width="682" height="377" <img src="{{ page.root }}/fig/01-03_LCA.png" alt="Diagram of taxonomic tree" />
<br clear="centre"/>
<em> Figure 1. Lowest common ancestor assignment example.<em/>

3. Markers: They look for markers of a database made _a priori_ in the sequences to be classified and assign the taxonomy depending on the hits obtained.    

A key result when you do taxonomic assignment of metagenomes is the abundance of each taxa in your sample. The absolute abundance of a taxon is the number of sequences (reads or contigs within a MAG, depending on how you have performed the searches) assigned to it.  
We also often use relative abundance, which is the proportion of sequences assigned to it from the total number of sequences rather than absolute abundances. This is because the absolute abundance can be misleading and samples can be sequenced to different depths, and the relative abundance makes it easier to compare between samples accounting for sequencing depth differences.  
It is important to be aware of the many biases that that can skew the abundances along the metagenomics workflow, shown in the figure, and that because of them we may not be obtaining the real abundance of the organisms in the sample.

<a href="{{ page.root }}/fig/03-06-02.png">
  <img src="{{ page.root }}/fig/03-06-02.png" alt="Flow diagram that shows how the initial composition of 33% for each of the three taxa in the sample ends up being 4%, 72% and 24% after the biases imposed by the extraction, PCR, sequencing and bioinformatics steps." />
</a>
<em>Figure 2. Abundance biases during a metagenomics protocol. <em/>

## Using Kraken 2
We will be using the command line program Kraken2 to do our taxonomic assignment. [Kraken 2](https://ccb.jhu.edu/software/kraken2/) is the newest version of Kraken, a taxonomic classification system using exact k-mer matches to achieve high accuracy and fast classification speeds.

`kraken2` is already installed on our instance so we can look at the `kraken2` help.
~~~  
 kraken2  
~~~
{: .bash}

> ## Kraken2 help documentation
>~~~
> Usage: kraken2 [options] <filename(s)>
>
> Options:
>   --db NAME               Name for Kraken 2 DB
>                           (default: none)
>   --threads NUM           Number of threads (default: 1)
>   --quick                 Quick operation (use first hit or hits)
>   --unclassified-out FILENAME
>                           Print unclassified sequences to filename
>   --classified-out FILENAME
>                           Print classified sequences to filename
>   --output FILENAME       Print output to filename (default: stdout); "-" will
>                           suppress normal output
>   --confidence FLOAT      Confidence score threshold (default: 0.0); must be
>                           in [0, 1].
>   --minimum-base-quality NUM
>                           Minimum base quality used in classification (def: 0,
>                           only effective with FASTQ input).
>   --report FILENAME       Print a report with aggregrate counts/clade to file
>   --use-mpa-style         With --report, format report output like Kraken 1's
>                           kraken-mpa-report
>   --report-zero-counts    With --report, report counts for ALL taxa, even if
>                           counts are zero
>   --report-minimizer-data With --report, report minimizer and distinct minimizer
>                           count information in addition to normal Kraken report
>   --memory-mapping        Avoids loading database into RAM
>   --paired                The filenames provided have paired-end reads
>   --use-names             Print scientific names instead of just taxids
>   --gzip-compressed       Input files are compressed with gzip
>   --bzip2-compressed      Input files are compressed with bzip2
>   --minimum-hit-groups NUM
>                           Minimum number of hit groups (overlapping k-mers
>                           sharing the same minimizer) needed to make a call
>                           (default: 2)
>   --help                  Print this message
>   --version               Print version information
>
> If none of the *-compressed flags are specified, and the filename provided
> is a regular file, automatic format detection is attempted.
> ~~~  
> {: .output}

In addition to our input files we also need a database with which to compare them. There are [several databases](http://ccb.jhu.edu/software/kraken2/downloads.shtml)
compatible to be used with kraken2 in the taxonomical assignment process. Some of these are larger and much more comprehensive, and some are more specific. There are also instructions on how to [generate a database of your own](https://github.com/DerrickWood/kraken2/wiki/Manual#special-databases).

> ## Very important to know your database!
> The database you use will determine the result you get for your data.
> Imagine you are searching for a lineage that was recently discovered and it is not part of the available databases. Would you find it?
{: .callout}

Minikraken is a popular database that attempts to conserve its sensitivity
despite its small size (Needs 8GB of RAM for the assignment). If you are using a HPC you may not have the same memory constraints and may want to use a much fuller database. We will have this database already available on the instance, however if you were to download the database, you would use the following command:
~~~
$ curl -O ftp://ftp.ccb.jhu.edu/pub/data/kraken2_dbs/old/minikraken2_v2_8GB_201904.tgz         
$ tar -xvzf minikraken2_v2_8GB_201904.tgz
~~~
{: .do not run this}


## Taxonomic assignment of MAGs

As we have learned, taxonomic assignment can be attempted before the assembly process.
In this case we would use FASTQ files as inputs, which would be
`pilon_R1.trim.fastq.gz` and `pilon_R2.trim.fastq.gz`. And the outputs would be two files: the report
`pilon.report` and the kraken file `pilon.kraken`.  

To run kraken2 run this command:  

~~~
 mkdir taxonomy
 kraken2 --db kraken-db --threads 12 -input pilon.fasta --output taxonomy/pilon.kraken --report TAXONOMY/pilon.report
~~~
{: .bash}

These commands generate two outputs, a .kraken and a .report file. Let's look at the these files with the following commands:
~~~
head ~/cs_workshop/taxonomy/pilon.kraken  
~~~
{: .bash}

~~~
- update to be for contig output for kraken
~~~
{: .output}

As we can see, the kraken file is not very readable. So let's look at the report file:

> ## Reading a Kraken report
>
> 1. Percentage of MAGs covered by the clade rooted at this taxon
> 2. Number of MAGs covered by the clade rooted at this taxon
> 3. Number of MAGs assigned directly to this taxon
> 4. A rank code, indicating (U)nclassified, (D)omain, (K)ingdom, (P)hylum, (C)lass, (O)rder, (F)amily, (G)enus, or (S)pecies. All other ranks are simply '-'.
> 5. NCBI taxonomy ID
> 6. Indented scientific name
{: .callout}

~~~
head ~/cs_workshop/taxonomy/pilon.report
~~~
{: .bash}
~~~
more ~/cs_workshop/taxonomy/mags_taxonomy/pilon.001.report
~~~
{: .bash}
~~~
 50.96	955	955	U	0	unclassified
 49.04	919	1	R	1	root
 48.83	915	0	R1	131567	  cellular organisms
 48.83	915	16	D	2	    Bacteria
 44.40	832	52	P	1224	      Proteobacteria
 19.37	363	16	C	28216	        Betaproteobacteria
 16.22	304	17	O	80840	          Burkholderiales
  5.66	106	12	F	506	            Alcaligenaceae
  2.72	51	3	G	517	              Bordetella
  1.12	21	21	S	2163011	                Bordetella sp. HZ20
  .
  .
  .
~~~
{: .output}   


By looking at the report, we can see that half of the contigs
are unclassified, and that a very little proportion of contigs
have been assigned a taxon. This is weird because we expected
to have only one genome in the bin.

Just to exemplify how a report of a complete and not contaminated
MAG should look like, let's look at the report of this MAG from
another study:
~~~
100.00	108	0	R	1	root
100.00	108	0	R1	131567	  cellular organisms
100.00	108	0	D	2	    Bacteria
100.00	108	0	P	1224	      Proteobacteria
100.00	108	0	C	28211	        Alphaproteobacteria
100.00	108	0	O	356	          Rhizobiales
100.00	108	0	F	41294	            Bradyrhizobiaceae
100.00	108	0	G	374	              Bradyrhizobium
100.00	108	108	S	2057741	                Bradyrhizobium sp. SK17
~~~
{: .output}

> ## Exercise 1:
>
> Why do you think we found so many taxons in this bin?
{: .challenge}

## Visualization of taxonomic assignment results  

After we have the taxonomy assignation what follows is some
visualization of our results.
[Krona](https://github.com/marbl/Krona/wiki) is a hierarchical
data visualization software. Krona allows data to be explored with zooming,
multi-layered pie charts and includes support for several bioinformatics
tools and raw data formats. To use Krona in our results, let's go first into
our taxonomy directory, which contains the pre-calculated Kraken outputs.  

### Krona  
With Krona we will explore the taxonomy of the JP4D.001 MAG.
~~~
$ cd ~/cs_workshop/taxonomy/mags_taxonomy
~~~
{: .bash}  

Krona is called with the `ktImportTaxonomy` command that needs an input and an output file.  
In our case we will create the input file with the columns three and four from `pilon.001.kraken` file.     
~~~
$ cut -f2,3 pilon.001.kraken > pilon.001.krona.input
~~~
{: .language-bash}  

Now we call Krona in our `pilon.001.krona.input` file and save results in `pilon.001.krona.out.html`.  
~~~
$ ktImportTaxonomy pilon.001.krona.input -o pilon.001.krona.out.html
~~~
{: .language-bash}  

~~~
Loading taxonomy...
Importing pilon.001.krona.input...
   [ WARNING ]  The following taxonomy IDs were not found in the local database and were set to root
                (if they were recently added to NCBI, use updateTaxonomy.sh to update the local
                database): 1804984 2109625 2259134
~~~
{: .output}  

And finally, open another terminal in your local computer,download the
Krona output and open it on a browser.
~~~
$ scp csuser@ec2-3-235-238-92.compute-1.amazonaws.com:~/cs_workshop/taxonomy/pilon.001.krona.out.html .
~~~
{: .bash}  
You will see a page like this:

<a href="{{ page.root }}/fig/03-06-03.png">
  <img src="{{ page.root }}/fig/03-06-03.png" alt="Krona displays a circled-shape bacterial taxonomy plot with abundance percentages of each taxa " />
</a>

> ## Exercise 2: Exploring Krona visualization
> Try double clicking on the segment of the pie chart that represents Bacteria and see what happens.
> What percentage of bacteria is represented by the genus Paracoccus?
>
> Hint: There is a search box in the top left corner of the window.
>
>> ## Solution
>> 2% of Bacteria corresponds to the genus Paracoccus in this sample.
>> In the top right of the window we see little pie charts that change whenever we change the visualization
>> to expand certain taxa.   
>>
> {: .solution}
{: .challenge}

### Pavian
Pavian is another visualization tool that allows comparison
between multiple samples. Pavian should be locally installed
and needs R and Shiny, but we can try the
[Pavian demo WebSite](https://fbreitwieser.shinyapps.io/pavian/)
to visualize our results.  

First we need to download the files needed as inputs in Pavian, t
his time we will visualize the assignation of the reads of both samples:
`JC1A.report` and `pilon.report`.  
This files corresponds to our Kraken reports. Again in our local
machine lets use `scp` command.  
~~~
$ scp csuser@ec2-3-235-238-92.compute-1.amazonaws.com:~/cs_workshop/taxonomy/*report .
~~~
{: .language-bash}

We go to the [Pavian demo WebSite](https://fbreitwieser.shinyapps.io/pavian/),
click on Browse and choose our reports. You need to select both reports at the same time.

<a href="{{ page.root }}/fig/03-06-04.png">
  <img src="{{ page.root }}/fig/03-06-04.png" alt="Pavian website showing the opload of two reports" />
</a>

We click on the Results Overview tab.

<a href="{{ page.root }}/fig/03-06-05.png">
  <img src="{{ page.root }}/fig/03-06-05.png" alt="Results Overview tab of the Pavian website where it shows the number of reads classified to several categories for the two samples" />
</a>

We click on the Sample tab.

<a href="{{ page.root }}/fig/03-06-06.png">
  <img src="{{ page.root }}/fig/03-06-06.png" alt="Sankey type visualization that shows the abundance of each taxonomic label in a tree-like manner" />
</a>

We can look at the abundance of a specific taxon by clicking on it.

<a href="{{ page.root }}/fig/03-06-07.png">
  <img src="{{ page.root }}/fig/03-06-07.png" alt="A bar chart of the abundance of reads of the two samples, showing a segment for the read identified at the specific taxon and another segment for the number of reads identifies at children of the specified taxon" />
</a>

We can look at a comparison of both our samples in the Comparison tab.

<a href="{{ page.root }}/fig/03-06-08.png">
  <img src="{{ page.root }}/fig/03-06-08.png" alt="A table of the same format as the Kraken report but for both samples at once." />
</a>


> ## Exercise 3: Taxonomic level of assignment
>
> What do you think is harder to assign, a species (like _E. coli_) or a phylum (like Proteobacteria)?
>
{: .challenge}


{% include links.md %}
