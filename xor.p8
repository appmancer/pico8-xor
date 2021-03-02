pico-8 cartridge // http://www.pico-8.com
version 30
__lua__
function _init()
 --map
 modelarge = -1
 modesmall = 1
 mode = modelarge
 mapx = 3
 mapy = 1
 animx = 0
 animy = 0
 mapsize = 28
 
 --player
 magus = 70 --sprite
 questor = 71 --sprite
 curplayer = magus
 playerx = 8
 playery = 2
 oldx = 8
 oldy = 2
 offsetx = 0
 offsety = 0 
 xs = -1
 xe = 8
 
 --this turn
 moves = 0
 found = 0
 total = 47
 
 --temporaray flags
 ismoving = false
 animframe = 0
 mapscrolling = true
 
 --constants
 left = 0
 right = 1
 up = 2
 down = 3
 
 --level data
 levels={}
 
 --dots and waves
 l1={}
 l1["index"] = "01"
 l1["name"] = "dots and waves"
 l1["magusx"] = 8
 l1["magusy"] = 2
 l1["questorx"] = 29
 l1["questory"] = 14
 l1["magusmx"] = 3
 l1["magusmy"] = 1
 l1["questormx"] = 22
 l1["questormy"] = 10
 l1["wall"] = 64 --brick
 
 levels[1]=l1
 
 --todo - copy the data this
 --must not destroy level data
 currlevel = l1

	initmapping()

 --temp values - delete
 flagdebug = 0
end

function _update60()
 if (ismoving) then
  updateanim()
 else
  updatemove()
 end 
end

function _draw()
 cls()
 if mode == modelarge then
	 drawmaze()
  drawlargeplayer()
	else
	 drawsmall()
  drawmaze() 
  drawmap()
	 drawmoves()
	 drawsmallplayer()
	end
	
	--drawdebug()
end

--the map data is in small tiles
--this converts the small to 
--large tiles
function initmapping()
 chickem = 75
 fish = 74
 frown = 73
 mask = 72
 questor = 71
 magus = 70
 mappiece = 69

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
end

function drawdebug()
	rectfill(0,96,128,128,0)
	print("px:"..playerx, 2, 110, 5)
	print("py:"..playery, 2, 120, 5)
end
-->8

--draws either small or large
--maze
function drawmaze()
 --we have to add an extra col
 --or row for the maze that is
 --coming into view
 
 for x=xs,xe do
  for y=xs,xe do
  	if(mapx + x == -1 
  	or mapx + x == 30
   or mapy + y == -1
   or mapy + y == 30) then
   	s = currlevel["wall"]
  	else
    s = mget(mapx+x, mapy+y)
   end
   if(mode==modelarge) then
   	if(s > 0 and s != curplayer) then
   		local tx = x*16
   		local ty = y*16
   	 if (mapscrolling) then
   	 	tx += offsetx
   	 	ty += offsety
   	 end
					drawtile(tilemap[s], tx, ty)
				end
	  else -- small, can just draw
	   clip(8, 48, 64, 64)--trim
	   if(s > 0) spr(s, (x+1)*8, (y+6)*8)
	 		clip(0, 0, 128, 128)
	  end
  end
 end
end

function drawtile(s, x, y)
 	 spr(s, x, y)
 	 spr(s+16, x, y+8)
 	 spr(s+1, x+8, y)
 	 spr(s+17, x+8, y+8)
end

function drawlargeplayer()
 local moldx = (playerx-mapx)*16
 local moldy =	(playery-mapy)*16

	if (ismoving and not mapscrolling) then
	 moldx += offsetx * -1 --offset is opposite
	 moldy += offsety * -1
	end
 
 drawtile(tilemap[curplayer],moldx,moldy)
 
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

function drawsmallplayer()
 spr(curplayer, 
 				(1+playerx-mapx)*8, 
 				(6+playery-mapy)*8)
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
function updatemove()
 --switch modes
 if (btnp(4)) mode *= -1

 --change player
 if (btnp(5)) then
 	if(curplayer == magus) then
 	 currlevel["magusx"] = playerx
 	 currlevel["magusy"] = playery
 	 currlevel["magusmx"] = mapx
 	 currlevel["magusmy"] = mapy
 	 playerx = currlevel["questorx"]
 	 playery = currlevel["questory"]
 	 mapx = currlevel["questormx"]
 	 mapy = currlevel["questormy"]
 	 curplayer = questor
 	else --questor
 	 currlevel["questorx"] = playerx
 	 currlevel["questory"] = playery
 	 currlevel["questormx"] = mapx
 	 currlevel["questormy"] = mapy
   playerx = currlevel["magusx"]
 	 playery = currlevel["magusy"]
 	 mapx = currlevel["magusmx"]
 	 mapy = currlevel["magusmy"]
 	 curplayer = magus
 	end
 end

 oldx = playerx
 oldy = playery
 
 -- can the player move in that direction?
 if (btn(0) and playerx > 0 and canmove(playerx-1, playery, 0)) then 
  playerx -= 1
  moveto(left)
 end
 if (btn(1) and playerx < 29 and canmove(playerx+1, playery, 0)) then
  playerx += 1
  moveto(right)
 end
 if (btn(2) and playery > 0 and canmove(playerx, playery-1, 1)) then
  playery -= 1
  moveto(up)
 end
 if (btn(3) and playery < 29 and canmove(playerx, playery+1, 1)) then
  playery += 1
  moveto(down)
 end
 
 mapscrolling = false
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

function updateanim()
 animframe -= 4
 
 if(movedir == left) then
		offsetx = animframe * -1
	elseif(movedir == right) then
	 offsetx = animframe
	elseif(movedir == up) then
	 offsety = animframe * -1
	elseif(movedir == down) then
	 offsety = animframe
	end

 if (animframe <= 0) then
  ismoving = false
 end
end

function moveto(d)
  --what am i moving into?
  target = mget(playerx, playery)
  
  if(target == chicken) then
  
  elseif(target == fish) then
  
  elseif(target == frown) then
  
  elseif(target == mask) then
  	--score a point
  	found += 1
  end

  moves += 1
  ismoving = true
  movedir = d
  animframe = 16
  offsetx = 0
		offsety = 0
		  
  --remove old player
  mset(oldx, oldy, 0)
  mset(playerx, playery, curplayer)

		--update animframe
		updateanim()
end

function canmove(cx, cy, d)
 local isvalid = false
 local s = mget(cx, cy)
 flagdebug = fget(s,d)
 --if the direction matches the flag
 if(fget(s, d)) isvalid = true
 return isvalid
end

__gfx__
000000008880f8888880f8888888808888808888007777000011111100000005000000051224442210033300cccccccccccccccc0ccccccccccccc7000000000
000000008880f8888880f888088888088888088811111170000111110099900000eee0002440004421100011c7c77c7777c7777c0ccccccccccccc7000000000
00700700fff0fffffff0ffff80888080888080881111111700000000099999000eeeee00400ccc0042211122c7cc7c7cc7c7cc7c0ccccccccccccc7000000000
000770000000000000000000880808880808880801111100000000000099900500eee0050ccdddcc04422244c7777c77c7777c7c0ccccccccccccc7000000000
00077000f8888880f8888880888088888088888000000000066000000000000000000000cdd666ddc0044400c7ccccc7cccc7c7c0ccccccccccccc7000000000
00700700f8888880f88888808808888808888808dddd0006666000dd0005000000050000d6600066dcc000ccc77777777c777c7c0ccccccccccccc7000000000
00000000fffffff0fffffff08088888088888088ddddd00666600dddb00000ccc00000bb600fff006ddcccddccccc7c77ccccc7c0ccccccccccccc7000000000
0000000000000000000000000888880888880888ddddd00666600dddbb000ccccc000bbb0ff999ff066ddd66c7c777cc77c7777c0ccccccccccccc7000000000
ccc77cc98880f8888880f8888088808088808088dddd0006666000ddb00000ccc00000bbf99aaa99f0066600c777cccc77cc7ccc0ccccccccccccc7000000000
c7cc77c98880f8888880f8888808088808088808000000006600000000050000000500009aa000aa9ff000ffc7c7c77cc7c7777c0ccccccccccccc7000000000
cc7c77c9fff0fffffff0ffff888088888088888000000ee0000222200000000500000000a00eee00a99fff99c7c7cc7cc7c77c7c0ccccccccccccc7000000000
cc7777c9000000000000000088080888880888880000eeeee002222200888000003330050eebbbee0aa999aac7c7cc7cc7cccc7c00ccccccccccc70000000000
0ccc7c90f8888880f88888808088808888808888000eeeeee00222200888880003333300ebb333bbe00aaa00ccc7c777ccc7777c000ccccccccc700000000000
0cc7cc90f8888880f88888800888880888880888000eeeeee00777770088800000333000b3300033bee000eec7c777c7ccccc7cc0000ccccccc7000000000000
00ccc900fffffff0fffffff08888808088808088000eeeeee01111170000000500000005300111003bbeeebbc777ccc77777777c000000ccc770000000000000
000c9000000000000000000088880888080888080000000000111111000500000005000001122211033bbb33cccccccccccccccc000000007000000000000000
000000000ccccccc7ccccc700ccccccccccccc700000000000000000000000000000000000007770077700000000880800000000000000000000000000000000
000000000cccccc777cccc700cccccaaaccccc700770000000077000077000000007700000000777777000000077888000000000000000000000000000000000
000000000cccc777777ccc700cccaaaaaaaccc700777700007777110077770000777711000000077770000000870788000000000000000000000000000000000
000000000c77ccc777cccc700caaaacccaaaac700770777777077110077077777707711000008877887700008877770800000000000000000000000000000000
000000000cc7cc7777cccc700aaacccccccaaa700777077770777110077707777077711000087788778870000077770000000000000000000000000000000000
000000000ccc777777cc7c700accccaaacccca700700777777007110070077777700711000778877887788000077777000000000000000000000000000000000
000000000cccc7777777cc700cccaaaaaaaccc700777770777777110077777077777711000887788778877000777777770000000000000000000000000000000
000000000ccc77c77777cc700caaaacccaaaac700777770777777110077777077777711008778877887788707770077777000000000000000000000000000000
000000000cc7ccc77777cc700aaacccccccaaa700777770077777110077777007777711007887788778877807707777777000000000000000000000000000000
000000000ccccccc7777cc700accccccccccca700777777777777110077777777777711008778877887788707707777777770000000000000000000000000000
000000000cccccccc77ccc700ccccccccccccc700077077770771110007770000777111007887788778877807770777700007777000000000000000000000000
0000000000cccccc77ccc70000ccccccccccc7000077700007771100007707777077110000778877887788000777000077777777000000000000000000000000
00000000000ccc77cccc7000000ccccccccc70000007777777711000000777777771100000077777777770000077777777770000000000000000000000000000
000000000000ccccccc700000000ccccccc700000000777777110000000077777711000000077c77877770000000777777000000000000000000000000000000
00000000000000ccc7700000000000ccc77000000000007711100000000000771110000000007778087700000000000800000000000000000000000000000000
00000000000000007000000000000000700000000000000111000000000000011100000000000078080000000000088800000000000000000000000000000000
880f8888880888080dddd0441111111170770700ccccccccccc77cc9ccc7ccc97700077977000779078007800088000000000000000000000000000000000000
880f88888880808046ddd4441c1c1c1c07007077c777777cc7cc77c9cc7c7cc9777777797777777900787800a778000000000000000000000000000000000000
ff0fffff08880888660000441111111170770700c7c7cc7ccc7c77c9c7ccc7c97077707977707779078787800077000000000000000000000000000000000000
000000008080888866099990c1c1c1c107007077c7c77c7ccc7777c97cc7cc797777777977070779787878787777777700000000000000000000000000000000
f888888088088880669999991111111170770700c7cc777c0ccc7c900c7c7c907077707907070790878787877777777000000000000000000000000000000000
f888888080888808669999991c1c1c1c07007077c77c7c7c0cc7cc9007ccc790700700790777779007c777707777770000000000000000000000000000000000
fffffff008888088600999001111111170770700c777777c00ccc90000ccc9000700079000777900007787000777700000000000000000000000000000000000
000000008088088860dd0000c1c1c1c107007077cccccccc000c9000000c900000777900000790000007800000aaa00000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000777777077777007777700077777770000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000007000007700077000770007700077000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000007000077700770000077007700007700000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000007000077000770000077007700007700000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000700777000770000077007700007700000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000700770000770000077007700007700000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000707700000770000077007700777000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000077700000770000077007777700000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000077700000770000077007770000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000770700000770000077007777000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000770700000770000077007707700000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000007700070000770000077007700770000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000007700070000770000077007700070000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000077000007000770000077007700077000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000077000007000077000770007700007000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000777770077770007777700077770077700000000000000000
__gff__
0300000000000001010202030300000000000000000000010102020303000000000000000003030000070707070000000000000000030300000707070700000080808001020300004303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0040404040404040404043404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0040484400004500464000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0040480000000040404000404040404040404040404040404040400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0040404000000048000000000000000000000000000000000000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004000404040404043404040404040404040404045404000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040004000404400000000000000000000000000000000004000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0043004000004840404040434040404343444040404040004000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4844004000404044000000000048440000004448000040004000430040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4844004000404844004040404040404040404040400040484000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4844004000400044004048404800000000000000400040404000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4844004000400044004000404040434343434000400040484000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4844004045400044000000000000000000004000400040004000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040004044400040004000404840400040004000400040004000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0040004000400040004000404040484800000000000044000000440040470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0040004000400040004048404840004840004000400040004000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0040004000400040004040400040404040004000400040004000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0040004000400000004000000000000000004000400040004000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0040004000400040404000404040404043404000400040004048400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4840004000400040484400400000000000000000400040004040400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4840004000400000484400404344434040404040400040004048400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0040004300400040484400434344444048000000000000004000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0040404000400040404040404443434040404040404040004000400040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0040484000400000004348404343444840484300000000004000404840000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0040484044404040444040404040404040404040404040444000404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0040004048404848444400000000000000000000000000000000404800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0043004040404040404000404040404040404040404040434040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0040430000000000000000000000000000000000000048484048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0040404340404040404040434343434343434343404040404000000045430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000044480000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
