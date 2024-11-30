# How to rapidly deploy: 

This will spin up the containers in a local or testing envronment.

Just run: 

    chmod +x deployer.sh && . ./deployer.sh 

This script will spin up everything in a local environment.
It will run 2 containers, grafana and mariadb. The grafana is configures to autoprovision cfg whem mounting the configs on a volume so it will have by default a datasource already configured for MySQL/MariaDB with the proper credentials.(Note also that for local env is ok but for RD for example an SSM parameter will be needed for that).

Then the deployer script follow executing my connecting to the database and importing a default database schema ( explained below). 

Note the `.` before `./deployer.sh` that's the same as "sourcing" the file so the variables can be exported outside of the script context and being used in the current shell to have all the access credentials and secrets available. 

The secrets are get in deploy time when running this script therefore you will need to create those secrets into SSM first.

## Demo data

You can add demo dummy data to test your database queries on the grafana map with `tools/populate_db_example_data.py` script. 

Example: 

    > python3 tools/populate_db_example_data.py 10
    Generando 10 registros aleatorios...
    Insertando registros en la base de datos...
    10 registros insertados exitosamente.

It will produce this inserts into the db:

```
+----+-----------------+-------------+--------------+--------------------------------+
| id | public_ip_addr  | lat         | lon          | metadata                       |
+----+-----------------+-------------+--------------+--------------------------------+
|  1 | 112.6.159.155   | -43.7029790 |  120.0950080 | {'continent': 'Australia'}     |
|  2 | 148.206.233.99  |  34.3103320 |  137.1015690 | {'continent': 'Asia'}          |
|  3 | 40.92.240.113   |  27.3948710 |   99.7198430 | {'continent': 'Asia'}          |
|  4 | 105.242.116.224 |  30.1794820 |  -86.3008610 | {'continent': 'North America'} |
|  5 | 167.49.31.234   |  40.4145390 | -115.0255060 | {'continent': 'North America'} |
|  6 | 70.186.146.107  |  53.7060240 |  123.5397020 | {'continent': 'Asia'}          |
|  7 | 13.135.251.137  |  35.5399520 |  -92.0634230 | {'continent': 'North America'} |
|  8 | 126.76.63.149   |  65.1129390 |  -62.4893870 | {'continent': 'North America'} |
|  9 | 147.190.147.2   |   8.4678060 |   78.7096260 | {'continent': 'Asia'}          |
| 10 | 24.113.68.57    | -14.8582570 |  116.8709910 | {'continent': 'Australia'}     |
+----+-----------------+-------------+--------------+--------------------------------+

```

# How to deploy on PRODUCTION

TODO: reviwew all TODO strings on the code with some hardcoded strings that need to b fixed :) 


# Dependencies

* Linux environment with bash ( AWS LinuxV2 ) 
* aws cli
* jq
* docker 
* docker-compose
* Terraform 


# How it works 


The deployer script spins up: 

* Registry? ( not neeedd for now all the images can go to a generic registry and b securely scanned by some tool) 
* A Grafana container image
* A MariaDB database container image
* A Prometheus time-series database container image
* A Lambda function with a python script taht gathers all the information and index it into MariaDB.


# Finetunning or customizing


# TODO: 

* automate getting RDS/mariadb endpoint directly into grafana CFG ( use SSM It's easy ) 
* automate getting prometheus endpoint to configure it also in grafana ( it would b nice to have historic data over time, to show some figures and progress)

## SECURITY STUFF: 

The database user should only be granted SELECT permissions on the specified database & tables you want to query.
Grafana does not validate that queries are safe so queries can contain any SQL statement. For example, statements like USE otherdb; and DROP TABLE user; would be executed.
To protect against this we Highly recommend you create a specific MySQL user with restricted permissions. Check out the docs for more information.

## DATABASE SCHEMA 
    +----------------+---------------+------+-----+---------+----------------+
    | Field          | Type          | Null | Key | Default | Extra          |
    +----------------+---------------+------+-----+---------+----------------+
    | id             | int(11)       | NO   | PRI | NULL    | auto_increment |
    | public_ip_addr | varchar(45)   | NO   |     | NULL    |                |
    | lat            | decimal(10,7) | NO   |     | NULL    |                |
    | lon            | decimal(10,7) | NO   |     | NULL    |                |
    | metadata       | longtext      | YES  |     | NULL    |                |
    +----------------+---------------+------+-----+---------+----------------+


