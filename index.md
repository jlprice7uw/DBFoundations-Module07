## Introduction
Module 07 covered uses and creation of SQL Functions, including pre-defined and user-defined functions (UDFs). I will explain when one would want to use a SQL UDF and the differences between types of UDFs.
## When to Use a SQL UDF
SQL provides users with many functions, but you may want to create your own function for a purpose specific to your organization or dataset. You may want to create a UDF for a custom filter—this allows you to display data filtered and/or ordered in a way that you may need to perform frequently. The UDF allows you to return results as frequently as you want without having to type out or copy the actual code for doing so. 
## Differences Between Scalar, In-Line, and Multi-Statement Functions
Scalar functions return a single value or data-point. One example is ‘IsDate()’ which returns true/false for whether the input is a date. In-Line functions would be used as part of another statement—the function would run as part of a larger statement. The results of an in-line function could be scalar or tabular. A multi-statement function can be used to display results in one table that are pulled from multiple tables. See Figure 1 for an example of a multi-statement table-value function from a Wise Owl Tutorials YouTube video.
 ![image here](https://github.com/jlprice7uw/DBFoundations-Module07/blob/main/assign07_figure1.png)
 ###### Figure 1.  Multi-statement table-valued function example (https://www.youtube.com/watch?v=nCAEgNxC7nU&list=PLfycUyp06LG9wAGPKBZ7poKBcbDZrmXpi&index=6, 2021).

In the video from which Figure 1 was pulled, the ‘Insert Into’ statement was repeated with ‘actor’ instead of ‘director’ to include data from both actor and director datasets in the ‘PeopleInYear’ table. These inserts are the ‘multi-statement’ part of this function. Multi-statement functions differ from scalar and in-line/simpler functions syntactically in that ‘Begin’/’End’ are necessary, as well as a table variable (‘@t’ in the example).
## Summary
Functions can range from simple data filters returning a single data point (scalar) to MSTVFs (multi-statement table-valued functions) combining filtered data from multiple tables or datasets. There are many functions provided in MS SQL, but you can create a custom function (UDF) to perform operations/filter/compile data based on your context or dataset.
