import * as $promise from "../../../gleam_javascript/gleam/javascript/promise.mjs";
import * as $dynamic from "../../../gleam_stdlib/gleam/dynamic.mjs";
import * as $decode from "../../../gleam_stdlib/gleam/dynamic/decode.mjs";
import * as $option from "../../../gleam_stdlib/gleam/option.mjs";
import * as $string from "../../../gleam_stdlib/gleam/string.mjs";
import { getCurrentPosition as get_current_position } from "../../geolocation_ffi.mjs";
import { Ok, Error, CustomType as $CustomType } from "../../gleam.mjs";
import * as $decodex from "../../plinth/decodex.mjs";

export { get_current_position };

export class GeolocationPosition extends $CustomType {
  constructor(latitude, longitude, altitude, accuracy, altitude_accuracy, heading, speed, timestamp) {
    super();
    this.latitude = latitude;
    this.longitude = longitude;
    this.altitude = altitude;
    this.accuracy = accuracy;
    this.altitude_accuracy = altitude_accuracy;
    this.heading = heading;
    this.speed = speed;
    this.timestamp = timestamp;
  }
}
export const GeolocationPosition$GeolocationPosition = (latitude, longitude, altitude, accuracy, altitude_accuracy, heading, speed, timestamp) =>
  new GeolocationPosition(latitude,
  longitude,
  altitude,
  accuracy,
  altitude_accuracy,
  heading,
  speed,
  timestamp);
export const GeolocationPosition$isGeolocationPosition = (value) =>
  value instanceof GeolocationPosition;
export const GeolocationPosition$GeolocationPosition$latitude = (value) =>
  value.latitude;
export const GeolocationPosition$GeolocationPosition$0 = (value) =>
  value.latitude;
export const GeolocationPosition$GeolocationPosition$longitude = (value) =>
  value.longitude;
export const GeolocationPosition$GeolocationPosition$1 = (value) =>
  value.longitude;
export const GeolocationPosition$GeolocationPosition$altitude = (value) =>
  value.altitude;
export const GeolocationPosition$GeolocationPosition$2 = (value) =>
  value.altitude;
export const GeolocationPosition$GeolocationPosition$accuracy = (value) =>
  value.accuracy;
export const GeolocationPosition$GeolocationPosition$3 = (value) =>
  value.accuracy;
export const GeolocationPosition$GeolocationPosition$altitude_accuracy = (value) =>
  value.altitude_accuracy;
export const GeolocationPosition$GeolocationPosition$4 = (value) =>
  value.altitude_accuracy;
export const GeolocationPosition$GeolocationPosition$heading = (value) =>
  value.heading;
export const GeolocationPosition$GeolocationPosition$5 = (value) =>
  value.heading;
export const GeolocationPosition$GeolocationPosition$speed = (value) =>
  value.speed;
export const GeolocationPosition$GeolocationPosition$6 = (value) => value.speed;
export const GeolocationPosition$GeolocationPosition$timestamp = (value) =>
  value.timestamp;
export const GeolocationPosition$GeolocationPosition$7 = (value) =>
  value.timestamp;

export function decoder() {
  return $decode.field(
    "timestamp",
    $decodex.float_or_int(),
    (timestamp) => {
      return $decode.field(
        "coords",
        $decode.field(
          "latitude",
          $decodex.float_or_int(),
          (latitude) => {
            return $decode.field(
              "longitude",
              $decodex.float_or_int(),
              (longitude) => {
                return $decode.field(
                  "altitude",
                  $decode.optional($decodex.float_or_int()),
                  (altitude) => {
                    return $decode.field(
                      "accuracy",
                      $decodex.float_or_int(),
                      (accuracy) => {
                        return $decode.field(
                          "altitudeAccuracy",
                          $decode.optional($decodex.float_or_int()),
                          (altitude_accuracy) => {
                            return $decode.field(
                              "heading",
                              $decode.optional($decodex.float_or_int()),
                              (heading) => {
                                return $decode.field(
                                  "speed",
                                  $decode.optional($decodex.float_or_int()),
                                  (speed) => {
                                    return $decode.success(
                                      new GeolocationPosition(
                                        latitude,
                                        longitude,
                                        altitude,
                                        accuracy,
                                        altitude_accuracy,
                                        heading,
                                        speed,
                                        timestamp,
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
        (n) => { return $decode.success(n); },
      );
    },
  );
}

export function current_position() {
  return $promise.new$(
    (resolve) => {
      return get_current_position(
        (position) => {
          let _block;
          let $ = $decode.run(position, decoder());
          if ($ instanceof Ok) {
            _block = $;
          } else {
            let reason = $[0];
            _block = new Error($string.inspect(reason));
          }
          let _pipe = _block;
          return resolve(_pipe);
        },
        (error) => { return resolve(new Error($string.inspect(error))); },
      );
    },
  );
}
