# Data mining

## Introduction

Data mining emerged in the late 80s due to an explosive growth of data and a
pressing need for the automated analysis of massive data. 

Big Data is a term that gets thrown around a lot: it indicates gigantic
quantities of data being collected. The quantity of data is so large that:

1. It facilitates predictions not previously possible
2. It necessitates special processes to deal with

### Machine learning

_"A computer program is said to learn from experience $E$ with respect to some
class of task $T$ and a performance measure $P$, if its performance at tasks in
$T$, as measured by $P$, improves because of experience $E$"_ 

Suppose we have the experience encoded as a dataset

$$
  D = x_1, x_2, x_3, \ldots, x_N
$$

1. It is called **supervised learning** if, given the desired outputs $t_1,
   \ldots, t_n$, it learns to produce the correct output given a new set of input
2. It is called **unsupervised learning** if it exploits regularities in the
   dataset to build a representation to be used for reasoning or prediction
3. It is called **reinforcement learning** if, producing actions $a_1, \ldots,
   a_N$ which affect the environment and receiving rewards, it learns to act in
   order to maximize rewards in the long term

### Data science

It can be brokem into 4 essential parts:

1. Mining data
2. Information analysis
3. Representation or visualization
4. Implication/application of the data, interaction using the data and
   predictions formed from studying it

### Data mining

_"Data mining is the process of identifying valid, novel, potentially useful and
understandable patterns in data"_

The general idea is to build computer programs that navigate through databases
automatically, seeking patterns. Problems:

1. Most patterns will be uninteresting
2. Most patterns will be spurious, inexact or accidental
3. Coincidences
4. Real data is imperfect (garbled data, missing data)

The algorithms we develop will need to be robust enough to cope with imperfect
data and extract regularities that are inexact but useful.

Models can be:

1. _Descriptive_: built for gaining insight?
2. _Predictive_: built for accurate prediction?

The main steps are:

1. Selection
2. Cleaning
3. Transformation
4. Mining
5. Validation
6. Presentation

### Data preparation

Preprocessing and preparation account for 90% of the work (trash-in trash-out
principle). Preprocessing is a necessity since data in the real world is dirty:

1. Incomplete (missing attributes)
2. Contains errors
3. Contains inconsistencies and discrepancies

Sampling is the main technique for selection. It is often used both in a
preliminary "investigation" and the final analysis. We also sample data because
analysing all the set may be too time consuming. 

A sample is **representative** if it has the same property (or interest) as the
original set of data. A representative sample works almost as good as the full
set.

We can sample in different ways:

1. Random
2. Sampling without replacing: each selected item is removed from the
   population
3. Sampling with replacement: selected items are not removed from the population
4. Stratified sampling: split the data in partitions and then draw at random
   from each

### Data mining tasks

1. **Regression**: identifies a relation inside a dataset between a target value and
   other values
   - **Linear**: provides a linear relation between input and output
   - **K-Nearest Neighbour**: calculates an average between the neighbours
   - **Tree**: creates various "steps" by dividing the dataset in a tree manner

   Each type of regression fits best a certain type of data.
2. **Classification**: ...
