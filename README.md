# HR_Analytics

### Introduction 
Data was all about employee distribution,race distribution, employeement length, jobtitles, race distribution etc of the company.

### Date Cleaning and Pre-Processing
Date columns required to do the changes such as change the text date format to a completely date format by using *_ STR_TO_DATE() _* and *_DATE_FORMAT()_*, and also clean the empty space of the termdate column into a *_NULL_* values.

### Challenges Faced
Unfortunately, for the first attempted I was not able to convert a text format date value into Date format, although, i was using the correct *_SQL_* function. After spending hours of time, dedicatoion and effort, i was able to figure it out the issue with which it was throwing an error. Well, the solution was so simple that the text format of the date data present in the birthdate, hire_date and termdate columns was not matching with date format. Hence, i changed the format to convert and resolve the issue. This was the biggest challenged i faced with this data

****************************************************************************************************************************************************************************************
