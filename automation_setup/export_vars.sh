#!/bin/bash

# epinio Services
#db_hostname=`epinio service show nameko_devPostgres | grep -i "Internal Routes" | awk '{ print $5 }' | awk -F "," '{ print $1 }' | awk -F ":" '{ print $1 }'`
#db_password=`epinio service show nameko_devPostgres | grep -i "postgres-password" | awk '{ print $4 }'`
#rabbit_hostname=`epinio service show nameko_devRabbit | grep -i "headless" | grep -i ":5672" | awk '{ print $3 }' | awk -F "," '{ print $1 }' | awk -F ":" '{ print $1 }'`
#rabbit_password=`epinio service show nameko_devRabbit |grep -i "rabbitmq-password" | awk '{ print $4 }'`
#redis_hostname=`epinio service show nameko_devRedis | grep -i "headless" | awk '{ print $5 }' | awk -F "," '{ print $1 }' | awk -F ":" '{ print $1 }'`
#redis_password=`epinio service show nameko_devRedis |grep -i "redis-password" | awk '{ print $4 }'`
#export AMQP_URI=amqp://user:${rabbit_password}@${rabbit_hostname}:5672
#export POSTGRES_URI=postgresql://postgres:${db_password}@${db_hostname}:5432/orders
#export REDIS_URI=redis://redis:${redis_password}@${redis_hostname}:6379/dev
#python -c """import psycopg2 as db;p='postgres';con=db.connect(dbname=p,host=${db_hostname}:5432,user=p,password=${db_password};con.autocommit=True;con.cursor().execute('CREATE DATABASE orders')""" 2> /dev/null
#echo "AMQP_URI=amqp://user:${rabbit_password}@${rabbit_hostname}:5672"
#echo "POSTGRES_URI=postgresql://postgres:${db_password}@${db_hostname}:5432/orders"
#echo "REDIS_URI=redis://user:${redis_password}@${redis_hostname}:6379/dev"
#cat <<EOF > config_vars.txt
#AMQP_URI="amqp://user:${rabbit_password}@${rabbit_hostname}:5672"
#POSTGRES_URI="postgresql://postgres:${db_password}@${db_hostname}:5432/orders"
#REDIS_URI="redis://user:${redis_password}@${redis_hostname}:6379/dev"
#DB_PASSWORD="${db_password}"
#DB_HOST="${db_hostname}"
#RABBIT_USER="user"
#RABBIT_PASSWORD="${rabbit_password}"
#RABBIT_HOST="${rabbit_hostname}"
#REDIS_PASSWORD="${redis_password}"
#REDIS_HOST="${redis_hostname}"
#EOF

#external_services
db_hostname="postgresql-h1"
db_password="postgres"
rabbit_hostname="rabbitmq-headless"
rabbit_password=`sudo kubectl get secret --namespace workspace rabbitmq -o jsonpath="{.data.rabbitmq-password}" | base64 -d`
redis_hostname="redis-headless"
redis_password=`sudo kubectl get secret --namespace workspace redis -o jsonpath="{.data.redis-password}" | base64 -d`
export AMQP_URI=amqp://user:${rabbit_password}@${rabbit_hostname}:5672
export POSTGRES_URI=postgresql://postgres:${db_password}@${db_hostname}:5432/orders
export REDIS_URI=redis://redis:${redis_password}@${redis_hostname}:6379/dev
echo "AMQP_URI=amqp://user:${rabbit_password}@${rabbit_hostname}:5672"
echo "POSTGRES_URI=postgresql://postgres:${db_password}@${db_hostname}:5432/orders"
echo "REDIS_URI=redis://user:${redis_password}@${redis_hostname}:6379/dev"
cat <<EOF > config_vars.txt
AMQP_URI="amqp://user:${rabbit_password}@${rabbit_hostname}:5672"
POSTGRES_URI="postgresql://postgres:${db_password}@${db_hostname}:5432/orders"
REDIS_URI="redis://user:${redis_password}@${redis_hostname}:6379/dev"
DB_PASSWORD="${db_password}"
DB_HOST="${db_hostname}"
RABBIT_USER="user"
RABBIT_PASSWORD="${rabbit_password}"
RABBIT_HOST="${rabbit_hostname}"
REDIS_PASSWORD="${redis_password}"
REDIS_HOST="${redis_hostname}"
EOF
