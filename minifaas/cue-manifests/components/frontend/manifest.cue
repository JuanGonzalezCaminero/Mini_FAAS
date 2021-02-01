package frontend

import k "kumori.systems/kumori/kmv"

#Manifest : k.#ComponentManifest & {

  ref: {
    domain: "kumori.systems.examples"
    name: "minifaasfe"
    version: [0,0,1]
  }

  description: {

    srv: {
      server: entrypoint: {
        protocol: "http"
        port:     8080
      }

      client: restnatsclient: {
        protocol: "tcp"
      }
      
      client: restdatabaseclient: {
        protocol: "tcp"
      }
    }

    config: {
      resource: {}
      parameter: {
        config: {
          param_one : string | *"default_param_one"
          param_two : number | *"default_param_two"
        }
        restapiclientPortEnv: string | *"80"
      }
    }

    size: {
      $_memory: *"100Mi" | uint
      $_cpu: *"100m" | uint
    }

    code: frontend: k.#Container & {
      name: "frontend"
      image: {
        hub: {
          name: "registry.hub.docker.com"
          secret: ""
        }
        //tag: "juangonzalezcaminero/simple_rest_test:0.0.4"
        tag: "juangonzalezcaminero/faas_frontend:0.0.14"
      }
      mapping: {
        filesystem: [
          {
            path: "/config/config.json"
            data: config.parameter.config
            format: "json"
          },
        ]
        env: {
          RESTAPICLIENT_PORT_ENV: config.parameter.restapiclientPortEnv
          SERVER_PORT_ENV: "\(srv.server.entrypoint.port)"
        }
      }
    }
  }
}
