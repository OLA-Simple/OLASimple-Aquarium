# Running OLASimple Aquarium

Run OLASimple Aquarium locally on your computer using Docker: 

1. Install Docker on your computer. 

2. Download OLA Simple aquarium fork (requires git on the terminal) 

`git clone https://github.com/OLA-Simple/OLASimple-Aquarium`

3. Change into the aquarium directory 

`cd aquarium`

4. Build the docker images by runing the command 

`docker-compose build`

5. Start the container. To start the services for Aquarium on non-Windows platforms (e.g. MacOS or Linux), run the command 

`docker-compose up`

>Important: The first run initializes the database, and so will be slower than subsequent runs. This can take longer than you think is reasonable, but let it finish unmolested. 

On Windows, instead use the command 

`docker-compose -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.windows.yml up` 

6. Login and check that everything is working. Once all of the services for Aquarium have started, visit `localhost` with the Chrome browser to find the Aquarium login page. If running Aquarium inside the Docker toolbox VM, the address will be instead be `192.168.99.100`. When started using the default database, aquarium has a single user with login `neptune` and password `aquarium`. If you get errors during startup after doing a build, you may need to run 

`docker-compose pull --ignore-pull-failures docker-compose build --no-cache` 

And, if that doesn't work, let Abe know. 

Stopping Aquarium in Docker: 

To halt the Aquarium services, first type `ctrl-c` in the terminal to stop the running containers, then remove the containers by running 

`docker-compose down`
