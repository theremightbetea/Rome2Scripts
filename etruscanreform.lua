-- Etruscan Reform Script
-- author: gesuntight


module(..., package.seeall);

_G.main_env = getfenv(1);

-- Object library:

scripting = require "lua_scripts.EpisodicScripting";

-- load libraries

-- require "lua_scripts.Reforms_Script_Header";

-- Log deactivated

isLogAllowed = false;



-- Log function

function Log(text, isTitle, isNew)
  if not isLogAllowed then return end

  local logfile;
  text = tostring(text);
  if isNew then
    logfile = io.open("Etruscan_Reform_Log.txt","w");
    local curr_date = os.date("%A, %m %B %Y");
    local text = tostring("- gesuntight Etruscan Reform Log\n".."- "..curr_date);
    logfile:write(text.."\n\n");
  else
    logfile = io.open("Etruscan_Reform_Log.txt","a");
    if not logfile then logfile = io.open("Etruscan_Reform_Log.txt","w") end
  end

  if isTitle then
    local title_text = "*************************************************************************\n";
    text = "\n"..title_text..text.."\n"..title_text;
  end

  logfile:write(text.."\n");
  logfile:close();
end

-- contains function

function contains(element, list)
  for _, v in ipairs(list) do
    if element == v then
        return true
    end
  end
  return false
end

-- Reform variables

etruscan_first_turn_setup = false
etruscan_reform_successful = false
--etruscan_reform_counter_start = false
--etruscan_reform_counter = 0
etruscan_units_lock = false
etruscan_units_unlock = false
etruscan_player_info = false
etruscan_global_info = false
refCon = false
altCon = false
warAllowed = true
EtrHuman = false

-- unit arrays:

etruscan_deleted_units = 
    {
            "Ita_Noble_Cav",
            "Ita_Noble_Infantry",
            "Ita_Etruscan_Hoplites",
            "Rom_Assault_Quinquereme_Etr",
            "Rom_Assault_Quinquereme_Admiral_Etr",
            "Rom_Assault_Hexareme_Admiral_Etr",
            "Rom_Quinquereme_Ballista_Etr",
            "Rom_Assault_Hexareme_Etr",
    }

etruscan_restricted_units =
        {
            "Etr_Noble_Infantry",
            "Etr_Axemen_gesuntight_reformed",
            "Etr_Thorax_Spears_gesuntight",
            "Etr_Late_Swordsmen",
            "Etr_late_noble_swords",
            "Etr_2Axe_late_gesuntight",
        
            "Etr_late_hastati_ges",
            --"Etr_Sword_Late",
            "Etr_Noble_Cav_Late",
            "Rom_Assault_Quadreme_Etr",
            
        }

etruscan_reform_units =
        {
            "Etr_Noble_Infantry",
            "Etr_Axemen_gesuntight_reformed",
            "Etr_Thorax_Spears_gesuntight",
            "Etr_Late_Swordsmen",
            "Etr_late_noble_swords",
            "Etr_2Axe_late_gesuntight",
            "Etr_late_hastati_ges",
            --"Etr_Sword_Late",
            "Etr_Noble_Cav_Late",
            "Rom_Assault_Quadreme_Etr",
        }

etruscan_disabled_units =
        {
            "Etr_Hoplites",
            "Etr_light_Hoplites",
            "Etr_Mid_Swordsmen",
            "Etr_noble_swords_gesuntight",
            "Principes_Early_Allied_Etr",
            "Hastati_Early_Allied_Etr",
            "Etr_Axemen_gesuntight",
            --"Etr_Sword",
            "Etr_Noble_Cav",
        }
 
-- Etruscan Reform function


local function EtruscanReform(context)
    
    Log("EtruscanReform called")
    
    if context:faction():name() == "rom_etruscan" then
    
    
    
        UpdateRestrictions()

        FirstTurnSetup(context)
        
        EtrDiplomacy(context)
        
        if etruscan_reform_successful == false then
            
            CheckEtruscanReform(context)
            
            Log("Check function called")
                
            if etruscan_reform_counter_start == true then
                    
                CheckEtruscanCounter()
                    
                Log("CheckCounter function called")
                    
            end
                    
        end
            
        if etruscan_reform_counter == 1 then
                
            Log("Reform counter = 1")
                
            effect.advance_contextual_advice_thread("ReformHappening", 1, context)
                
            Log("Advice displayed")
                
        end
            
        if etruscan_reform_successful == true
        and etruscan_units_unlock == false
            
        then
                
            Log("etruscan_reform_successful == true + etruscan_units_unlock == false")
                
            SetEtruscanUnits()
        end
            
        if etruscan_units_unlock == true
        and etruscan_player_info == false
            
        then
            
            if refCon == true
            
            then
                
                scripting.game_interface:show_message_event("custom_event_2608", 0, 0)
                
                Log("Reform Message shown")
                
                etruscan_player_info = true
            
            elseif altCon == true
            
            then
                
                scripting.game_interface:show_message_event("custom_event_2609", 0, 0)
                    
                Log("Alt Reform Message shown")
                
                etruscan_player_info = true
            
            end
            
        elseif context:faction():is_human() == false
        and etruscan_units_unlock == false
        and conditions.TurnNumber(context) >= 100 
        then
            SetEtruscanUnits()
        end
    end
end

function FirstTurnSetup(context)

    if context:faction():name() == "rom_etruscan" then

        Log("faction = etruscan")
        
        if etruscan_units_lock == false
        and etruscan_reform_successful == false 
        
        then
            
            for i = 1, #etruscan_restricted_units do

                local r_units = etruscan_restricted_units[i]

                scripting.game_interface:add_event_restricted_unit_record(r_units)

            end
            
            for j = 1, #etruscan_disabled_units do
        
                local d_units = etruscan_disabled_units[j]
        
                scripting.game_interface:remove_event_restricted_unit_record(d_units)
        
            end
            
            etruscan_units_lock = true
            
            Log("units locked")
        
        end

        etruscan_first_turn_setup = true

        Log("etruscan_first_turn_setup = true")

        if context:faction():is_human()

        and conditions.TurnNumber(context) == 1 then

            scripting.game_interface:show_message_event("custom_event_2607", 0, 0)

            Log("Turn 1 message displayed")

            effect.advance_contextual_advice_thread("ReformTip", 1, context)

            Log("ReformTip displayed")

        end
    end
end

function EtrDiplomacy(context)
    
    Log("EtrDiplomacy called")
    
    if scripting.game_interface:model():world():faction_by_key("rom_etruscan"):is_human()
    then
        EtrHuman = true
        Log("EtrHuman -> true")
    end

    if conditions.TurnNumber(context) == 1 
    and EtrHuman == true
    then
    
        scripting.game_interface:force_make_peace("rom_etruscan","rom_rome")
        Log("peace forced")
        
        if warAllowed == true
        then
            scripting.game_interface:force_diplomacy("rom_rome","rom_etruscan","war",false,true)
            warAllowed = false
            Log("warAllowed -> false")
        end
            
        scripting.game_interface:cai_strategic_stance_manager_clear_all_promotions_between_factions("rom_rome","rom_etruscan")
            
        scripting.game_interface:cai_strategic_stance_manager_clear_all_promotions_between_factions("rom_etruscan","rom_rome")
                
        scripting.game_interface:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction("rom_etruscan","rom_rome","CAI_STRATEGIC_STANCE_FRIENDLY")
            
        scripting.game_interface:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction("rom_rome","rom_etruscan","CAI_STRATEGIC_STANCE_FRIENDLY")
    
    Log("Peace signed")
    end
    
    if EtrHuman == true
    and conditions.TurnNumber(context) == 1
    and warAllowed == false
    then
        scripting.game_interface:show_message_event("custom_event_2611",0,0)
        Log("Peace treaty message displayed")
    end
    
    if conditions.TurnNumber(context) >= 40
    and warAllowed == false
    then
        
        scripting.game_interface:force_diplomacy("rom_rome","rom_etruscan","war",true,true)
        Log("Peace treaty ended")

        warAllowed = true
        
    end
    
    if EtrHuman == true
    and conditions.TurnNumber(context) == 40
    and warAllowed == true
    then
        scripting.game_interface:show_message_event("custom_event_2610",0,0)
        Log("Peace ended message displayed")
    end
end

function CheckEtruscanReform(context)
    
    Log("Check function started")
        
    local asculum = scripting.game_interface:model():world():region_manager():region_by_key("emp_latium_asculum");
    local owner_asculum = asculum:owning_faction():name();
    
    local arminium = scripting.game_interface:model():world():region_manager():region_by_key("emp_latium_ariminium");    
    local owner_arminium = arminium:owning_faction():name();

    local roma = scripting.game_interface:model():world():region_manager():region_by_key("emp_latium_roma");
    local owner_roma = roma:owning_faction():name();
    
    local arretium = scripting.game_interface:model():world():region_manager():region_by_key("emp_latium_arretium");
    local owner_arretium = arretium:owning_faction():name();
    
    Log("Region variables set")
    
    if owner_arretium ~= "rom_rome"
    and owner_asculum ~= "rom_rome"
    and owner_arminium ~= "rom_rome"
    and owner_roma ~= "rom_rome"
    and conditions.TurnNumber(context) >= 80
    
    then 
        
        Log("Check function conditions true")
        
        refCon = true
    
    elseif context:faction():imperium_level() >= 3
    and conditions.TurnNumber(context) >= 100
    
    then
        
        altCon = true
        
        Log("ImpLvl and turn condition true")
        
    end
        
    if refCon == true
    or altCon == true
    
    then
    
        etruscan_reform_successful = true
        
        --etruscan_reform_counter_start = true
        
        --Log("Reform counter started")
    
    --else
        
        --etruscan_reform_counter_start = false
        
        --etruscan_reform_counter = 0
        
        --Log("Reform counter reset")
    
    end
    
    Log("Check function finished")


end

--[[ function CheckEtruscanCounter()
   
    Log("CheckCounter started")
    
    
    if etruscan_reform_counter >= 2
    
    then
        
        etruscan_reform_successful = true
        
        Log("etruscan_reform_successful = true")
        
    else
        
        etruscan_reform_counter = etruscan_reform_counter + 1
        
        Log("etruscan_reform_counter + 1")
    
    end


    Log("CheckCounter finished")
end ]]


function SetEtruscanUnits()
    
    Log("Set function started")
    
    for i = 1, #etruscan_reform_units do
        
        local units1 = etruscan_reform_units[i]
        
        scripting.game_interface:remove_event_restricted_unit_record(units1)
        
    end
    
    Log("reform units unlocked")
    
    for j = 1, #etruscan_disabled_units do
        
        local units2 = etruscan_disabled_units[j]
        
        scripting.game_interface:add_event_restricted_unit_record(units2)
        
    end
    
    Log("old units disabled")
    
    etruscan_units_unlock = true
    
    Log("etruscan_units_unlock = true")
    
    Log("Set function finished")
end

function deleteEtruscanUnits()

    Log("delete units function started")
    
    for i = 1, #etruscan_deleted_units do
    
        local d_unit = etruscan_deleted_units[i]
        
        scripting.game_interface:add_event_restricted_unit_record(d_unit)
        
        Log("unit deleted: " .. d_unit)
    
    end
    
    Log("units deleted")
    
end

local function EtruscanGlobalInfo(context)
    
    local current_faction = context.string
    
    if etruscan_units_unlock == true
    
    and context:faction():is_human() == true
    
    and etruscan_global_info == false
    
    and current_faction ~= "rom_etruscan" then
        
        scripting.game_interface:show_message_event("custom_event_2608", 0, 0)
        
        Log("Global message displayed")
        
        etruscan_global_info = true
        
        etruscan_player_info = true
    end
end

local function RecruitmentButtonListener(context)
    
    if (context.string == "button_recruitment")
    then
        scripting.game_interface:add_time_trigger("HideUnavailableUnitsEtr", 0.1)
        Log("Recruitment button clicked")
    end
end

local function HideUnitsEtr(context)

    if(context.string == "HideUnavailableUnitsEtr")
        then
            local units_panel = UIComponent(scripting.m_root:Find("main_units_panel"))
            for _, name in pairs(etruscan_deleted_units)
            do
                local unit_name = name.."_recruitable"
                local unit_card = units_panel:Find(unit_name)
                local unit_card_parent = UIComponent(unit_card):Parent()
                UIComponent(unit_card):SetDisabled(true)
                UIComponent(unit_card_parent):Divorce(unit_card)
            end
            Log("deleted units hidden")
        end

    if etruscan_units_unlock == false 
    then
        if(context.string == "HideUnavailableUnitsEtr")
        then
            local units_panel = UIComponent(scripting.m_root:Find("main_units_panel"))
            for _, name in pairs(etruscan_restricted_units)
            do
                local unit_name = name.."_recruitable"
                local unit_card = units_panel:Find(unit_name)
                local unit_card_parent = UIComponent(unit_card):Parent()
                UIComponent(unit_card):SetDisabled(true)
                UIComponent(unit_card_parent):Divorce(unit_card)
            end
            Log("Units hidden")
        end
    elseif etruscan_units_unlock == true
    then
        if(context.string == "HideUnavailableUnitsEtr")
        then
            local units_panel = UIComponent(scripting.m_root:Find("main_units_panel"))
            for _, name in pairs(etruscan_disabled_units)
            do
                local unit_name = name.."_recruitable"
                local unit_card = units_panel:Find(unit_name)
                local unit_card_parent = UIComponent(unit_card):Parent()
                UIComponent(unit_card):SetDisabled(true)
                UIComponent(unit_card_parent):Divorce(unit_card)
            end
            Log("Units hidden")
        end        
    end
end

function UpdateRestrictions()

    Log("UpdateRestrictions called")

    deleteEtruscanUnits()

    if etruscan_reform_successful == false
    
    then

        for i = 1, #etruscan_restricted_units do

            local r_units = etruscan_restricted_units[i]

            scripting.game_interface:add_event_restricted_unit_record(r_units)
            
        end
    
    end
    
    if etruscan_reform_successful == true
    
    then
        
        for i = 1, #etruscan_reform_units do
        
            local n_units = etruscan_reform_units[i]
            
            scripting.game_interface:remove_event_restricted_unit_record(n_units)
            
        end
        
        for i = 1, #etruscan_disabled_units do
        
            local d_units = etruscan_disabled_units[i]
            
            scripting.game_interface:add_event_restricted_unit_record(d_units)
            
        end
    
    end
    
    Log("Unit restrictions updated")
    
end

local function OnSavingEtruscan(context)
    scripting.game_interface:save_named_value("warAllowed", warAllowed, context)
    scripting.game_interface:save_named_value("refCon", refCon, context)
    scripting.game_interface:save_named_value("altCon", altCon, context)
    scripting.game_interface:save_named_value("etruscan_reform_successful", etruscan_reform_successful, context)
    scripting.game_interface:save_named_value("etruscan_reform_counter", etruscan_reform_counter, context)
    scripting.game_interface:save_named_value("etruscan_reform_counter_start", etruscan_reform_counter_start, context)
    scripting.game_interface:save_named_value("etruscan_units_lock", etruscan_units_lock, context)
    scripting.game_interface:save_named_value("etruscan_units_unlock", etruscan_units_unlock, context)
    scripting.game_interface:save_named_value("etruscan_global_info", etruscan_global_info, context)
    scripting.game_interface:save_named_value("etruscan_first_turn_setup", etruscan_first_turn_setup, context)
    scripting.game_interface:save_named_value("etruscan_player_info", etruscan_player_info, context)
end

local function OnLoadingEtruscan(context)
    warAllowed = scripting.game_interface:load_named_value("warAllowed", warAllowed, context)
    etruscan_reform_successful = scripting.game_interface:load_named_value("refCon", refCon, context)
    etruscan_reform_successful = scripting.game_interface:load_named_value("altCon", altCon, context)
    etruscan_reform_successful = scripting.game_interface:load_named_value("etruscan_reform_successful", false, context)
    etruscan_reform_counter_start = scripting.game_interface:load_named_value("etruscan_reform_counter_start", false, context)
    etruscan_reform_counter = scripting.game_interface:load_named_value("etruscan_reform_counter", 0, context)
    etruscan_units_lock = scripting.game_interface:load_named_value("etruscan_units_lock", false, context)
    etruscan_units_unlock = scripting.game_interface:load_named_value("etruscan_units_unlock", false, context)
    etruscan_global_info = scripting.game_interface:load_named_value("etruscan_global_info", false, context)
    etruscan_player_info = scripting.game_interface:load_named_value("etruscan_player_info", false, context)
    etruscan_first_turn_setup = scripting.game_interface:load_named_value("etruscan_first_turn_setup", false, context)
end
--------------------------------------------------------------------------------------
scripting.AddEventCallBack("FactionTurnStart", EtruscanReform)
scripting.AddEventCallBack("FactionTurnStart", EtruscanGlobalInfo)
scripting.AddEventCallBack("LoadingGame", OnLoadingEtruscan)
scripting.AddEventCallBack("SavingGame", OnSavingEtruscan)
scripting.AddEventCallBack("ComponentLClickUp", RecruitmentButtonListener)
scripting.AddEventCallBack("TimeTrigger", HideUnitsEtr)
--------------------------------------------------------------------------------------------------------
