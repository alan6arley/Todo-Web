FROM node:12-alpine
WORKDIR /app
COPY . .
RUN yarn install --production
CMD ["node", "/app/src/index.js"]

# https://docs.microsoft.com/en-us/visualstudio/docker/tutorials/use-docker-compose

# Steps explained
# 1. Set base image
# 2. Create the workdir "/app" in host
# 3. Copy all from local dir to the set workdir in host
# 4. install required libraries
# 5. Exec command to run app

# Host OS type: Linux

# Basic execution
# docker build -t todolist:1.00.0 .
# docker run -dp 3001:3000 --name todoweb todolist:1.00.0

# Exec with volumes
# * Create volume:
# docker volume create todo-db
# * Build image
# docker build -t todolist:1.00.0 .
# * Run container using volume to persist database
# docker run -dp 3001:3000 --name todovolume -v todo-db:/etc/todos todolist:1.00.0

# Multi container with network and MySQL
# * Create network 
# docker network create todo-net
# * Create MySQL container attached to a docker network and using a new volume
# docker run -d --network todo-net --network-alias mysqlnet -v todo-mysql-data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=secret -e MYSQL_DATABASE=todos mysql:5.7
# To check if DB is running
# docker exec -it <mysql-container-id> mysql -p
# mysql> SHOW DATABASES;
# Install "nicolaka/netshoot" and attach to the same network than MySQL container to find its IP by "--network-alias"
# docker run -it --network todo-net nicolaka/netshoot
# * Inside netshoot run the following command
# dig mysqlnet
# * The response is in the "ANSWER SECTION" you will see an A record for mysqlnet that resolves the IP
# * Run the app attached to the same network than MySQL | MYSQL_HOST equals to "--network-alias" of mysql container
# * The $(pwd) sub-command expands to the current working directory on Linux or macOS hosts
# * There's no need to exec build command
# docker run -dp 3001:3000 --name todonetmysql -w /app -v ${PWD}:/app --network todo-net -e MYSQL_HOST=mysqlnet -e MYSQL_USER=root -e MYSQL_PASSWORD=secret -e MYSQL_DB=todos node:12-alpine sh -c "yarn install && yarn run dev"

# Runs a bind mount container (Dev mode), when using this command, there's no need to exec build command.
# docker run -dp 3001:3000 --name todolocal -w /app -v ${PWD}:/app node:12-alpine sh -c "yarn install && yarn run dev"