package nats

import k "kumori.systems/kumori/kmv"

#Manifest : k.#ComponentManifest & {

  ref: {
    domain: "kumori.systems.examples"
    name: "minifaasnats"
    version: [0,0,1]
  }

  description: {

    srv: {
      duplex: natsserver: {
        protocol: "tcp"
        port:     4222
      }
    }

    config: {
      resource: {}
      parameter: {}
    }

    size: {
      $_memory: *"100Mi" | uint
      $_cpu: *"100m" | uint
    }

    code: nats: k.#Container & {
      name: "nats"
      image: {
        hub: {
          name: "registry.hub.docker.com"
          secret: ""
        }
        tag: "library/nats:latest"
      }
      mapping: {
        filesystem: []
        env: {}
      }
    }
  }
}
