if love.system.getOS() ~= "Web" then
  lume = require "lib.lume"
  lurker = require "lib.lurker"
  if lurker then
    lurker.postswap = function(f)
      love.load()
    end
  end
end

local fontBig
local fontSmall
local catsnake
local face
local spindle
local glass
local hhand
local mhand
local shand

local settings = {
  color = {
    weekday_bg = { 0.4, 0.4, 0.4 },
    weekday_fg = { 1, 1, 1 },
    calendar_bg = { 1, 1, 1 },
    calendar_fg = { 0, 0, 0 },
    clock_bg = { 1, 1, 1 },
    clock_fg = { 0, 0, 0 },
    calendar_day_bg = { 0, 0, 1 },
    calendar_day_fg = { 1, 1, 1 }
  }
}

-- set initial date to now
local date_showing = os.date("*t")

-- offset of view from current month
local month_offset = 0

-- save on repeated math
local pi2 = math.pi * 2
local log2 = math.log(2)

-- almost identical to the function found in the LOVE docs; this one simply adds
-- the source image's width & height to its return
function newPaddedImage(filename)
    local source = love.image.newImageData(filename)
    local w, h = source:getWidth(), source:getHeight()
    local paddedData = {}
    -- Find closest power-of-two.
    local wp = math.pow(2, math.ceil(math.log(w)/log2))
    local hp = math.pow(2, math.ceil(math.log(h)/log2))
    -- Only pad if needed:
    if wp ~= w or hp ~= h then
        local padded = love.image.newImageData(wp, hp)
        padded:paste(source, 0, 0)
        paddedData.image=love.graphics.newImage(padded)
    else paddedData.image=love.graphics.newImage(source)
    end
    paddedData.w=w
    paddedData.h=h
    return paddedData
end

function drawCalendar(date, x, y, width, height)
  local cell_width = (width - 70) / 7
  local cell_height = (height - 60) / 7
  local daysOfWeek = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }
  local firstDay = os.date("*t", os.time{year=date.year, month=date.month, day=1, hour=0, sec=1})
  local lastDay = os.date("*t", os.time{year=date.year, month=date.month + 1, day=0, hour=0, sec=1})
  
  for column = 1, 7 do
    -- draw weekday headers
    love.graphics.setFont(fontBig)
    local xpos = x + ((cell_width + 10) * (column-1))
    love.graphics.setColor(settings.color.weekday_bg)
    love.graphics.rectangle("fill", xpos, y, cell_width, 60)
    love.graphics.setColor(settings.color.weekday_fg)
    love.graphics.printf(daysOfWeek[column], xpos, y + 5, cell_width, "center")

    love.graphics.setFont(fontSmall)
    for row = 1, 6 do
      local rowPosition = row * (cell_height + 10)

      -- the day the calendar is currently drawing
      local d = column + ((row - 1) * 7) - firstDay.wday + 1

      -- draw day backgrounds
      if date.day == d then
        love.graphics.setColor(settings.color.calendar_day_bg)
      else
        love.graphics.setColor(settings.color.calendar_bg)
      end
      love.graphics.rectangle("fill", xpos, y + rowPosition, cell_width, cell_height)

      -- draw day numbers
      if d > 0 and d <= lastDay.day then
        if date.day == d then
          love.graphics.setColor(settings.color.calendar_day_fg)
        else
          love.graphics.setColor(settings.color.calendar_fg)
        end
        love.graphics.printf(d, xpos + 5, y + rowPosition, cell_width, "left")
      end
    end
  end
end

function drawClock(time, x, y, s)
  love.graphics.setColor(1, 1, 1, 1)
  s=s or 1
  local dsec = pi2*(time["sec"]/60)
  local dmin = pi2*(time["min"]/60)
  local dhour = pi2*(((math.fmod(time["hour"],12)*60)+time["min"])/720)
  local origin = face.w/2
  local handoffset=origin*s
  love.graphics.draw(face.image,x,y,0,s,s)
  love.graphics.draw(spindle.image,x,y,0,s,s)
  love.graphics.draw(hhand.image,x+handoffset,y+handoffset,dhour,s,s,origin,origin)
  love.graphics.draw(mhand.image,x+handoffset,y+handoffset,dmin,s,s,origin,origin)
  love.graphics.draw(shand.image,x+handoffset,y+handoffset,dsec,s,s,origin,origin)
  love.graphics.draw(glass.image,x,y,0,s,s)
end

function love.load()
  fontBig = love.graphics.newFont("assets/comicsans.ttf", 35)
  fontSmall = love.graphics.newFont("assets/comicsans.ttf", 20)
  catsnake = love.graphics.newImage("assets/catsnake.png")
  face = newPaddedImage("assets/face.png")
  spindle = newPaddedImage("assets/spindle.png")
  glass = newPaddedImage("assets/glass.png")
  hhand = newPaddedImage("assets/hhand.png")
  mhand = newPaddedImage("assets/mhand.png")
  shand = newPaddedImage("assets/shand.png")
end

function love.mousepressed( x, y, button, istouch, presses )
  if y < 40 then
    if x < 30 then
      month_offset = month_offset - 1
    end
    if x > 1260 then
      month_offset = month_offset + 1
    end
  end
end

function love.update(dt)
  if lurker then
    lurker.update(dt)
  end
  date_showing = os.date("*t")
  date_showing.month = date_showing.month + month_offset
end

function love.draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(catsnake, 40, 0)
  drawCalendar(date_showing, 40, 260, 1200, 420)
  drawClock(date_showing, 980, 0)
  love.graphics.setFont(fontBig)
  love.graphics.printf(os.date("%B %Y", os.time(date_showing)), 0,0, 1280, "center")
  love.graphics.print("<", 10, 0)
  love.graphics.print(">", 1260, 0)
end