# Maji-Ndogo: From analysis to action
We dive into Maji Ndogo's expansive database containing 60,000 records spread across various tables.

<center>
    <img src="https://www.wvi.org/sites/default/files/WV-10.jpg" width="1000" alt="cognitiveclass.ai logo" />
</center>

## Project Overview:
This project focuses on wrangling and analyzing the Maji Ndogo database. The goal is to analyze data from various tables, assess its quality and tidiness, clean the data, and querying the data to gain insights into the Maji Ndogo water source quality, pollution issues and more. The project guides you through the process of querying and manipulating data using SQL commands.


## Getting Started
To run the SQL data analysis part of the project, follow these steps:


## Pre-requisites
- You should have access to a SQL database, such as MySQL or SQLite.
- You may need an integrated development environment (IDE) for SQL, such as MySQL Workbench or DBeaver.
- Download the database files in the datasets' section. 


## Summary of Methodologies:
In this four-part integrated project, we will investigate access to safe and affordable drinking water in Maji Ndogo as part of the United Nations Sustainable Development Goal 6 (Clean water and sanitation).

- In the first part of the integrated project, we dive into Maji Ndogo's expansive database containing 60,000 records spread across various tables. As we navigate this trove of data, we'll use basic queries to familiarise ourselves with the content of each table. Along the way, we'll also refine some data using DML.
- In the second part of the integrated project, we gear up for a deep analytical dive into Maji Ndogo's water scenario. Harness the power of a wide range of functions, including intricate window functions, to tease out insights from the data tables.
- In the third part of the integrated project, we will pull data from many different tables and apply some statistical analyses to examine the consequences of an audit report that cross-references a random sample of records.
- In the final part of the project, we finalise our data analysis using the full suite of SQL tools. We will gain our final insights, use these to classify water sources, and prepare relevant data for our engineering teams.
 

## Datasets
The dataset for this analysis was provided by [Explore-AI](https://github.com/Explore-AI) and it consists of 8 entities including the data dictionary, employee, global water access, location, water quality, visits, water source, well pollution. The datasets can be downloaded here:
- [Maji Ndogo DB](https://alxlearn.explore.ai/uploads/content/Additional_download-3901.zip)
- [Auditor Report](https://drive.google.com/file/d/1eh15yLUjzyA7sdxtkjqkG1NEscHNDsJC/view?usp=sharing)


## Data Wrangling
The data wrangling process involves several steps, including data gathering, data assessment, and data cleaning.

1. Data Gathering: The data is gathered from two different sources:
    - [Maji Ndogo DB](https://alxlearn.explore.ai/uploads/content/Additional_download-3901.zip) file provided by the        Explore AI team
    - [Auditor Report](https://drive.google.com/file/d/1eh15yLUjzyA7sdxtkjqkG1NEscHNDsJC/view?usp=sharing)  file            provided by the Explore AI team
2. Data Assessment: The validity of the data analysis and research results was compared with the
[Auditor Report](https://drive.google.com/file/d/1eh15yLUjzyA7sdxtkjqkG1NEscHNDsJC/view?usp=sharing) file to identify quality and tidiness issues. Issues such as missing data, incorrect data types, duplicate data, and inconsistencies are documented.
3. Data Cleaning: The identified issues are addressed by cleaning the data. This involves operations such as fixing data types, removing duplicates, and resolving inconsistencies.


## Summary of Results
The examination of the data regarding the water situation in Maji Ndogo yields the following findings:

- The majority of water sources in Maji Ndogo are located in rural areas.
- Approximately 43% of the population relies on shared taps, where as many as 2000 individuals share a single tap.
- About 31% of the community has water infrastructure within their households, but among this group,
- 45% encounter non-functional systems due to problems with pipes, pumps, and reservoirs. This issue is particularly prevalent in towns such as Amina, the rural areas of Amanzi, and several towns across Akatsi and Hawassa.
- Roughly 18% of the population depends on wells, but within this category, only 28% have access to clean wells. These are predominantly located in Hawassa, Kilimani, and Akatsi.
- Residents often experience extended waiting times for water, averaging more than 120 minutes:
   - Waiting lines are notably lengthy on Saturdays.
   - The longest queues occur during the morning and evening hours.
   - Wednesdays and Sundays typically have shorter wait times.
