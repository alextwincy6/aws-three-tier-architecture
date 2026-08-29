\# Database Tier



\## Amazon RDS MySQL



Amazon RDS for MySQL is used as the database tier of the 3-tier architecture.



\### Configuration



\* Engine: MySQL

\* DB Instance: `three-tier-db2`

\* Port: `3306`

\* Public Access: No

\* DB Subnet Group: Private Database Subnets

\* Deployment: Single-AZ



\### Connection



The Flask application in the Application Tier connects to the RDS MySQL database using the RDS endpoint.



```text

Application EC2

&#x20;     |

&#x20;     | MySQL : 3306

&#x20;     ↓

Amazon RDS MySQL

&#x20;     |

&#x20;     ↓

Private DB Subnets

```



\### Security



The RDS database is kept private and is not directly accessible from the internet.



Database access is controlled using AWS Security Groups.



> Database passwords and other credentials are not stored in this repository.

