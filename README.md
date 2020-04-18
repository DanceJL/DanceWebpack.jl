# DanceWebpack

Plugin to integrate Webpack and NodeJS environment into DanceJL project.

| **Build Status**                                       |
|:------------------------------------------------------:|
| [![Build Status](https://travis-ci.com/DanceJL/DanceWebpack.jl.svg?branch=master)](https://travis-ci.com/DanceJL/DanceWebpack.jl)  [![codecov](https://codecov.io/gh/DanceJL/DanceWebpack.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/DanceJL/DanceWebpack.jl)|

## 1 - Introduction

Well structured frontend environment is crucial for any modern website, to make best use of responsive layouts or simply have more SEO optimised behaviour.

That said taking advantage of Webpack, DanceWebpack:

- Allows Dance to serve minified production files (separate CSS and JS files). Files saved to `static/dist` directory of your Dance app.
- Uses `webpack-dev-server` on node port 3000 in development mode, in order to take advantage of `Hot Module Replacement` (no need refresh page to see changes).
- Supports `css`, `scss`, `sass` and `js` file formats.
- Supports ES6 style Javascript.
- Comes pre-configured with Bootstrap4 and jQuery.
- Pre-configured Javascript linting checker before creating Webpack bundle.
- Supports Webpack bundling (chunks and asynchronous loading).

Supplied Webpack integration is for very generic frontend environment: `css`, `scss`, `sass` and `js` files without any framework.
If you are using a frontend framework (e.g VueJS) for project, better rely on more specific Webpack integration directly offered by the framework.

That said **aim of DanceWebpack is to take away abstraction in setting up frontend environment for average web developer not specialised in any frontend framework**. 

---

## 2 - Installation

Package can be installed with Julia's package manager, either by using Pkg REPL mode (*press ]*):

```
pkg> add https://github.com/DanceJL/DanceWebpack.jl
```

or by using Pkg functions

```julia
julia> using Pkg; Pkg.add(Pkg.PackageSpec(url="https://github.com/DanceJL/DanceWebpack.jl"))
```

Compatibility is with Julia 1.1 and Dance 0.0.1 upward.

## 3 - Setup

**Please make sure NodeJS is installed on your system.**

If using Linux or MacOS your package manager should easily allow this.
For Windows please download installer from [NodeJS project web page](https://nodejs.org).

### 3.1 - File Generation

Invoke terminal in project root directory and run:

```julia
using DanceWebpack
setup()
```

If project base html template not located at `html/base.html`, please specify location relative to project root in command.
For example:

```julia
using DanceWebpack
setup(html_base_file_path="web/html/base.html")
```

As output of running above will suggest, please cd into `static` dir and run `npm install` thereafter to set up NodeJS packages.

### 3.2 - Package.json Metadata

Note that depending on whether `authors`, `name` and `version` are specified in `Project.toml`, corresponding values in `static/package.json` will be automatically filled-in.

If not is case, values will simply be left blank.

## 4 - NodeJS Integration

Setup will create `src/js/main.js` and `src/css/main.css` files, which serve as boilerplate for you to add custom styling and logic.

As you can see in `src/js/main.js` as well as `dependencies` section of `package.json`, Bootstrap4 and jQuery come pre-configured.

Any other required NodeJS packages can be installed by running:

```
npm add <package name>
```

### 4.1 - Structure

Javascript and CSS styling logic can be broken down into smaller module files.
These files are then loaded into `src/js/main.js` and `src/css/main.css`, where import path is relative to `src/js/main.js` and `src/css/main.css`.

In case of `css`, `scss` or `sass` files, under `src/css/main.css` add:

```
@import "base/page";
```

In case of `js` file, under `src/js/main.js` add:

```
import "./chat";
```

#### 4.1.1 - Static Files

One can also add media files under `src`. Supported formats are:

- `png`, `svg`, `jpg`, `jpeg`, `gif` for images
- `woff`, `woff2`, `eot`, `ttf`, `otf` for fonts

That said in order to take best advantage of Webpack bundling, it is recommended to serve all static files (images, fonts) via Javascript `require` calls.
Let Webpack optimise bundling process!

#### 4.1.2 - Lazy Loading 

Lazy-loading is also supported.
This means that browser will fetch resources only when required, speeding-up page loads.

As an example, consider chat integration via a button.
With demo code below, chat functionality will only be fetched by browser once user clicks button.

```javascript
$('#js-button').click(function() {
  import("./chat").then(chat => {
    chat.init()
  })
});
```

### 4.2 - Serving Webpack Bundle

When compiling Webpack bundle, DanceWebpack will automatically add `<script>` and `<link rel="stylesheet">` HTML tags to project's project base html template.

That said please understand difference between development and productions modes, explained here below.

#### 4.2.1 -  Development Mode

From `static` directory run:

```
npm run develop
```

Static files will be served via Node server web socket on port 3000.
Source maps will also be supplied, allowing you to easily debug eventual errors.

Any changes you make to static files will automatically be sent to browser via `webpack-dev-server`'s `Hot Module Replacement`.
If working with framework such as ReactJS or VueJS, state of page will be conserved during process.

**Save time without re-compiling and reloading page!**

#### 4.2.2  Production Mode

From `static` directory run:

```
npm run build
```

This will output minified files to `static/dist` dir of your project.
Source maps are not supplied.

Please start Dance web server in production mode to serve these static assets.

### 4.3 - Javascript Linting

Running `npm run develop` and `npm run build` will automatically check your Javascript files for errors.
This is particularly useful when having to debug Javascript of a running web app in the browser.

After linter outputs errors, easy fixes can be applied by running:

```
npm run lint:fix
```

Running `npm run develop` or `npm run build` again will warn of any persisting errors that you will need to manually fix.
