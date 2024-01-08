# IV1351 Data Storage Paradigms
This project is based on assignments for a course in 'Data Storage Paradigms' given at KTH Royal Institute of Technology
in Stockholm.

This repo contains SQL scripts to create and populate the database used for this project (task 2). 
It also contains the SQL queries used for task 3.

## How to Create the Database

Follow the steps below to create the database and insert data.

1. Create an empty database, this isn't done by the scripts.
2. Run the script `./src/db/tables/create_tables_soundgood_db.sql` against the database created above. 
   This creates the database schema.
3. Run the script `./src/db/functions/functions.sql` against the database used above, 
   to create the functions needed for step 4 and 5.
4. Run the script `./src/db/procedures/procedures.sql` against the database used above, 
   to create the procedures required for running
   the script in step 5. 
5. Run the script `./src/data/populate_tables.sql` against the database used above, which will insert data. 

As an alternative to the steps above, use the script `empdb-from-pg_dump.sql` which creates the empty database, the schema, and also inserts data. This script has been generated with `pg_dump`, and when executed will create a database with exactly the same state as when the script was generated.

## The queries listed in `tips and tricks for project task 3`

The file `queries.sql` contains all queries listed in the document `tips and tricks for project task 3`.

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
