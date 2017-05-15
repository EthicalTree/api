# EthicalTree

Welcome to EthicalTree! It's great to have you on board :)

The web application is built with a mish-mash of the following technologies:

### Rails

We use Ruby on Rails as both an API and minimal container that serves the basic web layer.
Eventually we will replace this with a Node/Express server for the benefit of server side React
rendering.

### Webpack / React

The entire client is a React app built with webpack. We also use react-hot-loader for hot reloading
during development. This means that we run `webpack-dev-server` which will transpile all assets and
serve them from memory.

### ES6 & JSX

ES5 is so 2005. We use Babel for transpiling in our webpack pipeline.

### Postgres SQL

Just your typical relational database


## Installation

This installation assumes you have installed:

- `ruby 2.3.3`
- `node 7.X`
- `psql`

```
bundle
npm install
```

## Running

#### Terminal 1

```
npm run server
```

#### Terminal 2

```
npm run webpack
```
