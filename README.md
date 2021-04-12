# Running OLASimple Aquarium

Run OLASimple Aquarium locally or on a server using Docker:

1. Install Docker and docker-compose.

2. Download OLA Simple aquarium fork using git (requires git on the terminal)

`git clone https://github.com/OLA-Simple/OLASimple-Aquarium`

3. Change into the aquarium directory

`cd OLASimple-Aquarium`

4. Build the docker images by running the command

`docker-compose build`

5. Start the container. To start the services for Aquarium on non-Windows platforms (e.g. MacOS or Linux), run the command

`docker-compose up -d`

On Windows, instead use the command

`docker-compose -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.windows.yml up -d`

6. Once all of the services for Aquarium have started, the website should now be online with an already initialized database. Access the website on port 80 either at `localhost`, or over the internet using the ip address of the machine (port 80 must be opened to make the website accessible on the internet).

>Important: The first run initializes the database, and so it may take up to 10 minutes before the website is accessible on the first run. If you suspect something is wrong with the initialization process, you can stand up the server in non-detached mode with `docker-compose up` instead of `docker-compose up -d`. Then you can view the initialization logs.

7. Login and check that everything is working. Default Admin login is u: `Neptune` p: `aquarium`. The password can be and should be changed from within the website after logging in for the first time (upper-left menu > users > change password).

>Use Chrome for best results

### Stopping Aquarium in Docker:

To halt the Aquarium services, navigate into the same folder and run:

`docker-compose down`

### Backing Up Aquarium Data

It is important to make occasional snapshots of the Aquarium data in case something goes wrong.

All the data is written to `OLASimple-Aquarium/docker/db` and `OLASimple-Aquarium/docker/s3`. These folders should be backed up at least once a week.

The following command will create a timestamped backup:

`zip -r my-backup-location/backup-$(date '+%Y-%m-%d-%s') OLASimple-Aquarium/docker/db OLASimple-Aquarium/docker/s3`

You can do this manually, or you could consider automating it with something like `Cron`.

Here is an example Cron job which will create a backup every 3 days (you may need to provide the absolute location of the OLASimple-Aquarium folder as in something like `/home/users/ola/OLASimple-Aquarium/docker/db`):

`0 0 */3 * * zip -r my-backup-location/backup-$(date '+%Y-%m-%d-%s') OLASimple-Aquarium/docker/db OLASimple-Aquarium/docker/s3 >/dev/null 2>&1`
