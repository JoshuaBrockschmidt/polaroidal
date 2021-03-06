--DOIT
-- * tweak controls; make more fluid; will probably keep snapping for petals, though

require "polar"
require "matchGraph"

playerGraph = {}

playerGraph.graph = polar.new(
      love.graphics.getWidth() / 2,
      love.graphics.getHeight() / 2,
      0, 0,
      0, 0, 0
)

playerGraph.keyMaps = {
   incr_a = "i",
   decr_a = "k",
   incr_b = "u",
   decr_b = "o",
   incr_n = "j",
   decr_n = "l"
}

playerGraph.doIncr = {}

playerGraph.doDecr = {}

playerGraph.maxLimits = {
   a = 7,
   b = 6,
   n = 10
}

playerGraph.minLimits = {
   a = -7,
   b = -6,
   n = -10
}

local graph = playerGraph.graph
local km = playerGraph.keyMaps
local doIncr = playerGraph.doIncr
local doDecr = playerGraph.doDecr
local maxLimits = playerGraph.maxLimits
local minLimits = playerGraph.minLimits

-- Change graph transformation variables
graph.maxSpeeds = {
   a = 20,
   b = 20,
   n = 12
}

graph.accels = {
   a = 45,
   b = 45,
   n = 24
}

function playerGraph.reload()
   -- Set all parameters to zero
   for _, par in pairs({"a", "b", "n"}) do
      doIncr[par] = false
      doDecr[par] = false

      graph["set_"..par](graph, 0)
   end

   playerGraph.canMove = false
   timers.new(
      1,
      function()
	 playerGraph.shuffleGraph()
	 playerGraph.canMove = true
      end
   )
end

function playerGraph.shuffleGraph()
   for _, par in pairs({"a", "b", "n"}) do
      local snap = math.random(minLimits[par], maxLimits[par] - 1)

      -- Ensure new parameter is not zero to avoid having an invisible graph
      if snap >= 0 then snap = snap + 1 end
      graph:snapTo(par, snap)
   end
end

function playerGraph.setSnap(k)
   local val = math.floor(graph["get_"..k](graph) + 0.5)
   val = math.max(minLimits[k], math.min(maxLimits[k], val))
   graph:snapTo(k, val)
end

function playerGraph.setIncr(k, bool)
   doIncr[k] = bool
   if bool then
      doDecr[k] = false
      graph:cancelSnap(k)
   elseif love.keyboard.isDown(km["decr_"..k]) then
      doDecr[k] = true
      graph:cancelSnap(k)
   elseif k == "n" then
      playerGraph.setSnap(k)
   end
end

function playerGraph.setDecr(k, bool)
   doDecr[k] = bool
   if bool then
      doIncr[k] = false
      graph:cancelSnap(k)
   elseif love.keyboard.isDown(km["incr_"..k]) then
      doIncr[k] = true
      graph:cancelSnap(k)
   elseif k == "n" then
      playerGraph.setSnap(k)
   end
end

function playerGraph.update(dt)
   local polarPars = {
      a = graph:get_a(),
      b = graph:get_b(),
      n = graph:get_n()
   }

   for k, v in pairs(polarPars) do
      if doIncr[k] then
	 if v > maxLimits[k] then
	    playerGraph.setIncr(k, false)
	 end

      elseif doDecr[k] then
	 if v < minLimits[k] then
	    playerGraph.setDecr(k, false)
	 end
      end

      if doIncr[k] then
	 graph:incrSpeed(k)

      elseif doDecr[k] then
	 graph:decrSpeed(k)
      end
   end

   graph:update(dt)
   graph:calcPoints()
end

function playerGraph.keypressed(key)
   if not playerGraph.canMove then
      return
   end

   for _, k in ipairs({"a", "b", "n"}) do
      if key == km["incr_"..k] then
	 playerGraph.setIncr(k, true)
	 return
      elseif key == km["decr_"..k] then
	 playerGraph.setDecr(k, true)
	 return
      end
   end
end

function playerGraph.keyreleased(key)
   if not playerGraph.canMove then
      return
   end

   for _, k in ipairs({"a", "b", "n"}) do
      if key == km["incr_"..k] then
	 playerGraph.setIncr(k, false)
	 return
      elseif key == km["decr_"..k] then
	 playerGraph.setDecr(k, false)
	 return
      end
   end
end

function playerGraph.draw()
   love.graphics.setColor(0, 0, 127, 255)
   graph:draw(5)
   
   --DEBUGGING
   love.graphics.setColor(0, 200, 0, 255)
   love.graphics.setFont(debugFont)
   love.graphics.print(
      "a:\t" .. graph:get_a()
	 .. "\nb:\t" .. graph:get_b()
	 .. "\nn:\t" .. graph:get_n(),
      5, 5
   )
   --EOF DEBUG
end
