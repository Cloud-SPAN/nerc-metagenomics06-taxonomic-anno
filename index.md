---
layout: lesson
root: .
---
Now we've assembled and polished our metagenome, it's time to start using it! In this lesson we will find out which species are present in our sample using taxonomic assignment. This is possible due to the vast amount of sequence data that already exists. We can compare our reads to a database of these sequences and see where the best matches are.

There are a few ways of doing this but we will be using a strategy called k-mers for high accuracy and rapid classification. We'll then go on to visualise our classification results using an interactive browser application.

After looking at our taxonomy we will use our results to explore and visualise the diversity of our sample.

By the end of this lesson you will be able to:
- apply Kraken2 to perform taxonomic assignment using exact k-mer matches
- use Pavian to visualise and compare samples dynamically
- understand α and β diversity
- calculate a biological observation matrix (BIOM) from Kraken output using KrakenBiom
- plot metagenome diversity using the phyloseq library

In this lesson we will be discussing how to assign a taxonomy to your metagenome data. We will discuss how taxonomy assignment works. We will be discussing the differences in assignment, through alignment and k-mer matching, and the software that uses these different methods. We will also talk about kraken2 which we will be using for this, and the importance of selecting an appropriate database. We will also talk about how you can visualise these results using [pavian](https://github.com/fbreitwieser/pavian). Once you have your taxonomy and can visualise it, we will then move onto how to explore the level of diversity and discuss alpha and beta diversity metrics using the [phyloseq and ggplot2 in R](https://cloud-span.github.io/metagenomics03-taxonomic-anno/02-Diversity-tackled-with-R/index.html).
