-- by Hso (Hussein Ali)
local sx, sy = guiGetScreenSize()
local Hso_win, Hso_grid, Hso_addEdit, Hso_btnAdd, Hso_btnEdit, Hso_btnRemove, Hso_btnClose, Hso_chkVeh, Hso_chkOcc, Hso_btnLang
local edit_win, edit_chkVeh, edit_chkOcc, edit_btnSave
local lang = "ar"

addEvent("Hso:vp:openPanel", true)
addEvent("Hso:vp:syncChange", true)
addEvent("Hso:vp:syncAll", true)

local texts = {
    ar = {
        window = "حماية السيارات", add = "اضافة", edit = "تعديل", remove = "حذف", close = "اغلاق", vehProt = "حماية السيارة", occProt = "حماية الركاب", langBtn = "English", colModel = "موديل", editWin = "تعديل الحماية", save = "حفظ", addEditPlaceholder = "ايدي السيارة"
    },
    en = {
        window = "Vehicle Protection", add = "Add", edit = "Edit", remove = "Remove", close = "Close", vehProt = "Vehicle Protection", occProt = "Occupant Protection", langBtn = "عربي", colModel = "Model", editWin = "Edit Protection", save = "Save", addEditPlaceholder = "ID Vehicle"
    }
}

local function Hso_createUI()
    if Hso_win and isElement(Hso_win) then return end
    Hso_win = guiCreateWindow((sx-500)/2, (sy-400)/2, 500, 400, texts[lang].window, false)
    guiWindowSetSizable(Hso_win, false)
    Hso_grid = guiCreateGridList(10, 10, 480, 250, false, Hso_win)
    guiGridListAddColumn(Hso_grid, texts[lang].colModel, 0.3)
    guiGridListAddColumn(Hso_grid, texts[lang].vehProt, 0.3)
    guiGridListAddColumn(Hso_grid, texts[lang].occProt, 0.3)
    Hso_addEdit = guiCreateEdit(10, 270, 100, 30, texts[lang].addEditPlaceholder, false, Hso_win)
    addEventHandler("onClientGUIFocus", Hso_addEdit, function()
        if guiGetText(source) == texts[lang].addEditPlaceholder then
            guiSetText(source, "")
        end
    end, false)
    addEventHandler("onClientGUIBlur", Hso_addEdit, function()
        if guiGetText(source) == "" then
            guiSetText(source, texts[lang].addEditPlaceholder)
        end
    end, false)
    Hso_chkVeh = guiCreateCheckBox(120, 270, 150, 30, texts[lang].vehProt, false, false, Hso_win)
    Hso_chkOcc = guiCreateCheckBox(280, 270, 150, 30, texts[lang].occProt, false, false, Hso_win)
    Hso_btnAdd = guiCreateButton(10, 310, 100, 30, texts[lang].add, false, Hso_win)
    Hso_btnEdit = guiCreateButton(120, 310, 100, 30, texts[lang].edit, false, Hso_win)
    Hso_btnRemove = guiCreateButton(230, 310, 100, 30, texts[lang].remove, false, Hso_win)
    Hso_btnClose = guiCreateButton(340, 310, 150, 30, texts[lang].close, false, Hso_win)
    Hso_btnLang = guiCreateButton(10, 350, 480, 30, texts[lang].langBtn, false, Hso_win)
    guiSetVisible(Hso_win, false)
    addEventHandler("onClientGUIClick", Hso_btnAdd, function()
        local text = guiGetText(Hso_addEdit)
        local model = tonumber(text)
        local vehProt = guiCheckBoxGetSelected(Hso_chkVeh)
        local occProt = guiCheckBoxGetSelected(Hso_chkOcc)
        if model and not getProtectedModel(model) then
            if not vehProt and not occProt then
                return
            end
            triggerServerEvent("Hso:vp:addModel", localPlayer, model, vehProt, occProt)
        end
    end, false)
    addEventHandler("onClientGUIClick", Hso_btnEdit, function()
        local selected = guiGridListGetSelectedItem(Hso_grid)
        if selected ~= -1 then
            local model = tonumber(guiGridListGetItemText(Hso_grid, selected, 1))
            local prot = getProtectedModel(model)
            if model and prot then
                if not edit_win or not isElement(edit_win) then
                    edit_win = guiCreateWindow((sx-250)/2, (sy-150)/2, 250, 150, texts[lang].editWin, false)
                    guiWindowSetSizable(edit_win, false)
                    edit_chkVeh = guiCreateCheckBox(20, 30, 200, 30, texts[lang].vehProt, prot.veh, false, edit_win)
                    edit_chkOcc = guiCreateCheckBox(20, 70, 200, 30, texts[lang].occProt, prot.occ, false, edit_win)
                    edit_btnSave = guiCreateButton(20, 110, 210, 30, texts[lang].save, false, edit_win)
                    addEventHandler("onClientGUIClick", edit_btnSave, function()
                        local vehProt = guiCheckBoxGetSelected(edit_chkVeh)
                        local occProt = guiCheckBoxGetSelected(edit_chkOcc)
                        triggerServerEvent("Hso:vp:updateProtection", localPlayer, model, vehProt, occProt)
                        destroyElement(edit_win)
                        edit_win = nil
                    end, false)
                else
                    guiSetVisible(edit_win, true)
                    guiBringToFront(edit_win)
                    guiCheckBoxSetSelected(edit_chkVeh, prot.veh)
                    guiCheckBoxSetSelected(edit_chkOcc, prot.occ)
                end
            end
        end
    end, false)
    addEventHandler("onClientGUIClick", Hso_btnRemove, function()
        local selected = guiGridListGetSelectedItem(Hso_grid)
        if selected ~= -1 then
            local model = tonumber(guiGridListGetItemText(Hso_grid, selected, 1))
            triggerServerEvent("Hso:vp:removeModel", localPlayer, model)
        end
    end, false)
    addEventHandler("onClientGUIClick", Hso_btnClose, function()
        guiSetVisible(Hso_win, false)
        showCursor(false)
    end, false)
    addEventHandler("onClientGUIClick", Hso_btnLang, function()
        local oldPlaceholder = texts[lang].addEditPlaceholder
        if lang == "ar" then lang = "en" else lang = "ar" end

        if guiGetText(Hso_addEdit) == oldPlaceholder or guiGetText(Hso_addEdit) == "" then
            guiSetText(Hso_addEdit, texts[lang].addEditPlaceholder)
        end
        
        guiSetText(Hso_win, texts[lang].window)
        guiSetText(Hso_chkVeh, texts[lang].vehProt)
        guiSetText(Hso_chkOcc, texts[lang].occProt)
        guiSetText(Hso_btnAdd, texts[lang].add)
        guiSetText(Hso_btnEdit, texts[lang].edit)
        guiSetText(Hso_btnRemove, texts[lang].remove)
        guiSetText(Hso_btnClose, texts[lang].close)
        guiSetText(Hso_btnLang, texts[lang].langBtn)
        guiGridListSetColumnTitle(Hso_grid, 1, texts[lang].colModel)
        guiGridListSetColumnTitle(Hso_grid, 2, texts[lang].vehProt)
        guiGridListSetColumnTitle(Hso_grid, 3, texts[lang].occProt)
        if edit_win and isElement(edit_win) then
            guiSetText(edit_win, texts[lang].editWin)
            guiSetText(edit_chkVeh, texts[lang].vehProt)
            guiSetText(edit_chkOcc, texts[lang].occProt)
            guiSetText(edit_btnSave, texts[lang].save)
        end
        Hso_updateGrid()
    end, false)
end

function Hso_updateGrid()
    if not Hso_grid or not isElement(Hso_grid) then return end
    guiGridListClear(Hso_grid)
    for model, prot in pairs(getAllProtectedModels()) do
        local row = guiGridListAddRow(Hso_grid)
        guiGridListSetItemText(Hso_grid, row, 1, tostring(model), false, false)
        guiGridListSetItemText(Hso_grid, row, 2, prot.veh and "✔" or "✘", false, false)
        guiGridListSetItemText(Hso_grid, row, 3, prot.occ and "✔" or "✘", false, false)
    end
end

addEventHandler("Hso:vp:syncAll", root, function(allModels)
    protectedModels = allModels or {}
end)

addEventHandler("Hso:vp:syncChange", root, function(model, veh, occ)
    if veh ~= nil and occ ~= nil then
        setProtectedModel(model, veh, occ)
    else
        removeProtectedModel(model)
    end
    if Hso_win and isElement(Hso_win) and guiGetVisible(Hso_win) then
        Hso_updateGrid()
    end
end)

addEventHandler("onClientPlayerDamage", localPlayer, function(attacker, weapon, bodypart, loss)
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh then
        local model = getElementModel(veh)
        local prot = getProtectedModel(model)
        if prot and prot.occ then
            cancelEvent()
        end
    end
end)

addEventHandler("onClientVehicleEnter", root, function(thePlayer, seat)
    if thePlayer == localPlayer then
        local model = getElementModel(source)
        local prot = getProtectedModel(model)
        if prot and prot.veh then
            setVehicleDamageProof(source, true)
        else
            setVehicleDamageProof(source, false)
        end
    end
end)

addEventHandler("Hso:vp:openPanel", resourceRoot, function(data)
    protectedModels = data
    Hso_createUI()
    Hso_updateGrid()
    guiSetVisible(Hso_win, true)
    showCursor(true)

end)
