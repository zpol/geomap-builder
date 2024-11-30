# How to rapidly deploy: 

This will spin up the containers in a local or testing envronment.

Just run: 

    chmod +x deployer.sh && . ./deployer.sh 

Note the `.` before `./deployer.sh` that's the same as "sourcing" the file so the variables can be exported outside of the script context and being used in the current shell to have all the access credentials and secrets available. 

The secrets are get in deploy time when running this script therefore you will need to create those secrets into SSM first.



# How to deploy on PRODUCTION




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
* automate getting prometheus endpoint to configure it also in grafana 

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


