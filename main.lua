lume = require "lume"

io.stdout:setvbuf("no") -- for live output in sublime 3
--map = require "map"

function love.load()
	-- love.window.setMode( 800, 600 )
	-- love.window.setMode( 800, 600, {fullscreen = true} )
	width = 1000
	height = 800
	love.window.setMode( width, height )

	-- our tiles
	tile = {}
	for i=0,4 do -- change 3 to the number of tile images minus 1.
		tile[i] = love.graphics.newImage( "tile"..i..".png" )
	end
 
	bullets = {}
	bullet_reset = 0

	-- the map (random junk + copy and paste
	-- map={
	-- { 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3}, 
	-- { 3, 1, 0, 0, 2, 2, 2, 0, 3, 0, 3, 0, 1, 1, 1, 0, 0, 3, 0, 0, 0},
	-- { 3, 1, 0, 0, 2, 0, 2, 0, 3, 0, 3, 0, 1, 0, 0, 0, 0, 0, 3, 0, 0},
	-- { 3, 1, 0, 0, 2, 2, 2, 0, 0, 3, 0, 0, 1, 1, 0, 0, 0, 0, 0, 3, 0},
	-- { 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 3},
	-- { 3, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 2},
	-- { 3, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	-- { 3, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	-- { 3, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	-- { 3, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	-- { 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	-- { 3, 2, 2, 2, 0, 3, 3, 3, 0, 1, 1, 1, 0, 2, 0, 0, 0, 0, 0, 0, 0},
	-- { 0, 2, 0, 0, 0, 3, 0, 3, 0, 1, 0, 1, 0, 2, 0, 0, 0, 0, 0, 0, 1},
	-- { 0, 2, 0, 0, 0, 3, 0, 3, 0, 1, 0, 1, 0, 2, 0, 0, 0, 0, 0, 0, 0},
	-- { 0, 2, 2, 2, 0, 3, 3, 3, 0, 1, 1, 1, 0, 2, 2, 2, 0, 0, 0, 0, 0},
	-- { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	-- { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	-- { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	-- { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	-- { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	-- { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
	-- { 0, 1, 0, 0, 2, 2, 2, 0, 3, 0, 3, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0},
	-- { 0, 1, 0, 0, 2, 0, 2, 0, 3, 0, 3, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0},
	-- { 0, 1, 1, 0, 2, 2, 2, 0, 0, 3, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0},
	-- { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 3},
	-- { 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0},
	-- { 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	-- { 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	-- { 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3}
	-- }

	map = {}

	mapdata = require "map1"
	mdat = mapdata.layers[1].data
	map_w = mapdata.layers[1].width
	map_h = mapdata.layers[1].height

	-- Hmmmm?
	print("hmm")
	-- print(toString(mdat))
	print(mdat)


	tmpl = {}
	for i=1,map_w*map_h do
		tmpl[#tmpl+1]=mdat[i]
		if(#tmpl == map_w) then
			map[#map+1]=tmpl
			tmpl = {}
		end
	end
	-- for i,5 do
	-- 	
	-- 	if(#tmpl == map_w) then
	-- 		map[#map+1]=tmpl
	-- 		tmpl = {}
	-- 	end
	-- end

	print(map_w..',,,'..map_h)
		map_w = #map[1] -- Obtains the width of the first row of the map
	map_h = #map -- Obtains the height of the map
	print(map_w..',,,'..map_h)

	print(map)
	print("hmm")

	-- local file = io.open("map1.csv", "r");
 -- 	local map = {}
 -- 	for line in file:lines() do
 --    	table.insert (map, line);
 -- 	end
 -- 	file.close()
 
	-- map variables
	-- map_w = #map[1] -- Obtains the width of the first row of the map
	-- map_h = #map -- Obtains the height of the map
	map_x = 0
	map_y = 0
	map_display_buffer = 2 -- We have to buffer one tile before and behind our viewpoint.
                               -- Otherwise, the tiles will just pop into view, and we don't want that.
	map_display_w = 20
	map_display_h = 15
	tile_w = 50
	tile_h = 50

	char_x = width/2
	char_y = height/2
	char_r = 16
end
 
function draw_map()
	offset_x = map_x % tile_w
	offset_y = map_y % tile_h
	firstTile_x = math.floor(map_x / tile_w)
	firstTile_y = math.floor(map_y / tile_h)
 
	for y=1, (map_display_h + map_display_buffer) do
		for x=1, (map_display_w + map_display_buffer) do
			-- Note that this condition block allows us to go beyond the edge of the map.
			if y+firstTile_y >= 1 and y+firstTile_y <= map_h
				and x+firstTile_x >= 1 and x+firstTile_x <= map_w
			then
				
				tilenum = map[y+firstTile_y][x+firstTile_x]
				-- if tilenum == 0 then
				-- 	love.graphics.setColor(0,255,255,255)
				-- elseif tilenum == 1 then
				-- 	love.graphics.setColor(255,255,0,255)
				-- elseif tilenum == 2 then
				-- 	love.graphics.setColor(0,255,0,255)
				-- elseif tilenum == 3 then
				-- 	love.graphics.setColor(255,0,0,255)
				-- elseif tilenum == 4 then
				-- 	love.graphics.setColor(255,0,255,255)
				-- end

				love.graphics.setColor(255,255,255,255)
				love.graphics.draw(tile[tilenum], ((x-1)*tile_w) - offset_x , ((y-1)*tile_h) - offset_y ) -- - tile_h/2

				-- love.graphics.rectangle("fill",((x-1)*tile_w) - offset_x, ((y-1)*tile_h) - offset_y,tile_w,tile_h)
			end
		end
	end
end
 
function love.update( dt )
	local speed = 400 * dt
	-- get input
	--speed = 50
	
	old_map_y = map_y
	old_map_x = map_x

	tmp_xspeed = 0
	tmp_yspeed = 0
	if love.keyboard.isDown( "w" ) then
		map_y = map_y - speed
		tmp_yspeed = -speed
	end
	if love.keyboard.isDown( "s" ) then
		map_y = map_y + speed
		tmp_yspeed = speed
	end
 
	if love.keyboard.isDown( "a" ) then
		map_x = map_x -speed
		tmp_xspeed = -speed
	end
	if love.keyboard.isDown( "d" ) then
		map_x = map_x + speed
		tmp_xspeed = speed
	end

	if love.keyboard.isDown( "escape" ) then
		love.event.quit()
	end

 	col = checkCharacterCollision()
 	if col then
 		map_y = old_map_y
 		map_x = old_map_x
 	end

 	-- bullets
 	b_speed = 800
 	if love.mouse.isDown( 1 ) then
 		if bullet_reset == 0 then
 			b = {}
 			b.x = char_x+map_x
 			b.y = char_y+map_y

 			b.yvel = 0
 			b.xvel = 0
 			if not (math.abs(tmp_xspeed) == 0) then
 				-- print('asdasdsa')
 				b.xvel = b_speed*lume.sign(tmp_xspeed)
			end
 			if not (math.abs(tmp_yspeed) == 0) then
 				b.yvel = b_speed*lume.sign(tmp_yspeed)
 			end
 			
 			bullets[#bullets+1]=b
 			bullet_reset = 0.1
 		end
 	end
 	if bullet_reset > 0 then
 		bullet_reset = lume.clamp(bullet_reset-dt,0,1)
 	end

 	-- update bullets
	for i=1,#bullets  do -- change 3 to the number of tile images minus 1.
		b = bullets[i]
		b.x = b.x + b.xvel*dt
		b.y = b.y + b.yvel*dt
		-- remove if hits wall
		b.alive = false
	end

	--checkMapBoundary()
	checkCharacterCollision()
end

function checkCharacterCollision()
	ctx = math.floor((char_x + map_x)/tile_w)	
	cty = math.floor((char_y + map_y)/tile_h)
	tilenum = map[cty+1][ctx+1] -- arrays in lua really start counting at 1 ??
	-- print(ctx..','..cty..':'..tile)
	-- check if may walk
	-- radius -> collision with surrounding tiles?
	collision = false
	for y=lume.clamp(cty-1, 0, map_h-1), lume.clamp(cty+1, 0, map_h-1) do
		for x=lume.clamp(ctx-1, 0, map_w-1), lume.clamp(ctx+1, 0, map_w-1) do
			-- print(x..'.'..y) 
			-- detect collision to individual square
			tx = x +1
			ty = y +1
			tcx = char_x + map_x
			tcy = char_y + map_y
			closestX = lume.clamp(tcx, x*tile_w, (1+x)*tile_w);
			closestY = lume.clamp(tcy, y*tile_h, (1+y)*tile_h);
			d = lume.distance(closestX, closestY, tcx, tcy, false)
			-- print(d)
			if d <= char_r then
				if map[ty][tx] == 4 then
					collision = true
				end
			end
		end
	end

	return collision
end

function checkMapBoundary()
	-- check boundaries. remove this section if you don't wish to be constrained to the map.
	
	if map_x < 0 then
		map_x = 0
	end
 
	if map_y < 0 then
		map_y = 0
	end	
 
	if map_x > map_w * tile_w - map_display_w * tile_w - 1 then
		map_x = map_w * tile_w - map_display_w * tile_w - 1
	end
 
	if map_y > map_h * tile_h - map_display_h * tile_h - 1 then
		map_y = map_h * tile_h - map_display_h * tile_h - 1
	end
end
 
function love.draw()
	love.graphics.setColor(255,0,255)
	love.graphics.rectangle("fill",0,0,width,height)

	draw_map()

	love.graphics.setColor(0,0,0)
	love.graphics.ellipse( "fill", char_x, char_y, char_r, char_r  )

	love.graphics.setColor(255,255,255)
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)

	-- draw bullets
	-- print(#bullets)
	for i=1,#bullets  do -- change 3 to the number of tile images minus 1.
		b = bullets[i]
		love.graphics.setColor(255,255,255)
		br = 5
		love.graphics.ellipse( "fill", b.x-map_x, b.y-map_y, br, br  )
		b.alive = true
	end
end
