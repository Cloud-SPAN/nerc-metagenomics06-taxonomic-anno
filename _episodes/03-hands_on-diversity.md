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
- "The R package `phyloseq` lets you manipulate metagenomic data in a taxonomic specific perspective."  
- 
---


## Reminder 
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

We saw how to find out how many phlya we have and how many OTU there are in each phlya by combining commands
We 
- turned the tax_table into a data frame (a useful data structure in R)
- grouped by the Phylum column
- summarised by counting the number of rows for each phylum
- viewed the result
This can be achieved with the following command:

~~~
bac_biom_metagenome@tax_table %>% 
  data.frame() %>% 
  group_by(Phylum) %>% 
  summarise(n = length(Phylum)) %>% 
  View()
~~~
{: .language-r}

`phyloseq` has a useful function that turns a phyloseq object into a dataframe.
Since the dataframe is a standard data format in R, this makes it easier for R 
users to apply methods they are familiar with.

Use `psmelt()` to make a dataframe for the bacterial metagenomes:
~~~
bac_meta_df <- psmelt(bac_biom_metagenome)
~~~
{: .language-r}

Clicking on `bac_meta_df` on the Environment window will open a spreadsheet-like view of it. 

Now we can more easily summarise our metagenomes by sample using standard syntax.
The following filters out all the rows with zero abundance then counts the 
number of taxa in each phylum for each sample:

~~~
number_of_taxa <- bac_meta_df %>% 
  filter(Abundance > 0) %>% 
  group_by(Sample, Phylum) %>% 
  summarise(n = length(Abundance))
~~~
{: .language-r}  

Clicking on `number_of_taxa` on the Environment window will open a spreadsheet-like view of it
This shows us that we have some phyla:
  - present in both samples such as Acidobacteria and Actinobacteria
  - present in just ERR2935805 such as Candidatus Bipolaricaulota
  - and present in just JP4D such as Calditrichaeota

We can use a similar approach to examine the abundance of each of these taxa:

~~~
abundance_of_taxa <- bac_meta_df %>% 
  filter(Abundance > 0) %>% 
  group_by(Sample, Phylum) %>% 
  summarise(abund = sum(Abundance))
~~~
{: .language-r}  

We can see the vast majority of our taxa are Proteobacteria and Firmicutes in ERR2935805



## Visualizing our data 

It would be nice to see the abundance by tax as a figure. We can use the `ggplot()` function to visualise the breakdown by Phylum in each of our two bacterial metagenomes:

~~~
abundance_of_taxa %>% 
  ggplot(aes(x = Sample, y = Abundance, fill = Phylum)) +
  geom_col(position = "stack")
~~~
{: .language-r}

<a href="{{ page.root }}/fig/03_03_abs_phyl_plot.png">
  <img src="{{ page.root }}/fig/03_03_abs_phyl_plot.png" alt="Plot of the absolute abundance of each Phylum in the two samples." />
</a>

We can see that the most abundant phyla in ERR2935805 are Proteobacteria and Firmicutes. However, we can't tell much from JP4D because the total number of reds is so much less.

## Transformation of data

Since our metagenomes have different sizes, it is imperative to convert the number
of assigned read into percentages (i.e. relative abundances) so as to compare them.

We can acheive this with:
~~~
abundance_of_taxa <- abundance_of_taxa %>% 
  group_by(Sample) %>% 
  mutate(relative = Abundance/sum(Abundance) * 100)
~~~
{: .language-r}

Then plot the result:

~~~
abundance_of_taxa %>% 
  ggplot(aes(x = Sample, y = relative, fill = Phylum)) +
  geom_col(position = "stack")
~~~
{: .language-r}

<a href="{{ page.root }}/fig/03_03_rel_phyl_plot.png">
  <img src="{{ page.root }}/fig/03_03_rel_phyl_plot.png" alt="Plot of the relative abundance of each Phylum in the two samples." />
</a>

