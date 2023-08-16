Config = {}


Config.NPC = {
    model = 's_m_m_scientist_01',
    locations = {
        vec4(959.235168, 3616.259277, 32.750977, 53.858269),
        vec4(959.235168, 3619.872559, 32.632935, 147.401581)
    }
}

Config.RequireItem = 'water'




Config.carModels = { -- Cars that can spawn
    'adder',
    'zentorno',
    'kuruma',
}

Config.MinPolice = 0

Config.truckerDelay = 10 -- in seconds


Config.tuckerLocations = {
    {
        areaPosition = vec3(1275.217529, 3134.927490, 40.400757),
        vehPositions = {
            vec4(1295.986816, 3140.597900, 40.400757, 286.299194),
            vec4(1236.962646, 3124.786865, 40.400757, 104.881889),
        }
    },
    {
        areaPosition = vec3(1365.692261, -579.204407, 74.369995),
        vehPositions = {
            vec4(1359.969238, -609.375793, 74.336304, 0.000000),
            vec4(1355.920898, -547.411011, 73.780273, 155.905502),
        }
    },
}

Config.destroyGPSTime = 10 --time after you can delete GPS from getting to car


Config.GPSRemove = 10000 -- Police blip time to delete after thief destroys GPS


Config.trackerHideoutLocations = { -- Locations to give back vehicle
    vec3(1730.334106, 3314.043945, 41.209473)
}

Config.lang = {
    ['talk_to_npc'] = "Talk to him",
    ['mission_in_progress'] = "I don't have anything for you now",
    ['car_location'] = "I marked the position on the GPS. The car to steal is an %s with the numbers %s",
    ['right_spot'] = "You're at the right spot, now find the car!",
    ['afk'] = "Trucker cancelled due to AFK",
    ['rid_of_gps'] = "Get rid of the GPS in the car, you will receive further instructions after doing this!",
    ['good_job'] = "Good job! Keep in touch!",
    ['stolen_vehicle'] = "Stolen Vehicle!",
    ['gps_off'] = "GPS off. I'm sending the locations to return the vehicle, just make sure no one is following you. Leave the vehicle there and get away",
    ['drop'] = "Drop site",
    ['taking_off_gps'] = "Takin off gps...",
    ['tow_the_vehicle'] = "Tow the vehicle",
    ['towing'] = "Towing the vehicle...",
    ['required_items'] = "You don't have required items!",
    ['gps_take_off'] = "Take off GPS"
}

Config.AFKProtect = 10 --- AFK time in minutes

Config.money = {
    type = "black_money", ---- 'black_money', 'bank', 'money'
    min = 1000, ---- min money
    max = 5000, ---- max money
}