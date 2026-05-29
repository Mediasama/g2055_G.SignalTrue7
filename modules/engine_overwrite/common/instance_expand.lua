local Instance = _ENV.Instance

function Instance:loadTriggerOnCreate(extendCfg, properties)
  if properties.mesh and (string.find(properties.mesh, "g2055_grass_") or string.find(properties.mesh, "g2055_tree_")) then
    properties.useTextureAlpha = "true"
  end
end

RETURN()
