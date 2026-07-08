require ecs
require Mission
require DagorDataBlock
require DagorSystem
require strings
require Unit


[es(on_event=EventEcsMissionLoaded, tag=server)]
def unit_loader_init(evt : Event;
                     eid : EntityId;
                     setting__unitType : string;
                     setting__className, setting__unit_class : string;
                     setting__tm : float3x4;
                     setting__name : string;
                     setting__army : int;
                     setting__playerNo : int;
                     setting__unit_target_list : StringList;
                     var setting__count : int&;
                     setting__active : bool;
                     setting__canChangeUnit : bool)
  if setting__count > 1
    logerr("unit_loader: setting__count {setting__count} > 1 is no longer supported and will be ignored name:{empty(setting__className) ? setting__unit_class : setting__className}")
    setting__count = 1
  if setting__playerNo != -1
    logerr("unit_loader: setting__playerNo {setting__playerNo} is not supported, set it to -1 or omit it name:{empty(setting__className) ? setting__unit_class : setting__className}")

  
  if setting__unitType == "objectGroups"
    using() <| $(var blk : DataBlock)
      add(blk, "unit_class", setting__unit_class)
      datablock_add_block(blk, "props") <| $(prop)
        add(prop, "name", setting__name)
        add(prop, "army", setting__army)
        add(prop, "active", setting__active)
      create_object_group(setting__tm, blk)
    print("unit_loader: re-create into object group name:{setting__unit_class}")
    destroyEntity(eid)
    return

  
  
  
  
  
  
  
  
  
  
  let customTemplatePrefix = "template:"
  var templateName = ""
  let fullUnitName = empty(setting__className) ? setting__unit_class : setting__className
  if starts_with(setting__unitType, customTemplatePrefix)
    templateName = slice(setting__unitType, length(customTemplatePrefix))
  else
    var unitTypeHint = UnitType.UT_Unknown
    var isValidType = true
    if setting__unitType == "tank"
      unitTypeHint = UnitType.UT_HeavyVehicle
    elif setting__unitType == "ship"
      unitTypeHint = UnitType.UT_Ship
    elif setting__unitType == "lightVehicle"
      unitTypeHint = UnitType.UT_LightVehicle
    elif setting__unitType == "barrageBalloon"
      unitTypeHint = UnitType.UT_Balloon
    elif setting__unitType == "walker"
      unitTypeHint = UnitType.UT_WalkerVehicle
    elif setting__unitType == "infantry"
      unitTypeHint = UnitType.UT_InfTroop
    elif setting__unitType == "fortification"
      unitTypeHint = UnitType.UT_Fortification
    elif setting__unitType == "aircraft"
      unitTypeHint = UnitType.UT_Airplane
    elif setting__unitType == "human"
      unitTypeHint = UnitType.UT_Human
    elif setting__unitType != ""
      isValidType = false
    if isValidType
      templateName = resolve_unit_ecs_template_from_name(fullUnitName, unitTypeHint)

  if templateName == ""
    let errorStr = "unit_loader: failed to resolve type:{setting__unitType} name:{fullUnitName} pos:{setting__tm[3]}"
    if length(dgs_get_settings() |> datablock_getStr("hangarBlk", "")) > 0 
      logwarn(errorStr)
    else
      logerr(errorStr)
    destroyEntity(eid)
    return

  if !empty(setting__unit_target_list)
    templateName += "+unit_target_list"

  print("unit_loader: re-create into template:{templateName}(type:{setting__unitType}) eid:{eid} name:{fullUnitName} pos:{setting__tm[3]}")
  addSubTemplate(eid, templateName) <| $(init)
    init |> set("transform", setting__tm)
    init |> set("unit__canChangeUnitInHangar", setting__canChangeUnit)
    
    
    
    init |> set("unit__verifyEcsTemplate", false)
    if !empty(setting__unit_target_list)
      init |> set("unit_target_list", setting__unit_target_list)
ollisions)
    add(blk, "canControlInHangar", setting__canControlInHangar)
    for i in range(0, length(setting__bullets))
      let bullet = string(setting__bullets[i])
      add(blk, "bullets{i}", bullet)
    for i in range(0, length(setting__bulletsCount))
      add(blk, "bulletsCount{i}", setting__bulletsCount[i])
    datablock_add_block(blk, "props") <| $(prop)
      add(prop, "isDelayed", setting__isDelayed)
      add(prop, "isDead", setting__isDead)
      add(prop, "active", setting__active)
      add(prop, "skin", setting__skin)
      add(prop, "shouldDrawSmallIndForMissTarget", setting__shouldDrawSmallIndForMissTarget)
      add(prop, "uniqueName", setting__uniqueName)
      add(prop, "count", setting__count)
      add(prop, "attack_type", setting__attack_type)
      add(prop, "army", setting__army)
      add(prop, "formation_type", setting__formation_type)
      add(prop, "formation_div", setting__formation_div)
      add(prop, "formation_step", setting__formation_step)
      add(prop, "formation_noise", setting__formation_noise)
      add(prop, "stealthRadius", setting__stealthRadius)
      add(prop, "supportUnitType", setting__supportUnitType)
      add(prop, "targetAir", setting__targetAir)
      add(prop, "targetGnd", setting__targetGnd)
      add(prop, "targetAAA", setting__targetAAA)
      add(prop, "maxDeviationAngle", setting__maxDeviationAngle)
      add(prop, "moveSysTraceRI", setting__moveSysTraceRI)
      add(prop, "accuracy", setting__accuracy)
      add(prop, "effShootingRate", setting__effShootingRate)
      add(prop, "lightlyArmored", setting__lightlyArmored)
      add(prop, "avoidObstacles", setting__avoidObstacles)
      add(prop, "targetableByAi", setting__targetableByAi)
      add(prop, "aiEnabled", setting__aiEnabled)
      add(prop, "isImmortal", setting__isImmortal)
      add(prop, "calmDetection", setting__calmDetection)
      add(prop, "aiReloadMult", setting__aiReloadMult)
      add(prop, "speed", setting__speed)
      add(prop, "name", setting__name)
    datablock_add_block(blk, "targetList") <| $(tBlk)
      for i in range(0, length(setting__unit_target_list))
        let target = string(setting__unit_target_list[i])
        add(tBlk, "t", target)

[es(on_event=EventEcsMissionLoaded, tag=server)]
def unit_loader_init(evt : Event;
                     eid : EntityId;
                     setting__unitType, setting__className : string;
                     setting__tm : float3x4;
                     setting__playerNo, setting__flags : int)
  using() <| $(var settingsBlk : DataBlock)
    components_to_blk(settingsBlk, eid)

    if setting__unitType == "ship"
      create_ship(setting__className, setting__tm, settingsBlk, setting__playerNo, 0)
    elif setting__unitType == "tank"
      create_tank(setting__className, setting__tm, settingsBlk, setting__playerNo, 0)
    elif setting__unitType == "lightVehicle"
      create_light_vehicle(setting__className, setting__tm, settingsBlk, setting__playerNo, 0)
    elif setting__unitType == "barrageBalloon"
      create_barrage_balloon(setting__className, setting__tm, settingsBlk, setting__playerNo, 0)
    elif setting__unitType == "walker"
      create_walker(setting__className, setting__tm, settingsBlk, setting__playerNo, 0)
    elif setting__unitType == "infantry"
      create_infantry(setting__className, setting__tm, settingsBlk, setting__playerNo, 0)
    elif setting__unitType == "fortification"
      create_fortification(setting__className, setting__tm, settingsBlk, setting__playerNo, setting__flags)
    elif setting__unitType == "aircraft"
      create_aircraft(setting__className, setting__tm, settingsBlk, setting__playerNo, 0)
    elif setting__unitType == "objectGroups"
      create_object_group(setting__tm, settingsBlk)
    elif setting__unitType == "human"
      create_human(setting__className, setting__tm, settingsBlk, setting__playerNo, setting__flags)

    let customTemplatePrefix = "template:"
    if starts_with(setting__unitType, customTemplatePrefix)
      add(settingsBlk, "ecsTemplateOverride", slice(setting__unitType, length(customTemplatePrefix)))
      create_tank(setting__className, setting__tm, settingsBlk, setting__playerNo, 0)
  destroyEntity(eid)
