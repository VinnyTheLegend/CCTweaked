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


while true do
    Stress = DA.getKineticStress(Meterside)
    Capacity = DA.getKineticCapacity(Meterside)
    local data = {
        id = 2,
        sender = "Factory",
        stress = Stress,
        capacity = Capacity,
    }
    Modem.transmit(60, 61, data)
    os.sleep(1)
end