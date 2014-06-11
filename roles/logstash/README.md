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
logstash_version: 1.4
elb:
  eu-west-1:
    - { name: awseb-e-1-AWSEBLoa-ELB1ID, tag: project1_name }
  us-east-1:
    - { name: awseb-e-2-AWSEBLoa-ELB2ID, tag: project2_name }
```