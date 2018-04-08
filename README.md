# 🎉 EthicalTree API 🎉

[![EthicalTree Project](https://img.shields.io/badge/site-EthicalTree-blue.svg)](https://ethicaltree.com)

## Prerequisites

Add the following entries to your `/etc/hosts` file:

```
127.0.0.1  api.ethicaltree.local
127.0.0.1  ethicaltree.local
127.0.0.1  cdn.ethicaltree.local
```

Install:

- [Docker](https://docs.docker.com/install/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Running

```
docker-compose up
```

Then to make sure things are working:

```
curl api.ethicaltree.local:3001/v1/ethicalities
```

should return a json blob of data

## Database

Docker compose will automatically create your database in the `./db-data` directory. If you ever remove that directory then you will lose all your local data.

