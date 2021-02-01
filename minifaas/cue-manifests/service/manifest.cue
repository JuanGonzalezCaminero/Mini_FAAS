package minifaas

import (
  k         "kumori.systems/kumori/kmv"
  frontend  "kumori.systems/examples/minifaas/components/frontend"
  worker    "kumori.systems/examples/minifaas/components/worker"
  nats      "kumori.systems/examples/minifaas/components/nats"
  database  "kumori.systems/examples/minifaas/components/database"
  autoscaler  "kumori.systems/examples/minifaas/components/autoscaler"
)

let mefrontend = frontend.#Manifest
let meworker = worker.#Manifest
let menats = nats.#Manifest
let medatabase = database.#Manifest
let meautoscaler = autoscaler.#Manifest

#Manifest: k.#ServiceManifest & {

  ref: {
    domain: "kumori.systems.examples"
    name: "minifaas"
    version: [0,0,1]
  }

  description: {

    srv: {
      server: {
        service: {
          protocol: "http"
          port: 80
        }
      }
    }

    config: {
      parameter: {
        frontend  : mefrontend.description.config.parameter
        worker    : meworker.description.config.parameter
        nats      : menats.description.config.parameter
        database  : medatabase.description.config.parameter
        autoscaler  : meautoscaler.description.config.parameter
      }
      resource: mefrontend.description.config.resource
    }

    // Config spread
    role: {
      frontend: k.#Role
      frontend: artifact: mefrontend
      frontend: cfg: parameter: config.parameter.frontend

      worker: k.#Role
      worker: artifact: meworker
      worker: cfg: parameter: config.parameter.worker

      nats: k.#Role
      nats: artifact: menats
      nats: cfg: parameter: config.parameter.nats

      database: k.#Role
      database: artifact: medatabase
      database: cfg: parameter: config.parameter.database

      autoscaler: k.#Role
      autoscaler: artifact: meautoscaler
      autoscaler: cfg: parameter: config.parameter.autoscaler
    }

    connector: {
      serviceconnector: {kind: "lb"}
      lbconnector:      {kind: "lb"}
      fullconnectorrestnats:    {kind: "full"}
      fullconnectorworkernats:    {kind: "full"}

      fullconnectorrestdatabase:    {kind: "full"}
      fullconnectorworkerdatabase:    {kind: "full"}
    }

    link: {

      // Outside -> FrontEnd (LB connector)
			self: service: to: "serviceconnector"
      serviceconnector: to: frontend: "entrypoint"

      frontend: restnatsclient: to: "fullconnectorrestnats"
      fullconnectorrestnats: to: nats: "natsserver"
      fullconnectorworkernats: to: nats: "natsserver"
      worker: workernatsclient: to: "fullconnectorworkernats"

      frontend: restdatabaseclient: to: "fullconnectorrestdatabase"
      fullconnectorrestdatabase: to: database: "databaseserver"
      fullconnectorworkerdatabase: to: database: "databaseserver"
      worker: workerdatabaseclient: to: "fullconnectorworkerdatabase"
   }
  }
}