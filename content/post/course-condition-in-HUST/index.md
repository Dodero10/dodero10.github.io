---
# Name of the article
title: "Course Condition in HUST"

# Quick description
description: Tool to check course conditions for HUST student.

# Author of the article
author: Dodero

# Appears as the tail of the output URL.
slug: "course-condition-in-hust"

# Date created
date: 2022-12-27T00:36:17+07:00

# Date published. Before that day, the post can not be available
publishDate: 

# Daye expired. After that day, the post can not be available
expiryDate:

# Last modified time of the file
lastmod: 
    - :fileModTime
    - :git
    
# Article's tags
tags: 
    - tool

# Article's categories: Blog, Project or Guideline
categories:
    - project

# Allow share?
socialShare: true

# Useful to link articles together for "See also" part
series: 

# is Math included? Default: false
math: false

# Cover image of the article
image: 
    cover.png

# License. Default: CC BY-NC-SA 4.0
license:

---

# Problem
Many HUST students are not eligible to take the course in the next semester because they do not complete the required courses. That makes it difficult for students to complete the program on time without following detailed qualifying courses. Keeping track of the conditional course makes students spend a lot of time and can't observe all of them.
# Solution
We have put into use this dependent module drawing model to make it easier to track students' conditional courses.
## Operation
Source data is downloaded from https://ctt-sis.hust.edu.vn/pub/CourseLists.aspx
then analyze the condition information and build the family tree of the modules.
Limits: new condition support and, or. Parallel subjects are considered as conditions and.
## Usage
- ver 1: Display all the courses that are dependent on the set of interest.
- ver 2: Continue tracing to form a full tree branch of dependent modules.
- ver 3: Displays the course name, number of credits, tuition credits, and weights at the end of the semester.
*If no graphs are displayed, the set code does not exist in the database.
You can use it at: http://sinno.soict.ai/dkhp.html
# Prize
We were fortunate to get the third prize in the contest "HIGH APPLICATION MVP PRODUCTS CONTEST 2022" organized by SVMC (Samsung Vietnam Mobile R&D Center) and SOICT. This reward is also a motivation for us to develop this product even better