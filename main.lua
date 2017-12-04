lume = require "lume"

io.stdout:setvbuf("no") -- for live output in sublime 3
--map = require "map"

-- TODO
-- bullet cooldown after 30 shots or so
-- bullets can pass through diagonal blocks -> ox,xo
-- walking collision not 100% snug
-- fix curses with rotation / interactivity with one another

function love.load()
	math.randomseed(os.time())	
	-- seems to use same thing after reseting otherwise?

	-- love.window.setMode( 800, 600 )
	-- love.window.setMode( 800, 600, {fullscreen = true} )
	width = 1200
	height = 700
	-- width = 1920
	-- height = 900
	love.window.setMode( width, height ) -- , {fullscreen = true}
	-- love.window.setMode( 1920, 1024, {fullscreen = true} )

	-- our tiles
	tile = {}
	for i=1,7 do -- TODO 0 to ? // TILESET SAME FOR ALL MAPS
		tile[i] = love.graphics.newImage( "tile"..i..".png" )
	end

	screens = {}
	for i=1,6 do -- TODO 0 to ? // TILESET SAME FOR ALL MAPS
		screens[i] = love.graphics.newImage( "screen"..i..".png" )
	end

	curse_pic = {}
	for i=1,9 do -- TODO 0 to ? // TILESET SAME FOR ALL MAPS
		if i == 7 then

		else
			curse_pic[i] = love.graphics.newImage( "curse"..i..".png" )
		end
	end

	pic_banana = love.graphics.newImage( "banana.png" )

	pic_char1 = love.graphics.newImage( "char1.png" )
	pic_char2 = love.graphics.newImage( "char2.png" )

	map = {}

	bullet_reloadcount = 15
	curses_to_win = 6 -- 1 for testing =================================================

	map_display_w = 20
	map_display_h = 15
	tile_w = 50
	tile_h = 50


	-- Default Values
	map_w = 10
	map_h = 10
	p1_x_respawn = 1000
	p1_y_respawn = 1000
	p2_x_respawn = 1000
	p2_y_respawn = 1000

	-- loadMap(1)

	frame_count = 0

	-- TODO buffer?
	map_display_buffer = 2 -- We have to buffer one tile before and behind our viewpoint.
                           -- Otherwise, the tiles will just pop into view, and we don't want that.


	br = 5 -- bullet radius
	bullets = {} -- bullets for both but TODO curse 3 change to larger reset instead

	-- PLAYER 1 ===========================
	p1 = {}
	createPlayer(1,p1)
	

  	-- PLAYER 2 ===========================
  	p2 = {}
	createPlayer(2,p2)

  	-- ===========================

  	-- loadMap(1)
  	-- respawn(1)
  	-- respawn(2)

  	-- {true,true,true,true,true,true,true,true,true}
  	-- {false,false,false,false,false,false,false,false,false}
  	p1.curses_active = {false,false,false,false,false,false,false,false,false}
  	p2.curses_active = {false,false,false,false,false,false,false,false,false}

	-- curse 1 screen shake
	-- curse 2 screen darken sometimes
	-- curse 3 can only have one bullet at a time
	-- curse 4 rotate slowly
	-- curse 5 banana
	-- curse 6 seasickness
	-- curse 7 colors TOO HARDCORE nevermind just freezes R not GB
	-- curse 8 switch up/right arrow
	-- curse 9 slow down sporadically

	-- love.graphics.setBackgroundColor(0, 0, 255, 50)

	-- TODO FONT
	-- font = love.graphics.newFont( 12 )
	love.graphics.setNewFont( 20 )

	-- SOUND

	-- TODO volumes ok?
	music = love.audio.newSource("LudumDare40_CrazyContest.ogg")
	playSound()
	setPitch(1)

	-- bullet shoot sound
	sound_bullet = love.audio.newSource("LudumDare40_Bulletsound.ogg")
	sound_hit = love.audio.newSource("LudumDare40_Hitsound.ogg")
	sound_hit:setVolume(1)
	sound_earthquake = love.audio.newSource("LudumDare40_Earthquake.ogg")
	sound_earthquake:setVolume(1) -- "Volume cannot be raised above 1.0." meh


	gameState = 1 -- to show pictures, map select, 100 = ingame, 200 = victory
	victory_player = 0 -- the player who won

	-- -- TODO: after map select
	-- loadMap(1)
 --  	respawn(1)
 --  	respawn(2)
end

function loadMap(map_num)
	if map_num == 1 then
			-- DeadGardens spawnpoints
		p1_x_respawn = 1200
		p1_y_respawn = 1100
		p2_x_respawn = 1200
		p2_y_respawn = 950

		mapdata = require "DeadGardens" -- TODO
	elseif map_num == 2 then  -- TODO
		p1_x_respawn = 475
		p1_y_respawn = 75
		p2_x_respawn = 475+50*4
		p2_y_respawn = 75

		mapdata = require "tinyisland" -- TODO
	end

	-- mapdata = require "map1"
	-- mapdata = require "map2"
	
	mdat = mapdata.layers[1].data
	map_w = mapdata.layers[1].width
	map_h = mapdata.layers[1].height

	-- Hmmmm?
	print("hmm")
	print(mdat)

	tmpl = {}
	for i=1,map_w*map_h do
		tmpl[#tmpl+1]=mdat[i]
		if(#tmpl == map_w) then
			map[#map+1]=tmpl
			tmpl = {}
		end
	end

	-- TODO
	tile_curse_spawn = 6
	tile_wall = 7
	tile_water = 3

	-- spawn curses
	map_curses = {}
	available_curses = {1,2,3,4,5,6,8,9}
	static_curse_spawns = {}
	spawnCurses()


	print(map_w..',,,'..map_h)
		map_w = #map[1] -- Obtains the width of the first row of the map
	map_h = #map -- Obtains the height of the map
	print(map_w..',,,'..map_h)

	print(map)
	print("hmm")

 
	-- map variables
	-- map_w = #map[1] -- Obtains the width of the first row of the map
	-- map_h = #map -- Obtains the height of the map

end

function spawnCurses()
	map_curses = {}

	for y=1, map_h do
		for x=1, map_w do
			if map[y][x] == tile_curse_spawn then
				print(x..'.'..y)
				-- print(#available_curses)
				ci = math.random(#available_curses)
				-- print(ci)
				c = available_curses[ci]
				map_curses[#map_curses+1] = {25+(x-1)*tile_h,25+(y-1)*tile_w,c} -- curse radius = 25
				static_curse_spawns[c] = {x,y}
				-- available_curses[ci] = nil
				table.remove(available_curses, ci)
			end
		end
	end
end

function spawnCurse(i)
	c = static_curse_spawns[i]
	x = c[1]
	y = c[2]

	map_curses[#map_curses+1] = {25+(x-1)*tile_h,25+(y-1)*tile_w,i} -- curse radius = 25
end

function checkCurseCollision(p_num)
	if p_num == 1 then -- WOW, nice thinking, could've saved some code www, quality < 0
		p = p1
	else
		p = p2
	end

	for i=1,#map_curses do
		c = map_curses[i]
		-- print(lume.distance(c[1],c[2],p.x_map+p.char_x,p.map_y+p.char_y))
		if lume.distance(c[1],c[2],p.map_x+p.char_x,p.map_y+p.char_y) < p.char_r+25 then
			-- print(c[3])
			-- apply curse
			p.curses_active[c[3]] = true
			table.remove(map_curses, i)
			break
		end
	end
end

function drawCurses(p_num)
	if p_num == 1 then -- WOW, nice thinking, could've saved some code www, quality < 0
		p = p1
	else
		p = p2
	end

	for i=1,#map_curses do
		love.graphics.setColor(255,255,255,255)
		c = map_curses[i]
		-- love.graphics.ellipse( "fill", c[1]-p.map_x, c[2]-p.map_y, 25, 25 )
		-- love.graphics.setColor(50,0,0,255)
		-- love.graphics.print("c"..c[3], c[1]-p.map_x, c[2]-p.map_y)
		love.graphics.draw(curse_pic[c[3]], c[1]-p.map_x, c[2]-p.map_y,0,1,1,25,25)
	end
end

function playSound()
	music:stop() -- stop music from last time, if reset
  	music:setVolume(0.3)
  	music:setLooping(true)
  	music:play() -- from beginning TODO ?
 	
end

function setPitch(n)
	music:setPitch(n)
end

function respawn(p_num)
	if p_num == 1 then -- WOW, nice thinking, could've saved some code www, quality < 0
		p = p1
	else
		p = p2
	end

	p.invincible = 4

	if p_num == 1 then
		p.map_x = p1_x_respawn
		p.map_y = p1_y_respawn
	else
		p.map_x = p2_x_respawn
		p.map_y = p2_y_respawn
	end
end

function createPlayer(p_num,p)
	p.map_x = 0
	p.map_y = 0

	p.char_x = width/2
	p.char_y = height/2
	p.char_r = 20

	p.bullet_reset = 0
	p.bullet_counter = bullet_reloadcount


	p.curse1_x = 0
	p.curse1_y = 0
	p.curse1_timeout = 0
	p.curse2_blacken = 100
	p.curse4_rotation = 0

	-- for bullet direction != 0
	p.char_old_xspeed = 1
	p.char_old_yspeed = 0

	p.curse_num = 0

	p.invincible = 0


	-- banana particle system
	p.psystem = love.graphics.newParticleSystem(pic_banana, 100)
  	p.psystem:setParticleLifetime(2, 5)
  	p.psystem:setEmissionRate(20)
  	p.psystem:setSizeVariation(1)
  	p.psystem:setSizes(1,0.5,0.6,0.7,1.1,1.3)
  	p.psystem:setSpin(-3,3)
  	p.psystem:setSpinVariation(1)

  	if p_num == 1 then
  		p.psystem:setLinearAcceleration(3000, -1000, 0, 1000)
		p.psystem:setPosition(width/2 - width/4 - 100,height/2)
  	else
  		p.psystem:setLinearAcceleration(-3000, -1000, 0, 1000)
		p.psystem:setPosition(width/2 + width/4 + 100,height/2)
  	end

  	-- psystem:setColors(255, 255, 255, 255, 200, 200, 0, 255, 255, 255, 255, 0)
end

function draw_map(p_num)
	if(p_num == 1) then
		map_x = p1.map_x
		map_y = p1.map_y
	else
		map_x = p2.map_x
		map_y = p2.map_y
	end

	offset_x = map_x % tile_w
	offset_y = map_y % tile_h
	firstTile_x = math.floor(map_x / tile_w) 
	firstTile_y = math.floor(map_y / tile_h)
 
	for y=-map_display_buffer, (map_display_h + map_display_buffer) do -- !! TODO update Love2d Wikid for y = -buffer instead of y = 1
		for x=-map_display_buffer, (map_display_w + map_display_buffer) do
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
	if(p_num == 1) then
		map_x = p1.map_x
		map_y = p1.map_y
	else
		map_x = p2.map_x
		map_y = p2.map_y
	end

	-- draw bullets
	-- print(#bullets)
	for i=1,#bullets  do -- change 3 to the number of tile images minus 1.
		b = bullets[i]
		love.graphics.setColor(0,0,0)
		if(b.alive == true) then
			love.graphics.ellipse( "fill", b.x-map_x, b.y-map_y, br, br  )
		end
		-- b.alive = true
	end
end

function draw_player(p_num)
	if p_num == 1 then
		char_x = p1.char_x
		char_y = p1.char_y
		char_r = p1.char_r
		p = p1
	else
		char_x = p2.char_x
		char_y = p2.char_y
		char_r = p2.char_r
		p = p2
	end

	love.graphics.setColor(255,255,255,255)
	if(p.invincible > 0) then
			love.graphics.setColor(255,255,255,100)
	end

	-- TODO Rotate
	rotate_by = 0

	--- -____-
	if p.char_old_xspeed > 0 and p.char_old_yspeed > 0 then
		rotate_by = (3/4)*math.pi
	elseif p.char_old_xspeed > 0 and p.char_old_yspeed < 0 then
		rotate_by = (1/4)*math.pi
	elseif p.char_old_xspeed > 0 and p.char_old_yspeed == 0 then
		rotate_by = (1/2)*math.pi
	elseif p.char_old_xspeed == 0 and p.char_old_yspeed > 0 then
		rotate_by = (1)*math.pi
	elseif p.char_old_xspeed < 0 and p.char_old_yspeed > 0 then
		rotate_by = (1+1/4)*math.pi
	elseif p.char_old_xspeed < 0 and p.char_old_yspeed == 0 then
		rotate_by = (1+1/2)*math.pi
	elseif p.char_old_xspeed < 0 and p.char_old_yspeed < 0 then
		rotate_by = (1+3/4)*math.pi
	end

	if p_num == 1 then
		-- love.graphics.draw(pic_char1, char_x-char_r , char_y-char_r, rotate_by)
		love.graphics.draw(pic_char1, char_x, char_y, rotate_by, 1, 1, char_r, char_r) -- offset around center to rotate properly
	else
		love.graphics.draw(pic_char2, char_x, char_y, rotate_by, 1, 1, char_r, char_r)
	end
	

	-- love.graphics.ellipse( "fill", char_x, char_y, char_r, char_r  )
end

function draw_other_player(p_num) -- haha such ugly code..
	-- love.graphics.setColor(255,0,0)

	if p_num == 1 then -- draw 2nd player on first screen
		char_x = p1.char_x
		char_y = p1.char_y
		char_r = p1.char_r
		map_x = p2.map_x-p1.map_x
		map_y = p2.map_y-p1.map_y
		p = p1
		-- p = p2

		-- if(p1.invincible > 0) then
		-- 	love.graphics.setColor(255,255,0,200)
		-- end
	else
		-- print('yesy')
		char_x = p2.char_x
		char_y = p2.char_y
		char_r = p2.char_r
		map_x = p1.map_x-p2.map_x
		map_y = p1.map_y-p2.map_y
		-- p = p1
		p = p2

		-- if(p2.invincible > 0) then
		-- 	love.graphics.setColor(255,255,0,200)
		-- end
	end
	-- print(p1.map_x ..','..p1.map_y..':'..p2.map_x ..','..p2.map_y..':')
	-- print(p1.char_x ..','..p1.char_y..':'..p2.char_x ..','..p2.char_y..':') -- static
	-- print(p1.map_x..'hmm'..p1.map_y)

	love.graphics.setColor(255,255,255,255)
	if(p.invincible > 0) then
			love.graphics.setColor(255,255,255,100)
	end

	-- TODO Rotate
	rotate_by = 0

	--- -____-
	if p.char_old_xspeed > 0 and p.char_old_yspeed > 0 then
		rotate_by = (3/4)*math.pi
	elseif p.char_old_xspeed > 0 and p.char_old_yspeed < 0 then
		rotate_by = (1/4)*math.pi
	elseif p.char_old_xspeed > 0 and p.char_old_yspeed == 0 then
		rotate_by = (1/2)*math.pi
	elseif p.char_old_xspeed == 0 and p.char_old_yspeed > 0 then
		rotate_by = (1)*math.pi
	elseif p.char_old_xspeed < 0 and p.char_old_yspeed > 0 then
		rotate_by = (1+1/4)*math.pi
	elseif p.char_old_xspeed < 0 and p.char_old_yspeed == 0 then
		rotate_by = (1+1/2)*math.pi
	elseif p.char_old_xspeed < 0 and p.char_old_yspeed < 0 then
		rotate_by = (1+3/4)*math.pi
	end

	if p_num == 2 then
		-- love.graphics.draw(pic_char1, char_x-char_r , char_y-char_r, rotate_by)
		love.graphics.draw(pic_char2, -map_x+char_x, -map_y+char_y, rotate_by, 1, 1, char_r, char_r) -- offset around center to rotate properly
	else
		love.graphics.draw(pic_char1, -map_x+char_x, -map_y+char_y, rotate_by, 1, 1, char_r, char_r)
	end
	
	-- love.graphics.ellipse( "fill", -map_x+char_x, -map_y+char_y, char_r, char_r  )
end
 
function love.keyreleased(key)
   if gameState < 5 then
		if key == "s" then
			gameState = 5
		elseif key == "space" then
			gameState = gameState +1
		end
	elseif gameState == 5 then
		if key == "1" then
			-- TODO: after map select
			loadMap(1)
  			respawn(1)
  			respawn(2)
  			gameState = 100
		elseif key == "2" then
			loadMap(2)
  			respawn(1)
  			respawn(2)
  			gameState = 100
		end
	end

	if gameState == 200 then
		if key == "r" then
			love.load()
			music:stop() -- otherwise keeps playing..
		end
	end

	if key == "escape" then
			love.event.quit()
	end
end

function love.update( dt ) -- TODO ======================================================

	-- see keyreleased for other gamestates

	if gameState == 100 then
		updateCurses(1,dt)
	  	updateCurses(2,dt)
		
		movePlayer(1,dt)
		movePlayer(2,dt)

		checkCurseCollision(1)
		checkCurseCollision(2)

	 	shootBullets(dt,1)
	 	shootBullets(dt,2)
	 	updateBullets(dt)

		--checkMapBoundary()
		-- checkCharacterCollision() -- ??? time to cleanup some code...
		

		-- Win Condition


		-- Adapt sound
		maxc = math.max(p1.curse_num,p2.curse_num)
		-- if maxc >= 6 then
		-- 	print('WINNER!')
		-- end
		p = 0.84
		if maxc >= 2 then p = 1 end
		if maxc >= 5 then p = 1.2 end
		-- p = 0.85+0.05*maxc
		setPitch(p) -- TODO ok to set pitch this often?
		-- print(p)


		-- check victory condition
		maxc = math.max(p1.curse_num,p2.curse_num)
		if maxc >= curses_to_win then
			if p1.curse_num >= curses_to_win then
				victory_player = 1
				gameState = 200
				setPitch(1)
			else
				victory_player = 2
				gameState = 200
				setPitch(1)
			end
		end
	end

  	if gameState == 200 then
  		-- hmmm
  		-- victory_player
  	end
end

function updateCurses(p_num, dt)
	if p_num == 1 then -- WOW, nice thinking, could've saved some code www, quality < 0
		p = p1
	else
		p = p2
	end

	frame_count = (frame_count+dt) % (3.14*2) -- TODO p1?
	-- print(frame_count)

	-- CURSE IRRELEVANT for Split Screen TODO
	-- if curses_active[7] then
	-- 	if lume.round((frame_count * 10))%3 == 0 then
	-- 		-- love.graphics.setColorMask( lume.randomchoice({true,false}), lume.randomchoice({true,false}), lume.randomchoice({true,false}), true )
	-- 		love.graphics.setColorMask( lume.randomchoice({true,false}), true, true, true )
	-- 	end
	-- end

	-- curse1_rotangle = (dt*5)-(10*dt)
	if p.curses_active[1] then
		if p.curse1_timeout < 0 then
			if not sound_earthquake:isPlaying() then
				sound_earthquake:play()
			end
			p.curse1_x = lume.random(-10, 10)
			p.curse1_y = lume.random(-10, 10)
			if p.curse1_timeout < -4 then
				sound_earthquake:stop()
				p.curse1_timeout = lume.random(3,7.5)
			end
		end
		p.curse1_timeout = p.curse1_timeout-dt
	end
	if p.curses_active[2] then
		-- curse2_blacken = curse2_blacken+dt*lume.random(-100, 100)
		p.curse2_blacken=math.sin(frame_count)*255
		p.curse2_blacken = lume.clamp(p.curse2_blacken,0,255)
	end
	if p.curses_active[4] then
		p.curse4_rotation = p.curse4_rotation+dt*0.1
	end
	if p.curses_active[5] then
  		p.psystem:update(dt)
  	end

  	-- count curses
  	i = 0 -- 0 good because one curse ignored
  	for j=1,#p.curses_active do
  		if p.curses_active[j] then
  			i = i+1
  		end
  	end
  	p.curse_num = i

end

function shootBullets(dt,p_num)

	char_x = p1.char_x
	char_y = p1.char_y

	if p_num == 1 then
		bullet_reset = p1.bullet_reset
		bullet_counter = p1.bullet_counter
		map_x = p1.map_x
		map_y = p1.map_y
		tmp_xspeed = p1.char_old_xspeed   -- TODO does work?
		tmp_yspeed = p1.char_old_yspeed
		p = p1
	else
		bullet_reset = p2.bullet_reset
		bullet_counter = p2.bullet_counter
		map_x = p2.map_x
		map_y = p2.map_y
		tmp_xspeed = p2.char_old_xspeed   -- TODO does work?
		tmp_yspeed = p2.char_old_yspeed
		p = p2
	end

	-- bullets
 	b_speed = 800
 	-- print('br'..p1.bullet_reset..'bc'..p1.bullet_counter)
 	-- if love.mouse.isDown( 1 ) then
 	if (love.keyboard.isDown( "q" ) and p_num == 1) or (love.keyboard.isDown( "m" ) and p_num == 2) then -- shoot with q and m TODO
 		if bullet_reset == 0 and p.invincible == 0 then
 			b = {}
 			b.x = char_x+map_x -- TODOOOOOO
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
 			-- if tmp_yspeed == 0 and tmp_xspeed == 0 then
 			-- 	-- print(char_old_xspeed..','..char_old_yspeed)
 			-- 	if not (p1.char_old_xspeed == 0) then
 			-- 		b.xvel = b_speed*lume.sign(p1.char_old_xspeed)
 			-- 	end
 			-- 	if not (p1.char_old_yspeed == 0) then
 			-- 		b.yvel = b_speed*lume.sign(p1.char_old_yspeed)
 			-- 	end
 			-- end
 			b.alive = true
 			-- if curses_active[3] then
 			-- 	if #bullets < 1 then -- TODO ---------------------------------------------------------
 			-- 		bullets[#bullets+1]=b
 			-- 	end
 			-- else
 			-- 	bullets[#bullets+1]=b
 			-- end
 			b.p_num = p_num

 			bullets[#bullets+1]=b

 			-- bullet sound
 			sound_bullet:stop()
 			sound_bullet:play()

 			if p.curses_active[3] then
 				bullet_counter = 1
 			end

 			bullet_reset = 0.1
 			bullet_counter = bullet_counter -1
 			if bullet_counter == 0 then
 				bullet_reset = 1
 				bullet_counter = bullet_reloadcount
 			end
 		end
 	end
 	if bullet_reset > 0 then
 		bullet_reset = lume.clamp(bullet_reset-dt,0,1)
 	end

 	if p_num == 1 then -- SIGHHH...
		p1.bullet_reset = bullet_reset
		p1.bullet_counter = bullet_counter
	else
		p2.bullet_reset = bullet_reset
		p2.bullet_counter = bullet_counter
	end

	-- TODO correct place?
	if p.invincible > 0 then
 		p.invincible = lume.clamp(p.invincible-dt,0,10)
 	end
end

function updateBullets(dt)

	-- update bullets
	for i=1,#bullets  do
		b = bullets[i]
		b.x = b.x + b.xvel*dt
		b.y = b.y + b.yvel*dt
		-- remove if hits wall
		ctx = math.floor((b.x)/tile_w)	
		cty = math.floor((b.y)/tile_h)
		-- print(ctx..','..cty..':')
		if b.alive and map[cty+1][ctx+1] == tile_wall then
			b.alive = false
		end

		-- collision with player?
		if lume.distance(b.x,b.y,p1.map_x+p1.char_x,p1.map_y+p1.char_y, false) < br+p1.char_r and b.p_num == 2 and p1.invincible == 0 then
			print('col1'..frame_count)
			respawn(1)
			sound_hit:play()
			-- pick a random true curse if there is one, set to false, respawn it
			actives = {}
			for j=1,#p1.curses_active do
				if p1.curses_active[j] then
					actives[#actives+1] = j
				end
			end
			if #actives > 0 then
				ci = lume.randomchoice(actives)
				p1.curses_active[ci] = false
				spawnCurse(ci)
			end
		end
		if lume.distance(b.x,b.y,p2.map_x+p2.char_x,p2.map_y+p2.char_y, false) < br+p2.char_r and b.p_num == 1 and p2.invincible == 0 then
			print('col2'..frame_count)
			respawn(2)
			sound_hit:play()
			-- steal random curse
			-- make p2 invisi. for a sec and respawn player
			actives = {}
			for j=1,#p1.curses_active do
				if p2.curses_active[j] then
					actives[#actives+1] = j
				end
			end
			if #actives > 0 then
				ci = lume.randomchoice(actives)
				p2.curses_active[ci] = false
				spawnCurse(ci)
			end
		end

	end

	-- remove dead bullets
	for i=#bullets,1,-1 do -- backwards...
      if bullets[i].alive == false then
        table.remove(bullets, i)
      end
   	end    

end

function movePlayer(p_num, dt)

	if p_num == 1 then --- sigh...
		p = p1
	else
		p = p2
	end

	local speed = 400 * dt
	-- get input
	--speed = 50

	if p.curses_active[9] and frame_count % 1 > 0.5 then
		speed = 100 * dt
	end

	if p_num == 1 then
		p1.old_map_y = p1.map_y
		p1.old_map_x = p1.map_x
		map_x = p1.map_x
		map_y = p1.map_y
	else
		p2.old_map_y = p2.map_y
		p2.old_map_x = p2.map_x
		map_x = p2.map_x
		map_y = p2.map_y
	end


	tmp_xspeed = 0
	tmp_yspeed = 0

	------------------- P1
	if (love.keyboard.isDown( "w" ) and p_num == 1) or (love.keyboard.isDown( "up" ) and p_num == 2) then
		
		if p.curses_active[8] then
			map_x = map_x + speed
			tmp_xspeed = speed
		else
			map_y = map_y - speed
			tmp_yspeed = -speed
		end
	end
	if (love.keyboard.isDown( "s" ) and p_num == 1) or (love.keyboard.isDown( "down" ) and p_num == 2) then
		map_y = map_y + speed
		tmp_yspeed = speed
	end
 
	if (love.keyboard.isDown( "a" ) and p_num == 1) or (love.keyboard.isDown( "left" ) and p_num == 2) then
		map_x = map_x -speed
		tmp_xspeed = -speed
	end
	if (love.keyboard.isDown( "d" ) and p_num == 1) or (love.keyboard.isDown( "right" ) and p_num == 2) then
		if p.curses_active[8] then
			map_y = map_y - speed
			tmp_yspeed = -speed
		else
			map_x = map_x + speed
			tmp_xspeed = speed
		end
		
	end

	if p_num == 1 then
		p1.map_x = map_x
		p1.map_y = map_y
	else
		p2.map_x = map_x
		p2.map_y = map_y
	end

 	col = checkCharacterCollision(p_num)

	if col then
		if p_num == 1 then
			p1.map_y = p1.old_map_y
	 		p1.map_x = p1.old_map_x
		else
			p2.map_y = p2.old_map_y
	 		p2.map_x = p2.old_map_x
		end
		
	end

	 if not (tmp_xspeed == 0 and tmp_yspeed == 0) then
	 	if p_num == 1 then
			p1.char_old_xspeed = tmp_xspeed
			p1.char_old_yspeed = tmp_yspeed
		else
			p2.char_old_xspeed = tmp_xspeed
			p2.char_old_yspeed = tmp_yspeed
		end
		
	end

	-- 	------------------- P2
	-- if love.keyboard.isDown( "up" ) then
		
	-- 	if curses_active[8] then
	-- 		map_x = map_x + speed
	-- 		tmp_xspeed = speed
	-- 	else
	-- 		map_y = map_y - speed
	-- 		tmp_yspeed = -speed
	-- 	end
	-- end
	-- if love.keyboard.isDown( "down" ) then
	-- 	map_y = map_y + speed
	-- 	tmp_yspeed = speed
	-- end
 
	-- if love.keyboard.isDown( "left" ) then
	-- 	map_x = map_x -speed
	-- 	tmp_xspeed = -speed
	-- end
	-- if love.keyboard.isDown( "right" ) then
	-- 	if curses_active[8] then
	-- 		map_y = map_y - speed
	-- 		tmp_yspeed = -speed
	-- 	else
	-- 		map_x = map_x + speed
	-- 		tmp_xspeed = speed
	-- 	end
		
	-- end
	-- ----------------

end

function checkCharacterCollision(p_num)
	if(p_num == 1) then
		char_x = p1.char_x
		char_y = p1.char_y
		char_r = p1.char_r
		map_x = p1.map_x
		map_y = p1.map_y
	else
		char_x = p2.char_x
		char_y = p2.char_y
		char_r = p2.char_r
		map_x = p2.map_x -- Oh.... this was a bad way to implement two players.... haha oh well
		map_y = p2.map_y
	end

	ctx = math.floor((char_x + map_x)/tile_w)	
	cty = math.floor((char_y + map_y)/tile_h)
	tilenum = map[cty+1][ctx+1] -- arrays in lua really start counting at 1 ??
	-- print(ctx..','..cty..':'..tile)
	-- check if may walk
	-- radius -> collision with surrounding tiles?
	collision = false
	for y=lume.clamp(cty-1, 0, map_h-1), lume.clamp(cty+1, 0, map_h-1) do
		for x=lume.clamp(ctx-1, 0, map_w-1), lume.clamp(ctx+1, 0, map_w-1) do
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
				if map[ty][tx] == tile_wall or map[ty][tx] == tile_water  then
					collision = true
				end
			end
		end
	end

	return collision
end

-- function checkMapBoundary()
-- 	-- check boundaries. remove this section if you don't wish to be constrained to the map.

-- 	-- TODO Superfluous?
	
-- 	if map_x < 0 then
-- 		map_x = 0
-- 	end
 
-- 	if map_y < 0 then
-- 		map_y = 0
-- 	end	
 
-- 	if map_x > map_w * tile_w - map_display_w * tile_w - 1 then
-- 		map_x = map_w * tile_w - map_display_w * tile_w - 1
-- 	end
 
-- 	if map_y > map_h * tile_h - map_display_h * tile_h - 1 then
-- 		map_y = map_h * tile_h - map_display_h * tile_h - 1
-- 	end
-- end


function pre_applyGraphicCurses(p_num)
	if p_num == 1 then --- sigh...
		p = p1
	else
		p = p2
	end

	if p.curses_active[6] then
		love.graphics.translate(width/2, height/2)
		local t = love.timer.getTime()
		love.graphics.shear(0.7*math.cos(t), 0.7*math.cos(t * 0.8))
		love.graphics.translate(-width/2, -height/2)
	end

	if p.curses_active[1] then
		love.graphics.translate(p.curse1_x, p.curse1_y)
	end
	if p.curses_active[4] then
		love.graphics.translate(width/2, height/2)
		love.graphics.rotate(p.curse4_rotation)
		love.graphics.translate(-width/2, -height/2)
	end

end

function post_applyGraphicCurses(p_num)
	if p_num == 1 then --- sigh...
		p = p1
	else
		p = p2
	end

	if p.curses_active[5] then
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(p.psystem, 0, 0)
		-- love.graphics.draw(pic_banana, 0 , 0 ) -- - tile_h/2
	end
end

function postpost_applyGraphicCurses(p_num)
	if p_num == 1 then --- sigh...
		p = p1
	else
		p = p2
	end

	if p.curses_active[2] then
		love.graphics.setColor(0,0,0,p.curse2_blacken)
		love.graphics.rectangle("fill",0,0,width,height)
		
	end
end

function drawHUD(p_num)
	if p_num == 1 then --- sigh...
		p = p1
		x = 10
	else
		p = p2
		x = width/2 + 10
	end

	love.graphics.setColor(255,255,255)
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)

	love.graphics.setColor(255,0,0)
	love.graphics.print("Curses: "..p.curse_num, x, height-30)

	if p.bullet_counter == bullet_reloadcount and p.bullet_reset > 0 then
		love.graphics.print("Reloading ("..lume.round(p.bullet_reset*10)..")", x, height-50)
	else
		love.graphics.print("Bullets: "..p.bullet_counter, x, height-50)
	end


end


function love.draw()
	if gameState < 10 then
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(screens[gameState], 0,0 )
	end

	-- love.graphics.clear()
	-- love.graphics.setColor(255,0,255)
	-- love.graphics.rectangle("fill",0,0,width,height)

	if gameState == 100 then
		--- player 1 ========================

		love.graphics.setScissor( 0, 0, width/2, height )
		love.graphics.translate(-width/4, 0)
		love.graphics.clear()
		
		pre_applyGraphicCurses(1)

		draw_map(1)
		drawCurses(1)
		draw_bullets(1)
		draw_player(1)
		draw_other_player(2)

		post_applyGraphicCurses(1)
		love.graphics.origin()
		postpost_applyGraphicCurses(1)

		drawHUD(1)

		--- player 2 ========================
		love.graphics.setScissor( width/2, 0, width, height )
		love.graphics.translate(width/4, 0)
		love.graphics.clear()

		pre_applyGraphicCurses(2)

		draw_map(2)
		drawCurses(2)
		draw_bullets(2)
		draw_player(2)
		draw_other_player(1)

		post_applyGraphicCurses(2)
		love.graphics.origin()
		postpost_applyGraphicCurses(2)

		drawHUD(2)
	end

	if gameState == 200 then
		-- victory_player
		love.graphics.setScissor( ) -- disable scissor

		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(screens[6], 0,0 )

		love.graphics.setColor(255,255,255)
		love.graphics.setNewFont( 200 )
		love.graphics.print(victory_player, width/2-50, height/4-50) -- TODO =======================
	end

end
