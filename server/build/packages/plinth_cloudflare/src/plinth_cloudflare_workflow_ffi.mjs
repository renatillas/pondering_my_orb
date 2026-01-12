import { Ok, Error, toBitArray } from "./gleam.mjs";


export function run(f, event, step) {
  return f(event, step)
}

export async function do_(step, name, config, callback) {
  return await step.do(name, config, callback)
}

export function sleep(step, name, duration) {
  return step.sleep(name, duration)
}

export function sleep_until(step, name, timestamp) {
  return step.sleepUntil(name, timestamp)
}

export async function wait_for_event(step, name, options) {
  try {
    return new Ok(await step.waitForEvent(name, options))
  } catch (reason) {
    return new Error(`${reason}`)
  }
}

export function create(workflow, options) {
  return workflow.create(options)
}

export function create_batch(workflow, options) {
  return workflow.createBatch(options)
}

export async function get(workflow, id) {
  try {
    // Throws an exception if the instance ID does not exist.
    return new Ok(await workflow.get(id))
  } catch (reason) {
    return new Error(`${reason}`)
  }
}

export function id(instance){
  return instance.id
}

export function status(instance){
  return instance.status()
}

export function pause(instance){
  return instance.pause()
}
export function resume(instance){
  return instance.resume()
}
export function restart(instance){
  return instance.restart()
}
export function terminate(instance){
  return instance.terminate()
}

export async function send_event(instance, event){
  return await instance.sendEvent(event)
}