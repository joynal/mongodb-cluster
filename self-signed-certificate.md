# Creating self-signed certificate for mongodb

## Step: 1 - Create a Certificate Authority

Generate a private key for CA certificate and keep it safe.

```bash
openssl genrsa -out CA.key 4096
```

You can add password for two-step verification, add `des3`

```bash
openssl genrsa -des3 -out CA.key 4096
```

Now self-sign to this certificate

```bash
openssl req -new -x509 -days 1825 -key CA.key -out CA.crt
```

Sample:

```bash
Country Name (2 letter code) [AU]:NL
State or Province Name (full name) [Some-State]:Nord Holland
Locality Name (eg, city) []:Purmerend
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Kryptonite Soft Ltd
Organizational Unit Name (eg, section) []:IT
Common Name (eg, YOUR name) []:Security Kryptonite Soft
Email Address []:support@kryptonite.com
```

Create `.pem` file

```bash
cat CA.key CA.crt > CA.pem
```

## Step: 2 - Generate a client certificate (Repeat this per device)

Generate key for client

```bash
openssl genrsa -out client.key 4096
openssl req -new -key client.key -out client.csr
```

Now self sign it

```bash
openssl x509 -req -days 1825 -in client.csr -CA CA.crt -CAkey CA.key -set_serial 01 -out client.crt
```

Create `.pem` file

```bash
cat client.key client.crt > client.pem
```
