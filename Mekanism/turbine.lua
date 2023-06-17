--Round Function
function round(float)
    local int, part = math.modf(float)
    if float == math.abs(float) and part >= .5 then return int+1
    elseif part <= -.5 then return int-1
    end
    return int
end

--Draw Function
function draw(xmin, xmax, ymin, ymax, c)
    Monitor.setBackgroundColor(c)
    Monitor.setCursorPos(xmin, ymin)
    if xmax ~= 1 then
        for i = 1, xmax, 1 do
            Monitor.write(" ")
            Monitor.setCursorPos(xmin+i, ymin)
        end
    end
    if ymax ~= 1 then
        for k = 1, ymax, 1 do
            Monitor.write(" ")
            Monitor.setCursorPos(xmin, ymin+k)
        end
    end
    Monitor.setBackgroundColor(32768)
end
 
--DrawBar Function
function drawBar(xmin, xmax, y, r, c)
    for i=1, r, 1 do    
        draw(xmin, xmax, y+i-1, 1, c)
    end
end
 

-- Auto-detects sides
for _, side in pairs(peripheral.getNames()) do
    if 'monitor' == peripheral.getType(side) then
        Monitor = peripheral.wrap(side)
    end
    if 'turbineValve' == peripheral.getType(side) then
        Turbine = peripheral.wrap(side)
    end
end

Monitor.clear()

while true do
    local flowrate = Turbine.getFlowRate()
    local maxflow = Turbine.getMaxFlowRate()
    if flowrate == 0 then
        Monitor.setTextColor(16384)
    else
        Monitor.setTextColor(32)
    end
    Monitor.setCursorPos(1,1)
    os.sleep(0.25)
    Monitor.clearLine()
    Monitor.write("FlowRate: " .. flowrate .. " mB/t")

    local flowbarval = round((flowrate / maxflow) * 29)
    drawBar(1, 29, 2, 1, 256)
    drawBar(1, flowbarval, 2, 1, 8)

    Monitor.setTextColor(1)

    local production = Turbine.getProductionRate()
    Monitor.setCursorPos(1,3)
    os.sleep(0.25)
    Monitor.clearLine()
    Monitor.write("Production: " .. round(production * 0.4) .. " FE/t")

    local steampercent = Turbine.getSteamFilledPercentage()
    Monitor.setCursorPos(1,4)
    os.sleep(0.25)
    Monitor.clearLine()
    Monitor.write("Steam: " .. round(steampercent * 100) .. "%")

    local energyfilled = Turbine.getEnergyFilledPercentage()
    Monitor.setCursorPos(1,5)
    os.sleep(0.25)
    Monitor.clearLine()
    Monitor.write("Battery: " .. round(energyfilled * 100) .. "%")

    os.sleep(1)
end