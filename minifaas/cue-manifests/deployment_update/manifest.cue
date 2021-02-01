package minifaas_deployment

import (
  k "kumori.systems/kumori/kmv"
  c "kumori.systems/examples/minifaas/service_nocache:minifaas"
)

#Manifest: k.#MakeDeployment & {

  _params: {
    ref: {
      domain: "kumori.systems.examples"
      name: "minifaasfg"
      version: [0,0,1]
    }

    inservice: c.#Manifest & {
      description: role: frontend: rsize: : 1
      description: role: worker: rsize: : 4
      description: role: nats: rsize: : 1
      description: role: database: rsize: : 1
      description: role: autoscaler: rsize: : 1
    }

    config: {
      parameter: {
        frontend: {
          config: {
            param_one : "myparam_one"
            param_two : 123
          }
          restapiclientPortEnv: "80"
        }
      }
    }
  }
}
