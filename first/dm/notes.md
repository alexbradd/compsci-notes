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
2. **Classification**: given the input values, we crate a model that tries to
   predict the label of other objects:
   - **Logistic regression**: extension of the linear regression
   - **K-Nearest neighbour**: assigns a label based on the values of the
     neighbouring objects
   - **Decision tree**: extension of the regression decision tree
3. **Clustering**: we have some points and we try to create groups based on the
   data:
   - **K-means**: we look for similarity based on a similarity function. The $k$
     specifies the number of groups the algorithm will create.

     The accuracy of the method depends heavily on the similarity function.
4. **Association**: we try to look create associations between various objects
   (like amazon's "also bought with")
5. Other:
   - Outlier analysis: opposite of clustering
   - Trend and deviation analysis: regression, pattern mining, periodicity
     analysis and similarity-based analysis
   - Text mining, Topic modeling, Graph mining, Data streams
   - Sentiment analysis, Opinion mining...
   - Other pattern or statistical analyses

### Relevant issues

Mining can generate thousands of patterns, but typically not all of them are
interesting. A pattern is **interesting if is easily understood by humans, valid
on new or test data with some degree of certainty, potentially useful, novel or
validates some hypothesis that a user seeks to confirm**. Objective vs
subjective interestingness matters:

1. Objective: based on statistic
2. Subjective: based on the user's beliefs in data

Our methods cannot find all interesting patterns, but most. We will optimize
algorithms by not wasting time on "uninteresting" patterns.

### Pitfalls

**Correlation does not imply causation!**. Just because a trend is similar
between two topics, it does not mean that there is a link between the two.

## Data representation

We will usually see tables:

1. Columns are called **attributes, features, independent variables**
2. The rows are called **instances, observations**
3. **Concepts, target, dependent variables** are still columns, however are
   special because they can be learned

Attributes can be: 

1. **Numerical**: numbers, or differences from a reference
2. **Categorical**: values taken from a set:
   - **Nominal**: when only equality make sense. The values serve only as a
     label, they are meaningless.
   - **Ordinal**: when both equality and inequality are meaningful. They are
     categorical values with an imposed order on values.
3. **Binary**: `0` or `1`

Some attributes can have an hierarchical structure (dates, addresses etc.).

#### Missing values

Missing values can be present due to various reasons (faulty questionnaires,
censor, anonymous data etc.). **Missing values can have a meaning themselves: if
the absence has a meaning, "missing" is a separate value; if it does not,
"missing" must be handled in a special way.** Missing values are of different
types:

1. **Missing not at random**: the distribution of missing values depends on the
   missing value (e.g. people with high income are less likely to
   report it).

   They are the most difficult to deal with: they can skew the results of the
   analysis. They must be handled on case by case basis.
2. **Missing at random**: distribution of missing values depends on the observed
   attributes, but not the missing value.
3. **Missing completely at random**: Distribution of missing values does not
   depend neither on observed attributes or missing values.

Identifying MNAR and MAR can be difficult and requires domain knowledge.

The best strategy to deal with missing data depends on the application:

1. Deletion: we can delete rows with missing data.
2. Single imputation: we can use other values to predict missing ones.
3. Model-based: we create a model to predict missing values

