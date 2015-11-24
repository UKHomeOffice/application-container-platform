
# allow thme to login via userpass
path "auth/userpass/login/*" {
  policy = "write"
}

# allow them to revoke a lease
path "sys/revoke" {
  policy = "write"
}

# allow them to renew a lease
path "sys/renew" {
  policy = "write"
}

