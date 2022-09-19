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

It can be broken into 4 essential parts:

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

### Missing values

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

1. **Deletion**: we can delete rows with missing data.

   - Pros: simplest method
   - Cons: we can introduce bias or hide relationships
2. **Single imputation** (_imputation = guessing_): we can use other values to
   predict missing ones. Methods: mean/mode, dummy variable, single regression.
3. **Model-based imputation**: we create a model to predict missing values. Methods:
   maximum likelihood, multiple imputation.

We can convert the missing values into a new value and assign meaning to it.
However this increases the difficulty of the mining process. We can use other
data mining methods to imputate missing values. We can also use a "Do Not
Impute" policy: simply use default policy of the mining method for handling the
missing values.

#### List-wise deletion

**We only analyze cases with available data on each variable**. This approach is the
simplest, however we reduce the sample size and we remove information. **Estimates
can be biased if data is not MCAR**.

#### Pair-wise deletion

**We delete cases with missing values that affect only the variable of interest**.
Doing as such means we keep as many cases as possible for each analysis and we
use as much info as possible. **Comparison of results, however, is more difficult
because samples are different each time**.

### Inaccurate values

Data is not collected for the only purpose of mining. Errors and omissions don't
affect the original purpose of data. We need to identify outliers and check for
consistency. Errors in data may be deliberate.

### Geometric view

When data contains only numerical values, every row can be viewed as a point in
$d$-dimensional space. Every column is a point in the space.

Another view is the probabilistic view: every instance is extracted from a
probability distribution.

### From Categorical attributes to numerical

We care about the type of the data because it influences the work we can do on
data. Some algorithms and functions work only on specific data types. We can
also check better for missing/invalid values.

**To transform data from categorical to numerical we use encoders. We can
transform numerical data into ordinal using discretization**.

#### Encoders (Scikit-Learn encoders)

1. **LabelEncoder**: Encodes target labels with values between 0 an $n-1$.

   This replacement can influence the process in unexpected ways: if we map two
   values to 1 and 2 we are implying that the first value is "smaller" than the
   second. We would need to redo the analysis and change the mapping to check
   that our encoding does not influence the analysis.
2. **OneHotEncoder**: Performs a one-hot encoding of features: we map each
   category to one boolean variable.

   The good part is that we use the same values with all the labels. However we
   can generate an enormous amount of variables if we have many categories.
3. **OrdinalEncoder**: Performs an ordinal (integer) encoding of the categorical
   features.

#### Categorical embeddings

A new approach that surfaced recently is applying deep learning to map
categorical variables into Euclidean spaces. Similar values are mapped close to
each other in the embedding space, revealing the intrinsic properties of the
categorical variables.

### Data formats

Most commercial tools have their own proprietary formats. Most tools import
excel an CSV files. There have been attempts to create a common format for data
like ARFF.

DSPL is an open format by Google. It consists in adding XML metadata to a CSV
file.

### Model representation

PMML is an XML markup language to provide  a way for applications to define
models related to predictive analytics and data mining. The goal is to share
models between applications.

## Data exploration

Preliminary exploration of the data is aimed at identifying their most relevant
characteristics. This helps in selecting the right tool for preprocessing and
mining. We also exploit our brain's ability to analyze patterns non captured by
automatic tools.

### Exploration Data Analysis

It is _an approach of analyzing data to summarize their main characteristics
without using a statistical model to having formulated a priori hypothesis_. It
mainly focuses on:

- Visualization
- Clustering and anomaly detection

### Summary statistics

Summary statistics are number that summarize properties of the data. Most
summaries can be calculated in a single pass.

1. **Frequency**: the percentage of time the values occurs in the dataset
2. **Mode**: the most frequent value
3. **Mean**: the most common measure for the location of a set of points. Very
   sensible to outliers.

   $$
    mean(x) = \bar{x} = \frac{1}{m}\sum_{i=1}^m x_i
   $$

4. **Median**:

   $$
   median(x) = \begin{cases}
     x_{(r+1)} &\quad \text{if m is odd} \\
     0.5(x_r + x_{r+1}) &\quad \text{if m is even}
   \end{cases}
   $$

5. **Percentile**: the p-th percentile is a value $x_p$ such that $p\%$ of the
   observed values of $x$ are less  than $x_p$
6. **Trimean**: weighted mean of the first, second and third quartile

   $$
     TM = \frac{x_{25} + 2x_{50} + x_{75}}{4}
   $$

7. **Truncated mean**: A mean that discards data above and below certain percentiles (e.g.
   5th and 95th)
8. **Interquantile mean**: A mean that truncates the data at the 25th and 75th percentiles.
   If the data is sorted, we have:

   $$
   X_{IQM} = \frac{2}{n}\sum_{i=0.25n+1}^{0.75n} x_i
   $$

9. **Range**: the differences between max and min
10. **Variance**: the most common measure for spread. Very sensitive to
    outliers.

    $$
    variance(x) = s^2_x = \frac{1}{m - 1}\sum_{i=1}^m (x_i - \bar{x})^2
    $$

    Alternatives to variance that are more resilient to outliers:

    $$
    \begin{gathered}
      AAD(x) = \frac{1}{m}\sum_{i=1}^m |x_i - \bar{x}| \\
      MAD(x) = median(\{|x_1 - \bar{x}|, \ldots, |x_m - \bar{x}|\}) \\
      \text{interquantile range}(x) = x_{75\%} - x_{25\%}
    \end{gathered}
    $$

### Correlation analysis

Given two attributes, we measure how strongly one attribute implies the other.
We mainly look for linear relationships between variables. They can be positive
or negative. Linear correlation is symmetric.

Given two attributes we need to measure how strongly one attribute implies the
other, based on the available data.

- Numerical variables: Pearson's product moment coefficient
- Ordinal variables: Spearman's rank correlation coefficient
- Categorical variables: $\chi^2$ statistic test
- Binary variables: Point-biserial correlation

**Correlation does not mean causation**:

1. Correlation does not imply causation
2. Causality has direction, correlation typically doesn't
3. Confounding variables can cause attributes to be correlated

### Outliers

Outliers are data objects that do not comply with the general behaviours or model
of the data. Most analysis methods consider outliers as noise/exceptions.
Outliers may be selected using:

- **Manual inspection** and domain knowledge
- **Statistical tests** that assume a distribution or probability model for the data
- **Distance measures** where objects that are a substantial distance from any other
  cluster
- **Deviation based methods** identify outliers by examining differences in the main
  characteristics of objects in a group

Outliers are frequently filtered out, but **can be the focus of the analysis**.

### Normalization

We might need to normalize attributes that have a very different scales. 

Range normalization converts all values to the range $[0;1]$:

$$
x'_i = \frac{x_i-min_i x_i}{max_i x_i - min_i x_i}
$$

Standard score normalization forces variables to have mean of 0 and standard
deviation of 1

$$
x'_i = \frac{x_i - \mu}{\sigma}
$$

### Visualization

Visualization is the conversion of data into a visual or tabular format so that
characteristics of the data and the relationships among data items or attributes
can be analyzed or reported.

It is one of the most powerful and appealing techniques for data exploration:

1. Pattern-matching and visual brain
2. Can detect general patterns and trends
3. Can detect outliers and unusual patterns


