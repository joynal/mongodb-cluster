# certified authority
openssl ecparam -genkey -name prime256v1 -out ca_private.key
openssl req -new -sha256 -key ca_private_key.pem -out ca.csr
openssl req -x509 -sha256 -days 3650 -key ca_private_key.pem -in ca_csr.csr -out ca_certificate.pem

# cluster member
openssl req -new -sha256 -key ca_private.key -out mermber_csr.pem
openssl x509 -req -sha256 -days 3650 -in mermber_csr.pem -signkey ca_private.key -out mermber_certificate.pem

# webapp/admin client
openssl req -new -sha256 -key ca_private.key -out app_csr.pem
openssl x509 -req -sha256 -days 3650 -in app_csr.pem -signkey ca_private.key -out app_certificate.pem

