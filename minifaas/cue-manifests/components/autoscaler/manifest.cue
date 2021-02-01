package autoscaler

import k "kumori.systems/kumori/kmv"

#Manifest:  k.#ComponentManifest & {

  ref: {
    domain: "kumori.systems.examples"
    name: "minifaasautoscaler"
    version: [0,0,1]
  }

  description: {

    srv: {
    }

    config: {
      resource: {}
      parameter: {}
    }

    size: {
      $_memory: *"100Mi" | uint
      $_cpu: *"100m" | uint
    }

    code: autoscaler: k.#Container & {
      name: "autoscaler"
      image: {
        hub: {
          name: "registry.hub.docker.com"
          secret: ""
        }
        //tag: "juangonzalezcaminero/simple_worker_test:0.0.4"
        tag: "juangonzalezcaminero/faas_autoscaler:0.0.14"
      }
      mapping: {
        filesystem: []
        env: {
          //RESTAPISERVER_PORT_ENV: "\(srv.server.restapiserver.port)"
        }
      }
    }
  }
}