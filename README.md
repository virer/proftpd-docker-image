# README #
A simple docker image with proftpd compiled into alpine 3.13 for mod_sftp module only.

## Usage
### Create password file
```console
  # ftpasswd --passwd --file=/etc/proftpd/ftp.passwd --uid=UID --home=/path/to/home --shell=/bin/false --sha256 --name=username

 or use the following structure :
   <username1>:<HASH>:<UID>:<GID>::<HOME>:<SHELL>
   <username2>:<HASH>:<UID>:<GID>::<HOME>:<SHELL>   

  Example:
   userexample:$5$xAJDjmFE7TtGDqYS$115H7.8YIQWaBvvk2.17Ht3EIiHjCKks2USmLOq7z37:1007:1007::/opt:/bin/false
 And hash passwords using something like this :
 echo MyPassw0rd | mkpasswd -s -m sha-512

 And group file usign the follwing strucure:
   groupname:x:<GID>:<username1>,<username2>
 Example:
   group1:x:1007:username1,username2
```