# mosquitto-passwd
OpenSSL and Mosquitto password generator based on Alpine Linux.

## Security Warning

**IMPORTANT**: This tool generates and stores passwords in plain text files for convenience during development and testing. Please be aware of the following security considerations:

- Plain-text passwords are stored in `./passwd/mosquitto.plain` and individual `./passwd/<username>_passwd.json` files
- All generated files are created with `600` permissions (owner read/write only) for security
- **Never commit these password files to version control**
- **Do not use in production environments without proper security measures**
- Consider deleting plain-text files after importing encrypted passwords to your Mosquitto broker
- Ensure the `./passwd` directory has appropriate access controls on your host system
- Be cautious when sharing or backing up the `./passwd` directory

For production deployments, consider:
- Using a secrets management system (e.g., HashiCorp Vault, AWS Secrets Manager)
- Implementing additional encryption for the `./passwd` directory
- Restricting access to the Docker host and mounted volumes

## Generate password files

The password script will generate the following password files into the mounted volume `./passwd`:

 - `./passwd/mosquitto.plain` - username(s) and plain password(s) using [openssl rand](https://www.openssl.org/docs/man1.0.2/man1/openssl-rand.html)
 - `./passwd/mosquitto.passwd` - username(s) and encrypted password(s) using [mosquitto_passwd](https://mosquitto.org/man/mosquitto_passwd-1.html)
 - `./passwd/<username>_passwd.json` - for each username and plain password

 Note: usernames and passwords will be appended to the _mosquitto.plain_ file. If you want to clear the password files run the following command: 
   - Linux: `sudo rm -rf ./passwd`
   - Windows PS: `rm passwd`

## Prerequisites

1. Create the `passwd` directory, if it doesn't exist:

   `mkdir -p passwd`

   Note: while Linux will create the _passwd_ folder automatically, Windows needs an existing _passwd_ directory, before mounting the volume.
   
2. Ensure that you use the latest docker image:

   `docker pull burkhardm/mosquitto-passwd:latest`

## For single user
The following command generates the password files for the default username: 'user'.

`docker run -v ${pwd}/passwd:/passwd burkhardm/mosquitto-passwd:latest`

## For multiple users
The following command generates the password files for every user passed as command-line argument.

`docker run -v ${pwd}/passwd:/passwd burkhardm/mosquitto-passwd:latest user0 user1 user2`
