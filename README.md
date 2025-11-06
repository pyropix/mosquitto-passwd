# mosquitto-passwd

[![CI/CD](https://github.com/burkhardm/mosquitto-passwd/workflows/CI%2FCD/badge.svg)](https://github.com/burkhardm/mosquitto-passwd/actions)
[![Docker Pulls](https://img.shields.io/docker/pulls/burkhardm/mosquitto-passwd)](https://hub.docker.com/r/burkhardm/mosquitto-passwd)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

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

## Username Requirements

For security reasons, usernames must meet the following criteria:

- Only alphanumeric characters, dots (`.`), hyphens (`-`), and underscores (`_`) are allowed
- Maximum length of 64 characters
- Cannot be empty
- No path traversal characters or special symbols

Examples of valid usernames: `user`, `mqtt-broker`, `sensor.01`, `device_123`

## Important Notes

### Non-Root User

The container runs as a non-root user (UID/GID 1000) for improved security. The generated files will be owned by UID 1000. If you need to access these files on your host system:

```bash
# Option 1: Change ownership after generation
sudo chown -R $USER:$USER ./passwd

# Option 2: Run container with your user ID
docker run --user $(id -u):$(id -g) -v ${pwd}/passwd:/passwd burkhardm/mosquitto-passwd:latest
```

### File Permissions

All generated password files are created with `600` permissions (owner read/write only) to prevent unauthorized access. This is a security best practice but means:

- Only the file owner can read the password files
- Other users on the system cannot access the passwords
- You may need to adjust permissions or ownership based on your use case

## Development

### Running Tests

Tests are written using [BATS](https://github.com/bats-core/bats-core). To run tests locally:

```bash
# Install BATS (if not already installed)
# On macOS: brew install bats-core
# On Ubuntu: sudo apt-get install bats

# Run tests
bats tests/passwd_test.sh
```

See [tests/README.md](tests/README.md) for more information.

### Building Locally

```bash
# Build image
./docker_build.sh

# Or manually
docker build -t mosquitto-passwd:local \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VCS_REF=$(git rev-parse --short HEAD) \
  --build-arg BUILD_VERSION="dev" \
  .
```

## CI/CD

This project uses GitHub Actions for continuous integration and deployment:

- **Linting**: Dockerfile (Hadolint) and shell scripts (ShellCheck)
- **Testing**: Automated BATS tests for all functionality
- **Security Scanning**: Trivy vulnerability scanning
- **Multi-Platform Builds**: Supports `linux/amd64`, `linux/arm64`, and `linux/arm/v7`
- **Automated Publishing**: Pushes to Docker Hub on releases

## License

MIT License - see [LICENSE](LICENSE) file for details.
