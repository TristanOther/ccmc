-- User settings.
m_loc = "right" -- Which face the monitor is attached to.
me_loc = "bottom" -- Which face the ME is attached to.
interval = 1 -- How many seconds between refreshes.
tracked_items = { -- List of items to display {<display_name>, <item_name>, <nbt>}.
  [1] = {"Iron Ingot", "minecraft:iron_ingot", "0"},
  [2] = {"Pure Certus Quartz", "appliedenergistics2:item.ItemMultiMaterial", "10"}
}

-- System variables.
monitor = peripheral.wrap(m_loc)
me = peripheral.wrap(me_loc)
lastCounts = {} -- List of previous item counts.
toDraw = {} -- List of items that need to be drawn on the next cycle.

-- Function to floor a number to 2 decimal places.
function round(num)
  return math.floor(100 * num) / 100
end

-- Function to check the ME for an item and add it to the toDraw list if found.
function checkMe(checkName, name)
  -- Check list of items in the ME.
  items = me.getAvailableItems()
  for i = 1, #items do
    itemName = items[i].fingerprint.id .. items[i].fingerprint.dmg
    if itemName == checkName then
      -- Calculate correct suffix and factor for the item count.
      count = items[i].size
      suffix = ""
      factor = 1
      if (count / 1000000000000) > 1 then
        suffix = "t"
        factor = 1000000000000
      elseif (count / 1000000000) > 1 then
        suffix = "b"
        factor = 1000000000
      elseif (count / 1000000) > 1 then
        suffix = "m"
        factor = 1000000
      elseif (count / 1000) > 1 then
        suffix = "k"
        factor = 1000
      end
      -- Calculate I/O rate.
      if lastCounts[itemName] == nil then
        lastCounts[itemName] = count
      end
      dif = math.floor(count - lastCounts[itemName])
      color = colors.blue
      prefixn = ""
      if dif > 0 then
        color = colors.green
        prefix = "+"
      elseif dif < 0 then
        color = colors.red
      end
      -- Add item to the list of items to draw.
      toDraw[itemName] = {
        "name" = name,
        "count" = round(count/factor)..suffix,
        "io" = prefix..tostring(dif),
        "color" = color
      }
    end
  end
end

-- Function that checks the ME for configured items.
function checkTable()
  toDraw = {}
  for i = 1, #trackedItems do
    checkName = trackedItems[i][2] .. trackedItems[i][3]
    checkMe(checkName, trackedItems[i][1])
  end
end

-- Function to clear the screen.
function clearScreen()
  monitor.setBackgroundColor(colors.black)
  monitor.clear()
  monitor.setCursorPos(1, 1)
end

-- Function for drawing text to the monitor.
function drawText(text, line, bgColor, color, pos)
  mX, mY = monitor.getSize()
  monitor.setBackgroundColor(bgColor)
  monitor.setTextColor(color)
  length = string.len(text)
  dif = math.floor(mX - length)
  x = math.floor(dif / 2)

  if pos == "L" then
    monitor.setCursorPos(2, line)
  elseif pos == "C" then
    monitor.setCursorPos(x+1, line)
  elseif pos == "R" then
    monitor.setCursorPos(mX - length, line)
  end
  monitor.write(text)
end

-- Function to draw all text.
function drawScreen()
  drawText(" I/O Rates ", 1, colors.gray, colors.white, "C")
  drawText("Name", 2, colors.black, colors.white, "L")
  drawText("Count", 2, colors.black, colors.white, "C")
  drawText("I/O", 2, colors.black, colors.white, "R")
  curLine = 3
  for _, v in ipairs(toDraw) do
    drawText(v["name"], curLine, colors.black, colors.white, "L")
    drawText(v["count"], curLine, colors.black, colors.blue, "C")
    drawText(v["io"], curLine, colors.black, v["color"], "R")
    curLine = curLine + 1
  end
end

-- Run the program.
while true do
  clearScreen()
  checkTable()
  drawScreen()
  sleep(interval)
end

      
    