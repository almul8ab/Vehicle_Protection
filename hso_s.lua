-- by Hso (Hussein Ali)
local db = dbConnect("sqlite", "vehicleProtection.db")
if db then
    dbExec(db, [[
        CREATE TABLE IF NOT EXISTS protectedVehicles (
            model INTEGER PRIMARY KEY,
            vehProtection INTEGER,
            occProtection INTEGER
        )
    ]])
end

local function updateVehicleProtection(vehicle)
    local model = getElementModel(vehicle)
    local protectionData = getProtectedModel(model)
    if protectionData and protectionData.veh then
        setVehicleDamageProof(vehicle, true)
    else
        setVehicleDamageProof(vehicle, false)
    end
end

addEventHandler("onResourceStart", resourceRoot, function()
    local qh = dbQuery(db, "SELECT * FROM protectedVehicles")
    local result = dbPoll(qh, -1)
    if result then
        for _, row in ipairs(result) do
            setProtectedModel(tonumber(row.model), tonumber(row.vehProtection) == 1, tonumber(row.occProtection) == 1)
        end
    end
    for _, vehicle in ipairs(getElementsByType("vehicle")) do
        updateVehicleProtection(vehicle)
    end
    setTimer(function()
        for _, player in ipairs(getElementsByType("player")) do
            triggerClientEvent(player, "Hso:vp:syncAll", resourceRoot, getAllProtectedModels())
        end
    end, 1000, 1)
end)

addEventHandler("onVehicleSpawn", root, updateVehicleProtection)

addCommandHandler("vp", function(player)
    if isObjectInACLGroup("user."..getAccountName(getPlayerAccount(player)), aclGetGroup("Admin")) then
        triggerClientEvent(player, "Hso:vp:openPanel", resourceRoot, getAllProtectedModels())
    end
end)

local function updateAllVehiclesOfModel(model, isProtected)
    for _, vehicle in ipairs(getElementsByType("vehicle")) do
        if getElementModel(vehicle) == model then
            setVehicleDamageProof(vehicle, isProtected)
        end
    end
end

addEvent("Hso:vp:addModel", true)
addEventHandler("Hso:vp:addModel", root, function(model, veh, occ)
    if not client then
        return
    end
    if not isObjectInACLGroup("user."..getAccountName(getPlayerAccount(client)), aclGetGroup("Admin")) then
        return
    end
    setProtectedModel(model, veh, occ)
    dbExec(db, "INSERT OR REPLACE INTO protectedVehicles (model, vehProtection, occProtection) VALUES (?,?,?)", model, veh and 1 or 0, occ and 1 or 0)
    updateAllVehiclesOfModel(model, veh)
    triggerClientEvent(root, "Hso:vp:syncChange", resourceRoot, model, veh, occ)
end)

addEvent("Hso:vp:updateProtection", true)
addEventHandler("Hso:vp:updateProtection", root, function(model, veh, occ)
    if not client then
        return
    end
    if not isObjectInACLGroup("user."..getAccountName(getPlayerAccount(client)), aclGetGroup("Admin")) then
        return
    end
    if getProtectedModel(model) then
        setProtectedModel(model, veh, occ)
        dbExec(db, "UPDATE protectedVehicles SET vehProtection=?, occProtection=? WHERE model=?", veh and 1 or 0, occ and 1 or 0, model)
        updateAllVehiclesOfModel(model, veh)
        triggerClientEvent(root, "Hso:vp:syncChange", resourceRoot, model, veh, occ)
    end
end)

addEvent("Hso:vp:removeModel", true)
addEventHandler("Hso:vp:removeModel", root, function(model)
    if not client then
        return
    end
    if not isObjectInACLGroup("user."..getAccountName(getPlayerAccount(client)), aclGetGroup("Admin")) then
        return
    end
    removeProtectedModel(model)
    dbExec(db, "DELETE FROM protectedVehicles WHERE model=?", model)
    updateAllVehiclesOfModel(model, false)
    triggerClientEvent(root, "Hso:vp:syncChange", resourceRoot, model, nil, nil)

end)
