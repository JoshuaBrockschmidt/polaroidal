matchGraph = {}

matchGraph.graph = polar.new(
   love.graphics.getWidth() / 2,
   love.graphics.getHeight() / 2,
   0, 50,
   2, 4, 2
)

-- When checking if this and the player's polar graph's match, this is how
-- much lenience will be granted for each parameter. The absolute difference
-- between each of the player's parameters must be less than or equal to it's
-- "fuzz," respectively.
matchGraph.fuzz = {
   a = .2,
   b = .3,
   n = .2,
}

local graph = matchGraph.graph
local fuzz = matchGraph.fuzz

function matchGraph.load()
   return --> PLACEHOLDER
end

function matchGraph.graphsMatch()
   plyr = {
      a = playerGraph.graph:get_a(),
      b = playerGraph.graph:get_b(),
      n = playerGraph.graph:get_n()
   }

   this = {
      a = matchGraph.graph:get_a(),
      b = matchGraph.graph:get_b(),
      n = matchGraph.graph:get_n()
   }

   -- If 'b' or 'n' is near 0
   if math.abs(this.n) <= matchGraph.fuzz.n
   or math.abs(this.b) <= matchGraph.fuzz.b then
      -- Ensure 'b' or 'n' of player's graph are near 0
      if not (
	 math.abs(plyr.n) <= matchGraph.fuzz.n
	 or math.abs(plyr.b) <= matchGraph.fuzz.b
      ) then
	 return false
      end

      if math.abs(math.abs(plyr.a) - math.abs(this.a)) > matchGraph.fuzz.a then
	 return false
      end
   --[[
   -- If 'n' is near 0
   if math.abs(this.n) <= matchGraph.fuzz.n then
      -- Disregard 'b'

      if math.abs(math.abs(plyr.a) - math.abs(this.a)) > matchGraph.fuzz.a then
	 return false
      end

      if math.abs(plyr.n - this.n) > matchGraph.fuzz.n then
	 return false
      end

   -- If 'b' is near 0
   elseif math.abs(this.b) <= matchGraph.fuzz.b then
      -- Disregard 'n'

      if math.abs(math.abs(plyr.a) - math.abs(this.a)) > matchGraph.fuzz.a then
	 return false
      end

      if math.abs(plyr.b - this.b) > matchGraph.fuzz.b then
	 return false
      end
   --]]

   -- If 'n' is odd
   elseif isOdd(this.n) then
      if math.abs(math.abs(plyr.a) - math.abs(this.a)) > matchGraph.fuzz.a then
	 return false
      end

      -- True for positive sign. False for negative sign.
      local plyr_sign = (plyr.b >= 0) == (plyr.n >= 0)
      local this_sign = (this.b >= 0) == (this.n >= 0)

      if plyr_sign ~= this_sign then
	 return false
      end

      if math.abs(math.abs(plyr.b) - math.abs(this.b)) > matchGraph.fuzz.b then
	 return false
      end

      if math.abs(math.abs(plyr.n) - math.abs(this.n)) > matchGraph.fuzz.n then
	 return false
      end

   -- Regular checking
   else
      -- True for positive sign. False for negative sign.
      local plyr_sign = true
      local this_sign = true

      for k, plyr_v in pairs(plyr) do
	 plyr_sign = plyr_sign == (plyr_v >= 0)
	 this_sign = this_sign == (this[k] >= 0)
      end

      if plyr_sign ~= this_sign then
	 return false
      end

      for k, plyr_v in pairs(plyr) do
	 if math.abs(math.abs(plyr_v) - math.abs(this[k])) > matchGraph.fuzz[k] then
	    return false
	 end
      end
   end

   return true
end

function matchGraph.shuffleGraph()
   local polarPars = {
      a = graph:get_a(),
      b = graph:get_b(),
      n = graph:get_n()
   }

   for k, v in pairs(polarPars) do
      local new = math.random(playerGraph.minLimits[k], playerGraph.maxLimits[k] - 1)
      -- Ensure that new value actually changes.
      if new > v then
	 new = new + 1
      end
      --graph["set_"..k](graph, new)
      graph:snapTo(k, new)
   end
end

function matchGraph.update(dt)
   if matchGraph.graphsMatch() then
      matchGraph.shuffleGraph()
   end

   graph:set_scale(playerGraph.scale)
   graph:update(dt)
   graph:calcPoints()
end

function matchGraph.draw()
   love.graphics.setColor(200, 200, 200, 255)
   graph:draw(5)
   
   --DEBUGGING
   love.graphics.setColor(200, 0, 0, 255)
   love.graphics.print(
      "\n\n\na:\t" .. graph:get_a()
	 .. "\nb:\t" .. graph:get_b()
	 .. "\nn:\t" .. graph:get_n(),
      5, 5
   )
   --EOF DEBUG
end
