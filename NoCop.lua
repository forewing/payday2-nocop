_G.NoCop = _G.NoCop or {}
NoCop._path = ModPath
NoCop._data_path = SavePath .. "no_cop_data.json"
NoCop._data = {}

--[[
	Menu logics
]]
function NoCop:Save()
    local file = io.open(self._data_path, "w+")
    if file then
        file:write(json.encode(self._data))
        file:close()
    end
end

function NoCop:Load()
    local file = io.open(self._data_path, "r")
    if file then
        self._data = json.decode(file:read("*all"))
        file:close()
    end
end

function isNoCopEnabled()
    if NoCop._data.enable_value == nil then
        NoCop:Load()
    end
    return NoCop._data.enable_value
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_NoCop", function(loc)
    loc:load_localization_file(NoCop._path .. "loc/en.json")
end)

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_NoCop", function(menu_manager)
    MenuCallbackHandler.no_cop_callback_enable_toggle = function(self, item)
        NoCop._data.enable_value = (item:value() == "on" and true or false)
        NoCop:Save()
        log("Toggle is: " .. item:value())
    end

    NoCop:Load()
    MenuHelper:LoadFromJsonFile(NoCop._path .. "menu.json", NoCop, NoCop._data)
end)

--[[
	Mod logics
]]
if (isNoCopEnabled() == true and Global.game_settings.single_player) then

    local init = GroupAITweakData.init
    function GroupAITweakData:init(...)
        init(self, ...)
        self.special_unit_spawn_limits = {
            shield = 0,
            medic = 0,
            taser = 0,
            tank = 0,
            spooc = 0
        }
        for _, group in pairs(self.enemy_spawn_groups) do
            group.amount = {0, 0}
            if group.spawn then
                for _, spawn in pairs(group.spawn) do
                    spawn.amount_min = 0
                    spawn.amount_max = 0
                    spawn.freq = 0
                end
            end
        end
    end

end
