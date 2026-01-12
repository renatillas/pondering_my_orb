export function send(queue, message, options) {
  return queue.send(message, options)
}

export function send_batch(queue, messages, options) {
  return queue.sendBatch(messages, options)
}

export function queue(batch) {
  return batch.queue
}

export function messages(batch) {
  return batch.messages
}

export function ack_all(batch) {
  return batch.ackAll()
}

export function retry_all(batch, options) {
  return batch.retryAll(options)
}

export function id(message) {
  return message.id
}

export function timestamp(message) {
  return message.timestamp
}

export function body(message) {
  return message.body
}

export function attempts(message) {
  return message.attempts
}

export function ack(message) {
  return message.ack()
}

export function retry(message, options) {
  return message.retry(options)
}