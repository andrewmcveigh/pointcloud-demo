
exports._renderPointControl = function(dispatch, parse, just, nothing, boxPoint) {
  function addEventListeners(node, val, property) {
    node.addEventListener("mousedown", function (e) {
      dispatch(just(val.ref))(parse(property))();
    });
    node.addEventListener("mouseup", function (e) {
      dispatch(nothing)(nothing)();
    });
  }
  return function() {
    return renderControl(dispatch, parse, just, nothing, boxPoint, addEventListeners);
  }
}

exports._renderGlobalControl = function(dispatch, parse, just, nothing, boxVal) {
  function addEventListeners(node, val, property) {
    node.addEventListener("mousedown", function (e) {
      dispatch(parse(property))();
    });
    node.addEventListener("mouseup", function (e) {
      dispatch(nothing)();
    });
  }
  return function() {
    return renderControl(dispatch, parse, just, nothing, boxVal, addEventListeners);
  }
}

// Bit of a naive rendering function, but we can get away with just redrawing
// everything because there are few elements, and updates are (relatively) rare.
exports._renderHUD = function(node, children) {
  return function() {
    // Delete nodes existing children
    while (node.hasChildNodes()) { node.removeChild(node.lastChild); }
    // Redraw all children
    children.map(function(child) { node.appendChild(child) });
  };
}

exports._nodeOffset = function(constant, node) {
  const out = constant({ w: node.offsetWidth, h: node.offsetHeight,
                         left: node.offsetLeft, top: node.offsetTop });
  window.addEventListener("resize", function() {
    out.set({ w: node.offsetWidth, h: node.offsetHeight,
              left: node.offsetLeft, top: node.offsetTop });
  });
  return function() {
    return out;
  }
}

exports.document = function () {
  return document;
}

exports._getElementById = function(just, nothing, node, id) {
  return function() {
    const element = node.getElementById(id);
    if (element === undefined) {
      return nothing;
    } else {
      return just(element);
    }
  }
}

exports._setCursor = function(document, cursor) {
  return function() {
    document.body.style.cursor = cursor;
  }
}

function renderControl(dispatch, parse, just, nothing, boxVal, addEvents) {
  const val = boxVal.value0
  function renderCheckbox(val, property, label) {
    const node = document.createElement("label");
    const text = document.createTextNode(label.concat(" "));
    node.appendChild(text)
    const checkbox = document.createElement("input");
    checkbox.type = "checkbox";
    checkbox.checked = val.display[property];
    addEvents(checkbox, val, property);
    node.appendChild(checkbox)
    return node;
  };
  const node = document.createElement("div");
  node.className = "point-control";
  const fieldset = document.createElement("fieldset");
  node.appendChild(fieldset);
  const legend = document.createElement("legend");
  fieldset.appendChild(legend);
  legend.innerHTML = val.label;
  fieldset.appendChild(legend);
  fieldset.appendChild(renderCheckbox(val, "show", "Show"));
  fieldset.appendChild(renderCheckbox(val, "colorized", "Colourise"));
  fieldset.appendChild(renderCheckbox(val, "annotated", "Annotate"));
  return node;
}
