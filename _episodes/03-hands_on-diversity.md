---
title: "Taxonomic Analysis with R"
teaching: 40
exercises: 20
questions:
- "How can we use standard R methods to summarise metagenomes?"
- "How can we plot the shared and unique compositions of samples?"
- "How can we compare samples with very different numbers of reads?"
objectives:
- "Make dataframes out of `phyloseq` objects"
- "Summarise metagenomes with standard R methods"
- "Make Venn diagrams for samples"
- "Plot absolute and relative abundances of samples"
keypoints:
- "The R package `phyloseq` has a function `psmelt()` to make dataframes from `phyloseq` objects."  
- "A venn diagram can be used to show the shared and unique compositions of samples." 
- "Plotting relative abundance allows you to compare samples with differing numbers of reads"
---


## Reminder 
In the last lesson, we created our phyloseq object, which contains the information
of our samples: `ERR4998593` and `JP4D`. Let´s take a look again at the
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

ERR4998593       JP4D   
  38058101     149590   
~~~
{: .output}


> ## Exercise 1
>
> Repeat this for the bacterial metagenome.
>> ## Solution
>> Use `bac_biom_metagenome` instead of `biom_metagenome`
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
>>   ERR4998593       JP4D
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

## Summarise metagenomes
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
  - present in just ERR4998593 such as Candidatus Bipolaricaulota
  - and present in just JP4D such as Calditrichaeota

One way to visualise the number of shared phyla is with a Venn diagram. The package `ggvenn` will draw one for us. It needs a data structure called a list which will contain an item for each sample of the phyla in that sample. We can see the phyla in the ERR4998593 sample with:

~~~
unique(number_of_taxa$Phylum[number_of_taxa$Sample == "ERR4998593"])
~~~
{: .language-r}  

~~~
"Acidobacteria"               "Actinobacteria"              "Aquificae"                  
"Armatimonadetes"             "Bacteroidetes"               "Caldiserica"                
"Candidatus Bipolaricaulota"  "Candidatus Cloacimonetes"    "Candidatus Saccharibacteria"
"Chlamydiae"                  "Chlorobi"                    "Chloroflexi"                
"Chrysiogenetes"              "Cyanobacteria"               "Deferribacteres"            
"Deinococcus-Thermus"         "Elusimicrobia"               "Firmicutes"                 
"Fusobacteria"                "Gemmatimonadetes"            "Kiritimatiellaeota"         
"Nitrospirae"                 "Planctomycetes"              "Proteobacteria"             
"Spirochaetes"                "Synergistetes"               "Tenericutes"                
"Thermodesulfobacteria"       "Thermotogae"                 "Verrucomicrobia"
~~~
{: .output}

> ## Exercise 2
>
> Repeat this for the JP4D sample
>> ## Solution
>> Use JP4D instead of ERR4998593
>> ~~~
>> unique(number_of_taxa$Phylum[number_of_taxa$Sample == "JP4D"])
>> ~~~
>> {: .language-r}
>>
>> ~~~
>> "Acidobacteria"               "Actinobacteria"              "Aquificae"                  
>> "Armatimonadetes"             "Bacteroidetes"               "Caldiserica"                
>> "Calditrichaeota"             "Candidatus Cloacimonetes"    "Candidatus Saccharibacteria"
>> "Chlamydiae"                  "Chlorobi"                    "Chloroflexi"                
>> "Chrysiogenetes"              "Coprothermobacterota"        "Cyanobacteria"              
>> "Deferribacteres"             "Deinococcus-Thermus"         "Dictyoglomi"                
>> "Elusimicrobia"               "Fibrobacteres"               "Firmicutes"                 
>> "Fusobacteria"                "Gemmatimonadetes"            "Ignavibacteriae"            
>> "Kiritimatiellaeota"          "Lentisphaerae"               "Nitrospirae"                
>> "Planctomycetes"              "Proteobacteria"              "Spirochaetes"               
>> "Synergistetes"               "Tenericutes"                 "Thermodesulfobacteria"      
>> "Thermotogae"                 "Verrucomicrobia"      
>> ~~~
>> {: .output}
>>
> {: .solution}
{: .challenge}

To place the two sets of phlya in a list, we use
~~~
venn_data <- list(ERR4998593 = unique(number_of_taxa$Phylum[number_of_taxa$Sample == "ERR4998593"]),
                  JP4D = unique(number_of_taxa$Phylum[number_of_taxa$Sample == "JP4D"]))
~~~
{: .language-r}  

And to draw the venn diagram
~~~
ggvenn(venn_data)
~~~
{: .language-r}  


<a href="{{ page.root }}/fig/03_03_phlya_venn.png">
  <img src="{{ page.root }}/fig/03_03_phlya_venn.png" alt="venn diagram for the phyla in the two sample." />
</a>
The Venn diagram shows that most of the phyla (29 which is 80.6%) are in both samples, one is in ERR4998593 only and 6 are in JP4D only. 
Perhaps you would like to know which phyla is in ERR4998593 only? The following command will print that for us:

~~~
venn_data$ERR4998593[!venn_data$ERR4998593 %in% venn_data$JP4D]
~~~
{: .language-r}  

~~~
"Candidatus Bipolaricaulota"
~~~
{: .output}


> ## Exercise 3
>
> Which phyla are in JP4D only?
>> ## Solution
>> Use JP4D instead of ERR4998593 and ERR4998593 instead of JP4D!
>> ~~~
>> venn_data$JP4D[!venn_data$JP4D %in% venn_data$ERR4998593]
>> ~~~
>> {: .language-r}
>>
>> ~~~
>> "Calditrichaeota"      "Coprothermobacterota" "Dictyoglomi"         
>> "Fibrobacteres"        "Ignavibacteriae"      "Lentisphaerae"  
>> ~~~
>> {: .output}
>>
> {: .solution}
{: .challenge}


We summarised our metagenomes for the number of phyla in each sample in `number_of_taxa`. We can use a similar approach to examine the abundance of each of these taxa:

~~~
abundance_of_taxa <- bac_meta_df %>% 
  filter(Abundance > 0) %>% 
  group_by(Sample, Phylum) %>% 
  summarise(Abundance = sum(Abundance))
~~~
{: .language-r}  

We can see the vast majority of our taxa are Proteobacteria and Firmicutes in ERR4998593



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

We can see that the most abundant phyla in ERR4998593 are Proteobacteria and Firmicutes. However, we can't tell much from JP4D because the total number of reds is so much less.

## Transformation of data

Since our metagenomes have different sizes, it is imperative to convert the number
of assigned read into percentages (i.e. relative abundances) to compare them.

We can achieve this with:
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

