import {Ajax} from "phoenix"

const TIMEOUT = 5_000

export class PhxRequest {
  static get(endpoint) {
    return this.promisify("GET", endpoint, "application/json", null, TIMEOUT)
  }

  static post(endpoint, body) {
    return this.promisify("POST", endpoint, "application/json", body, TIMEOUT)
  }

  static delete(endpoint, body) {
    return this.promisify("DELETE", endpoint, "application/json", body, TIMEOUT)
  }

  static promisify(...args) {
    return new Promise((resolve, reject) => {
      Ajax.request(args[0], args[1], args[2], args[3], args[4], reject, resolve)
    })
  }
}