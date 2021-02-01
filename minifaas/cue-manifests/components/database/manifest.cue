package database

import k "kumori.systems/kumori/kmv"

#Manifest : k.#ComponentManifest & {

  ref: {
    domain: "kumori.systems.examples"
    name: "minifaasdatabase"
    version: [0,0,1]
  }

  description: {

    srv: {
      duplex: databaseserver: {
        protocol: "tcp"
        port:     26257
      }
    }

    config: {
      resource: {}
      parameter: {}
    }

    size: {
      $_memory: *"1000Mi" | uint
      $_cpu: *"100m" | uint
    }

    code: database: k.#Container & {
      name: "database"
      image: {
        hub: {
          name: "registry.hub.docker.com"
          secret: ""
        }
        tag: "juangonzalezcaminero/custom_cockroachdb:latest"
      }
      mapping: {
        filesystem: []
        env: {}
      }
    }
  }
}
