const three = require("three");
window.three = three;

const AmbientLight      = three.AmbientLight;
const Camera            = three.Camera;
const Controls          = require("three-orbit-controls")(three);
const Object3D          = three.Object3D;
const PerspectiveCamera = three.PerspectiveCamera;
const Point             = three.Point;
const PointLight        = three.PointLight;
const Renderer          = three.WebGLRenderer;
const Scene             = three.Scene;
const Sprite            = three.Sprite;
const Vector2           = three.Vector2;
const Vector3           = three.Vector3;

exports._addToScene = function(scene, obj) {
  return function() {
    scene.add(obj);
  };
}

exports._children = function(scene) {
  return function() { //Effect
    return scene.children;
  }
}

exports._domElement = function(renderer) {
  return function() {
    return renderer.domElement;
  }
}

exports._findObject = function(just, nothing, id, scene) {
  return function() {
    const obj = scene.getObjectByProperty("id", uuid);
    if (obj === undefined) {
      return nothing;
    } else {
      return just(obj);
    }
  }
}

exports._getId = function(obj) {
  return obj.id;
}

exports._intersectionObj = function(intersection) {
  return intersection.object;
}

exports._intersects = function(objects, camera, coords) {
  return function() { // Effect
    const raycaster = new three.Raycaster();
    raycaster.setFromCamera(coords, camera);
    return raycaster.intersectObjects(objects);
  }
}

exports._length = function(v) {
  return v.length();
}

exports._lookAt = function(obj, v) {
  return function() {
    return obj.lookAt(v);
  }
}

exports._mkAmbientLight = function(color, intensity) {
  return function() {
    return new AmbientLight(color, intensity);
  };
}

exports._mkCamera = function (fov, aspect, near, far) {
  return function() {
    return new PerspectiveCamera(fov, aspect, near, far);
  };
}

exports._mkControls = function (camera, node) {
  return function() {
    return new Controls(camera, node);
  };
}

exports._mkRenderer = function (bgcolor, alpha, width, height) {
  return function() {
    var renderer = new Renderer({antialias: true});
    renderer.setSize(width, height);
    renderer.setPixelRatio(window.devicePixelRatio);
    renderer.setClearColor(bgcolor, alpha);
    return renderer;
  }
}

exports._mkPoint = function(opts, radius, x, y, z) {
  return function() {
    const point =
          new three.Mesh(
            new three.SphereGeometry(radius, 32, 32),
            new three.MeshPhysicalMaterial(opts));
    point.position.set(x, y, z);
    return point;
  }
}

exports._mkPointLight = function(color, intensity, distance, decay) {
  return function() {
    return new PointLight(color, intensity, distance, decay);
  };
}

exports._mkScene = function () {
  return new Scene();
}

exports._mkText = function(text, textHeight, color, fontFace, weight, fontSize) {
  return function() {
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    const font = weight + " " + fontSize + "px " + fontFace;
    ctx.font = font;
    const textWidth = ctx.measureText(text).width;
    canvas.width = textWidth;
    canvas.height = fontSize;
    ctx.font = font;
    ctx.fillStyle = color;
    ctx.textBaseline = 'bottom';
    ctx.fillText(text, 0, canvas.height);
    const texture = new three.Texture(canvas);
    texture.needsUpdate = true;
    const spriteMaterial = new three.SpriteMaterial({map: texture});
    const sprite = new Sprite(spriteMaterial);
    sprite.scale.set(textHeight * canvas.width / canvas.height, textHeight, 1);
    return sprite;
  }
}

exports._mkVector2 = function (x, y) {
  return function() {
    return new Vector2(x, y);
  }
}

exports._mkVector3 = function (x, y, z) {
  return function() {
    return new Vector3(x, y, z);
  }
}

exports._position = function(obj) {
  return obj.position;
}

exports._removeFromScene = function(scene, obj) {
  return function() {
    scene.remove(obj);
  };
}

exports._render = function(renderer, scene, camera) {
  return function() {
    renderer.render(scene, camera);
  }
}

exports._setColor = function(obj, color) {
  return function() {
    obj.material.color.set(color);
  }
}

exports._setPosition = function(obj, x, y, z) {
  return function() {
    obj.position.set(x, y, z);
  };
}

exports._sizeToNode = function(renderer, node) {
  return function() {
    renderer.setPixelRatio(window.devicePixelRatio);
    renderer.setSize(node.offsetWidth, node.offsetHeight);
  }
}

exports._updateAspect = function(camera, aspect) {
  return function() {
    camera.aspect = aspect;
    camera.updateProjectionMatrix();
  };
}

exports._updateControls = function(controls) {
  return function() {
    controls.update();
  };
}

exports._vecAdd = function(v1, v2) {
  return v1.add(v2);
}

exports._vecSub = function(v1, v2) {
  return v1.sub(v2);
}
