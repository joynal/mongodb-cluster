# Ceating self signed certificate

## Step: 1 - Create a Certificate Authority

Generate a private key for CA certificate and keep it safe.
```
openssl genrsa -out CA.key 4096
```

You can add password for two step verification, add `des3`
```
openssl genrsa -des3 -out CA.key 4096
```

Now self sign to this certificate

```
openssl req -new -x509 -days 1825 -key CA.key -out CA.crt
```

Sample:
```
Country Name (2 letter code) [AU]:BD
State or Province Name (full name) [Some-State]:Dhaka
Locality Name (eg, city) []:Gazipur
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Kryptonite Soft Ltd
Organizational Unit Name (eg, section) []:IT
Common Name (eg, YOUR name) []:Security Kryptonite Soft
Email Address []:contact@kryptonite.com
```

## Step: 2 - Generate a client certificate (Repeat this per device)

Generate key for client
```
openssl genrsa -out client.key 4096
openssl req -new -key client.key -out client.csr
```

Now self sign it
```
openssl x509 -req -days 1825 -in client.csr -CA CA.crt -CAkey CA.key -set_serial 01 -out client.crt
```

Create `.pem` file
```
cat client.key client.crt > client.pem
```