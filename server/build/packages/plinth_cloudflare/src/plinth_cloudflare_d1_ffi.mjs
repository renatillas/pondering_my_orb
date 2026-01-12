import { Ok, Error } from "./gleam.mjs";

export function prepare(db, query) {
  return db.prepare(query);
}

export function bind(statement, values) {
  return statement.bind(...values);
}

export async function run(statement) {
  try {
    return new Ok(await statement.run());
  } catch (error) {
    return new Error(`${error}`);
  }
}

export async function raw(statement) {
  try {
    return new Ok(await statement.raw());
  } catch (error) {
    return new Error(`${error}`);
  }
}

export async function first(statement) {
  try {
    return new Ok(await statement.first());
  } catch (error) {
    return new Error(`${error}`);
  }
}

export async function batch(db, statements) {
  try {
    return new Ok(await db.batch(statements));
  } catch (error) {
    return new Error(`${error}`);
  }
}

export async function exec(db, query) {
  try {
    return new Ok(await db.exec(query));
  } catch (error) {
    return new Error(`${error}`);
  }
}