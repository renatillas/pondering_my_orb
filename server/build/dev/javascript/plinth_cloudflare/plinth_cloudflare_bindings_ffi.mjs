import { Ok, Error } from "./gleam.mjs";

export function get(env, key) {
  if (Object.hasOwn(env, key)) {
    return new Ok(env[key])
  } else {
    return new Error()
  }
}

export function cast_to_d1_database(raw) {
  const isDatabase = raw &&
    typeof raw.prepare === 'function' &&
    typeof raw.batch === 'function' &&
    typeof raw.exec === 'function' &&
    typeof raw.withSession === 'function';
  return isDatabase ? new Ok(raw) : new Error()
}

export function cast_to_durable_object_namespace(raw) {
  const isNamespace = raw &&
    typeof raw.idFromName === 'function' &&
    typeof raw.newUniqueId === 'function' &&
    typeof raw.idFromString === 'function' &&
    typeof raw.get === 'function' &&
    typeof raw.jurisdiction === 'function';
  return isNamespace ? new Ok(raw) : new Error()
}

export function cast_to_queue(raw) {
  const isQueue = raw &&
    typeof raw.send === 'function' &&
    typeof raw.sendBatch === 'function';
  return isQueue ? new Ok(raw) : new Error()
}


export function cast_to_workflow(raw) {
  const isWorkflow = raw &&
    typeof raw.create === 'function' &&
    typeof raw.createBatch === 'function' &&
    typeof raw.get === 'function';
  return isWorkflow ? new Ok(raw) : new Error()
}

export function cast_to_r2_bucket(raw) {
  const isBucket = raw &&
    typeof raw.get === 'function' &&
    typeof raw.put === 'function' &&
    typeof raw.delete === 'function' &&
    typeof raw.list === 'function';
  return isBucket ? new Ok(raw) : new Error()
}