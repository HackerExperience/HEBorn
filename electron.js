'use strict'

// to test this  on dev, uncomment the lines 23:27 at `static/main.js` and use
// these environment variables before running `make app`:
//
//  HEBORN_API_HTTP_URL="https://localhost:4000/v1"
//  HEBORN_API_WEBSOCKET_URL="wss://localhost:4000/websocket"

const packager = require('electron-packager')
const fs = require('fs-extra')
const path = require('path')

const options = {
  dir: "build",
  platform: "all",
  arch: "all",
  overwrite: true,
  out: "dist",
  executableName: "Hacker Experience 2",
  afterCopy: [
    (buildPath, electronVersion, platform, arch, done) => {
      // workaround to move files to a visible place
      const promises =
        ["fonts", "images", "favicon.ico"]
          .map(file => {
            const from = path.join(buildPath, file)
            const to = path.join(buildPath, "..", file)

            return fs.move(from, to, {overwrite: true})
          })

      Promise.all(promises).then(() => done())
    }
  ]
}

packager(options)
  .then(paths =>
    paths.forEach(path =>
      console.log("Wrote new app to `" + path +"`")))
