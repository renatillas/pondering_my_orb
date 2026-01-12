/**
 * ThreeJS FFI - Pure 1:1 bindings to Three.js library
 *
 * This module provides direct, minimal wrappers around Three.js API calls.
 *
 * All higher-level logic should be in the Gleam declarative layer.
 */

import * as THREE from 'three';
import { CSS2DRenderer, CSS2DObject } from 'three/addons/renderers/CSS2DRenderer.js';
import { CSS3DRenderer, CSS3DObject } from 'three/addons/renderers/CSS3DRenderer.js';
import { TextGeometry } from 'three/addons/geometries/TextGeometry.js';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
import { FontLoader } from 'three/addons/loaders/FontLoader.js';
import { OBJLoader } from 'three/addons/loaders/OBJLoader.js';
import { STLLoader } from 'three/addons/loaders/STLLoader.js';
import { FBXLoader } from 'three/addons/loaders/FBXLoader.js';

import { Result$Ok, Result$Error } from './gleam.mjs';
import { Vec3$Vec3 } from '../vec/vec/vec3.mjs';
import { Vec2$Vec2, Vec2$Vec2$x, Vec2$Vec2$y } from '../vec/vec/vec2.mjs';
import { Option$isSome, Option$Some$0 } from '../gleam_stdlib/gleam/option.mjs';
import { Quaternion$Quaternion } from '../quaterni/quaternion.mjs';


// ============================================================================
// CORE - Scene, Renderer, Camera
// ============================================================================

/**
 * Create a Three.js Scene
 * @returns {THREE.Scene}
 */
export function createScene() {
  return new THREE.Scene();
}

/**
 * Set scene background color
 * @param {THREE.Scene} scene
 * @param {number} color - Hex color
 */
export function setSceneBackgroundColor(scene, color) {
  scene.background = new THREE.Color(color);
}

/**
 * Set scene background texture
 * @param {THREE.Scene} scene
 * @param {THREE.Texture} texture
 */
export function setSceneBackgroundTexture(scene, texture) {
  scene.background = texture;
}

/**
 * Set scene background cube texture (skybox)
 * @param {THREE.Scene} scene
 * @param {THREE.CubeTexture} cubeTexture
 */
export function setSceneBackgroundCubeTexture(scene, cubeTexture) {
  scene.background = cubeTexture;
}

/**
 * Get the current canvas dimensions from the renderer
 * @param {THREE.WebGLRenderer} renderer
 * @returns {[number, number]} [width, height] as a tuple
 */
export function getCanvasDimensions(renderer) {
  const canvas = renderer.domElement;
  return Vec2$Vec2(canvas.clientWidth, canvas.clientHeight);
}

/**
 * Create a WebGLRenderer
 * @param {Object} options - {antialias: boolean, alpha: boolean, dimensions: Option<{width, height}>}
 * @returns {THREE.WebGLRenderer}
 */
export function createRenderer(options) {
  const renderer = new THREE.WebGLRenderer({
    antialias: options.antialias,
    alpha: options.alpha
  });
  renderer.shadowMap.enabled = true;
  renderer.shadowMap.type = THREE.PCFSoftShadowMap;

  // Set renderer size based on dimensions or fullscreen
  const is_some = Option$isSome(options.dimensions);
  if (is_some) {
    const dimensions = Option$Some$0(options.dimensions)
    // Fixed size
    renderer.setSize(Vec2$Vec2$x(dimensions), Vec2$Vec2$y(dimensions));
    renderer.setPixelRatio(window.devicePixelRatio || 1);
  } else {
    // Fullscreen mode
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setPixelRatio(window.devicePixelRatio || 1);
  }

  return renderer;
}

/**
 * Set renderer size
 * @param {THREE.WebGLRenderer} renderer
 * @param {number} width
 * @param {number} height
 */
export function setRendererSize(renderer, width, height) {
  renderer.setSize(width, height);
}

/**
 * Set renderer pixel ratio
 * @param {THREE.WebGLRenderer} renderer
 * @param {number} ratio
 */
export function setRendererPixelRatio(renderer, ratio) {
  renderer.setPixelRatio(ratio);
}

/**
 * Get renderer DOM element (canvas)
 * @param {THREE.WebGLRenderer} renderer
 * @returns {HTMLCanvasElement}
 */
export function getRendererDomElement(renderer) {
  return renderer.domElement;
}

/**
 * Get canvas client width (CSS width)
 * @param {HTMLCanvasElement} canvas
 * @returns {number}
 */
export function getCanvasClientWidth(canvas) {
  return canvas.clientWidth;
}

/**
 * Get canvas client height (CSS height)
 * @param {HTMLCanvasElement} canvas
 * @returns {number}
 */
export function getCanvasClientHeight(canvas) {
  return canvas.clientHeight;
}

/**
 * Render a scene with camera
 * @param {THREE.WebGLRenderer} renderer
 * @param {THREE.Scene} scene
 * @param {THREE.Camera} camera
 */
export function render(renderer, scene, camera) {
  renderer.render(scene, camera);
}

/**
 * Clear the renderer
 * @param {THREE.WebGLRenderer} renderer
 */
export function clearRenderer(renderer) {
  renderer.clear();
}

/**
 * Set viewport
 * @param {THREE.WebGLRenderer} renderer
 * @param {number} x
 * @param {number} y
 * @param {number} width
 * @param {number} height
 */
export function setViewport(renderer, x, y, width, height) {
  renderer.setViewport(x, y, width, height);
}

/**
 * Set scissor
 * @param {THREE.WebGLRenderer} renderer
 * @param {number} x
 * @param {number} y
 * @param {number} width
 * @param {number} height
 */
export function setScissor(renderer, x, y, width, height) {
  renderer.setScissor(x, y, width, height);
}

/**
 * Enable/disable scissor test
 * @param {THREE.WebGLRenderer} renderer
 * @param {boolean} enabled
 */
export function setScissorTest(renderer, enabled) {
  renderer.setScissorTest(enabled);
}

/**
 * Get renderer info for stats
 * @param {THREE.WebGLRenderer} renderer
 * @returns {Object}
 */
export function getRendererInfo(renderer) {
  return renderer.info;
}

/**
 * Get render stats (draw calls and triangles) from renderer
 * @param {THREE.WebGLRenderer} renderer
 * @returns {[number, number]} [drawCalls, triangles]
 */
export function getRenderStats(renderer) {
  const info = renderer.info;
  return [
    info.render?.calls || 0,
    info.render?.triangles || 0,
  ];
}

/**
 * Check if WebGL context is valid
 * @param {THREE.WebGLRenderer} renderer
 * @returns {boolean}
 */
export function isContextValid(renderer) {
  const gl = renderer.getContext();
  return gl && !gl.isContextLost();
}

// ============================================================================
// CAMERAS
// ============================================================================

/**
 * Create a perspective camera
 * @param {number} fov - Field of view in degrees
 * @param {number} aspect - Aspect ratio
 * @param {number} near - Near clipping plane
 * @param {number} far - Far clipping plane
 * @returns {THREE.PerspectiveCamera}
 */
export function createPerspectiveCamera(fov, aspect, near, far) {
  return new THREE.PerspectiveCamera(fov, aspect, near, far);
}

/**
 * Create an orthographic camera
 * @param {number} left
 * @param {number} right
 * @param {number} top
 * @param {number} bottom
 * @param {number} near
 * @param {number} far
 * @returns {THREE.OrthographicCamera}
 */
export function createOrthographicCamera(left, right, top, bottom, near, far) {
  const camera = new THREE.OrthographicCamera(left, right, top, bottom, near, far);
  // Store original bounds as custom properties for aspect ratio preservation during resize
  camera._originalLeft = left;
  camera._originalRight = right;
  camera._originalTop = top;
  camera._originalBottom = bottom;
  return camera;
}

/**
 * Update camera projection matrix
 * @param {THREE.Camera} camera
 */
export function updateProjectionMatrix(camera) {
  camera.updateProjectionMatrix();
}

/**
 * Set camera aspect ratio
 * @param {THREE.PerspectiveCamera} camera
 * @param {number} aspect
 */
export function setCameraAspect(camera, aspect) {
  camera.aspect = aspect;
}

/**
 * Set camera to look at a point
 * @param {THREE.Camera} camera
 * @param {Vec3} target
 */
export function cameraLookAt(camera, target) {
  camera.updateMatrixWorld(true);
  camera.lookAt(target.x, target.y, target.z);
}

// ============================================================================
// GEOMETRIES
// ============================================================================

/**
 * Create box geometry
 * @param {number} width
 * @param {number} height
 * @param {number} depth
 * @returns {THREE.BoxGeometry}
 */
export function createBoxGeometry(width, height, depth) {
  return new THREE.BoxGeometry(width, height, depth);
}

/**
 * Create sphere geometry
 * @param {number} radius
 * @param {number} widthSegments
 * @param {number} heightSegments
 * @returns {THREE.SphereGeometry}
 */
export function createSphereGeometry(radius, widthSegments, heightSegments) {
  return new THREE.SphereGeometry(radius, widthSegments, heightSegments);
}

/**
 * Create cone geometry
 * @param {number} radius
 * @param {number} height
 * @param {number} segments
 * @returns {THREE.ConeGeometry}
 */
export function createConeGeometry(radius, height, segments) {
  return new THREE.ConeGeometry(radius, height, segments);
}

/**
 * Create plane geometry
 * @param {number} width
 * @param {number} height
 * @param {number} widthSegments
 * @param {number} heightSegments
 * @returns {THREE.PlaneGeometry}
 */
export function createPlaneGeometry(
  width,
  height,
  widthSegments,
  heightSegments,
) {
  return new THREE.PlaneGeometry(width, height, widthSegments, heightSegments);
}

/**
 * Create circle geometry
 * @param {number} radius
 * @param {number} segments
 * @returns {THREE.CircleGeometry}
 */
export function createCircleGeometry(radius, segments) {
  return new THREE.CircleGeometry(radius, segments);
}

/**
 * Create cylinder geometry
 * @param {number} radiusTop
 * @param {number} radiusBottom
 * @param {number} height
 * @param {number} radialSegments
 * @returns {THREE.CylinderGeometry}
 */
export function createCylinderGeometry(radiusTop, radiusBottom, height, radialSegments) {
  return new THREE.CylinderGeometry(radiusTop, radiusBottom, height, radialSegments);
}

/**
 * Create torus geometry
 * @param {number} radius
 * @param {number} tube
 * @param {number} radialSegments
 * @param {number} tubularSegments
 * @returns {THREE.TorusGeometry}
 */
export function createTorusGeometry(radius, tube, radialSegments, tubularSegments) {
  return new THREE.TorusGeometry(radius, tube, radialSegments, tubularSegments);
}

/**
 * Create tetrahedron geometry
 * @param {number} radius
 * @param {number} detail
 * @returns {THREE.TetrahedronGeometry}
 */
export function createTetrahedronGeometry(radius, detail) {
  return new THREE.TetrahedronGeometry(radius, detail);
}

/**
 * Create icosahedron geometry
 * @param {number} radius
 * @param {number} detail
 * @returns {THREE.IcosahedronGeometry}
 */
export function createIcosahedronGeometry(radius, detail) {
  return new THREE.IcosahedronGeometry(radius, detail);
}


/**
 * Create text geometry
 * @param {string} text - The text to render
 * @param {Font} font - The loaded font
 * @param {number} size - Text size
 * @param {number} depth - Extrusion depth (3D thickness)
 * @param {number} curveSegments - Number of points on curves
 * @param {boolean} bevelEnabled - Enable beveling
 * @param {number} bevelThickness - Bevel depth
 * @param {number} bevelSize - Bevel extension distance
 * @param {number} bevelOffset - Bevel start offset
 * @param {number} bevelSegments - Number of bevel segments
 * @returns {THREE.BufferGeometry}
 */
export function createTextGeometry(
  text,
  font,
  size,
  depth,
  curveSegments,
  bevelEnabled,
  bevelThickness,
  bevelSize,
  bevelOffset,
  bevelSegments
) {
  return new TextGeometry(text, {
    font: font,
    size: size,
    depth: depth,
    curveSegments: curveSegments,
    bevelEnabled: bevelEnabled,
    bevelThickness: bevelThickness,
    bevelSize: bevelSize,
    bevelOffset: bevelOffset,
    bevelSegments: bevelSegments
  });
}

// ============================================================================
// MATERIALS
// ============================================================================

/**
 * Get THREE.FrontSide constant
 * @returns {number}
 */
export function getFrontSide() {
  return THREE.FrontSide;
}

/**
 * Get THREE.BackSide constant
 * @returns {number}
 */
export function getBackSide() {
  return THREE.BackSide;
}

/**
 * Get THREE.DoubleSide constant
 * @returns {number}
 */
export function getDoubleSide() {
  return THREE.DoubleSide;
}

/**
 * Create basic material
 * @param {number} color
 * @param {boolean} transparent
 * @param {number} opacity
 * @param {THREE.Texture|null} map
 * @param {number} side - THREE.js side constant (FrontSide, BackSide, DoubleSide)
 * @param {number} alphaTest
 * @param {boolean} depthWrite
 * @returns {THREE.MeshBasicMaterial}
 */
export function createBasicMaterial(color, transparent, opacity, map, side, alphaTest, depthWrite) {
  return new THREE.MeshBasicMaterial({
    color,
    transparent,
    opacity,
    map: Option$isSome(map) ? Option$Some$0(map) : null,
    side,
    alphaTest,
    depthWrite
  });
}

/**
 * Create standard material
 * @param {number} color
 * @param {number} metalness
 * @param {number} roughness
 * @param {THREE.Texture|null} map
 * @param {THREE.Texture|null} normalMap
 * @param {THREE.Texture|null} aoMap
 * @param {THREE.Texture|null} displacementMap
 * @param {number} displacementScale
 * @param {number} displacementBias
 * @param {THREE.Texture|null} roughnessMap
 * @param {THREE.Texture|null} metalnessMap
 * @returns {THREE.MeshStandardMaterial}
 */
export function createStandardMaterial(
  color,
  metalness,
  roughness,
  transparent,
  opacity,
  map,
  normalMap,
  aoMap,
  displacementMap,
  displacementScale,
  displacementBias,
  roughnessMap,
  metalnessMap,
  emissive,
  emissiveIntensity,
) {
  const validMap = Option$isSome(map) ? Option$Some$0(map) : null;
  const validNormalMap = Option$isSome(normalMap) ? Option$Some$0(normalMap) : null;
  const validAoMap = Option$isSome(aoMap) ? Option$Some$0(aoMap) : null;
  const validDisplacementMap = Option$isSome(displacementMap) ? Option$Some$0(displacementMap) : null;
  const validRoughnessMap = Option$isSome(roughnessMap) ? Option$Some$0(roughnessMap) : null;
  const validMetalnessMap = Option$isSome(metalnessMap) ? Option$Some$0(metalnessMap) : null;

  const material = new THREE.MeshStandardMaterial({
    color,
    metalness,
    roughness,
    transparent,
    opacity,
    map: validMap,
    normalMap: validNormalMap,
    aoMap: validAoMap,
    displacementMap: validDisplacementMap,
    displacementBias,
    displacementScale,
    roughnessMap: validRoughnessMap,
    metalnessMap: validMetalnessMap,
    emissive,
    emissiveIntensity,
  });

  if (validNormalMap) {
    material.normalScale.set(1.0, 1.0);
  }

  return material;
}

/**
 * Create phong material
 * @param {number} color
 * @param {number} shininess
 * @param {THREE.Texture|null} map
 * @param {THREE.Texture|null} normalMap
 * @param {THREE.Texture|null} aoMap
 * @param {boolean} transparent
 * @param {number} opacity
 * @param {number} alphaTest
 * @returns {THREE.MeshPhongMaterial}
 */
export function createPhongMaterial(color, shininess, map, normalMap, aoMap, transparent, opacity, alphaTest) {
  const validMap = Option$isSome(map) ? Option$Some$0(map) : null;
  const validNormalMap = Option$isSome(normalMap) ? Option$Some$0(normalMap) : null;
  const validAoMap = Option$isSome(aoMap) ? Option$Some$0(aoMap) : null;

  const material = new THREE.MeshPhongMaterial({
    color,
    shininess,
    map: validMap,
    normalMap: validNormalMap,
    aoMap: validAoMap,
    transparent,
    opacity,
    alphaTest
  });

  if (validNormalMap) {
    material.normalScale.set(1.0, 1.0);
  }

  return material;
}

/**
 * Create lambert material
 * @param {number} color
 * @param {THREE.Texture|null} map
 * @param {THREE.Texture|null} normalMap
 * @param {THREE.Texture|null} aoMap
 * @returns {THREE.MeshLambertMaterial}
 */
export function createLambertMaterial(color, map, normalMap, aoMap, transparent, opacity, alphaTest) {
  const validMap = Option$isSome(map) ? Option$Some$0(map) : null;
  const validNormalMap = Option$isSome(normalMap) ? Option$Some$0(normalMap) : null;
  const validAoMap = Option$isSome(aoMap) ? Option$Some$0(aoMap) : null;

  const material = new THREE.MeshLambertMaterial({
    color,
    map: validMap,
    normalMap: validNormalMap,
    aoMap: validAoMap,
    transparent,
    opacity,
    alphaTest,
    side: THREE.DoubleSide,
  });

  // Ensure texture is configured for transparency
  if (validMap && transparent) {
    validMap.format = THREE.RGBAFormat;
    validMap.needsUpdate = true;
  }

  if (validNormalMap) {
    material.normalScale.set(1.0, 1.0);
  }

  return material;
}

/**
 * Create toon material
 * @param {number} color
 * @param {THREE.Texture|null} map
 * @param {THREE.Texture|null} normalMap
 * @param {THREE.Texture|null} aoMap
 * @param {boolean} transparent
 * @param {number} opacity
 * @param {number} alphaTest
 * @returns {THREE.MeshToonMaterial}
 */
export function createToonMaterial(color, map, normalMap, aoMap, transparent, opacity, alphaTest) {
  return new THREE.MeshToonMaterial({
    color,
    map: Option$isSome(map) ? Option$Some$0(map) : null,
    normalMap: Option$isSome(normalMap) ? Option$Some$0(normalMap) : null,
    aoMap: Option$isSome(aoMap) ? Option$Some$0(aoMap) : null,
    transparent,
    opacity,
    alphaTest
  });
}

/**
 * Create line material
 * @param {number} color
 * @param {number} linewidth
 * @returns {THREE.LineBasicMaterial}
 */
export function createLineMaterial(color, linewidth) {
  return new THREE.LineBasicMaterial({
    color,
    linewidth
  });
}

/**
 * Create sprite material
 * @param {number} color
 * @param {boolean} transparent
 * @param {number} opacity
 * @param {THREE.Texture|null} map
 * @returns {THREE.SpriteMaterial}
 */
export function createSpriteMaterial(color, transparent, opacity, map) {
  return new THREE.SpriteMaterial({
    color,
    transparent,
    opacity,
    map: Option$isSome(map) ? Option$Some$0(map) : null
  });
}

/**
 * Create point material
 * @param {number} size
 * @param {boolean} vertexColors
 * @param {boolean} transparent
 * @param {number} opacity
 * @param {boolean} depthWrite
 * @param {number} blending
 * @param {boolean} sizeAttenuation
 * @returns {THREE.PointsMaterial}
 */
export function createPointsMaterial(size, vertexColors, transparent, opacity, depthWrite, blending, sizeAttenuation) {
  return new THREE.PointsMaterial({
    size,
    vertexColors,
    transparent,
    opacity,
    depthWrite,
    blending,
    sizeAttenuation
  });
}

// ============================================================================
// LIGHTS
// ============================================================================

/**
 * Create ambient light
 * @param {number} color
 * @param {number} intensity
 * @returns {THREE.AmbientLight}
 */
export function createAmbientLight(color, intensity) {
  return new THREE.AmbientLight(color, intensity);
}

/**
 * Create directional light
 * @param {number} color
 * @param {number} intensity
 * @param {boolean} castShadow
 * @param {number} shadowResolution
 * @param {number} shadowBias
 * @returns {THREE.DirectionalLight}
 */
export function createDirectionalLight(color, intensity, castShadow, shadowResolution, shadowBias, shadowNormalBias, shadowCameraLeft, shadowCameraRight, shadowCameraTop, shadowCameraBottom, shadowCameraNear, shadowCameraFar) {
  const light = new THREE.DirectionalLight(color, intensity);
  light.castShadow = castShadow;

  if (castShadow) {
    light.shadow.mapSize.width = shadowResolution;
    light.shadow.mapSize.height = shadowResolution;
    light.shadow.bias = shadowBias;
    light.shadow.normalBias = shadowNormalBias;
    light.shadow.camera.left = shadowCameraLeft;
    light.shadow.camera.right = shadowCameraRight;
    light.shadow.camera.top = shadowCameraTop;
    light.shadow.camera.bottom = shadowCameraBottom;
    light.shadow.camera.near = shadowCameraNear;
    light.shadow.camera.far = shadowCameraFar;
    light.shadow.camera.updateProjectionMatrix();
  }

  return light;
}

/**
 * Set shadow camera bounds for a directional or spot light
 * @param {THREE.Light} light
 * @param {number} left
 * @param {number} right
 * @param {number} top
 * @param {number} bottom
 * @param {number} near
 * @param {number} far
 */
export function setShadowCameraBounds(light, left, right, top, bottom, near, far) {
  if (light.shadow && light.shadow.camera) {
    light.shadow.camera.left = left;
    light.shadow.camera.right = right;
    light.shadow.camera.top = top;
    light.shadow.camera.bottom = bottom;
    light.shadow.camera.near = near;
    light.shadow.camera.far = far;
    light.shadow.camera.updateProjectionMatrix();
  }
}


/**
 * Create point light
 * @param {number} color
 * @param {number} intensity
 * @param {number} distance
 * @param {boolean} castShadow
 * @param {number} shadowResolution
 * @param {number} shadowBias
 * @returns {THREE.PointLight}
 */
export function createPointLight(color, intensity, distance, castShadow, shadowResolution, shadowBias, shadowNormalBias) {
  const light = new THREE.PointLight(color, intensity, distance);
  light.castShadow = castShadow;

  if (castShadow) {
    light.shadow.mapSize.width = shadowResolution;
    light.shadow.mapSize.height = shadowResolution;
    light.shadow.bias = shadowBias;
    light.shadow.normalBias = shadowNormalBias;
    light.shadow.camera.updateProjectionMatrix();
  }

  return light;
}

/**
 * Create spot light
 * @param {number} color
 * @param {number} intensity
 * @param {number} distance
 * @param {number} angle
 * @param {number} penumbra
 * @param {boolean} castShadow
 * @param {number} shadowResolution
 * @param {number} shadowBias
 * @returns {THREE.SpotLight}
 */
export function createSpotLight(color, intensity, distance, angle, penumbra, castShadow, shadowResolution, shadowBias, shadowNormalBias) {
  const light = new THREE.SpotLight(color, intensity, distance, angle, penumbra);
  light.castShadow = castShadow;

  if (castShadow) {
    light.shadow.mapSize.width = shadowResolution;
    light.shadow.mapSize.height = shadowResolution;
    light.shadow.bias = shadowBias;
    light.shadow.normalBias = shadowNormalBias;
    light.shadow.camera.updateProjectionMatrix();
  }

  return light;
}

/**
 * Create hemisphere light
 * @param {number} skyColor
 * @param {number} groundColor
 * @param {number} intensity
 * @returns {THREE.HemisphereLight}
 */
export function createHemisphereLight(skyColor, groundColor, intensity) {
  return new THREE.HemisphereLight(skyColor, groundColor, intensity);
}

// ============================================================================
// OBJECTS
// ============================================================================

/**
 * Create a mesh
 * @param {THREE.BufferGeometry} geometry
 * @param {THREE.Material} material
 * @returns {THREE.Mesh}
 */
export function createMesh(geometry, material) {
  const mesh = new THREE.Mesh(geometry, material);
  mesh.castShadow = true;
  mesh.receiveShadow = true;
  return mesh;
}

/**
 * Create an instanced mesh
 * @param {THREE.BufferGeometry} geometry
 * @param {THREE.Material} material
 * @param {number} count
 * @returns {THREE.InstancedMesh}
 */
export function createInstancedMesh(geometry, material, count) {
  return new THREE.InstancedMesh(geometry, material, count);
}

/**
 * Set instance matrix
 * @param {THREE.InstancedMesh} mesh
 * @param {number} index
 * @param {THREE.Matrix4} matrix
 */
export function setInstanceMatrix(mesh, index, matrix) {
  mesh.setMatrixAt(index, matrix);
}

/**
 * Mark instance matrix as needing update
 * @param {THREE.InstancedMesh} mesh
 */
export function updateInstanceMatrix(mesh) {
  mesh.instanceMatrix.needsUpdate = true;
}

/**
 * Create a group
 * @returns {THREE.Group}
 */
export function createGroup() {
  return new THREE.Group();
}

/**
 * Create an LOD object
 * @returns {THREE.LOD}
 */
export function createLOD() {
  return new THREE.LOD();
}

/**
 * Add LOD level
 * @param {THREE.LOD} lod
 * @param {THREE.Object3D} object
 * @param {number} distance
 */
export function addLODLevel(lod, object, distance) {
  lod.addLevel(object, distance);
}

/**
 * Remove LOD level
 * @param {THREE.LOD} lod
 * @param {number} distance
 */
export function removeLODLevel(lod, distance) {
  lod.removeLevel(distance);
}

/**
 * Create a sprite
 * @param {THREE.SpriteMaterial} material
 * @returns {THREE.Sprite}
 */
export function createSprite(material) {
  return new THREE.Sprite(material);
}

/**
 * Create points
 * @param {THREE.BufferGeometry} geometry
 * @param {THREE.PointsMaterial} material
 * @returns {THREE.Points}
 */
export function createPoints(geometry, material) {
  return new THREE.Points(geometry, material);
}

/**
 * Create line segments
 * @param {THREE.BufferGeometry} geometry
 * @param {THREE.LineBasicMaterial} material
 * @returns {THREE.LineSegments}
 */
export function createLineSegments(geometry, material) {
  return new THREE.LineSegments(geometry, material);
}

/**
 * Clone an object
 * @param {THREE.Object3D} object
 * @returns {THREE.Object3D}
 */
export function cloneObject(object) {
  return object.clone();
}

// ============================================================================
// SCENE GRAPH MANIPULATION
// ============================================================================

/**
 * Add child to parent
 * @param {THREE.Object3D} parent
 * @param {THREE.Object3D} child
 */
export function addChild(parent, child) {
  parent.add(child);
}

/**
 * Remove child from parent
 * @param {THREE.Object3D} parent
 * @param {THREE.Object3D} child
 */
export function removeChild(parent, child) {
  parent.remove(child);
}

/**
 * Set position
 * @param {THREE.Object3D} object
 * @param {Vec3} position
 */
export function setPosition(object, position) {
  object.position.set(position.x, position.y, position.z);
}

/**
 * Set rotation
 * @param {THREE.Object3D} object
 * @param {Vec3} rotation
 */
export function setRotation(object, rotation) {
  object.rotation.set(rotation.x, rotation.y, rotation.z);
}

/**
 * Set scale
 * @param {THREE.Object3D} object
 * @param {Vec3} scale
 */
export function setScale(object, scale) {
  object.scale.set(scale.x, scale.y, scale.z);
}

/**
 * Update world matrix
 * @param {THREE.Object3D} object
 * @param {boolean} updateParents
 * @param {boolean} updateChildren
 */
export function updateMatrixWorld(object, updateParents, updateChildren) {
  object.updateMatrixWorld(updateParents, updateChildren);
}

/**
 * Update object's world matrix with force flag
 * @param {THREE.Object3D} object
 * @param {boolean} force - If true, forces update of all children
 */
export function updateMatrixWorldForce(object, force) {
  object.updateMatrixWorld(force);
}

/**
 * Get world position from object (includes parent transforms)
 * @param {THREE.Object3D} object
 * @returns {Vec3} Gleam Vec3 with world position
 */
export function getWorldPosition(object) {
  const worldPos = new THREE.Vector3();
  object.getWorldPosition(worldPos);
  return Vec3$Vec3(worldPos.x, worldPos.y, worldPos.z);
}

/**
 * Get world quaternion from object (includes parent transforms)
 * @param {THREE.Object3D} object
 * @returns {Array[Number]} Gleam Quaternion with world rotation
 */
export function getWorldQuaternion(object) {
  const worldQuat = new THREE.Quaternion();
  object.getWorldQuaternion(worldQuat);
  return Quaternion$Quaternion(worldQuat.x, worldQuat.y, worldQuat.z, worldQuat.w);
}

/**
 * Copy position from another object
 * @param {THREE.Object3D} object
 * @param {THREE.Object3D} source
 */
export function copyPosition(object, source) {
  object.position.copy(source.position);
}

/**
 * Copy rotation from another object
 * @param {THREE.Object3D} object
 * @param {THREE.Object3D} source
 */
export function copyRotation(object, source) {
  object.rotation.copy(source.rotation);
}

/**
 * Copy scale from another object
 * @param {THREE.Object3D} object
 * @param {THREE.Object3D} source
 */
export function copyScale(object, source) {
  object.scale.copy(source.scale);
}

/**
 * Set object position from a dynamic position object
 * @param {THREE.Object3D} object
 * @param {Object} position - {x, y, z}
 */
export function setObjectPosition(object, position) {
  object.position.set(position.x, position.y, position.z);
}

/**
 * Set object rotation from a dynamic rotation object
 * @param {THREE.Object3D} object
 * @param {Object} rotation - {x, y, z}
 */
export function setObjectRotation(object, rotation) {
  object.rotation.set(rotation.x, rotation.y, rotation.z);
}

/**
 * Set object scale from a dynamic scale object
 * @param {THREE.Object3D} object
 * @param {Object} scale - {x, y, z}
 */
export function setObjectScale(object, scale) {
  object.scale.set(scale.x, scale.y, scale.z);
}

// ============================================================================
// ANIMATION
// ============================================================================

/**
 * Create animation mixer
 * @param {THREE.Object3D} root
 * @returns {THREE.AnimationMixer}
 */
export function createAnimationMixer(root) {
  return new THREE.AnimationMixer(root);
}

/**
 * Get clip action from mixer
 * @param {THREE.AnimationMixer} mixer
 * @param {THREE.AnimationClip} clip
 * @returns {THREE.AnimationAction}
 */
export function clipAction(mixer, clip) {
  return mixer.clipAction(clip);
}

/**
 * Update animation mixer
 * @param {THREE.AnimationMixer} mixer
 * @param {number} deltaTime - in seconds
 */
export function updateMixer(mixer, deltaTime) {
  // Three.js AnimationMixer.update() expects time in seconds
  mixer.update(deltaTime);
}

/**
 * Play animation action
 * @param {THREE.AnimationAction} action
 */
export function playAction(action) {
  action.play();
}

/**
 * Stop animation action
 * @param {THREE.AnimationAction} action
 */
export function stopAction(action) {
  action.stop();
}

/**
 * Set action loop mode
 * @param {THREE.AnimationAction} action
 * @param {number} loopMode - THREE.LoopOnce, THREE.LoopRepeat, etc.
 */
export function setActionLoop(action, loopMode) {
  action.setLoop(loopMode);
}

/**
 * Set action time scale
 * @param {THREE.AnimationAction} action
 * @param {number} timeScale
 */
export function setActionTimeScale(action, timeScale) {
  action.timeScale = timeScale;
}

/**
 * Set action weight
 * @param {THREE.AnimationAction} action
 * @param {number} weight
 */
export function setActionWeight(action, weight) {
  action.weight = weight;
}

/**
 * Get animation clip name
 * @param {THREE.AnimationClip} clip
 * @returns {string}
 */
export function getClipName(clip) {
  return clip.name || 'unnamed';
}

/**
 * Get animation clip duration
 * @param {THREE.AnimationClip} clip
 * @returns {number}
 */
export function getClipDuration(clip) {
  return clip.duration;
}

// ============================================================================
// TEXTURES
// ============================================================================


/**
 * Clone texture for independent animation
 * @param {THREE.Texture} texture
 * @returns {THREE.Texture}
 */
export function cloneTexture(texture) {
  return texture.clone();
}

/**
 * Set texture offset (UV coordinates)
 * @param {THREE.Texture} texture
 * @param {number} x - Horizontal offset (0.0 to 1.0)
 * @param {number} y - Vertical offset (0.0 to 1.0)
 */
export function setTextureOffset(texture, x, y) {
  texture.offset.set(x, y);
  texture.needsUpdate = true;
}

/**
 * Set texture repeat (UV scaling)
 * @param {THREE.Texture} texture
 * @param {number} x - Horizontal repeat (fraction to show)
 * @param {number} y - Vertical repeat (fraction to show)
 */
export function setTextureRepeat(texture, x, y) {
  texture.repeat.set(x, y);
  texture.needsUpdate = true;
}

/**
 * Set texture wrapping mode
 * @param {THREE.Texture} texture
 * @param {number} wrapS - Horizontal wrap mode (THREE.RepeatWrapping, THREE.ClampToEdgeWrapping, THREE.MirroredRepeatWrapping)
 * @param {number} wrapT - Vertical wrap mode
 */
export function setTextureWrapMode(texture, wrapS, wrapT) {
  texture.wrapS = wrapS;
  texture.wrapT = wrapT;
  texture.needsUpdate = true;
}

/**
 * Set texture filtering mode
 * @param {THREE.Texture} texture
 * @param {number} minFilter - Minification filter (THREE.NearestFilter, THREE.LinearFilter)
 * @param {number} magFilter - Magnification filter
 */
export function setTextureFilterMode(texture, minFilter, magFilter) {
  texture.minFilter = minFilter;
  texture.magFilter = magFilter;
  texture.generateMipmaps = (minFilter === THREE.LinearFilter);
  texture.needsUpdate = true;
}

/**
 * Get THREE.RepeatWrapping constant
 * @returns {number}
 */
export function getRepeatWrapping() {
  return THREE.RepeatWrapping;
}

/**
 * Get THREE.ClampToEdgeWrapping constant
 * @returns {number}
 */
export function getClampToEdgeWrapping() {
  return THREE.ClampToEdgeWrapping;
}

/**
 * Get THREE.MirroredRepeatWrapping constant
 * @returns {number}
 */
export function getMirroredRepeatWrapping() {
  return THREE.MirroredRepeatWrapping;
}

/**
 * Get THREE.NearestFilter constant (for pixel art)
 * @returns {number}
 */
export function getNearestFilter() {
  return THREE.NearestFilter;
}

/**
 * Get THREE.LinearFilter constant (for smooth textures)
 * @returns {number}
 */
export function getLinearFilter() {
  return THREE.LinearFilter;
}


// ============================================================================
// AUDIO
// ============================================================================

/**
 * Create audio listener
 * @returns {THREE.AudioListener}
 */
export function createAudioListener() {
  return new THREE.AudioListener();
}

/**
 * Create global audio (non-positional)
 * @param {THREE.AudioListener} listener
 * @returns {THREE.Audio}
 */
export function createAudio(listener) {
  return new THREE.Audio(listener);
}

/**
 * Create positional audio (3D audio)
 * @param {THREE.AudioListener} listener
 * @returns {THREE.PositionalAudio}
 */
export function createPositionalAudio(listener) {
  return new THREE.PositionalAudio(listener);
}

/**
 * Set audio buffer
 * @param {THREE.Audio} audio
 * @param {AudioBuffer} buffer
 */
export function setAudioBuffer(audio, buffer) {
  audio.setBuffer(buffer);
}

/**
 * Play audio
 * @param {THREE.Audio} audio
 */
export function playAudio(audio) {
  audio.play();
}

/**
 * Pause audio
 * @param {THREE.Audio} audio
 */
export function pauseAudio(audio) {
  audio.pause();
}

/**
 * Stop audio
 * @param {THREE.Audio} audio
 */
export function stopAudio(audio) {
  audio.stop();
}

/**
 * Set audio volume
 * @param {THREE.Audio} audio
 * @param {number} volume
 */
export function setAudioVolume(audio, volume) {
  audio.setVolume(volume);
}

/**
 * Set audio loop
 * @param {THREE.Audio} audio
 * @param {boolean} loop
 */
export function setAudioLoop(audio, loop) {
  audio.setLoop(loop);
}

/**
 * Set audio playback rate
 * @param {THREE.Audio} audio
 * @param {number} rate
 */
export function setAudioPlaybackRate(audio, rate) {
  audio.setPlaybackRate(rate);
}

/**
 * Check if audio is playing
 * @param {THREE.Audio} audio
 * @returns {boolean}
 */
export function isAudioPlaying(audio) {
  return audio.isPlaying;
}

/**
 * Set positional audio reference distance
 * @param {THREE.PositionalAudio} audio
 * @param {number} distance
 */
export function setRefDistance(audio, distance) {
  audio.setRefDistance(distance);
}

/**
 * Set positional audio rolloff factor
 * @param {THREE.PositionalAudio} audio
 * @param {number} factor
 */
export function setRolloffFactor(audio, factor) {
  audio.setRolloffFactor(factor);
}

/**
 * Set positional audio max distance
 * @param {THREE.PositionalAudio} audio
 * @param {number} distance
 */
export function setMaxDistance(audio, distance) {
  audio.setMaxDistance(distance);
}

/**
 * Check if audio has a buffer
 * @param {THREE.Audio} audio
 * @returns {boolean}
 */
export function hasAudioBuffer(audio) {
  return audio.buffer !== null && audio.buffer !== undefined;
}

/**
 * Get audio loop state
 * @param {THREE.Audio} audio
 * @returns {boolean}
 */
export function getAudioLoop(audio) {
  return audio.loop || false;
}

/**
 * Get AudioContext state
 * @returns {string} - 'suspended', 'running', or 'closed'
 */
export function getAudioContextState() {
  // Get audio listener from asset module
  const listener = new THREE.AudioListener();
  return listener.context.state;
}

/**
 * Resume AudioContext
 */
export function resumeAudioContext() {
  const listener = new THREE.AudioListener();
  if (listener.context.state === 'suspended') {
    listener.context.resume();
  }
}

// ============================================================================
// DEBUG HELPERS
// ============================================================================

/**
 * Create axes helper
 * @param {number} size
 * @returns {THREE.AxesHelper}
 */
export function createAxesHelper(size) {
  return new THREE.AxesHelper(size);
}

/**
 * Create grid helper
 * @param {number} size
 * @param {number} divisions
 * @param {number} color
 * @returns {THREE.GridHelper}
 */
export function createGridHelper(size, divisions, color) {
  return new THREE.GridHelper(size, divisions, color, color);
}

/**
 * Create box helper
 * @param {THREE.Object3D} object
 * @param {number} color
 * @returns {THREE.BoxHelper}
 */
export function createBoxHelper(object, color) {
  return new THREE.BoxHelper(object, color);
}

// ============================================================================
// BUFFER GEOMETRY MANIPULATION
// ============================================================================

/**
 * Create buffer geometry
 * @returns {THREE.BufferGeometry}
 */
export function createBufferGeometry() {
  return new THREE.BufferGeometry();
}

/**
 * Set geometry attribute
 * @param {THREE.BufferGeometry} geometry
 * @param {string} name
 * @param {THREE.BufferAttribute} attribute
 */
export function setGeometryAttribute(geometry, name, attribute) {
  geometry.setAttribute(name, attribute);
}

/**
 * Create buffer attribute
 * @param {Float32Array|Uint16Array} array
 * @param {number} itemSize
 * @returns {THREE.BufferAttribute}
 */
export function createBufferAttribute(array, itemSize) {
  return new THREE.BufferAttribute(array, itemSize);
}

/**
 * Mark buffer attribute as needing update
 * @param {THREE.BufferAttribute} attribute
 */
export function markAttributeNeedsUpdate(attribute) {
  attribute.needsUpdate = true;
}

/**
 * Set geometry draw range
 * @param {THREE.BufferGeometry} geometry
 * @param {number} start
 * @param {number} count
 */
export function setDrawRange(geometry, start, count) {
  geometry.setDrawRange(start, count);
}

// ============================================================================
// MATH UTILITIES
// ============================================================================

/**
 * Create Matrix4
 * @returns {THREE.Matrix4}
 */
export function createMatrix4() {
  return new THREE.Matrix4();
}

/**
 * Compose matrix from position, quaternion, scale
 * @param {THREE.Matrix4} matrix
 * @param {THREE.Vector3} position
 * @param {THREE.Quaternion} quaternion
 * @param {THREE.Vector3} scale
 */
export function composeMatrix(matrix, position, quaternion, scale) {
  // quaternion is a Gleam Quaternion record with x, y, z, w fields
  const threeQuat = new THREE.Quaternion(quaternion.x, quaternion.y, quaternion.z, quaternion.w);
  matrix.compose(position, threeQuat, scale);
}


/**
 * Create Color
 * @param {number} hex
 * @returns {THREE.Color}
 */
export function createColor(hex) {
  return new THREE.Color(hex);
}

/**
 * Lerp between two colors
 * @param {THREE.Color} color1
 * @param {THREE.Color} color2
 * @param {number} t
 * @returns {THREE.Color}
 */
export function lerpColor(color1, color2, t) {
  return color1.clone().lerp(color2, t);
}

// ============================================================================
// UI - CSS2DRenderer
// ============================================================================

/**
 * Create CSS2DRenderer
 * @returns {CSS2DRenderer}
 */
export function createCSS2DRenderer() {
  return new CSS2DRenderer();
}

/**
 * Set CSS2DRenderer size
 * @param {CSS2DRenderer} renderer
 * @param {number} width
 * @param {number} height
 */
export function setCSS2DRendererSize(renderer, width, height) {
  renderer.setSize(width, height);
}

/**
 * Get CSS2DRenderer DOM element
 * @param {CSS2DRenderer} renderer
 * @returns {HTMLElement}
 */
export function getCSS2DRendererDomElement(renderer) {
  return renderer.domElement;
}

/**
 * Render CSS2D
 * @param {CSS2DRenderer} renderer
 * @param {THREE.Scene} scene
 * @param {THREE.Camera} camera
 */
export function renderCSS2D(renderer, scene, camera) {
  renderer.render(scene, camera);
}

/**
 * Create CSS2DObject from HTML string
 * @param {string} html - HTML string to render
 * @returns {CSS2DObject}
 */
export function createCSS2DObject(html) {
  const div = document.createElement('div');
  div.innerHTML = html;
  const element = div.children.length === 1 ? div.children[0] : div;
  return new CSS2DObject(element);
}

/**
 * Set CSS2DObject position
 * @param {THREE.Object3D} object
 * @param {Vec3} position
 */
export function setCSS2DObjectPosition(object, position) {
  object.position.set(position.x, position.y, position.z);
}

/**
 * Update CSS2DObject HTML content
 * @param {CSS2DObject} object
 * @param {string} html
 */
export function updateCSS2DObjectHTML(object, html) {
  // Update the actual DOM element
  if (object.element) {
    object.element.innerHTML = html;
  }
}

// ============================================================================
// UI - CSS3DRenderer
// ============================================================================

/**
 * Create CSS3DRenderer
 * @returns {CSS3DRenderer}
 */
export function createCSS3DRenderer() {
  return new CSS3DRenderer();
}

/**
 * Set CSS3DRenderer size
 * @param {CSS3DRenderer} renderer
 * @param {number} width
 * @param {number} height
 */
export function setCSS3DRendererSize(renderer, width, height) {
  renderer.setSize(width, height);
}

/**
 * Get CSS3DRenderer DOM element
 * @param {CSS3DRenderer} renderer
 * @returns {HTMLElement}
 */
export function getCSS3DRendererDomElement(renderer) {
  return renderer.domElement;
}

/**
 * Render CSS3D
 * @param {CSS3DRenderer} renderer
 * @param {THREE.Scene} scene
 * @param {THREE.Camera} camera
 */
export function renderCSS3D(renderer, scene, camera) {
  renderer.render(scene, camera);
}

/**
 * Create CSS3DObject from HTML string
 * @param {string} html - HTML string to render
 * @returns {CSS3DObject}
 */
export function createCSS3DObject(html) {
  const div = document.createElement('div');
  div.innerHTML = html;
  const element = div.children.length === 1 ? div.children[0] : div;
  return new CSS3DObject(element);
}

/**
 * Set CSS3DObject position
 * @param {THREE.Object3D} object
 * @param {Vec3} position
 */
export function setCSS3DObjectPosition(object, position) {
  object.position.set(position.x, position.y, position.z);
}

/**
 * Update CSS3DObject HTML content
 * @param {CSS3DObject} object
 * @param {string} html
 */
export function updateCSS3DObjectHTML(object, html) {
  // Update the actual DOM element
  if (object.element) {
    object.element.innerHTML = html;
  }
}

// ============================================================================
// CONSTANTS
// ============================================================================

/**
 * Get THREE.LoopOnce constant
 * @returns {number}
 */
export function getLoopOnce() {
  return THREE.LoopOnce;
}

/**
 * Get THREE.LoopRepeat constant
 * @returns {number}
 */
export function getLoopRepeat() {
  return THREE.LoopRepeat;
}

/**
 * Get THREE.LoopPingPong constant
 * @returns {number}
 */
export function getLoopPingPong() {
  return THREE.LoopPingPong;
}

/**
 * Get THREE.AdditiveBlending constant
 * @returns {number}
 */
export function getAdditiveBlending() {
  return THREE.AdditiveBlending;
}

/**
 * Get THREE.NormalBlending constant
 * @returns {number}
 */
export function getNormalBlending() {
  return THREE.NormalBlending;
}

// ============================================================================
// PARTICLE SYSTEMS
// ============================================================================

/**
 * Get red component from color
 * @param {THREE.Color} color
 * @returns {number}
 */
export function getColorR(color) {
  return color.r;
}

/**
 * Get green component from color
 * @param {THREE.Color} color
 * @returns {number}
 */
export function getColorG(color) {
  return color.g;
}

/**
 * Get blue component from color
 * @param {THREE.Color} color
 * @returns {number}
 */
export function getColorB(color) {
  return color.b;
}

/**
 * Create Float32Array
 * @param {number} size - Number of elements
 * @returns {Float32Array}
 */
export function createFloat32Array(size) {
  return new Float32Array(size);
}

/**
 * Set buffer attribute (combines array and attribute creation)
 * @param {THREE.BufferGeometry} geometry
 * @param {string} name
 * @param {Float32Array} array
 * @param {number} itemSize
 */
export function setBufferAttribute(geometry, name, array, itemSize) {
  const attribute = new THREE.BufferAttribute(array, itemSize);
  geometry.setAttribute(name, attribute);
}

/**
 * Get geometry from Points object
 * @param {THREE.Points} points
 * @returns {THREE.BufferGeometry}
 */
export function getGeometry(points) {
  return points.geometry;
}

/**
 * Get attribute from geometry
 * @param {THREE.BufferGeometry} geometry
 * @param {string} name
 * @returns {THREE.BufferAttribute}
 */
export function getAttribute(geometry, name) {
  return geometry.getAttribute(name);
}

/**
 * Set XYZ values in buffer attribute at index
 * @param {THREE.BufferAttribute} attribute
 * @param {number} index
 * @param {Vec3} value
 */
export function setBufferXYZ(attribute, index, value) {
  const i = index * 3;
  attribute.array[i] = value.x;
  attribute.array[i + 1] = value.y;
  attribute.array[i + 2] = value.z;
}

/**
 * Set single value in buffer attribute at index
 * @param {THREE.BufferAttribute} attribute
 * @param {number} index
 * @param {number} value
 */
export function setBufferX(attribute, index, value) {
  attribute.array[index] = value;
}

/**
 * Mark attribute as needing update (alias for markAttributeNeedsUpdate)
 * @param {THREE.BufferAttribute} attribute
 * @param {boolean} needsUpdate
 */
export function setAttributeNeedsUpdate(attribute, needsUpdate) {
  attribute.needsUpdate = needsUpdate;
}


// ============================================================================
// RENDERER PATCH APPLICATION - IMPERATIVE OPERATIONS
// ============================================================================

/**
 * Apply transform to Three.js object
 * @param {THREE.Object3D} object
 * @param {Vec3 } position - Gleam Vec3
 * @param {Vec3 } rotation - Gleam Vec3 (Euler angles in radians)
 * @param {Vec3 } scale - Gleam Vec3
 */
export function applyTransform(object, position, rotation, scale) {
  object.position.set(position.x, position.y, position.z);
  object.rotation.set(rotation.x, rotation.y, rotation.z);
  object.scale.set(scale.x, scale.y, scale.z);
}

/**
 * Apply transform to Three.js object using quaternion for rotation
 * This avoids Euler angle conversion issues when working with physics engines
 * @param {THREE.Object3D} object
 * @param {Object} position - {x, y, z}
 * @param {Object} quaternion - {x, y, z, w}
 * @param {Object} scale - {x, y, z}
 */
export function applyTransformWithQuaternion(object, position, quaternion, scale) {
  object.position.set(position.x, position.y, position.z);
  object.quaternion.set(quaternion.x, quaternion.y, quaternion.z, quaternion.w);
  object.scale.set(scale.x, scale.y, scale.z);
}

/**
 * Apply camera lookAt with proper world matrix handling
 * @param {THREE.Camera} camera
 * @param {Vec3} target - Gleam Vec3
 */
export function applyCameraLookAt(camera, target) {
  camera.updateMatrixWorld(true);
  camera.lookAt(target.x, target.y, target.z);
}

/**
 * Make any Object3D look at a target position.
 * Uses Three.js lookAt which rotates the object so its local -Z axis points at the target.
 * @param {THREE.Object3D} object
 * @param {Vec3} target - Gleam Vec3
 */
export function objectLookAt(object, target) {
  object.lookAt(target.x, target.y, target.z);
}

/**
 * Set shadow properties on an object
 * @param {THREE.Object3D} object
 * @param {boolean} castShadow
 * @param {boolean} receiveShadow
 */
export function setShadowProperties(object, castShadow, receiveShadow) {
  object.castShadow = castShadow;
  object.receiveShadow = receiveShadow;
}

/**
 * Add object to scene
 * @param {THREE.Scene} scene
 * @param {THREE.Object3D} object
 */
export function addToScene(scene, object) {
  scene.add(object);
}

/**
 * Remove object from its parent (works for both scene root and nested parents)
 * @param {THREE.Scene} scene - Not used anymore, kept for API compatibility
 * @param {THREE.Object3D} object
 */
export function removeFromScene(_, object) {
  // Use removeFromParent() instead of scene.remove() to handle nested hierarchies
  // This works whether the object is a direct child of the scene or nested deeper
  if (object && object.removeFromParent) {
    object.removeFromParent();
  }
}

// ============================================================================
// OBJECT3D USER DATA
// ============================================================================

/**
 * Set user data on any Object3D (works for cameras, meshes, etc.)
 * @param {THREE.Object3D} object
 * @param {string} key
 * @param {any} value
 */
export function setObjectUserData(object, key, value) {
  object.userData[key] = value;
}

/**
 * Get user data from any Object3D
 * @param {THREE.Object3D} object
 * @param {string} key
 * @returns {any}
 */
export function getObjectUserData(object, key) {
  return object.userData[key];
}

/**
 * Delete user data from any Object3D
 * @param {THREE.Object3D} object
 * @param {string} key
 */
export function deleteObjectUserData(object, key) {
  delete object.userData[key];
}

/**
 * Check if Object3D has user data for a key
 * @param {THREE.Object3D} object
 * @param {string} key
 * @returns {boolean}
 */
export function hasObjectUserData(object, key) {
  return object.userData && object.userData[key] !== undefined;
}

/**
 * Update instanced mesh transforms
 * @param {THREE.InstancedMesh} mesh
 * @param {Array} instances - Gleam List of tuples: #(Vec3 position, Vec3 euler_rotation, Vec3 scale)
 */
export function updateInstancedMeshTransforms(mesh, instances) {
  const matrix = new THREE.Matrix4();
  const position = new THREE.Vector3();
  const euler = new THREE.Euler();
  const quaternion = new THREE.Quaternion();
  const scale = new THREE.Vector3();

  let i = 0;
  for (const inst of instances) {
    // Gleam tuple is a 3-element array: [position_vec3, rotation_vec3, scale_vec3]
    const posVec = inst[0];
    const rotVec = inst[1];
    const scaleVec = inst[2];

    position.set(posVec.x, posVec.y, posVec.z);
    euler.set(rotVec.x, rotVec.y, rotVec.z);
    quaternion.setFromEuler(euler);
    scale.set(scaleVec.x, scaleVec.y, scaleVec.z);

    matrix.compose(position, quaternion, scale);

    mesh.setMatrixAt(i, matrix);
    i++;
  }

  mesh.instanceMatrix.needsUpdate = true;
}
/**
 * Clear all LOD levels
 * @param {THREE.LOD} lod
 */
export function clearLODLevels(lod) {
  while (lod.levels.length > 0) {
    lod.removeLevel(lod.levels[0].distance);
  }
}

/**
 * Update camera projection matrix
 * @param {THREE.Camera} camera
 */
export function updateCameraProjectionMatrix(camera) {
  camera.updateProjectionMatrix();
}

/**
 * Set camera projection parameters for perspective camera
 * @param {THREE.PerspectiveCamera} camera
 * @param {number} fov
 * @param {number} aspect
 * @param {number} near
 * @param {number} far
 */
export function setPerspectiveCameraParams(camera, fov, aspect, near, far) {
  camera.fov = fov;
  camera.aspect = aspect;
  camera.near = near;
  camera.far = far;
}

/**
 * Set camera projection parameters for orthographic camera
 * @param {THREE.OrthographicCamera} camera
 * @param {number} left
 * @param {number} right
 * @param {number} top
 * @param {number} bottom
 * @param {number} near
 * @param {number} far
 */
export function setOrthographicCameraParams(camera, left, right, top, bottom, near, far) {
  camera.left = left;
  camera.right = right;
  camera.top = top;
  camera.bottom = bottom;
  camera.near = near;
  camera.far = far;
  // Update stored original bounds for aspect ratio preservation during resize
  camera._originalLeft = left;
  camera._originalRight = right;
  camera._originalTop = top;
  camera._originalBottom = bottom;
}

/**
 * Get object geometry (if it has one)
 * @param {THREE.Object3D} object
 * @returns {THREE.BufferGeometry|undefined}
 */
export function getObjectGeometry(object) {
  return object.geometry;
}

/**
 * Get object material (if it has one)
 * @param {THREE.Object3D} object
 * @returns {THREE.Material|THREE.Material[]|undefined}
 */
export function getObjectMaterial(object) {
  return object.material;
}

/**
 * Set object geometry
 * @param {THREE.Object3D} object
 * @param {THREE.BufferGeometry} geometry
 */
export function setObjectGeometry(object, geometry) {
  object.geometry = geometry;
}

/**
 * Set object material
 * @param {THREE.Object3D} object
 * @param {THREE.Material|THREE.Material[]} material
 */
export function setObjectMaterial(object, material) {
  object.material = material;
}

/**
 * Get object position
 * @param {THREE.Object3D} object
 * @returns {Vec3} - Gleam Vec3
 */
export function getObjectPosition(object) {
  return Vec3$Vec3(object.position.x, object.position.y, object.position.z);
}

/**
 * Get object rotation (Euler angles)
 * @param {THREE.Object3D} object
 * @returns {Vec3} - Gleam Vec3 with Euler angles in radians
 */
export function getObjectRotation(object) {
  return Vec3$Vec3(object.rotation.x, object.rotation.y, object.rotation.z);
}

/**
 * Get object scale
 * @param {THREE.Object3D} object
 * @returns {Vec3} - Gleam Vec3
 */
export function getObjectScale(object) {
  return Vec3$Vec3(object.scale.x, object.scale.y, object.scale.z);
}

/**
 * Get object quaternion
 * @param {THREE.Object3D} object
 * @returns {Array[Number]} - Gleam Quaternion
 */
export function getObjectQuaternion(object) {
  return Quaternion$Quaternion(
    object.quaternion.x,
    object.quaternion.y,
    object.quaternion.z,
    object.quaternion.w
  );
}

/**
 * Set object quaternion
 * @param {THREE.Object3D} object
 * @param {Quaternion} quaternion
 */
export function setObjectQuaternion(object, quaternion) {
  object.quaternion.set(quaternion.x, quaternion.y, quaternion.z, quaternion.w);
}

// ============================================================================
// OBJECT3D UTILITIES - Helper functions for working with loaded models
// ============================================================================

/**
 * Clone an Object3D with all its children, geometries, and materials
 * @param {THREE.Object3D} object
 * @returns {THREE.Object3D}
 */
export function cloneObject3D(object) {
  return object.clone(true);
}

/**
 * Set texture filtering mode
 * @param {THREE.Texture} texture
 * @param {string} filterMode - "LinearFilter" or "NearestFilter"
 */
export function setTextureFilter(texture, filterMode) {
  const filter = filterMode === 'NearestFilter' ? THREE.NearestFilter : THREE.LinearFilter;
  texture.minFilter = filter;
  texture.magFilter = filter;
  texture.generateMipmaps = (filterMode === 'LinearFilter');
  texture.colorSpace = THREE.SRGBColorSpace;
  texture.needsUpdate = true;
}

/**
 * Enable transparency on all materials in an Object3D
 * @param {THREE.Object3D} object
 */
export function enableTransparency(object) {
  object.traverse((child) => {
    if (child.isMesh) {
      const material = child.material;
      if (Array.isArray(material)) {
        material.forEach(mat => {
          mat.transparent = true;
          mat.alphaTest = 0.5;
          mat.side = THREE.DoubleSide;
          mat.needsUpdate = true;
        });
      } else if (material) {
        material.transparent = true;
        material.alphaTest = 0.5;
        material.side = THREE.DoubleSide;
        material.needsUpdate = true;
      }
    }
  });
}

/**
 * Enable shadow casting and receiving on all meshes in an Object3D
 * @param {THREE.Object3D} object
 * @param {boolean} castShadow
 * @param {boolean} receiveShadow
 */
export function enableShadows(object, castShadow, receiveShadow) {
  object.traverse((child) => {
    if (child.isMesh) {
      child.castShadow = castShadow;
      child.receiveShadow = receiveShadow;
    }
  });
}

/**
 * Apply a Three.js material to all meshes in an Object3D
 * Note: This expects a THREE.Material, not a Tiramisu Material.
 * The Tiramisu Material should be converted using create_material first (from material.mjs)
 * @param {THREE.Object3D} object - The object to apply the material to
 * @param {THREE.Material} threeMaterial - The Three.js material
 */
export function applyMaterialToObject(object, threeMaterial) {
  // Traverse and replace all materials
  object.traverse((child) => {
    if (child.isMesh) {
      // Dispose old material(s)
      if (Array.isArray(child.material)) {
        child.material.forEach(mat => mat.dispose());
      } else if (child.material) {
        child.material.dispose();
      }

      // Apply new material
      child.material = threeMaterial;
    }
  });
}

/**
 * Apply a texture to all materials in an Object3D
 * @param {THREE.Object3D} object
 * @param {THREE.Texture} texture
 * @param {number} filterMode - THREE.NearestFilter or THREE.LinearFilter constant
 */
export function applyTextureToObject(object, texture, filterMode) {
  // Set texture filtering using the int constant directly
  texture.minFilter = filterMode;
  texture.magFilter = filterMode;
  texture.generateMipmaps = (filterMode === THREE.LinearFilter);
  texture.colorSpace = THREE.SRGBColorSpace;
  texture.needsUpdate = true;

  let count = 0;
  object.traverse((child) => {
    if (child.isMesh) {
      const material = child.material;
      if (Array.isArray(material)) {
        material.forEach(mat => {
          mat.map = texture;
          mat.transparent = true;
          mat.alphaTest = 0.5;
          mat.side = THREE.DoubleSide; // Render both sides for vegetation
          mat.needsUpdate = true;
          count++;
        });
      } else if (material) {
        material.map = texture;
        material.transparent = true;
        material.alphaTest = 0.5;
        material.side = THREE.DoubleSide; // Render both sides for vegetation
        material.needsUpdate = true;
        count++;
      }
    }
  });
}

/**
 * Extract all unique mesh/material pairs from an Object3D
 * Returns Gleam lists of geometries and materials (parallel arrays)
 * @param {THREE.Object3D} object
 * @returns {Array[Array[any]]}
 */
export function extractMeshMaterialPairs(object) {
  const geometries = [];
  const materials = [];

  object.traverse((child) => {
    if (child.isMesh && child.geometry && child.material) {
      // Handle both single materials and material arrays
      if (Array.isArray(child.material)) {
        child.material.forEach(mat => {
          geometries.push(child.geometry);
          materials.push(mat);
        });
      } else {
        geometries.push(child.geometry);
        materials.push(child.material);
      }
    }
  });

  return [geometries, materials];
}

/**
 * Update all instanced meshes in a group (recursively)
 * Used for InstancedModel updates
 * @param {THREE.Object3D} object
 * @param {Array} instances - Array of transforms
 */
export function updateGroupInstancedMeshes(object, instances) {
  object.traverse((child) => {
    if (child instanceof THREE.InstancedMesh) {
      updateInstancedMeshTransforms(child, instances);
    }
  });
}

// ============================================================================
// POST-PROCESSING
// ============================================================================

// Note: Post-processing imports are lazy-loaded to avoid import errors
// if the addons are not available. The imports are done inside the functions.

/**
 * Create an EffectComposer for post-processing
 * @param {THREE.WebGLRenderer} renderer
 * @returns {Promise<any>} EffectComposer instance
 */
export async function createEffectComposer(renderer) {
  const { EffectComposer } = await import('three/addons/postprocessing/EffectComposer.js');
  return new EffectComposer(renderer);
}

/**
 * Add render pass to composer
 * @param {any} composer - EffectComposer
 * @param {THREE.Scene} scene
 * @param {THREE.Camera} camera
 * @returns {Promise<void>}
 */
export async function addRenderPass(composer, scene, camera) {
  const { RenderPass } = await import('three/addons/postprocessing/RenderPass.js');
  const pass = new RenderPass(scene, camera);
  composer.addPass(pass);
}

/**
 * Add bloom pass to composer
 * @param {any} composer - EffectComposer
 * @param {number} strength
 * @param {number} threshold
 * @param {number} radius
 * @returns {Promise<void>}
 */
export async function addBloomPass(composer, strength, threshold, radius) {
  const { UnrealBloomPass } = await import('three/addons/postprocessing/UnrealBloomPass.js');
  const resolution = new THREE.Vector2(window.innerWidth, window.innerHeight);
  const pass = new UnrealBloomPass(resolution, strength, radius, threshold);
  composer.addPass(pass);
}

/**
 * Add pixelation pass to composer
 * @param {any} composer - EffectComposer
 * @param {number} pixelSize
 * @param {number} normalEdgeStrength
 * @param {number} depthEdgeStrength
 * @returns {Promise<void>}
 */
export async function addPixelatePass(composer, pixelSize, normalEdgeStrength, depthEdgeStrength) {
  const { ShaderPass } = await import('three/addons/postprocessing/ShaderPass.js');

  const pixelShader = {
    uniforms: {
      'tDiffuse': { value: null },
      'resolution': { value: new THREE.Vector2(window.innerWidth, window.innerHeight) },
      'pixelSize': { value: pixelSize },
      'normalEdgeStrength': { value: normalEdgeStrength },
      'depthEdgeStrength': { value: depthEdgeStrength },
    },
    vertexShader: `
      varying vec2 vUv;
      void main() {
        vUv = uv;
        gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
      }
    `,
    fragmentShader: `
      uniform sampler2D tDiffuse;
      uniform vec2 resolution;
      uniform float pixelSize;
      uniform float normalEdgeStrength;
      uniform float depthEdgeStrength;
      varying vec2 vUv;

      void main() {
        vec2 dxy = pixelSize / resolution;
        vec2 coord = dxy * floor(vUv / dxy);
        vec4 color = texture2D(tDiffuse, coord);

        // Simple edge detection if strength > 0
        if (normalEdgeStrength > 0.0 || depthEdgeStrength > 0.0) {
          vec4 edgeColor = vec4(0.0, 0.0, 0.0, 1.0);

          // Sample neighbors
          vec4 n = texture2D(tDiffuse, coord + vec2(0.0, dxy.y));
          vec4 s = texture2D(tDiffuse, coord - vec2(0.0, dxy.y));
          vec4 e = texture2D(tDiffuse, coord + vec2(dxy.x, 0.0));
          vec4 w = texture2D(tDiffuse, coord - vec2(dxy.x, 0.0));

          // Compute edge strength based on color difference
          float edge = 0.0;
          edge += length(color.rgb - n.rgb);
          edge += length(color.rgb - s.rgb);
          edge += length(color.rgb - e.rgb);
          edge += length(color.rgb - w.rgb);
          edge *= 0.25;

          // Apply edge
          float edgeStrength = max(normalEdgeStrength, depthEdgeStrength);
          if (edge > 0.3 * edgeStrength) {
            color = mix(color, edgeColor, min(edge * edgeStrength, 1.0));
          }
        }

        gl_FragColor = color;
      }
    `
  };

  const pass = new ShaderPass(pixelShader);
  composer.addPass(pass);

  // Store reference for resize updates
  if (!composer.userData) composer.userData = {};
  if (!composer.userData.pixelatePasses) composer.userData.pixelatePasses = [];
  composer.userData.pixelatePasses.push(pass);
}

/**
 * Add film grain pass to composer
 * @param {any} composer - EffectComposer
 * @param {number} noiseIntensity
 * @param {number} scanlineIntensity
 * @param {number} scanlineCount
 * @param {boolean} grayscale
 * @returns {Promise<void>}
 */
export async function addFilmPass(composer, noiseIntensity, scanlineIntensity, scanlineCount, grayscale) {
  const { FilmPass } = await import('three/addons/postprocessing/FilmPass.js');
  const pass = new FilmPass(noiseIntensity, scanlineIntensity, scanlineCount, grayscale);
  composer.addPass(pass);
}

/**
 * Add vignette pass to composer
 * @param {any} composer - EffectComposer
 * @param {number} darkness
 * @param {number} offset
 * @returns {Promise<void>}
 */
export async function addVignettePass(composer, darkness, offset) {
  const { ShaderPass } = await import('three/addons/postprocessing/ShaderPass.js');

  const vignetteShader = {
    uniforms: {
      'tDiffuse': { value: null },
      'offset': { value: offset },
      'darkness': { value: darkness },
    },
    vertexShader: `
      varying vec2 vUv;
      void main() {
        vUv = uv;
        gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
      }
    `,
    fragmentShader: `
      uniform sampler2D tDiffuse;
      uniform float offset;
      uniform float darkness;
      varying vec2 vUv;

      void main() {
        vec4 texel = texture2D(tDiffuse, vUv);
        vec2 uv = (vUv - vec2(0.5)) * vec2(offset);
        float vignette = 1.0 - dot(uv, uv);
        texel.rgb *= mix(1.0, vignette, darkness);
        gl_FragColor = texel;
      }
    `
  };

  const pass = new ShaderPass(vignetteShader);
  composer.addPass(pass);
}

/**
 * Add FXAA anti-aliasing pass to composer
 * @param {any} composer - EffectComposer
 * @returns {Promise<void>}
 */
export async function addFXAAPass(composer) {
  const { ShaderPass } = await import('three/addons/postprocessing/ShaderPass.js');
  const { FXAAShader } = await import('three/addons/shaders/FXAAShader.js');

  const pass = new ShaderPass(FXAAShader);
  const pixelRatio = window.devicePixelRatio || 1;
  pass.material.uniforms['resolution'].value.x = 1 / (window.innerWidth * pixelRatio);
  pass.material.uniforms['resolution'].value.y = 1 / (window.innerHeight * pixelRatio);
  composer.addPass(pass);

  // Store reference for resize updates
  if (!composer.userData) composer.userData = {};
  if (!composer.userData.fxaaPasses) composer.userData.fxaaPasses = [];
  composer.userData.fxaaPasses.push(pass);
}

/**
 * Add glitch pass to composer
 * @param {any} composer - EffectComposer
 * @param {number} dtSize
 * @returns {Promise<void>}
 */
export async function addGlitchPass(composer, dtSize) {
  const { GlitchPass } = await import('three/addons/postprocessing/GlitchPass.js');
  const pass = new GlitchPass(dtSize);
  composer.addPass(pass);
}

/**
 * Add color correction pass to composer
 * @param {any} composer - EffectComposer
 * @param {number} brightness
 * @param {number} contrast
 * @param {number} saturation
 * @returns {Promise<void>}
 */
export async function addColorCorrectionPass(composer, brightness, contrast, saturation) {
  const { ShaderPass } = await import('three/addons/postprocessing/ShaderPass.js');

  const colorCorrectionShader = {
    uniforms: {
      'tDiffuse': { value: null },
      'brightness': { value: brightness },
      'contrast': { value: contrast },
      'saturation': { value: saturation },
    },
    vertexShader: `
      varying vec2 vUv;
      void main() {
        vUv = uv;
        gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
      }
    `,
    fragmentShader: `
      uniform sampler2D tDiffuse;
      uniform float brightness;
      uniform float contrast;
      uniform float saturation;
      varying vec2 vUv;

      void main() {
        vec4 color = texture2D(tDiffuse, vUv);

        // Brightness
        color.rgb += brightness;

        // Contrast
        color.rgb = (color.rgb - 0.5) * (1.0 + contrast) + 0.5;

        // Saturation
        float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
        color.rgb = mix(vec3(gray), color.rgb, 1.0 + saturation);

        gl_FragColor = color;
      }
    `
  };

  const pass = new ShaderPass(colorCorrectionShader);
  composer.addPass(pass);
}

/**
 * Add custom shader pass to composer
 * @param {any} composer - EffectComposer
 * @param {string} vertexShader
 * @param {string} fragmentShader
 * @param {Array} uniforms - Array of {name, value} objects
 * @returns {Promise<void>}
 */
export async function addCustomShaderPass(composer, vertexShader, fragmentShader, uniforms) {
  const { ShaderPass } = await import('three/addons/postprocessing/ShaderPass.js');

  // Convert Gleam uniform list to shader uniforms object
  const shaderUniforms = {
    'tDiffuse': { value: null }
  };

  for (const uniform of uniforms) {
    const [name, value] = uniform;
    // Value comes from Gleam's UniformValue type
    if (value && typeof value === 'object') {
      if ('FloatUniform' in value) {
        shaderUniforms[name] = { value: value.FloatUniform[0] };
      } else if ('IntUniform' in value) {
        shaderUniforms[name] = { value: value.IntUniform[0] };
      } else if ('Vec2Uniform' in value) {
        shaderUniforms[name] = { value: new THREE.Vector2(value.Vec2Uniform[0], value.Vec2Uniform[1]) };
      } else if ('Vec3Uniform' in value) {
        shaderUniforms[name] = { value: new THREE.Vector3(value.Vec3Uniform[0], value.Vec3Uniform[1], value.Vec3Uniform[2]) };
      } else if ('ColorUniform' in value) {
        shaderUniforms[name] = { value: new THREE.Color(value.ColorUniform[0]) };
      }
    }
  }

  const shader = {
    uniforms: shaderUniforms,
    vertexShader: vertexShader,
    fragmentShader: fragmentShader
  };

  const pass = new ShaderPass(shader);
  composer.addPass(pass);
}

/**
 * Render using effect composer
 * @param {any} composer - EffectComposer
 * @param {number} deltaTime - in milliseconds
 */
export function renderComposer(composer, deltaTime) {
  composer.render(deltaTime / 1000.0);
}

/**
 * Set composer size (called on resize)
 * @param {any} composer - EffectComposer
 * @param {number} width
 * @param {number} height
 */
export function setComposerSize(composer, width, height) {
  composer.setSize(width, height);

  // Update resolution-dependent passes
  const pixelRatio = window.devicePixelRatio || 1;

  // Update FXAA passes
  if (composer.userData && composer.userData.fxaaPasses) {
    for (const pass of composer.userData.fxaaPasses) {
      pass.material.uniforms['resolution'].value.x = 1 / (width * pixelRatio);
      pass.material.uniforms['resolution'].value.y = 1 / (height * pixelRatio);
    }
  }

  // Update pixelate passes
  if (composer.userData && composer.userData.pixelatePasses) {
    for (const pass of composer.userData.pixelatePasses) {
      pass.uniforms['resolution'].value.set(width, height);
    }
  }
}

// ============================================================================
// RESOURCE DISPOSAL - Memory management helpers
// ============================================================================

/**
 * Dispose of a Three.js Texture and free GPU memory
 * @param {THREE.Texture} texture - The texture to dispose
 */
export function disposeTexture(texture) {
  if (texture && texture.dispose) {
    texture.dispose();
  }
}

/**
 * Dispose of a Three.js BufferGeometry and free GPU memory
 * @param {THREE.BufferGeometry} geometry - The geometry to dispose
 */
export function disposeGeometry(geometry) {
  if (geometry && geometry.dispose) {
    geometry.dispose();
  }
}

/**
 * Dispose of a Three.js Material and free GPU memory
 * Includes all associated texture maps
 * @param {THREE.Material} material - The material to dispose
 */
export function disposeMaterial(material) {
  if (material) {
    // Dispose of material textures if they exist
    if (material.map) material.map.dispose();
    if (material.lightMap) material.lightMap.dispose();
    if (material.bumpMap) material.bumpMap.dispose();
    if (material.normalMap) material.normalMap.dispose();
    if (material.specularMap) material.specularMap.dispose();
    if (material.envMap) material.envMap.dispose();
    if (material.alphaMap) material.alphaMap.dispose();
    if (material.aoMap) material.aoMap.dispose();
    if (material.displacementMap) material.displacementMap.dispose();
    if (material.emissiveMap) material.emissiveMap.dispose();
    if (material.gradientMap) material.gradientMap.dispose();
    if (material.metalnessMap) material.metalnessMap.dispose();
    if (material.roughnessMap) material.roughnessMap.dispose();

    // Dispose of the material itself
    material.dispose();
  }
}

/**
 * Dispose of an Object3D recursively (geometry, materials, textures, children)
 * @param {THREE.Object3D} object - The object to dispose
 */
export function disposeObject3D(object) {
  if (!object) return;

  // Dispose geometry
  if (object.geometry) {
    object.geometry.dispose();
  }

  // Dispose material(s)
  if (object.material) {
    if (Array.isArray(object.material)) {
      object.material.forEach(material => disposeMaterial(material));
    } else {
      disposeMaterial(object.material);
    }
  }

  // Recursively dispose children
  if (object.children) {
    for (const child of object.children) {
      disposeObject3D(child);
    }
  }
}

// ============================================================================
// ASSET LOADING
// ============================================================================

/**
 * Load texture
 * @param {string} url
 * @returns {Promise<Result<THREE.Texture, undefined>>}
 */
export function loadTexture(url) {
  return new Promise((resolve) => {
    const loader = new THREE.TextureLoader();
    loader.load(
      url,
      (texture) => resolve(Result$Ok(texture)),
      undefined,
      (_) => resolve(Result$Error())
    );
  });
}

/**
 * Load an audio file and return an AudioBuffer
 * @param {string} url - URL of the audio file
 * @returns {Promise<Result<AudioBuffer, undefined>>}
 */
export function loadAudio(url) {
  return new Promise((resolve) => {
    const loader = new THREE.AudioLoader();
    loader.load(
      url,
      (audioBuffer) => resolve(Result$Ok(audioBuffer)),
      undefined,
      (_) => resolve(Result$Error())
    );
  });
}

/**
 * Load STL model
 * @param {string} url
 * @returns {Promise<Result<THREE.BufferGeometry, undefined>>}
 */
export function loadSTL(url) {
  return new Promise((resolve) => {
    const loader = new STLLoader();
    loader.load(
      url,
      (geometry) => {
        // STL files don't contain normals - compute them for proper lighting
        geometry.computeVertexNormals();
        resolve(Result$Ok(geometry));
      },
      undefined,
      (_) => resolve(Result$Error())
    );
  });
}

/**
 * Center a geometry around its bounding box center.
 * Useful for STL/OBJ models that need to rotate around their geometric center.
 * @param {THREE.BufferGeometry} geometry
 * @returns {THREE.BufferGeometry} The same geometry (mutated), for chaining
 */
export function centerGeometry(geometry) {
  geometry.center();
  return geometry;
}

/**
 * Center an Object3D around its bounding box center.
 * This computes the bounding box of all children and offsets
 * the children so the object's local origin is at the geometric center.
 * Useful for FBX/GLTF models that have their origin at a corner.
 * @param {THREE.Object3D} object - The object to center
 * @returns {THREE.Object3D} The same object (mutated)
 */
export function centerObject3D(object) {
  const box = new THREE.Box3().setFromObject(object);
  const center = box.getCenter(new THREE.Vector3());

  object.children.forEach(child => {
    child.position.sub(center);
  });

  return object;
}

/**
 * Load GLTF model
 * @param {string} url
 * @returns {Promise<Result<Object, undefined>>}
 */
export function loadGLTF(url) {
  const loader = new GLTFLoader();
  return new Promise((resolve) => {
    loader.load(
      url,
      (gltf) => resolve(Result$Ok(gltf)),
      undefined,
      (_) => resolve(Result$Error())
    );
  });
}

/**
 * Load OBJ model
 * @param {string} url
 * @returns {Promise<Result<THREE.Group, undefined>>}
 */
export function loadOBJ(url) {
  const loader = new OBJLoader();
  return new Promise((resolve) => {
    loader.load(
      url,
      (obj) => resolve(Result$Ok(obj)),
      undefined,
      (_) => resolve(Result$Error())
    );
  });
}

/**
 * Load FBX model
 * @param {string} url
 * @returns {Promise<Result<THREE.Group, undefined>}
 */
export function loadFBX(url) {
  const loader = new FBXLoader();
  return new Promise((resolve) => {
    loader.load(
      url,
      (fbx) => resolve(Result$Ok(fbx)),
      undefined,
      (_) => resolve(Result$Error())
    );
  });
}

/**
 * Load font for text geometry
 * @param {string} url - URL to typeface.json font file
 * @returns {Promise<Result<Font, undefined>>}
 */
export function loadFont(url) {
  const loader = new FontLoader();
  return new Promise((resolve) => {
    loader.load(
      url,
      (font) => resolve(Result$Ok(font)),
      undefined,
      (_) => resolve(Result$Error())
    );
  });
}

/**
 * Load equirectangular texture (360° spherical texture)
 * @param {string} url
 * @returns {Promise<Result<THREE.Texture, undefined>>}
 */
export function loadEquirectangularTexture(url) {
  const loader = new THREE.TextureLoader();
  return new Promise((resolve) => {
    loader.load(
      url,
      (texture) => {
        texture.mapping = THREE.EquirectangularReflectionMapping;
        resolve(Result$Ok(texture));
      },
      undefined,
      (_) => resolve(Result$Error())
    );
  });
}

/**
 * Load cube texture (skybox)
 * @param {string[]} urls - Array of 6 URLs [px, nx, py, ny, pz, nz]
 * @returns {Promise<Result<THREE.CubeTexture, undefined>>}
 */
export function loadCubeTexture(urls) {
  const loader = new THREE.CubeTextureLoader();
  return new Promise((resolve) => {
    loader.load(
      urls,
      (cubeTexture) => resolve(Result$Ok(cubeTexture)),
      undefined,
      (_) => resolve(Result$Error())
    );
  });
}
