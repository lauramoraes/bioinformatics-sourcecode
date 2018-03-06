# A Decision-Tree Approach for the Differential Diagnosis of Chronic Lymphoid Leukemias and Peripheral B-cell Lymphomas


## Abstract
**Objective** Here we propose a decision-tree approach for the differential diagnosis of distinct WHO
categories B-cell chronic lymphoproliferative disorders using flow cytometry data. Flow cytometry
is the preferred method for the immunophenotypic characterization of leukemia and lymphoma,
being able to process and register multiparametric data about tens of thousands of cells per
second.

**Methods** The proposed approach was validated in diagnostic peripheral blood and bone marrow
samples from 283 mature lymphoid leukemias/lymphomas patients. The proposed decision-tree is
composed by logistic function nodes that branch throughout the tree into sets of (possible) distinct
leukemia/lymphoma diagnoses. To avoid overfitting, regularization via the Lasso algorithm was
used.

**Results** The proposed approach achieved 95% correctness in the cross-validation test phase
(100% in-sample), 61% giving a single diagnosis and 34% (possible) multiple disease diagnoses.
Similar results were obtained in an out-of-sample validation dataset. The generated tree reached
the final diagnoses after up to seven decision nodes.

**Conclusions** Here we propose a decision-tree approach for the differential diagnosis of mature
lymphoid leukemias/lymphomas, which proved to be accurate during out-of-sample validation. The
full process is accomplished through seven binary transparent decision nodes.

## How to run?
Execute the run.sh file. This will run the code for in sample and new cases. The out of sample takes a long time, since we use leave one out validation. I recommend you download the code and run in your own computer.

Complete code: [https://github.com/lauramoraes/bioinformatics-sourcecode](https://github.com/lauramoraes/bioinformatics-sourcecode)

## Dataset available
The dataset contains data from real patients, that were anonymized. The main dataset is composed of 283 patients containing 24 markers for each patient. The additional dataset contains 96 patients. Each marker represents the median of a set of cells that were analyzed using Flow Cytometry.