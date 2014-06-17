logstash ansible role
=====================

Install [logstash]() and set it up. Create a cron job to import AWS CloudTrail and AWS ELB access logs.

Requirements
------------

### Platforms

- Debian
- Ubuntu

### Roles

- common
- awscli
- elasticsearch

### Variables

```yaml
logstash:
  version: 1.4
  tcp:
    - { host: 127.0.0.1, port: 3333, tags: [ 'elb', 'eu-west-1' ] }
    - { host: 127.0.0.1, port: 3334, tags: [ 'elb', 'us-east-1' ] }
    - { host: 127.0.0.1, port: 3335, tags: [ 'cloudtrail' ] }
elb:
  eu-west-1:
    - { elbid: awseb-e-1-AWSEBLoa-ELB1ID, tags: [ 'project1_name' ] }
  us-east-1:
    - { elbid: awseb-e-2-AWSEBLoa-ELB2ID, tags: [ 'project2_name' ] }
```