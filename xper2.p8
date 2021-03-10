pico-8 cartridge // http://www.pico-8.com
version 30
__lua__
--*************************
--* init and setup
--************************

function _init()
 --map
 modelarge = -1
 modesmall = 1
 mode = modelarge
 mapx = 2
 mapy = -1
 mapsize = 30 --w/h
 
 --player
 magus = 70 --sprite
 questor = 71 --sprite
 curplayer = magus
 playerpos = 68
 
 --this turn
 moves = 0
 found = 0
 total = 47
 
 --temporaray flags
 ismoving = false
 animframe = 0
 mapscrolling = true
 lightson = true
 
 --tile properties
 pushable = 2
 fallleft = 3
 falldown = 4
 invisible = 7
 fpriority = fallleft
 
 --falling tiles
 fallingleft = {}
 fallingdown = {}
 
 --constants
 left = 0
 right = 1
 up = 2
 down = 3
 
 --falling fieces
 fp = {}
 
 --level data
 levels={}

 --levels[1]=getlevel1()
 levels[1]=getlevel2()

	initmapping()
	
	--load the level
	loadlevel(60, 0, 1)
	
	--set starting positions
 playerpos = currlevel["maguspos"]
 mapx = currlevel["magusmapx"]
 mapy = currlevel["magusmapy"]
	
	printh("started")
end

function _update()
 if (ismoving) then
  updateanim()
 elseif (not updatefalling()) then
  updatemove()
 end 
end

function _draw()
 cls()
 if mode == modelarge then
	 drawlargemaze()
  drawplayer()
	else
	 drawsmall()
  drawsmallmaze() 
  drawmap()
	 drawmoves()
	 drawplayer()
	end
	
	--drawdebug()
end

--copies the map into the first
--position, counts masks
function loadlevel(x, y, n)
 printh("setting currlevel to "..n)
 currlevel = levels[n]
 total = 0
 
 --copy the map from source to 
 --the zero map space
 for i=0, mapsize do
  for j=0, mapsize do
   local s=mget(x+i,y+j)
   if(s == mask) total += 1
   if(s == magus) then
    currlevel["maguspos"] = topos(i,j)
   end
   
   if(s == questor) then
    currlevel["questorpos"] = topos(i,j)
   end
   
   mset(i,j,s)
  end
 end
end

--the map data is in small tiles
--this converts the small to 
--large tiles
function initmapping()
 space = 0
 dots = 67
 waves = 68
 chicken = 75
 fish = 74
 frown = 73
 mask = 72
 questor = 71
 magus = 70
 mappiece = 69
 bomb = 76
 poison = 77
 doll = 78
 door = 79

 tilemap={}
 tilemap[64] = 1
 tilemap[65] = 3
 tilemap[66] = 5
 tilemap[67] = 7
 tilemap[68] = 9
 tilemap[69] = 11
 tilemap[70] = 33
 tilemap[71] = 35
 tilemap[72] = 37
 tilemap[73] = 39
 tilemap[74] = 41
 tilemap[75] = 43
 tilemap[bomb] = 96
 tilemap[poison] = 98
 tilemap[door] = 13
 tilemap[doll] = 100
end

--dots and waves
function getlevel1()
 l1={}
 l1["index"] = "01"
 l1["name"] = "dots and waves"
 l1["maguspos"] = 68
 l1["questorpos"] = 449
 l1["magusmapx"] = 0
 l1["magusmapy"] = 0
 l1["questormapx"] = 22
 l1["questormapy"] = 10
 l1["wall"] = 64 --brick
 l1["mainmapx"] = 30
 l1["mainmapy"] = 0
 return l1
end

--something fishy
function getlevel2()
 l1={}
 l1["index"] = "02"
 l1["name"] = "something fishy"
 l1["maguspos"] = 26
 l1["questorpos"] = 87
 l1["magusmapx"] = 23
 l1["magusmapy"] = -1
 l1["questormapx"] = 23
 l1["questormapy"] = -1
 l1["wall"] = 65
 l1["mainmapx"] = 60
 l1["mainmapy"] = 0
 return l1 
end

function drawdebug()
	rectfill(0,96,128,128,0)
	local playerx, playery = tocoords(playerpos)
	print("px:"..playerx, 2, 100, 5)
	print("py:"..playery, 30, 100, 5)
	print("mx:"..mapx, 2, 110, 5)
	print("my:"..mapy, 30, 110, 5)

end
-->8
--***************************
--* drawing
--***************************

--draws either small or large
--maze
function drawlargemaze()
 --we have to add an extra col
 --or row for the maze that is
 --coming into view
 for x=0, 7 do
  for y=0, 7 do
			s = getmappiece(x,y)
			
  	--if(s > 0 and s != curplayer) then
  	if(s >0) then
  		local tx = x*16
  		local ty = y*16
  	 --if (mapscrolling) then
  	 --	tx += offsetx
  	 --	ty += offsety
  	 --end
  	 --don't draw the wall 
  	 --if the lights are off
  	 if(lightson or not fget(s, invisible)) then
  	  drawtile(tilemap[s], tx, ty)
  	 end 
			end
  end
 end
end

function drawsmallmaze()
	for x=0,7 do
	 for y=0,7 do
	  getmappiece(x,y)
	  if(s > 0) spr(s, (x+1)*8, (y+6)*8)
  end
 end
end

function getmappiece(xpos,ypos)
 if(mapx + xpos == -1 
	or mapx + xpos == 30
 or mapy + ypos == -1
 or mapy + ypos == 30) then 
 	s = currlevel["wall"]
 else
  --pos is 0 based, map is 1 based
  local tpx = mapx+xpos
  local tpy = mapy+ypos
  s = mget(tpx, tpy)
 end
 
 return s 
end

function drawtile(s, x, y)
 spr(s, x, y)
 spr(s+16, x, y+8)
 spr(s+1, x+8, y)
 spr(s+17, x+8, y+8)
end

function drawplayer()
 local playerx, playery = tocoords(playerpos)
 local moldx = (playerx-mapx)*16
 local moldy =	(playery-mapy)*16
 
 local tx = playerx-mapx
 local ty = playery-mapy
	--if (ismoving and not mapscrolling) then
	-- moldx += offsetx * -1 --offset is opposite
	-- moldy += offsety * -1
	--end
 if(mode == modelarge) then
  drawtile(tilemap[curplayer],moldx,moldy)
 else
  --drawsmall
  spr(curplayer, 
   (1+playerx-mapx)*8, 
   (6+playery-mapy)*8)
 end
end

--draw the screen for the small map
function drawsmall()
 rectfill(0,0,128,128,12)
 rectfill(28,26,52,32,0) --level
 line(28,25,52,25,7)
 line(28,33,52,33,7)
 
 rectfill(5,36,75,42,0) --name
 line(5,35,75,35,7)
 line(5,43,75,43,7)
 
 rect(5,45,75,113,7) --map
 rect(6,46,74,112,0)
 rectfill(8, 48, 72, 110, 0)

 print(currlevel.index, 37, 27, 7)
 local len = #currlevel["name"]*3
 print(currlevel.name, 35-(len/2), 37, 7)
 
 --draw the logo
 spr(106,84,12)
 spr(107,92,12)
 spr(108,100,12)
 spr(109,108,12)
 spr(122,84,20)
 spr(123,92,20)
 spr(124,100,20)
 spr(125,108,20)
end

--if the player has map tiles, show them
function drawmap()
 rect(81,45,116,80,7)
 rect(82,46,115,79,0)
 rectfill(84, 48, 113, 77, 0)

 for x=0,29 do
 	for y=0,29 do
 	 --get the map item
 	 local m = mget(x,y)
 	 --if flag 7 plot red
 	 if (fget(m, 7)) pset(84+x,48+y,8)
 	 --if flag 6 plot white
 	 if (fget(m, 6)) pset(84+x,48+y,7)
 	end
 end
end

--draw the moves used
function drawmoves()
 --moves box
 rectfill(84, 85, 115, 95, 0)
 rect(82, 83, 117, 97, 0)
 rect(81, 82, 118, 98, 7)
 
 spr(curplayer, 86, 87)
 local m = ""
 if (moves<10) then
  m = "000"
 elseif (moves<100) then
  m = "00"
 else 
  m = "0"
 end
 
 print(m..moves, 98, 88)
 
 --remaining masks box
 rectfill(84, 103, 115, 113, 0) 
 rect(82, 101, 117, 115, 0)
 rect(81, 100, 118, 116, 7)
 
 spr(72, 96, 104)
 print(total, 86, 106)
 print(found, 107, 106)
end
-->8
--***************************
--* moving player and map
--***************************

function tocoords(pos)
	return pos % mapsize, pos \ mapsize
end

function topos(x, y)
 return y*mapsize + x
end 

function tileat(pos)
 local tx, ty = tocoords(pos)
 return mget(tx, ty)
end

function settile(pos, s)
 local tx, ty = tocoords(pos)
 return mset(tx, ty, s)
end

function getoffset(d)
 local offset = -1
 if(d == right) then
  offset = 1
 elseif(d == up) then
  offset = -mapsize
 elseif(d == down) then
  offset = mapsize
 end
 return offset
end

function updatemove()
 --switch modes
 if (btnp(4)) mode *= -1

 --change player
 if (btnp(5)) then
 	if(curplayer == magus) then
 	 currlevel["maguspos"] = playerpos
 	 currlevel["magusmapx"] = mapx
 	 currlevel["magusmapy"] = mapy
 	 playerpos = currlevel["questorpos"]
 	 mapx = currlevel["questormapx"]
 	 mapy = currlevel["questormapy"]
 	 curplayer = questor
 	else --questor
 	 currlevel["questorpos"] = playerpos
 	 currlevel["questormapx"] = mapx
 	 currlevel["questormapy"] = mapy
   playerpos = currlevel["maguspos"]
 	 mapx = currlevel["magusmapx"]
 	 mapy = currlevel["magusmapy"]
 	 curplayer = magus
 	end
 end
 
 if (btn(0)) then 
  playerleft()
 elseif (btn(1)) then
  playerright()
 elseif (btn(2)) then
  playerup()
 elseif (btn(3)) then
  playerdown()
 end
 
 --check to see if we need to
 --scroll the map
 scrollmap()
end

function scrollmap() 
 mapscrolling = false
 local playerx, playery = tocoords(playerpos)
 --does the map need to scroll?
 if((playerx == mapx) and mapx>-1) then
  mapx -= 1
  mapscrolling = true
 end
 if((playerx == mapx+7) and mapx<29) then
  mapx += 1
  mapscrolling = true
 end 
 if((playery == mapy+7) and mapy<29) then 
  mapy += 1
  mapscrolling = true
 end
 if((playery == mapy) and mapy>-1) then
  mapy -= 1
  mapscrolling = true
 end
end

function playerleft()
 move(playerpos, left)
end

function playerright()
 move(playerpos, right)
end

function playerup()
 move(playerpos, up)
end

function playerdown()
 move(playerpos, down)
end

--true if the position is on the
--edge of the map
function atedge(pos, d)
 local isedge = false

  if(d == left 
     and pos % mapsize == 0) then
   isedge = true
  elseif(d == right
     and pos % mapsize == mapsize-1) then
   isedge = true
  elseif(d == up 
     and pos < mapsize) then
   isedge = true
  elseif(d == down 
     and (pos \ mapsize) == mapsize-1) then
   isedge = true
  end  
 return isedge
end

--returns true if something
--can move from pos 
--in the direction d
function canmove(pos,  d)
 local isvalid = false
 
 --are we at the edge of the map?
 if(not atedge(pos, d)) then
  local newpos = pos + getoffset(d)
  --can we move into the tile
  --in the direction
  local s = tileat(newpos)
  local n = tileat(pos)
  
  --rules for player token
  if(n == questor or n == magus) then
	  --is the tile enterable?
	  if(d == left or d == right) then
	   if(fget(s, 0)) then
	    isvalid = true
	   end
	  elseif(d == up or d == down) then
	 		if(fget(s, 1)) then
	 		 isvalid = true
 		 end
   end 
  else --anything else
   --only true for spaces and
   --forcefields in the right
   --direction
   if(s == space or
     (s == dots and (d == left or d == right)) or
     (s == waves and (d == up or d == down))) then
     isvalid = true
   end 
  end
 end
 
 return isvalid
end

--see if we can move the player
--into position, or if another
--tile can be pushed
function move(pos, d)
 local newpos = pos + getoffset(d)
 local tx, ty = tocoords(newpos)
 --check that we can move to
 --new position
 if(canmove(pos,d)) then
  --nice and simple, update pos
  moveplayer(d)
 end
 
 --not free, but can we push?
 if(push(newpos,d)) then
  moveplayer(d)
 end
end

--move the player in the
--specified direction
function moveplayer(d)
 local newpos = playerpos + getoffset(d)
 local s = tileat(newpos)
 
 settile(playerpos, space)
 settile(newpos, curplayer)

 local oldpos = playerpos
 playerpos = newpos
 
 --perform any action for
 --taking this tile  
 takenpiece(s)

 --check to see something can
 --fall into the vacated space
 canfallinto(oldpos, d)
 
 --update the moves counter
 moves += 1
 
 --if we are moving horizontally
 --ensure that items falling
 --vertically get processed 
 --first
 if(d == left or d == right) then
  fpriority = fallingdown
 else --horizontally
  fpriority = fallingleft
 end
end

--moves a non-player tile
--returns new position
function movetile(pos, d)
 local newpos = pos + getoffset(d)
 local s = tileat(pos)
 settile(pos, space)
 settile(newpos, s)
 
 return newpos
end 
-->8
--*********************
--* falling
--*********************

--check to see if something
--can fill this space now
function canfallinto(pos, d)
 local tpos = pos
 --are we on the top row?
 if(not atedge(pos, up)) then
  canfalldown(pos + getoffset(up))
 end
 
 if(not atedge(pos, right)) then
  canfallleft(pos + getoffset(right))
 end
end

--can the tile at pos fall left
function canfallleft(pos)
 if(not atedge(pos, left)) then
		local s = tileat(pos)
		if(fget(s, fallleft)) then
		 --check to see that we have
		 --space to fall into
		 local t = tileat(pos-1)
		 if (t == space or t == dots) then
				--this tile can fall
				add(fallingleft, pos)
			end	
		end
	end
end

--can the tile at pos fall down?
function canfalldown(pos)
	if(not atedge(pos, up)) then
		local s = tileat(pos)
		if(fget(s, falldown)) then
			local t = tileat(pos+mapsize)
			if(t == space or t == waves) then
				--this tile can fall
				add(fallingdown, pos)
			end
		end
	end
end

--update each falling piece
--returns true if something 
--has moved
function updatefalling()
 local hasfallendown = false
 
 if(fpriority == fallingdown) then
  hasfallendown = updatefalldown()
  hasfallenleft = updatefallleft()
 else
  hasfallenleft = updatefallleft()
  hasfallendown = updatefalldown()
 end
 return hasfallenleft or hasfallendown
end

function updatefalldown()
 return updatefall(fallingdown, down)
end

function updatefallleft()
 return updatefall(fallingleft, left)
end

function updatefall(set, d)
 local hasfallen = false
 for pos in all(set) do
  if(canmove(pos, d)) then
   movetile(pos, d)
   --remove the old position
   --and add the new one
   add(set, 
   			 pos+getoffset(d))
   
   hasfallen = true
   
   --check to see if we have 
   --set something else falling
   canfallinto(pos, d)
  else
   --we've bumped into something
   local hit = tileat(pos 
   					         +getoffset(d))
   
  end   
  --we always remove this item
  del(set, pos)
 end
 
 return hasfallen
end
-->8
--***************************
--* pushing
--***************************
--push the tile at pos in the
--direction of d
function push(pos, d)
 local pushed = canpush(pos, d)
 if(pushed) then
  local newpos = movetile(pos,d)
  
  --can the pushed tile fall?
  if(d == left or d == right) then
   canfalldown(newpos)
  else
   canfallleft(newpos)
  end
 end 
 
 return pushed
end

--return true only if next tile
--is empty or valid forcefield
--you cannot push two items
function canpush(pos, d)
 local pushed = false
 
 --can only push items with 
 --flag 2 set
 local s = tileat(pos)
 if(not fget(s, pushable)) then
  return false
 end
 
 --can only push chickens up
 --and down, and fish only 
 --left and right
 if(d == up and fget(s, falldown)) then
  return false
 elseif(d == right and fget(s, fallleft)) then
  return false
 end
 
 if(not atedge(pos, d)) then
  --we need the next tile now
  local newpos = pos + getoffset(d)
  s = tileat(newpos)
  if(s == space) then
   pushed = true
  elseif(s == dots 
    and (d == left or d == right)) then
 	 pushed = true
 	elseif(s == waves
 	  and (d == up or d == down)) then
 	 pushed = true
 	end 
 end
 
 return pushed
end
-->8
--************************
--* tile actions
--************************
function takenpiece(p)
 if(p == mask) then
 	found += 1
 elseif(p == frown) then
  lightson = not lightson
 end
end

--something falling has 
--hit piece p
function hitpiece(p)
 if(p == bomb) then
 
 elseif(p == poison) then
 
 elseif(p == questor) then
 
 elseif(p == magus) then
 
 end
end
__gfx__
000000008880f8888880f8888888808888808888007777000011111100000005000000051224442210033300cccccccccccccccc044444444444440000000000
000000008880f8888880f888088888088888088811111170000111110099900000eee0002440004421100011c7c77c7777c7777c044aaaaaaaaa440000000000
00700700fff0fffffff0ffff80888080888080881111111700000000099999000eeeee00400ccc0042211122c7cc7c7cc7c7cc7c044a99999992440000000000
000770000000000000000000880808880808880801111100000000000099900500eee0050ccdddcc04422244c7777c77c7777c7c044a99999992440000000000
00077000f8888880f8888880888088888088888000000000066000000000000000000000cdd666ddc0044400c7ccccc7cccc7c7c044a99999992440000000000
00700700f8888880f88888808808888808888808dddd0006666000dd0005000000050000d6600066dcc000ccc77777777c777c7c044a99999992440000000000
00000000fffffff0fffffff08088888088888088ddddd00666600dddb00000ccc00000bb600fff006ddcccddccccc7c77ccccc7c044a22222222440000000000
0000000000000000000000000888880888880888ddddd00666600dddbb000ccccc000bbb0ff999ff066ddd66c7c777cc77c7777c044444444444440000000000
ccc77cc98880f8888880f8888088808088808088dddd0006666000ddb00000ccc00000bbf99aaa99f0066600c777cccc77cc7ccc044444444444440000000000
c7cc77c98880f8888880f8888808088808088808000000006600000000050000000500009aa000aa9ff000ffc7c7c77cc7c7777c044aaaaaaaaa440000000000
cc7c77c9fff0fffffff0ffff888088888088888000000ee0000222200000000500000000a00eee00a99fff99c7c7cc7cc7c77c7c044a99999992440000000000
cc7777c9000000000000000088080888880888880000eeeee002222200888000003330050eebbbee0aa999aac7c7cc7cc7cccc7c044a99999992440000000000
0ccc7c90f8888880f88888808088808888808888000eeeeee00222200888880003333300ebb333bbe00aaa00ccc7c777ccc7777c044a99999992440000000000
0cc7cc90f8888880f88888800888880888880888000eeeeee00777770088800000333000b3300033bee000eec7c777c7ccccc7cc044a99999992440000000000
00ccc900fffffff0fffffff08888808088808088000eeeeee01111170000000500000005300111003bbeeebbc777ccc77777777c044a22222222440000000000
000c9000000000000000000088880888080888080000000000111111000500000005000001122211033bbb33cccccccccccccccc044444444444440000000000
000000000ccccccc7ccccc700ccccccccccccc7000cc000000007700000000000000000000007770077700000000880800000000000000000000000000000000
000000000cccccc777cccc700cccccaaaccccc700ccccc000077ccc0077000000007700000000777777000000077888000000000077000000007700000000000
000000000cccc777777ccc700cccaaaaaaaccc700cccccccccccccc0077770000777711000000077770000000870788000000000077770000777711000000000
000000000c77ccc777cccc700caaaacccaaaac700cc77cccccc77cc0077077777707711000008877887700008877770800000000077077777707711000000000
000000000cc7cc7777cccc700aaacccccccaaa700c700cccccc00cc0077707777077711000087788778870000077770000000000077707777077711000000000
000000000ccc777777cc7c700accccaaacccca700c0000cccc0000c0070077777700711000778877887788000077777000000000070077777700711000000000
000000000cccc7777777cc700cccaaaaaaaccc700cc00cccccc00cc0077777077777711000887788778877000777777770000000077777077777711000000000
000000000ccc77c77777cc700caaaacccaaaac700cccccccccccccc0077777077777711008778877887788707770077777000000077777077777711000000000
000000000cc7ccc77777cc700aaacccccccaaa700cccccccccccccc0077777007777711007887788778877807707777777000000077777007777711000000000
000000000ccccccc7777cc700accccccccccca700cc00cccccc00cc0077777777777711008778877887788707707777777770000077777777777711000000000
000000000cccccccc77ccc700ccccccccccccc7000c000cccc000c00007770000777111007887788778877807770777700007777007707777077111000000000
0000000000cccccc77ccc70000ccccccccccc70000cc000000007c00007707777077110000778877887788000777000077777777007770000777110000000000
00000000000ccc77cccc7000000ccccccccc7000000cc0000007c000000777777771100000077777777770000077777777770000000777777771100000000000
000000000000ccccccc700000000ccccccc700000000cc00007c0000000077777711000000077c77877770000000777777000000000077777711000000000000
00000000000000ccc7700000000000ccc770000000000cc777c00000000000771110000000007778087700000000000800000000000000771110000000000000
00000000000000007000000000000000700000000000000000000000000000011100000000000078080000000000088800000000000000011100000000000000
880f8888880888080dddd0441111111170770700ccccccccccc77cc9ccc7ccc977000779770007790780078000880000000077000777777000aaaa0004444440
880f88888880808046ddd4441c1c1c1c07007077c777777cc7cc77c9cc7c7cc9777777797777777900787800a7780000000ee0700333333000affa0004999940
ff0fffff08880888660000441111111170770700c7c7cc7ccc7c77c9c7ccc7c9707770797770777907878780007700000eeeee703770077300aeea0004999940
000000008080888866099990c1c1c1c107007077c7c77c7ccc7777c97cc7cc7977777779770707797878787877777777eeeea07e37700773ffe77eff04999940
f888888088088880669999991111111170770700c7cc777c0ccc7c900c7c7c9070777079070707908787878777777770eeee070e300770030eeeeee004444440
f888888080888808669999991c1c1c1c07007077c77c7c7c0cc7cc9007ccc790700700790777779007c7777077777700eeeea0ae37700773eee77eee04999940
fffffff008888088600999001111111170770700c777777c00ccc90000ccc900070007900077790000778700077770000eeeeee0300770030eeeeee004999940
000000008088088860dd0000c1c1c1c107007077cccccccc000c9000000c900000777900000790000007800000aaa000000ee000033333300044440004444440
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000007777999000005777777777750000000aaaaa00000000000000000000000000000000000000777777077777007777700077777770000000000000000000
000077ee0e77090000577777777775000000aaaaaaa0000000000000000000000000000000000000007000007700077000770007700077000000000000000000
0007eeeee0e0990003355555555553300000afcfcfa0000000000000000000000000000000000000007000077700770000077007700007700000000000000000
007eeeee0e0e97003333333333333333000aafffffaa000000000000000000000000000000000000007000077000770000077007700007700000000000000000
07eeeee0a0e090703377777777777733000a0fffff0a000000000000000000000000000000000000000700777000770000077007700007700000000000000000
07eeeeee0a0990703777700000077773000000fff000000000000000000000000000000000000000000700770000770000077007700007700000000000000000
7eeeeeeee09900073777707007077773000000eee000000000000000000000000000000000000000000707700000770000077007700777000000000000000000
7eeeeeee0a0a00073777700000077773ffeeeeeeeeeeeff000000000000000000000000000000000000077700000770000077007777700000000000000000000
7eeeeee0a0e0a0073700770000770073ffeeeee7eeeeeff000000000000000000000000000000000000077700000770000077007770000000000000000000000
7eeeeeee0e00000737000007700000730000eeeeeee0000000000000000000000000000000000000000770700000770000077007777000000000000000000000
07eeeeeee0e000703777770000777773000eeee7eeee000000000000000000000000000000000000000770700000770000077007707700000000000000000000
07eeeeee0e0e00703700000000000073000eeeeeeeee000000000000000000000000000000000000007700070000770000077007700770000000000000000000
007eeee0e0e0070037007777777700730eeeeee7eeeeee0000000000000000000000000000000000007700070000770000077007700070000000000000000000
0007eeee0e0e70003777777777777773000eeeeeeeee000000000000000000000000000000000000077000007000770000077007700077000000000000000000
000077eee077000033777777777777330000ff000ff0000000000000000000000000000000000000077000007000077000770007700007000000000000000000
00000077770000000333333333333330000444000444000000000000000000000000000000000000777770077770007777700077770077700000000000000000
__gff__
0300000000000001010202030300000000000000000000010102020303000000000000000003030000070707070303000000000000030300000707070703030080808001020300004303140c140c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004148004600004800000000000000424a4a4a484200000000004200484200484b424848484a0000000000000000
00000000000000000000000000000000000000000000000000000000000000404040404040404040434040404040404040404040404040404040400041004a4a0000414a004143434a000000410000004a000041414100004141004200004a42004248484848420042484b0042004a48444b4b4200004a4b0000000000000000
0000000000000000000000000000000000000000000000000000000000000040484443004500464000000000000000000000000000000000000040004443434a0041484300414148414143444100004441410041004a0000414700440042484b00424842484b4200424242004200004200004242004a4b000000000000000000
0000000000000000000000000000000000000000000000000000000000000040480000000040404000404040404040404040404040404040400040004448444a004a41410041484100000000414100444841004100414141410000440000484800424848484b4200424a4a000000420000000042484b00000000000000000000
00000000000000000000000000000000000000000000000000000000000000404040000049484900004a0000000000000000000000000000400040004348444a0043000000410000004a0000414a00444541000000484141414b004400424a420042000000000000424a4b000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000400040404040404340404040404040404040404540400040004000484844430048414148414a4a4a484a4a414800444841004100410000000000440048484a4b42424242424242424800004200420000004b420000444b0000000000000000
000000000000000000000000000000000000000000000000000000000000404000404b4044000000000000000000000000000000000040004000400045414141414141414141414141414141414141414141414141414141410000440000444b43424242000000004248000042484248484b4b42480000000000000000000000
00000000000000000000000000000000000000000000000000000000000000430040000048404040404340404043434440404040400040004000400000000000004848484841484b484b484b41480000000045410000000041000044000000000042420000424243424242424200424242424242424242000000000000000000
000000000000000000000000000000000000000000000000000000000000484400400040404400000000004844000000444800004000400043004000414141410041414141410000000000000044004148414b41444b41004100004200000000004248480000424842484a4a004a4a4a4a444b4b4b4842000000000000000000
0000000000000000000000000000000000000000000000000000000000004844004000404844004040404040404040404040400040484000400040004a00000000004a434a410000484b4b4b4144000000000041444b41444b00000000004a4b0042424200004248434a4a48004343434300444b4b4b42000000000000000000
0000000000000000000000000000000000000000000000000000000000004844004000400044004048404800000000000000400040404000400040004300000000004a444841444b4b4b4b4b4144004148410041484b41004100444242424a000042000000004242424a434800444448444a00444b4b42000000000000000000
0000000000000000000000000000000000000000000000000000000000004844004000400044004000404040434343434000400040484000400040000041414141004a4148410000484b4b4b414b4b4b4b4b4b41444b410041004443434248000042424242000000424800004343434443430000444b42480000000000000000
0000000000000000000000000000000000000000000000000000000000004844004000400044000000000000000000004000400040004000400040000000004a41004341444148444b4b4b4b41000000000000000000410000484242444242420042424242424200424242444242424242424442424242420000000000000000
0000000000000000000000000000000000000000000000000000000000004040004044400040004000404040400040004000400040004000400040000000004a41004841444141414141410041414141414141414141414141414800004a00000042000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000400040004000400040004040404848000000000000440000004400404748000048410000000041484300000000414b48444148414800000000484b484b4b4b00004b42424242424242424242424242424242424242424242420000000000000000
00000000000000000000000000000000000000000000000000000000000000400040004000400040484048404f484000400040004000400040004000440000414141414141414141000041414148484b41484148000000414b4b48004a4b00000042000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000400040004000400040404000404040400040004000400040004000400044000000000000444a4148414b00414841484b0000004148414800414848444b4b0000000042004242424242424242420000000000424b4b4b4b4b000000000000000000
0000000000000000000000000000000000000000000000000000000000000040004000400000004000000000000000004000400040004000400040004400004a00000043434100000000444b414b484b4100004441414b41000042000000004848420042000000000000424842004a000042480000004a000000000000000000
000000000000000000000000000000000000000000000000000000000000004000400040004040400040404040404340400040004000404840004000440000480041004448414141000000004148000000004141410000000000000000004242424200000042484a424b42000000434a4b42420048004a000000000000000000
00000000000000000000000000000000000000000000000000000000000048400040004000404844004000000000000000004000400040404000400000000000004100414141480000484b004100000000000000000000000000000000004848484242424242484b420042000000004a0042000000004a000000000000000000
00000000000000000000000000000000000000000000000000000000000048400040004000004844004043444340404040404000400040484000400044004a004a41004a4a414141414141004143444100000041414b4b4b4b4b004242424242424242424242484a4200420000484b4b4b42484200004a000000000000000000
000000000000000000000000000000000000000000000000000000000000004000430040004048440043434444404800000000000000400040004000440048004841004a4841434348004400414344410000000041484444444b000000000000004200000042484b424b4248484248484842484842484a000000000000000000
000000000000000000000000000000000000000000000000000000000000004040400040004040404040444343404040404040404000400040004000440000000041004a4a4100444b44440041444b4b414100004141000048004842420000004842004200000000000042424242424242424242424242000000000000000000
000000000000000000000000000000000000000000000000000000000000004048400040000000434840434344484048430000000000400040484000440000004a41004a4a41480043444b0041444b4b48410000414800484b44484200000000004200424242424242424200484b420000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000404840444040404440404040404040404040404040404440004040400044410000484143484a414b004443440041480000484100004141414141414842004a4b4b004200000000000000000000000042004a004200004a004a0000000000000000
0000000000000000000000000000000000000000000000000000000000000040004048404848444400000000000000000000000000000000404800004841004800414148434144444444430041414141414141000000000000004842004a4a00004200424b4b4b4b420000004a4b420048004200004a484a0000000000000000
000000000000000000000000000000000000000000000000000000000000004300404040404040400040404040404040404040404043404040000000484100000041000000414443434343004500000000000000414841444b4b4842004a420000480042444842444200004a4b444200424b42004242424a0000000000000000
000000000000000000000000000000000000000000000000000000000000004043000000000000000000000000000000000000004848404800000000484100004a410000004141414141414141444b4b000000414841414b4b48484248484248484200424800000042484b4b42424200000042444848484b0000000000000000
0000000000000000000000000000000000000000000000000000000000000040404340404040404040434343434343434343404040404000000045434841000048000000004a00004f0000000000000000004148444b414448444842424242424242424242424242424242424242424b4b4b4244484f484b0000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444848414a4a4a4a00000000000041000041484148414841480000000000000048000000000000000000000000000000000000000000000042444848484b0000000000000000
