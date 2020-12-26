
-- GUID of an object we know is already loaded in the MP_Subway Super Bundle
-- In this case, it's a small bag
-- See https://github.com/EmulatorNexus/Venice-EBX/blob/ead5472e20bbcfed9a4dbd677bc31547f2607a3d/Levels/MP_Subway/Objects/Bag/Bag.txt
bag_GUID = "86109A07-8794-11E0-9345-9992712BCB5C"
bag_spawn_pos = Vec3(-141.074219, 57.755665, -162.667969)

-- A global variable for storing the bag entity
bag_entity = nil

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

    -- Since we're running on Client only, we could remove the check for levelName == "MP_Subway"
    if (levelName == "Levels/MP_Subway/MP_Subway" or  levelName == "MP_Subway") and gameMode == "ConquestSmall0" then
        print("On Level MP_Subway, GameMode is Conquest Small")
        print(levelName)
        -- Use the resource manager to search for the instance
        local bagData = ResourceManager:SearchForInstanceByGuid(Guid(bag_GUID))

        -- bagData will should not be nil because the Bag is included in the MP_Subway Super Bundle
        if bagData ~= nil then
            -- Create a new LinearTransform object and set the bag position
            local bag_transform = LinearTransform()
            bag_transform.trans = bag_spawn_pos

            -- Create the entity
            -- This call will return nil if a script prevented the entity from being created using the EntityFactory:Create hook
            -- or there was something wrong with the data passed in and the engine failed to create it
            -- See the "Dealing with Entities" guide for more details
            bag_entity = EntityManager:CreateEntity(bagData, bag_transform)

            if bag_entity ~= nil then
                -- Since this script is client only, use the Client Realm
                bag_entity:Init(Realm.Realm_Client, true)
            end
        end
    end
end)

Events:Subscribe('Client:PostFrameUpdate', function(deltaTime)
    -- We want to move 1 unit every 1 second
    local delta_x = deltaTime * 1

    if bag_entity ~= nil then
        -- To move the entity, we must first cast it to a SpatialEntity
        local spacial_bag = SpatialEntity(bag_entity)
        local current_x = spacial_bag.transform.trans.x

        -- Move the bag 5 units in the x direction, then reset to the start pos
        local new_x = (((current_x - bag_spawn_pos.x) + delta_x) % 5) + bag_spawn_pos.x

        -- We cannot edit individual transform components, we must assign a new LinearTransfrom to update
        -- Clone the current transform
        local new_transform = spacial_bag.transform:Clone()
        new_transform.trans.x = new_x

        -- Move the bag
        spacial_bag.transform = new_transform
    end
end)
