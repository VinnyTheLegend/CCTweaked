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
    if 'fissionReactorLogicAdapter' == peripheral.getType(side) then
        Reactor = peripheral.wrap(side)
    end
end

Monitor.clear()

while true do
    local status = Reactor.getStatus()
    local burnrate = Reactor.getBurnRate()


    Monitor.setCursorPos(1,1)
    os.sleep(0.25)
    Monitor.clearLine()
    if status == true then
        Monitor.setTextColor(32)
        Monitor.write("Online")
    else
        Monitor.setTextColor(16384)
        Monitor.write("Offline")
    end
    Monitor.setCursorPos(8,1)
    Monitor.setTextColor(1)
    Monitor.write("| Rate: " .. burnrate)

    Monitor.setTextColor(1)
    local coolantpercent = round(Reactor.getCoolantFilledPercentage() * 100)
    Monitor.setCursorPos(1,2)
    os.sleep(0.25)
    Monitor.clearLine()
    Monitor.write("Coolant: " .. coolantpercent .. "%")

    local cbarval = (coolantpercent / 100) * 18
    drawBar(1, 18, 3, 1, 256)
    drawBar(1, cbarval, 3, 1, 8)

    local fuelpercent = round(Reactor.getFuelFilledPercentage() * 100)
    Monitor.setCursorPos(1,4)
    os.sleep(0.25)
    Monitor.clearLine()
    Monitor.write("Fuel: " .. fuelpercent .. "%")

    local fbarval = (fuelpercent / 100) * 18
    drawBar(1, 18, 5, 1, 256)
    drawBar(1, fbarval, 5, 1, 8)

    os.sleep(1)
end