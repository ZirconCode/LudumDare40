lume = require "lume"

io.stdout:setvbuf("no") -- for live output in sublime 3
--map = require "map"

-- TODO
-- bullet cooldown after 30 shots or so
-- bullets can pass through diagonal blocks -> ox,xo
-- walking collision not 100% snug
-- fix curses with rotation / interactivity with one another

function love.load()
	-- love.window.setMode( 800, 600 )
	-- love.window.setMode( 800, 600, {fullscreen = true} )
	width = 1200
	height = 700
	love.window.setMode( width, height )
	-- love.window.setMode( 1920, 1024, {fullscreen = true} )

	-- our tiles
	tile = {}
	for i=0,4 do -- change 3 to the number of tile images minus 1.
		tile[i] = love.graphics.newImage( "tile"..i..".png" )
	end

	pic_banana = love.graphics.newImage( "banana.png" )
 
	bullets = {}
	bullet_reset = 0
	bullet_counter = 10


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
	-- TODO buffer?
	map_display_buffer = 2 -- We have to buffer one tile before and behind our viewpoint.
                               -- Otherwise, the tiles will just pop into view, and we don't want that.
	map_display_w = 20
	map_display_h = 15
	tile_w = 50
	tile_h = 50

	char_x = width/2
	char_y = height/2
	char_r = 16

	-- for bullet direction != 0
	char_old_xspeed = 1
	char_old_yspeed = 0

	curses_active = {false,false,false,false,false,false,false,false,false}
	-- curses_active = {true,true,true,true,true,true,true,true,true}
	-- curse 1 screen shake
	-- curse 2 screen darken sometimes
	-- curse 3 can only have one bullet at a time
	-- curse 4 rotate slowly
	-- curse 5 banana
	-- curse 6 seasickness
	-- curse 7 colors TOO HARDCORE nevermind just freezes R not GB
	-- curse 8 switch up/right arrow
	-- curse 9 slow down sporadically

	curse1_x = 0
	curse1_y = 0
	curse1_timeout = 0
	curse2_blacken = 100
	curse4_rotation = 0
	frame_count = 0

	  -- love.graphics.setBackgroundColor(0, 0, 255, 50)

	-- banana particle system
	psystem = love.graphics.newParticleSystem(pic_banana, 100)
  	psystem:setParticleLifetime(2, 5)
  	psystem:setEmissionRate(20)
  	psystem:setSizeVariation(1)
  	psystem:setSizes(1,0.5,0.6,0.7,1.1,1.3)
  	psystem:setSpin(-3,3)
  	psystem:setSpinVariation(1)
  	psystem:setLinearAcceleration(-3000, -1000, 0, 1000)
	psystem:setPosition(width+200,height/2)
-- 
 
  	--psystem:setLinearAcceleration(-20, -20, 20, 20) -- Random movement in all directions.
  	-- psystem:setColors(255, 255, 255, 255, 200, 200, 0, 255, 255, 255, 255, 0)
end
 
function draw_map(p_num)
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

function draw_bullets(p_num)
	-- draw bullets
	-- print(#bullets)
	for i=1,#bullets  do -- change 3 to the number of tile images minus 1.
		b = bullets[i]
		love.graphics.setColor(0,0,0)
		br = 5
		if(b.alive == true) then
			love.graphics.ellipse( "fill", b.x-map_x, b.y-map_y, br, br  )
		end
		-- b.alive = true
	end
end

function draw_player(p_num)
	love.graphics.setColor(0,0,0)
	love.graphics.ellipse( "fill", char_x, char_y, char_r, char_r  )
end
 
function love.update( dt )
	frame_count = (frame_count+dt) % (3.14*2)
	-- print(frame_count)


	local speed = 400 * dt
	-- get input
	--speed = 50

	if curses_active[9] and frame_count % 1 > 0.5 then
		speed = 100 * dt
	end

	if curses_active[7] then
		if lume.round((frame_count * 10))%3 == 0 then
			-- love.graphics.setColorMask( lume.randomchoice({true,false}), lume.randomchoice({true,false}), lume.randomchoice({true,false}), true )
			love.graphics.setColorMask( lume.randomchoice({true,false}), true, true, true )
		end
	end


	-- curse1_rotangle = (dt*5)-(10*dt)
	if curses_active[1] then
		if curse1_timeout < 0 then
			curse1_x = lume.random(-10, 10)
			curse1_y = lume.random(-10, 10)
			if curse1_timeout < -4 then
				curse1_timeout = lume.random(3,7.5)
			end
		end
		curse1_timeout = curse1_timeout-dt
	end
	if curses_active[2] then
		-- curse2_blacken = curse2_blacken+dt*lume.random(-100, 100)
		curse2_blacken=math.sin(frame_count)*255
		curse2_blacken = lume.clamp(curse2_blacken,0,255)
	end
	if curses_active[4] then
		curse4_rotation = curse4_rotation+dt*0.1
	end
	if curses_active[5] then
  		psystem:update(dt)
  	end
	
	old_map_y = map_y
	old_map_x = map_x

	tmp_xspeed = 0
	tmp_yspeed = 0
	if love.keyboard.isDown( "w" ) then
		
		if curses_active[8] then
			map_x = map_x + speed
			tmp_xspeed = speed
		else
			map_y = map_y - speed
			tmp_yspeed = -speed
		end
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
		if curses_active[8] then
			map_y = map_y - speed
			tmp_yspeed = -speed
		else
			map_x = map_x + speed
			tmp_xspeed = speed
		end
		
	end

	if love.keyboard.isDown( "escape" ) then
		love.event.quit()
	end

 	col = checkCharacterCollision()
 	if col then
 		map_y = old_map_y
 		map_x = old_map_x
 	end

 	if not (tmp_xspeed == 0 and tmp_yspeed == 0) then
		char_old_xspeed = tmp_xspeed
		char_old_yspeed = tmp_yspeed
	end
 		-- char_old_xspeed = 1
	-- char_old_yspeed = 1


 	-- bullets
 	b_speed = 800
 	print('br'..bullet_reset..'bc'..bullet_counter)
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
 			if tmp_yspeed == 0 and tmp_xspeed == 0 then
 				-- print(char_old_xspeed..','..char_old_yspeed)
 				if not (char_old_xspeed == 0) then
 					b.xvel = b_speed*lume.sign(char_old_xspeed)
 				end
 				if not (char_old_yspeed == 0) then
 					b.yvel = b_speed*lume.sign(char_old_yspeed)
 				end
 			end
 			b.alive = true
 			if curses_active[3] then
 				if #bullets < 1 then
 					bullets[#bullets+1]=b
 				end
 			else
 				bullets[#bullets+1]=b
 			end
 			bullet_reset = 0.1
 			bullet_counter = bullet_counter -1
 			if bullet_counter == 0 then
 				bullet_reset = 1
 				bullet_counter = 10
 			end
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
		ctx = math.floor((b.x)/tile_w)	
		cty = math.floor((b.y)/tile_h)
		-- print(ctx..','..cty..':')
		if b.alive and map[cty+1][ctx+1] == 4 then
			b.alive = false
			-- bullets[i] = nil
			-- print('!!!')
		end
	end
	-- print(#bullets)

	-- print(curses_active[1])

	-- for i=1,#bullets  do
	-- 	if bullets[i].alive == false then
	-- 		bullets.remove(i)
	-- 	end
	-- end
	for i=#bullets,1,-1 do -- i starts at the end, and goes "down"
      if bullets[i].alive == false then
        table.remove(bullets, i)
      end
   	end      



	-- remove dead bullets

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
	-- love.graphics.setColorMask( red, green, blue, alpha )


	-- love.graphics.clear()
	-- TODO
	-- Split Screen Attempt
	love.graphics.setScissor( 0, 0, width/2, height )
	love.graphics.translate(-width/4, 0)
	love.graphics.clear()

	if curses_active[6] then
		love.graphics.translate(width/2, height/2)
		local t = love.timer.getTime()
		love.graphics.shear(0.7*math.cos(t), 0.7*math.cos(t * 0.8))
		love.graphics.translate(-width/2, -height/2)
	end
	if curses_active[1] then
		love.graphics.translate(curse1_x, curse1_y)
	end
	if curses_active[4] then
		love.graphics.translate(width/2, height/2)
		love.graphics.rotate(curse4_rotation)
		love.graphics.translate(-width/2, -height/2)
	end


	-- love.graphics.setColor(255,0,255)
	-- love.graphics.rectangle("fill",0,0,width,height)

	draw_map(1)
	draw_bullets(1)
	draw_player(1)

	
	-- TODO draw HUD
	love.graphics.setColor(255,255,255)
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)

	


	if curses_active[2] then
		love.graphics.setColor(0,0,0,curse2_blacken)
		love.graphics.rectangle("fill",0,0,width,height)
		
	end
	if curses_active[5] then
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(psystem, 0, 0)
		-- love.graphics.draw(pic_banana, 0 , 0 ) -- - tile_h/2
	end


	--- player 2
	love.graphics.setScissor( width/2, 0, width, height )
	love.graphics.translate(width/4+width/4, 0)
	love.graphics.clear()

	draw_map(2)
	draw_bullets(2)
	draw_player(2)

end
