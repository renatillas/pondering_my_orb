import { Ok, Error } from "./gleam.mjs";

export function id_from_name(namespace, name) {
  return namespace.idFromName(name)
}

export function new_unique_id(namespace) {
  return namespace.newUniqueId()
}

export function id_from_string(namespace, id) {
  return namespace.idFromString(id)
}

export function get(namespace, id, options) {
  return namespace.get(id, options)
}

export function jurisdiction(namespace, j) {
  return namespace.jurisdiction(j)
}

export function to_string(id) {
  return id.toString()
}

export function equals(id1, id2) {
  return id1.equals(id2)
}

export function name(id) {
  return id.name
}

export function stub_id(stub) {
  return stub.id
}

export async function rpc(stub, method, args) {
  try {
    return new Ok(await stub[method](...args))
  } catch (error) {
    return new Error(`${error}`)
  }
}

export function block_concurrency_while(state, f) {
  return state.blockConcurrencyWhile(f)
}

export function state_id(state) {
  return state.id
}

export function storage(state) {
  return state.storage
}

export function sql(storage) {
  return storage.sql
}

export function exec(sql, query, bindings) {
  return sql.exec(query, ...bindings)
}

export function database_size(sql) {
  return sql.databaseSize;
}

export async function get_one(storage, key, options) {
  const value = await storage.get(key, options)
  if (value == undefined) {
    return new Error()
  } else {
    return new Ok(value)
  }
}

export function get_many(storage, keys, options) {
  return storage.get(keys, options)
}

export function put_one(storage, key, value, options) {
  return storage.put(key, value, options)
}

export async function get_alarm(storage) {
  const alarm = await storage.getAlarm()
  if (alarm == null) {
    return new Error()
  } else {
    return new Ok(alarm)
  }
}

export function set_alarm(storage, scheduled_time) {
  return storage.setAlarm(scheduled_time)
}

export function delete_alarm(storage) {
  return storage.deleteAlarm()
}

export async function await_(p, then) {
  const value = await p
  return then(value)
}

export function resolve(value) {
  return Promise.resolve(value)
}

export function id(value) {
  return value
}