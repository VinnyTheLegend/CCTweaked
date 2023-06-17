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
    if 'modem' == peripheral.getType(side) then
      Modem = peripheral.wrap(side)
    end
    if 'monitor' == peripheral.getType(side) then
        Monitor = peripheral.wrap(side)
      end
end

Modem.open(60)
Monitor.clear()
Monitor.setTextScale(1.5)

while true do
    local event, side, channel, replyChannel, message, distance
    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    until channel == 60

    local output = tostring(message.sender .. ": " .. message.stress .. "/" .. message.capacity)
    print(output)
    
    local line = message.id
    if line ~= 1 then
        line = line * 2 - 1
    end

    Monitor.setCursorPos(1,line)
    Monitor.clearLine()
    Monitor.write(output)

    local barval = round(20 * (message.stress / message.capacity))
    drawBar(1, 20, line + 1, 1, 256)
    drawBar(1, barval, line + 1, 1, 8)
    print("line " .. line)

end