# IOH NestJS Microservices (Backbone)

## Get started Notes:

- Use `git submodule update --init --recursive` command to update/fetch submodules.
- Use `.env.local` file while working on local environment, use `.env.docker` for docker compose environment and use `.env` for production.
- `kong.yml` from `kong/conf/kong.yml` file is configured for api gateway.
- Kong development server endpoint will start on port `8000`.
- Health endpoint: `host:port/api/health`
- Swagger docs endpoint: `host:port/api/docs`

## Run in local

Start core services first (rabbitmq, mongodb, redis)

```bash
yarn dep:up
```

Now go to service folder

```bash
yarn dev
```

To stop core services, run

```bash
yarn dep:down
```

## Run all services in local with docker-compose

```bash
docker compose up
docker compose down
```

To run grafana stack in local

```bash
yarn grafana:up
yarn grafana:down
```

Note: to attach fluent bit container with service container make sure that you enable logging configuration in docker-compose.yml file.

## Setup Grafana Dashboard in Local Env

To see the logs on Grafana dashboard, follow below steps.

1. Open the browser and go to http://localhost:3000, use default credentials username "admin" and password "admin" to login.
2. Now, go to http://localhost:3000/datasources and select Loki from Logging and document databases section.
3. Enter http://loki:3100 in URL under HTTP section. We can do this because we are running Loki and Grafana in the same network.
4. loki else you have to enter host IP address and port here, click on Save and Test button from the bottom of the page.
5. Now, go to 3rd tab "Explore" from the left sidebar or http://localhost:3000/explore
6. select containers and run the query. you will see view on your screen.
  