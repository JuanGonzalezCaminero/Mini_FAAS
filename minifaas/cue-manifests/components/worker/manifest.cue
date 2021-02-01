package worker

import k "kumori.systems/kumori/kmv"

#Manifest:  k.#ComponentManifest & {

  ref: {
    domain: "kumori.systems.examples"
    name: "minifaasworker"
    version: [0,0,1]
  }

  description: {

    srv: {
      client: workernatsclient: {
        protocol: "tcp"
      }

      client: workerdatabaseclient: {
        protocol: "tcp"
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

    code: worker: k.#Container & {
      name: "worker"
      image: {
        hub: {
          name: "registry.hub.docker.com"
          secret: ""
        }
        //tag: "juangonzalezcaminero/simple_worker_test:0.0.4"
        tag: "juangonzalezcaminero/faas_worker:0.0.14"
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