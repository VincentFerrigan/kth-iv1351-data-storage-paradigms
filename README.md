# IV1351 Data Storage Paradigms
This project is based on assignments for a course in 'Data Storage Paradigms' given at KTH Royal Institute of Technology
in Stockholm.

## Content and learning outcomes
### Course contents
Examples of fields that are treated:
* Databases, data storage and information administration
* The relational model and normalisation
* Conceptual modelling and logical database modeling
* Query language
* Memory management and handling of persistent storage

### Intended learning outcome
One shall be able to
* describe and explain basic concepts, principles and theories in the area of data/databases/data storage and in
  information administration and database design
* model needs for information based on an organizational description and convert the model to a functioning database
* use relational databases and query languages
* describe how a program can access a database and write such a program.

## The Database project
###  Overview
This project entails creating a database application for a fictitious Music School to streamline information handling
and business processes. 
It focuses on creating a database system for managing various aspects of the music school's operations,
from student enrollment to instrument rentals. It progresses from conceptual modeling to the practical application,
ensuring the system caters to the needs of the Music School.

### 1. Project Description
#### **The Soundgood Music School**
- **Objective:** To develop a database and application for managing school data and operations.
- **Business Overview:**
    - Offers music lessons on an ongoing basis.
    - Payment is per lesson with options for individual, group lessons, and ensembles in various genres.
- **Student Information:**
    - Tracks personal details, instrument choice, skill level.
    - Records sibling relationships for offering discounts.
- **Instructor Information:**
    - Includes details and schedules, covering the range of instruments they can teach.
- **Payments:**
    - Students are billed monthly, with charges varying by lesson type and level.
    - Instructors are paid based on the lessons they give.
- **Instrument Rental:**
    - Provide instrument rentals with a limit of two per student.

### 2. Tasks
#### **Task 1: Conceptual Model**
- Create a conceptual model that describes the parts of the reality that
  are to be stored in the database.
  It includes the main concepts (entities) required to store
  information and the relationships that exist between these entities.

#### **Task 2: Logical and Physical Model**
- Convert the conceptual model into a functional database
  (that encapsulates the
  informational requirements outlined in the business description and application requirements).
- Implementation of a relational database system along with the utilization of
  SQL as the query language.
- Address the issue of changing lesson prices over time.

#### **Task 3: SQL**
- OLAP queries for business analysis.
- Queries include lessons per month, sibling statistics, instructor workload, and ensemble schedules.
- Create a denormalized historical database for marketing purposes.

#### **Task 4: Programmatic Access**
- Develop a command-line interface for instrument rental functionalities.
- Emphasize database access and proper handling of ACID transactions.


# Output Samples
[//]: # (![]&#40;https://github.com/VincentFerrigan/kth-iv1350-object-oriented-design/blob/main/output/samples/peek_basic_flow.gif&#41;)
