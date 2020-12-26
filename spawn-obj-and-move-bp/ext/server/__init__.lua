
-- GUID of an object we know is already loaded in the MP_Subway Super Bundle
-- In this case, it's a small bag
-- See https://github.com/EmulatorNexus/Venice-EBX/blob/ead5472e20bbcfed9a4dbd677bc31547f2607a3d/Levels/MP_Subway/Objects/Bag/Bag.txt
-- Since we're spawning the blueprint, we need the GUID for the primary blueprint instance
bag_GUID = "E79F66DB-007C-9A23-D9F2-231C622268D9 "
bag_partition_GUID = "86109A06-8794-11E0-9345-9992712BCB5C"
bag_spawn_pos = Vec3(-141.074219, 57.755665, -163.667969)
bag_transform = nil


Events:Subscribe('Level:Loaded', function(levelName, gameMode)
    -- This function will fire when the client has loaded the level
    -- Print statements are visible in the console
    print("Level loaded")

    -- This if statement contains two level names
    -- The levelName can be different if running on the Server vs on the Client
    -- On the Client, levelName == "Levels/MP_Subway/MP_Subway"
    -- On the Server, levelName == "MP_Subway"
    -- We could replace the two checks with a single string.ends(...) (This is left as an excercise for the reader...)
    -- See https://docs.veniceunleashed.net/vext/#added-functionality for more details

    -- Since we're running on Server only, we could remove the check for levelName == "Levels/MP_Subway/MP_Subway"
    if (levelName == "Levels/MP_Subway/MP_Subway" or  levelName == "MP_Subway") and gameMode == "ConquestSmall0" then
        bag_transform = LinearTransform()
        bag_transform.trans = bag_spawn_pos
        Events:Dispatch('BlueprintManager:SpawnBlueprint', "bag", Guid(bag_partition_GUID), Guid(bag_GUID), bag_transform)
    end
end)

Events:Subscribe('Engine:Update', function(deltaTime, simulationDeltaTime)
    -- We want to move 1 unit every 1 second
    local delta_x = deltaTime * 1

    if bag_transform ~= nil then
        local current_x = bag_transform.trans.x

        -- Move the bag 5 units in the x direction, then reset to the start pos
        local new_x = (((current_x - bag_spawn_pos.x) + delta_x) % 5) + bag_spawn_pos.x

        bag_transform.trans.x = new_x

        Events:Dispatch('BlueprintManager:MoveBlueprint', "bag", bag_transform)
    end
end)
