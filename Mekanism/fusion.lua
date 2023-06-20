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

function Listen(target)
    local event, side, channel, replyChannel, message, distance
    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    until channel == 50
    print(textutils.formatTime(os.time("local")) .. " message recieved")
    return message
end


function Startup()
    if not fs.exists('/startup.lua') then
        fs.copy('/fusion.lua', '/startup.lua')
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
    local input
    while input ~= 1 and input ~= 2 do
        print("transmitter or reciever?")
        print("1. transmitter")
        print("2. reciever")
        write("selection: ")
        input = tonumber(read())
        os.sleep(0.25)
    end
    if input == 1 then
        data.Reciever = false
    elseif input == 2 then
        data.Reciever = true
    end
    SaveConfig(data)
end

Startup()
Config = LoadConfig()
Reciever = Config.Reciever

if Reciever == true then
    Reactor = true
end

-- Auto-detects sides
while Reactor == nil or Modem == nil do
    for _, side in pairs(peripheral.getNames()) do
        if 'monitor' == peripheral.getType(side) then
            Monitor = peripheral.wrap(side)
        end
        if 'fusionReactorLogicAdapter' == peripheral.getType(side) then
            Reactor = peripheral.wrap(side)
        end
        if 'modem' == peripheral.getType(side) then
            Modem = peripheral.wrap(side)
            print('modem found')
        end
    end
end


print("starting monitor")
Modem.open(50)
Monitor.clear()
Data = {}
while true do
    if Reciever == false then
        Data.cooled = Reactor.isActiveCooledLogic() --true or false
        Data.burnrate = Reactor.getInjectionRate()
        Data.tritiumpercent = round(Reactor.getTritiumFilledPercentage() * 100)
        Data.deuteriumpercent = round(Reactor.getDeuteriumFilledPercentage() * 100)
        Data.dtfuelpercent = round(Reactor.getDTFuelFilledPercentage() * 100)
        Data.productionrate = round(Reactor.getProductionRate() * 0.4)
        Data.plasmatemp = round(Reactor.getPlasmaTemperature())
        Data.casingtemp = round(Reactor.getCaseTemperature())
        Modem.transmit(50, 51, Data)
        print(textutils.formatTime(os.time("local")) .. " message sent")
    else
        Data = Listen(50)
    end

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
    Monitor.write(" Rate: " .. Data.burnrate)

    Monitor.setCursorPos(1,2)
    os.sleep(0.25)
    Monitor.clearLine()
    Monitor.write("Prod.: " .. pwr(Data.productionrate))

    Monitor.setCursorPos(1,3)
    os.sleep(0.25)
    Monitor.clearLine()
    Monitor.write("Plasma: " .. pwr(Data.plasmatemp, "temp"))

    Monitor.setCursorPos(1,4)
    os.sleep(0.25)
    Monitor.clearLine()
    Monitor.write("Casing: " .. pwr(Data.casingtemp, "temp"))

    Monitor.setTextColor(1)
    Monitor.setCursorPos(1,7)
    os.sleep(0.25)
    Monitor.clearLine()
    Monitor.write("DT Fuel: " .. Data.dtfuelpercent .. "%")
    local dtbarval = (Data.dtfuelpercent / 100) * 18
    drawBar(1, 18, 8, 1, 256)
    drawBar(1, dtbarval, 8, 1, 8)

    Monitor.setTextColor(1)
    Monitor.setCursorPos(1,9)
    os.sleep(0.25)
    Monitor.clearLine()
    Monitor.write("Tritium: " .. Data.tritiumpercent .. "%")
    local tbarval = (Data.tritiumpercent / 100) * 18
    drawBar(1, 18, 10, 1, 256)
    drawBar(1, tbarval, 10, 1, 32)

    Monitor.setCursorPos(1,11)
    os.sleep(0.25)
    Monitor.clearLine()
    Monitor.write("Deuterium: " .. Data.deuteriumpercent .. "%")
    local dbarval = (Data.deuteriumpercent / 100) * 18
    drawBar(1, 18, 12, 1, 256)
    drawBar(1, dbarval, 12, 1, 16384)

    os.sleep(1)
end