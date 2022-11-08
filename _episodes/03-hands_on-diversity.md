---
title: "Taxonomic Analysis with R"
teaching: 40
exercises: 20
questions:
- "How can we compare depth-contrasting samples?"
- "How can we manipulate our data to deliver a messagge?"
objectives:
- "Learn and create figures using `ggplot2`"
- "Learn how to manipulate data-types inside your phyloseq object"
- "Understand how to extract specific information from taxonomic-assignation data"
keypoints:
- "The library `phyloseq` lets you manipulate metagenomic data in a taxonomic specific perspective."  
- "The library `ggplot2` is helpful for visualising your taxonomy data"
---


## Visualizing our data 
In the last lesson, we created our phyloseq object, which contains the information
of our samples: `ERR2935805` and `JP4D`. Let´s take a look again at the
 number of reads in our data.  

For the whole metagenome:

~~~
biom_metagenome
sample_sums(biom_metagenome)
~~~
{: .language-r}

~~~
phyloseq-class experiment-level object  
otu_table()   OTU Table:         [ 5905 taxa and 2 samples ]  
tax_table()   Taxonomy Table:    [ 5905 taxa by 7 taxonomic ranks ]  

ERR2935805       JP4D   
  38058101     149590   
~~~
{: .output}


> ## Exercise 1
>
> Repeat this for the bacterial metagenome.
>> ## Solution
>> `Use bac_biom_metagenome` instead of `biom_metagenome`
>> ~~~
>> bac_biom_metagenome
>> sample_sums(bac_biom_metagenome)
>> ~~~
>> {: .language-r}
>>
>> ~~~
>> phyloseq-class experiment-level object
>> otu_table()   OTU Table:         [ 5808 taxa and 2 samples ]
>> tax_table()   Taxonomy Table:    [ 5808 taxa by 7 taxonomic ranks ]
>> 
>>   ERR2935805       JP4D
>>     38057090     149590
>> ~~~
>> {: .output}
>>
> {: .solution}
{: .challenge}


We can use the `plot_bar()` function to visualise the breakdown by phylum in these two samples.

~~~
bac_biom_metagenome
sample_sums(bac_biom_metagenome)
~~~
{: .language-r}



## Transformation and manipulation of data

By inspection on the above figure, it is evident that there is a great difference in the number of total
reads(i.e. information) of each sample. Before we further process our data, take a look if we have any
non-identified read. Marked as blank (i.e "") on the different taxonomic levels:

~~~
> summary(bac_biom_metagenome@tax_table@.Data == "")
~~~
{: .language-r}
~~~
Kingdom          Phylum          Class           Order           Family          Genus          Species       
Mode :logical   Mode :logical   Mode :logical   Mode :logical   Mode :logical   Mode :logical   Mode :logical  
FALSE:5808      FALSE:5808      FALSE:5645      FALSE:5796      FALSE:5754      FALSE:5647      FALSE:5251     
                               TRUE :163       TRUE :12        TRUE :54        TRUE :161       TRUE :557      
~~~
{: .output}
With the command above, we can see that there are blanks on different taxonomic leves. Although it is
expected to see some blanks at the species, or even at the genus level, we will get rid of the ones at
the genus level to proceed with the analysis:

~~~
> bac_biom_metagenome <- subset_taxa(bac_biom_metagenome, Genus != "")
> summary(bac_biom_metagenome@tax_table@.Data== "")
~~~
{: .language-r}
~~~
Kingdom          Phylum          Class           Order           Family          Genus          Species       
Mode :logical   Mode :logical   Mode :logical   Mode :logical   Mode :logical   Mode :logical   Mode :logical  
FALSE:5808      FALSE:5808      FALSE:5645      FALSE:5796      FALSE:5754      FALSE:5647      FALSE:5251     
                               TRUE :163       TRUE :12        TRUE :54        TRUE :161       TRUE :557     
~~~
{: .output}


Next, since our metagenomes have different sizes, it is imperative to convert the number
of assigned read into percentages (i.e. relative abundances) so as to compare them.
~~~
> head(bac_biom_metagenome@otu_table@.Data)
~~~
{: .language-r}
~~~
  ERR2935805 JP4D
1385        39112   31
186820       1014    0
1637      4877507    7
1639     28925791    8
1642        48735    1
529731      21018    0
~~~
{: .output}
~~~
> percentages  = transform_sample_counts(bac_biom_metagenome, function(x) x*100 / sum(x) )
> head(percentages@otu_table@.Data)
~~~
{: .language-r}
~~~
  ERR2935805         JP4D
1385    0.102771915 0.0207233104
186820  0.002664418 0.0000000000
1637   12.816289948 0.0046794572
1639   76.006313147 0.0053479511
1642    0.128057610 0.0006684939
529731  0.055227554 0.0000000000
~~~
{: .output}

## Beta diversity

As we mentioned before, the beta diversity is a measure of how alike or different are our samples(overlap between
discretely defined sets of species or operational taxonomic units).
In order to measure this, we need to calculate an index that suits the objetives of our research. By this code,
we can display all the possible distance metrics that phyloseq can use:
~~~
> distanceMethodList
~~~
{: .language-r}
~~~
$UniFrac
[1] "unifrac"  "wunifrac"

$DPCoA
[1] "dpcoa"

$JSD
[1] "jsd"

$vegdist
 [1] "manhattan"  "euclidean"  "canberra"   "bray"       "kulczynski" "jaccard"    "gower"      "altGower"   "morisita"   "horn"      
[11] "mountford"  "raup"       "binomial"   "chao"       "cao"       

$betadiver
 [1] "w"   "-1"  "c"   "wb"  "r"   "I"   "e"   "t"   "me"  "j"   "sor" "m"   "-2"  "co"  "cc"  "g"   "-3"  "l"   "19"  "hk"  "rlb" "sim"
[23] "gl"  "z"  

$dist
[1] "maximum"   "binary"    "minkowski"

$designdist
[1] "ANY"
~~~
{: .output}
Describing all this possible distance-metrics is beyond the scope
of this lesson, but here we show which are the ones that need a
phylogenetic relationship between the species-OTUs present in our samples:

* Unifrac
* Weight-Unifrac
* DPCoA  

We do not have a phylogenetic tree or the phylogenetic relationships.
So we can not use any of those three. We will use [Bray-curtis](http://www.pelagicos.net/MARS6300/readings/Bray_&_Curtis_1957.pdf),
since is one of the most robust and widely use distance metric to
calculate beta diversity.


## Ploting our data

### Difference of our samples at specific taxonomic levels

In order to group all the OTUs that have the same taxonomy at a certain taxonomic rank,
we will use the function `tax_glom()`.

~~~
> glom <- tax_glom(percentages, taxrank = 'Phylum')
> View(glom@tax_table)
~~~
{: .language-r}  

<a href="{{ page.root }}/fig/03_03_glom_tax.png">
  <img src="{{ page.root }}/fig/03_03_glom_tax.png" alt="Table containing the
  taxonomic information of each of the OTUs inside the three samples. Here,
  we can see how only the Phylum column has information, leaving the other
  taxonomic levels in blank." />
</a>
<em> Figure 5. Taxonomic-data table after agrupation at phylum level. <em/>

Another phyloseq function is `psmelt()`, which melts phyloseq objects into a `data.frame`
to manipulate them with packages like `ggplot2` and `vegan`.
~~~
> percentages <- psmelt(glom)
> str(percentages)
~~~
{: .language-r}
~~~
'data.frame':	72 obs. of  5 variables:
 $ OTU      : chr  "1639" "286" "286" "1883" ...
 $ Sample   : chr  "ERR2935805" "JP4D" "ERR2935805" "JP4D" ...
 $ Abundance: num  90.07 85.72 9.9 6.33 3.98 ...
 $ Kingdom  : chr  "Bacteria" "Bacteria" "Bacteria" "Bacteria" ...
 $ Phylum   : chr  "Firmicutes" "Proteobacteria" "Proteobacteria" "Actinobacteria" ...
~~~
{: .output}

Now, let's create another data-frame with the original data. This will help us to compare
both datasets.
~~~
> raw <- tax_glom(physeq = bac_biom_metagenome, taxrank = "Phylum")
> raw.data <- psmelt(raw)
> str(raw.data)
~~~
{: .language-r}
~~~
'data.frame':	70 obs. of  5 variables:
 $ OTU      : chr  "1639" "286" "286" "78331" ...
 $ Sample   : chr  "ERR2935805" "ERR2935805" "JP4D" "JP4D" ...
 $ Abundance: num  34238425 3717008 116538 9227 8037 ...
 $ Kingdom  : chr  "Bacteria" "Bacteria" "Bacteria" "Bacteria" ...
 $ Phylum   : chr  "Firmicutes" "Proteobacteria" "Proteobacteria" "Actinobacteria" ...
~~~
{: .output}

With these objects and what we have learned regarding `ggplot2`, we can proceed to compare them
with a plot. First, let´s create the figure for the absolute abundances data (*i.e* `abs.plot` object)
~~~
> abs.plot <- ggplot(data=raw.data, aes(x=Sample, y=Abundance, fill=Phylum))+
    geom_bar(aes(), stat="identity", position="stack")
> abs.plot
~~~
{: .language-r}
<a href="{{ page.root }}/fig/03_03_abs_plot.png">
  <img src="{{ page.root }}/fig/03_03_abs_plot.png" alt="A two-part plot contrasting
  the absolute abundance between the two samples." />
</a>
<em> Figure 6. Taxonomic diversity of absolute and relative abundance. <em/>

With the `position="stack"` command, we are telling the `ggplot` function that the values must stack each other for each of the samples. In this way, we will
have all of our different categories (OTUs) stacked in one bar and not each in a separate one.
For more info [position_stack](https://ggplot2.tidyverse.org/reference/position_stack.html)

Next, we will create the figure for the representation of the relative abundance data, and ask
RStudio to show us both plots side by side:
~~~
> rel.plot <- ggplot(data=percentages, aes(x=Sample, y=Abundance, fill=Phylum))+
  geom_bar(aes(), stat="identity", position="stack")
> rel.plot
~~~
{: .language-r}

<a href="{{ page.root }}fig/03_03_abs_plot.png">
  <img src="{{ page.root }}fig/03_03_abs_plot.png" alt="A two-part plot contrasting the relative abundance of the two samples." />
</a>
<em> Figure 6. Taxonomic diversity of absolute and relative abundance. <em/>

At once, we can denote the difference between the two plots and how processing the data can
enhance the display of important results. However, it is noticeable that we have too much taxa
to adequatly distinguish the color of each one of them, less of the ones that hold the greatest
abundance. In order to change that, we will use the power of data-frames and R. We will change
the identification of the OTUs whose relative abundance is less than 0.2%:
~~~
> percentages$Phylum <- as.character(percentages$Phylum)
> percentages$Phylum[percentages$Abundance < 0.5] <- "Phyla < 0.5% abund."
> unique(percentages$Phylum)
~~~
{: .language-r}
~~~
[1] "Firmicutes"          "Proteobacteria"      "Actinobacteria"     
[4] "Bacteroidetes"       "Cyanobacteria"       "Phyla < 0.5% abund."
~~~
{: .output}

Let's ask R to display the figures again by re-running our code:
~~~
> rel.plot <- ggplot(data=percentages, aes(x=Sample, y=Abundance, fill=Phylum))+
    geom_bar(aes(), stat="identity", position="stack")
> rel.plot
~~~
{: .language-r}

<a href="{{ page.root }}/fig/03_03_top5.png">
  <img src="{{ page.root }}/fig/03_03_top5.png" alt="A new two-part plot with
  a reassignment of the low-abundant taxa on the right side. Compared to the
  left legend, the one in the right has fewer groups because the process of
  reassigning the taxa with an abundance lower than 0.5 % to just one
  group/color." />
</a>
<em> Figure 7. Taxonomic diversity of absolute and relative abundance with corrections. <em/>

>## Exercise 2  : Taxa agglomeration
>
> Go into groups and agglomerate the taxa in the raw data, so as to have
> a better visualization of the data. Remeber checking the data-classes inside
> your data-frame. According to the [ColorBrewer](https://github.com/axismaps/colorbrewer/) package
> it is recommended not to have more than 9 different colors in a plot.
>
> What is the best way to run the next script? Compare your graphs with your partners
>
> Hic Sunt Leones! (Here be Lions!):
>
> A) `raw.plot <- ggplot(data=raw.data, aes(x=Sample, y=Abundance, fill=Phylum))+`
>    `geom_bar(aes(), stat="identity", position="stack")`
>  
> B) `unique(raw.data$Phylum)`
>
> C) `raw.data$Phylum[raw.data$Abundance < 300] <- "Minoritary Phyla"`
>> ## Solution
>> By reducing agglomerating the samples that have less than 300 reads, we can get a more decent plot.
>> Certainly, this will be difficult since each of our samples has contrasting number of reads.
>>
>> C) `raw.data$Phylum[raw.data$Abundance < 300] <- "Minoritary Phyla"`
>>
>> B) `unique(raw.data$Phylum)`
>>
>> A) `raw.plot <- ggplot(data=raw.data, aes(x=Sample, y=Abundance, fill=Phylum))+`
>>  `geom_bar(aes(), stat="identity", position="stack")`
>>  
>>  Show your plots:
>>  
>>  `raw.plot | rel.plot`
>>
>> <a href="{{ page.root }}/fig/03-08-01e.png">
>>   <img src="{{ page.root }}/fig/03-08-01e.png" alt="New reassignation to the low abundant taxa on the left part of the plot. A new class has been created that contains the taxa with less than 300 reads" />
>> </a>
> {: .solution}
{: .challenge}

## Going further, let's take an interesting lineage and explore it thoroughly

As we have already reviewed, phyloseq offers a lot of tools to manage and explore data. Let's take a
look deeply to a function that we already use, but now with a guided exploration. The `subset_taxa`
command is used to extract specific lineages from a stated taxonomic level, we have used it to get
rid from the reads that does not belong to bacteria:
~~~
>> merged_metagenomes <- subset_taxa(merged_metagenomes, Kingdom == "Bacteria")
~~~
{: .language-r}

We are going to use it now to extract an specific phylum from our data, and explore it at a lower
taxonomic level: Genus. We will take as an example the phylum cyanobacteria (certainly, this is a biased
and arbitrary decision, but who does not feel attracted these incredible microorganisms?):
~~~
> cyanos <- subset_taxa(bac_biom_metagenome, Phylum == "Cyanobacteria")
> unique(cyanos@tax_table@.Data[,2])
~~~
{: .language-r}
~~~
[1] "Cyanobacteria"
~~~
{: .output}

Let's do a little review of all that we saw today: **Transformation of the data; Manipulation of the
information; and plotting**:
~~~
> cyanos  = transform_sample_counts(cyanos, function(x) x*100 / sum(x) )
> glom <- tax_glom(cyanos, taxrank = "Genus")
> g.cyanos <- psmelt(glom)
> g.cyanos$Genus[g.cyanos$Abundance < 10] <- "Genera < 10.0 abund"
> p.cyanos <- ggplot(data=g.cyanos, aes(x=Sample, y=Abundance, fill=Genus))+
    geom_bar(aes(), stat="identity", position="stack")
> p.cyanos
~~~
{: .language-r}

<a href="{{ page.root }}/fig/03_03_cyano.png">
  <img src="{{ page.root }}/fig/03_03_cyano.png" alt="A new plot with two bars
  representing the relative abundance of Cyanobacteria in each of the samples.
  Each of the colors represent a Genus. Because we are seeing relative
  abundances, all the bars are of the same hight." />
</a>
<em> Figure 8. Diversity of Cyanobacteria at genus level inside our samples.<em/>

> ## Exercise 3
>
> Choose one phylum that is interesting and use the code learned to generate a plot where you can
> show us the abundance at genus level in each of the samples.
>> ## Solution
>> Change "Cyanobacteria" wherever it is needed to get a result for
>> other phylum, as an example, here is the solution for Proteobacteria:
>>
>>`proteo <- subset_taxa(bac_biom_metagenome, Phylum == "Proteobacteria")`
>>
>>`proteo  = transform_sample_counts(proteo, function(x) x*100 / sum(x) )`
>>
>>`glom <- tax_glom(proteo, taxrank = "Genus")`
>>
>>`g.proteo <- psmelt(glom)`
>>
>>`g.proteo$Genus[g.proteo$Abundance < 3] <- "Genera < 3.0 abund"`
>>
>>`unique(g.proteo$Genus)`
>>
>>`proteo <- ggplot(data=g.proteo, aes(x=Sample, y=Abundance, fill=Genus))+`
>>  `geom_bar(aes(), stat="identity", position="stack")`
>>
>>`proteo`
>><a href="{{ page.root }}/fig/03_03_proteo.png">
>>  <img src="{{ page.root }}/fig/03_03_proteo.png" alt="A new plot with three bars
  representing the absolute abundance of Proteobacteria in each of the samples.
  Each of the colors represent a Genus. Because we are seeing relative
  abundances, all the bars are of the same hight." />
>></a>
> {: .solution}
{: .challenge}
