#!/bin/bash

rm -rf certificates
mkdir certificates
cd certificates

# certificate authority
openssl genrsa -out CA.key 4096
openssl req -new -x509 -days 1825 -config ../scripts/CA.cnf -key CA.key -out CA.crt
cat CA.key CA.crt > CA.pem


# database instance member
openssl genrsa -out member.key 4096
openssl req -new -config ../scripts/member.cnf -key member.key -out member.csr
openssl x509 -req -days 365 -in member.csr -CA CA.crt -CAkey CA.key -set_serial 01 -out member.crt
cat member.key member.crt > member.pem

# database admin
openssl genrsa -out db_admin.key 4096
openssl req -new -config ../scripts/db_admin.cnf -key db_admin.key -out db_admin.csr
openssl x509 -req -days 365 -in db_admin.csr -CA CA.crt -CAkey CA.key -set_serial 01 -out db_admin.crt
cat db_admin.key db_admin.crt > db_admin.pem

# webapp
openssl genrsa -out webapp.key 4096
openssl req -new -config ../scripts/webapp.cnf -key webapp.key -out webapp.csr
openssl x509 -req -days 365 -in webapp.csr -CA CA.crt -CAkey CA.key -set_serial 01 -out webapp.crt
cat webapp.key webapp.crt > webapp.pem

