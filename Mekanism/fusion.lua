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
 
function pwr (val, type)
    local pre = ''
    local suf = ''

    if type == "temp" then
        type = "K"
    else
        type = "FE/t"
    end
   
    local is_neg = false
    if val < 0 then
      pre = '-'
      is_neg = true
      val = -val
    end
    
    if val > 1000 then
      suf = ' k'
      val = val / 1000
    end
    
    if val > 1000 then
      suf = ' M'
      val = val / 1000
    end
    
    if val > 1000 then
      suf = ' G'
      val = val / 1000
    end
    
    if val > 1000 then
      suf = ' T'
      val = val / 1000
    end
    
    return string.format('%s%s%s%s', pre, round(val), suf, type)
end

-- Auto-detects sides
for _, side in pairs(peripheral.getNames()) do
    if 'monitor' == peripheral.getType(side) then
        Monitor = peripheral.wrap(side)
    end
    if 'fusionReactorLogicAdapter' == peripheral.getType(side) then
        Reactor = peripheral.wrap(side)
    end
end


Monitor.clear()

while true do
    local cooled = Reactor.isActiveCooledLogic() --true or false
    local burnrate = Reactor.getInjectionRate()
    local tritiumpercent = round(Reactor.getTritiumFilledPercentage() * 100)
    local deuteriumpercent = round(Reactor.getDeuteriumFilledPercentage() * 100)
    local dtfuelpercent = round(Reactor.getDTFuelFilledPercentage() * 100)
    local productionrate = round(Reactor.getProductionRate() * 0.4)
    local plasmatemp = round(Reactor.getPlasmaTemperature())
    local casingtemp = round(Reactor.getCaseTemperature())

    Monitor.setCursorPos(1,1)
    os.sleep(0.25)
    Monitor.clearLine()
    if cooled == true then
        Monitor.setTextColor(32)
        Monitor.write("Cooled")
    else
        Monitor.setTextColor(16384)
        Monitor.write("Cooled")
    end
    Monitor.setCursorPos(8,1)
    Monitor.setTextColor(1)
    Monitor.write(" Rate: " .. burnrate)

    Monitor.setCursorPos(1,2)
    os.sleep(0.25)
    Monitor.clearLine()
    Monitor.write("Prod.: " .. pwr(productionrate))

    Monitor.setCursorPos(1,3)
    os.sleep(0.25)
    Monitor.clearLine()
    Monitor.write("Plasma: " .. pwr(plasmatemp, "temp"))

    Monitor.setCursorPos(1,4)
    os.sleep(0.25)
    Monitor.clearLine()
    Monitor.write("Casing: " .. pwr(casingtemp, "temp"))

    Monitor.setTextColor(1)
    Monitor.setCursorPos(1,7)
    os.sleep(0.25)
    Monitor.clearLine()
    Monitor.write("DT Fuel: " .. dtfuelpercent .. "%")
    local dtbarval = (dtfuelpercent / 100) * 18
    drawBar(1, 18, 8, 1, 256)
    drawBar(1, dtbarval, 8, 1, 8)

    Monitor.setTextColor(1)
    Monitor.setCursorPos(1,9)
    os.sleep(0.25)
    Monitor.clearLine()
    Monitor.write("Tritium: " .. tritiumpercent .. "%")
    local tbarval = (tritiumpercent / 100) * 18
    drawBar(1, 18, 10, 1, 256)
    drawBar(1, tbarval, 10, 1, 32)

    Monitor.setCursorPos(1,11)
    os.sleep(0.25)
    Monitor.clearLine()
    Monitor.write("Deuterium: " .. deuteriumpercent .. "%")
    local dbarval = (deuteriumpercent / 100) * 18
    drawBar(1, 18, 12, 1, 256)
    drawBar(1, dbarval, 12, 1, 16384)

    os.sleep(1)
end