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
<img align="centre" width="682" height="377" <img src="{{ page.root }}/fig/03-01_LCA.png" alt="Diagram of taxonomic tree" />
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
We will be using the command line program Kraken2 to do our taxonomic assignment. [Kraken 2](https://ccb.jhu.edu/software/kraken2/) is the newest version of Kraken, a taxonomic classification system using exact k-mer matches to achieve high accuracy and fast classification speeds. Taxonomic assignment can be attempted on raw reads (aka before the assembly process) however we will be using our polished assembly (`pilon.fasta`) here.


`kraken2` is already installed on our instance so we can look at the `kraken2` help.
~~~  
 kraken2  
~~~
{: .bash}


> ## Kraken2 help documentation
> ~~~
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

We will be using the flags `-input` to specify our input assembly, `--output` and `--report` to specify the location of the output files Kraken will generate. And also `--threads` to speed up Kraken on our instance.

In addition to our input files we also need a database (`-db`) with which to compare them. There are [several different databases](http://ccb.jhu.edu/software/kraken2/downloads.shtml)
available for `kraken2`. Some of these are larger and much more comprehensive, and some are more specific. There are also instructions on how to [generate a database of your own](https://github.com/DerrickWood/kraken2/wiki/Manual#special-databases).

> ## Very important to know your database!
> The database you use will determine the result you get for your data.
> Imagine you are searching for a lineage that was recently discovered and it is not part of the available databases. Would you find it?
> Make sure you keep a note of what database you have used and when you downloaded it or when it was last updated.
{: .callout}

You can view and download many of the common Kraken2 databases [on this site](https://benlangmead.github.io/aws-indexes/k2). We will be using `Standard-8` which is already pre installed on the instance.

## Taxonomic assignment of an assembly

First, we need to make a directory for the kraken output and then we can run our kraken command.

~~~
 cd ~/cs_course/analysis/
 mkdir taxonomy

 kraken2 --db ../databases/kraken_20220926/ --output taxonomy/pilon.kraken --report taxonomy/pilon.report --threads 8 pilon/pilon.fasta
~~~
{: .bash}

This should take around an minute to run so we will run it in the foreground.

You should see an output similar to below:
~~~
Loading database information... done.
148 sequences (14.97 Mbp) processed in 0.814s (10.9 Kseq/m, 1103.42 Mbp/m).
  88 sequences classified (59.46%)
  60 sequences unclassified (40.54%)
~~~
{: .output}

This command generates two outputs, a .kraken and a .report file. Let's look at the top of these files with the following commands:
~~~
head taxonomy/pilon.kraken  
~~~
{: .bash}

~~~
U	contig_47_pilon	0	12293	0:12259
U	contig_75_pilon	0	6016	0:5982
C	contig_162_pilon	1386	10762	0:9 1386:8 0:6 1386:1 0:5 1386:1 0:4 1386:5 0:91 1386:1 0:38 1386:5 0:2 1386:7 0:15 1386:5 0:26 1386:3 0:5 1386:5 0:9 1386:2 0:46 1386:2 0:33 1386:5 0:21 1386:1 0:12 1386:2 0:77 1386:4 0:5 1386:1 0:7 1386:7 0:5 1386:5 0:16 1386:8 0:24 1386:1 0:43 1386:1 0:91 1386:2 0:17 1386:5 0:58 1386:7 0:96 1386:6 0:6 1386:3 0:14 1386:5 0:3 1386:2 0:17 1386:5 0:29 1386:1 0:1 1386:3 0:28 1386:2 0:13 1386:5 0:28 1386:1 0:5 1386:1 0:1 1386:4 0:4 1386:5 0:64 1386:5 0:9 1386:1 0:3 1386:5 0:24 1386:3 0:6 1386:5 0:13 1386:5 0:31 1386:5 0:11
...
~~~
{: .output}

As we can see, the kraken file is not very readable. So let's look at the report file instead:

~~~
 40.54  60      60      U       0       unclassified
 59.46  88      1       R       1       root
 56.76  84      1       R1      131567    cellular organisms
 45.27  67      1       D       2           Bacteria
 36.49  54      0       D1      1783272       Terrabacteria group
 35.14  52      0       P       1239            Firmicutes
 35.14  52      0       C       91061             Bacilli
 34.46  51      0       O       1385                Bacillales
 32.43  48      0       F       186817                Bacillaceae
 31.76  47      4       G       1386                    Bacillus
...
~~~
{: .bash}

> ## Reading a Kraken report
>
> 1. Percentage of MAGs covered by the clade rooted at this taxon
> 2. Number of MAGs covered by the clade rooted at this taxon
> 3. Number of MAGs assigned directly to this taxon
> 4. A rank code, indicating (U)nclassified, (D)omain, (K)ingdom, (P)hylum, (C)lass, (O)rder, (F)amily, (G)enus, or (S)pecies. All other ranks are simply '-'.
> 5. NCBI taxonomy ID
> 6. Indented scientific name
{: .callout}

By looking at the report, we can see that around 40% of the contigs
are unclassified.


> ## Exercise 1:
> Looking back at the [information]{https://cloud-span.github.io/metagenomics01-qc-assembly/00-introduction-meta/index.html} we have about our dataset are we seeing the species that we expect? Are there any that we don't expect, and if so why do you think we might be seeing them? Remember we have run this taxonomic assignment on a Nanopore assembly using the Standard 8GB database.
> > ## Solution
> > We are seeing _Listeria monocytogenes_, _Pseudomonas aeruginosa_, _Bacillus subtilis_, _Escherichia coli_ and _Salmonella enterica_ in the Kraken output.
> > We do not see _Saccharomyces cerevisiae_ in the output and this is likely because of database choice the Standard 8GB does not contain Fungi. This is also likely why we are seeing such a high percentage of Homo sapiens in our results - this is likely the closest approximation to this organism that Kraken can find in the database used. This is why database choice is important! You should aim to use the most comprehensive database for the compute power available to you.  
> > The order Lactobacillales is present but kraken does not manage to identify any lower than that. This is likely because _Lactobacillus fermentum_ only makes up a small fraction of the raw sequences so was not abundant enough to be successfully assembled. The low overall abundance of _Enterococcus faecalis_, _Cryptococcus neoformans_ and _Staphylococcus aureus_ is likely why we don't see them in this output either.
> > Finally, you may have noticed the proportion of each species does not match the proportions in the sequencing data. This is because this we are now looking at the proportion of the _contigs_ each species makes up. It is likely that the more abundant species have been assembled relatively completely (i.e. in a few of long contigs) so they will make up only a small proportion of the overall assembly (as length isn't taken into account here). If you wanted to look at the abundance of each species in the sequencing it would be more appropriate to run Kraken on the raw short reads. 
> {: .solution}
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
