protectedModels = {}
function setProtectedModel(model, vehProt, occProt)
    protectedModels[model] = {veh = vehProt, occ = occProt}
end
function removeProtectedModel(model)
    protectedModels[model] = nil
end
function getProtectedModel(model)
    return protectedModels[model]
end
function getAllProtectedModels()
    return protectedModels
end