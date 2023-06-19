-- Auto-detects sides
for _, side in pairs(peripheral.getNames()) do
    if 'modem' == peripheral.getType(side) then
      Modem = peripheral.wrap(side)
    end
    if 'digital_adapter' == peripheral.getType(side) then
      DA = peripheral.wrap(side)
    end
end

for _, side in pairs({"top", "bottom", "north", "south", "east", "west"}) do
    Stress = DA.getKineticStress(side)
    if Stress ~= 0 then
        Meterside = side
    end 
end

function Startup()
    if fs.exists('/startup.lua') then
        fs.delete('/startup.lua')
        fs.copy('/create_transmitter.lua', '/startup.lua')
    end
end

function SaveConfig(data)
    if not fs.exists('/data/config.txt') then
        fs.makeDir('/data')
    end
    local f = fs.open('/data/config.txt', 'w')
    f.write(textutils.serialize(data))
    f.close()
end
 
function LoadConfig()
    local data = nil
    if fs.exists('/data/config.txt') then
        print('config found')
        local file = fs.open('/data/config.txt', 'r')
        os.sleep(0.1)
        local text = file.readAll()
        os.sleep(0.1)
        data = textutils.unserialize(text)
        file.close()
    else
        print('config not found')
    end
    return data
end

if not fs.exists('/data/config.txt') then
    local data = {}
    while tonumber(data.id) == nil or data.displayname == nil do
        write("id: ")
        data.id = read()
        write("display name: ")
        data.displayname = read()
        os.sleep(1)
    end
    SaveConfig(data)
    Startup()
end

Config = LoadConfig()
print('starting transmitter...')
while true do
    Stress = DA.getKineticStress(Meterside)
    Capacity = DA.getKineticCapacity(Meterside)
    local data = {
        id = Config.id,
        sender = Config.displayname,
        stress = Stress,
        capacity = Capacity,
    }
    Modem.transmit(60, 61, data)
    os.sleep(1)
end