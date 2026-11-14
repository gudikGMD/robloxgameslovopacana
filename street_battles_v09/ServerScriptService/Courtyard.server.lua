-- Courtyard v0.8: улучшенный двор + площадь с 2 лидербордами в центре. Процедурная геометрия, без внешних ассетов.
local Lighting=game:GetService('Lighting')
local rng=Random.new(1984)
local rad=math.rad
local function fresh(class,name)
 local o=Lighting:FindFirstChild(name);if o then o:Destroy() end
 o=Instance.new(class);o.Name=name;o.Parent=Lighting;return o
end
Lighting.ClockTime=9.5;Lighting.Brightness=2.6;Lighting.GlobalShadows=true;Lighting.ShadowSoftness=.25
Lighting.Ambient=Color3.fromRGB(140,147,156);Lighting.OutdoorAmbient=Color3.fromRGB(138,144,152)
Lighting.EnvironmentDiffuseScale=.7;Lighting.EnvironmentSpecularScale=.55
local atm=fresh('Atmosphere','StreetAtmosphere');atm.Density=.26;atm.Offset=.2;atm.Color=Color3.fromRGB(199,205,214);atm.Decay=Color3.fromRGB(150,160,176);atm.Glare=.12;atm.Haze=1.1
local bloom=fresh('BloomEffect','StreetBloom');bloom.Intensity=.28;bloom.Size=24;bloom.Threshold=1.5
local cc=fresh('ColorCorrectionEffect','StreetColor');cc.Saturation=.1;cc.Contrast=.08;cc.TintColor=Color3.fromRGB(255,248,238)
local rays=fresh('SunRaysEffect','StreetRays');rays.Intensity=.05;rays.Spread=.7

local old=workspace:FindFirstChild('StreetCourtyard');if old then old:Destroy() end
local w=Instance.new('Folder');w.Name='StreetCourtyard';w.Parent=workspace
local M=Enum.Material
local function C3(r,g,b) return Color3.fromRGB(r,g,b) end
local function part(name,size,cf,color,mat,parent)
 local o=Instance.new('Part');o.Name=name;o.Size=size;o.CFrame=typeof(cf)=='CFrame' and cf or CFrame.new(cf);o.Color=color;o.Material=mat or M.Concrete;o.Anchored=true
 o.TopSurface=Enum.SurfaceType.Smooth;o.BottomSurface=Enum.SurfaceType.Smooth;o.Parent=parent or w;return o
end
local function cyl(name,diam,height,pos,color,mat,parent) -- вертикальный цилиндр
 local o=part(name,Vector3.new(height,diam,diam),CFrame.new(pos)*CFrame.Angles(0,0,rad(90)),color,mat,parent);o.Shape=Enum.PartType.Cylinder;return o
end
local function ball(name,d,pos,color,mat,parent)
 local o=part(name,Vector3.new(d,d,d),pos,color,mat,parent);o.Shape=Enum.PartType.Ball;o.CanCollide=false;return o
end

-- ===== Земля =====
local asphalt=C3(75,78,78);local concrete=C3(148,145,137)
part('Асфальт',Vector3.new(620,2,620),Vector3.new(0,-1,0),asphalt,M.Asphalt)
for _,z in ipairs({-225,225}) do part('Тротуар поперечный',Vector3.new(565,.25,14),Vector3.new(0,.14,z),concrete) end
for _,x in ipairs({-225,225}) do part('Тротуар продольный',Vector3.new(14,.25,565),Vector3.new(x,.14,0),concrete) end
for _,z in ipairs({-80,80}) do part('Дорожка',Vector3.new(455,.18,9),Vector3.new(0,.12,z),C3(119,116,108),M.Pavement) end
for _,x in ipairs({-90,90}) do part('Дорожка',Vector3.new(9,.18,440),Vector3.new(x,.12,0),C3(119,116,108),M.Pavement) end
-- газоны
for _,l in ipairs({{-185,0,36,150},{185,0,36,150},{0,-185,150,36},{0,185,150,36}}) do
 part('Газон',Vector3.new(l[3],.16,l[4]),Vector3.new(l[1],.08,l[2]),C3(84,122,68),M.Grass)
 part('Газон бордюр',Vector3.new(l[3]+1.2,.3,l[4]+1.2),Vector3.new(l[1],.05,l[2]),C3(160,157,148))
end
-- заплатки асфальта, люки, разметка
for i=1,60 do
 local x,z=rng:NextNumber(-290,290),rng:NextNumber(-290,290)
 if math.sqrt(x*x+z*z)>45 then
  part('Заплатка',Vector3.new(rng:NextNumber(3,9),.04,rng:NextNumber(2,7)),CFrame.new(x,.03,z)*CFrame.Angles(0,rng:NextNumber(0,3),0),C3(58+rng:NextInteger(0,12),60+rng:NextInteger(0,12),61+rng:NextInteger(0,12)),M.Asphalt).CanCollide=false
 end
end
for _,v in ipairs({{-40,-110},{40,110},{-150,40},{150,-40},{110,-200},{-110,200}}) do
 cyl('Люк',3.4,.12,Vector3.new(v[1],.1,v[2]),C3(52,54,56),M.Metal).CanCollide=false
end
for i=-3,3 do part('Разметка парковки',Vector3.new(.35,.05,9),Vector3.new(i*8-100,.04,-212),C3(224,224,215),M.SmoothPlastic).CanCollide=false end
for i=-3,3 do part('Разметка парковки',Vector3.new(.35,.05,9),Vector3.new(i*8+100,.04,212),C3(224,224,215),M.SmoothPlastic).CanCollide=false end

-- ===== Центральная площадь + лидерборды =====
cyl('Площадь основание',84,.5,Vector3.new(0,.15,0),C3(103,101,96),M.Concrete)
cyl('Площадь',78,.6,Vector3.new(0,.22,0),C3(172,169,160),M.Pavement)
cyl('Площадь кольцо',62,.7,Vector3.new(0,.24,0),C3(143,140,132),M.Slate)
cyl('Площадь центр',58,.8,Vector3.new(0,.26,0),C3(176,173,164),M.Pavement)
for i=0,15 do -- декоративные плиты-лучи
 part('Луч',Vector3.new(1,.05,26),CFrame.new(0,.7,0)*CFrame.Angles(0,rad(i*11.25),0),C3(150,147,138),M.Slate).CanCollide=false
end
local boards=Instance.new('Model');boards.Name='Leaderboards';boards.Parent=w
local function board(name,x,title,kind,accent)
 local m=Instance.new('Model');m.Name=name;m.Parent=boards
 part('Основание',Vector3.new(24,.7,4),Vector3.new(x,.75,0),C3(55,57,60),M.Concrete,m)
 for _,dx in ipairs({-8,8}) do part('Опора',Vector3.new(1.4,3.4,1.4),Vector3.new(x+dx,2.5,0),C3(40,42,45),M.Metal,m) end
 part('Рама',Vector3.new(21.8,17.8,.6),Vector3.new(x,12,0),C3(35,37,40),M.Metal,m)
 local screen=part('Экран',Vector3.new(20,16,.9),Vector3.new(x,12,0),C3(14,16,20),M.SmoothPlastic,m)
 screen:SetAttribute('Board',kind)
 local strip=part('Подсветка',Vector3.new(20,.35,.35),Vector3.new(x,21.2,0),accent,M.Neon,m);strip.CanCollide=false
 local lamp=Instance.new('PointLight');lamp.Color=accent;lamp.Range=26;lamp.Brightness=.9;lamp.Parent=strip
 for _,face in ipairs({Enum.NormalId.Front,Enum.NormalId.Back}) do
  local gui=Instance.new('SurfaceGui');gui.Face=face;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=50;gui.LightInfluence=0;gui.Brightness=1.3;gui.Parent=screen
  local bg=Instance.new('Frame');bg.Size=UDim2.fromScale(1,1);bg.BackgroundColor3=C3(16,18,24);bg.BorderSizePixel=0;bg.Parent=gui
  local head=Instance.new('Frame');head.Size=UDim2.new(1,0,0,110);head.BackgroundColor3=accent;head.BorderSizePixel=0;head.Parent=bg
  local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Font=Enum.Font.GothamBlack;t.TextSize=62;t.TextColor3=C3(20,20,24);t.Text=title;t.Parent=head
  for i=1,10 do
   local row=Instance.new('Frame');row.Name='Row'..i;row.Position=UDim2.new(0,20,0,122+(i-1)*66);row.Size=UDim2.new(1,-40,0,60);row.BorderSizePixel=0
   row.BackgroundColor3=i%2==0 and C3(30,33,42) or C3(24,27,35);row.Parent=bg
   local rank=Instance.new('TextLabel');rank.Name='Rank';rank.Size=UDim2.new(0,90,1,0);rank.BackgroundTransparency=1;rank.Font=Enum.Font.GothamBlack;rank.TextSize=40
   rank.TextColor3=(i==1 and C3(255,205,60)) or (i==2 and C3(205,210,220)) or (i==3 and C3(214,140,80)) or C3(150,155,170);rank.Text='#'..i;rank.Parent=row
   local nm=Instance.new('TextLabel');nm.Name='PlayerName';nm.Position=UDim2.new(0,95,0,0);nm.Size=UDim2.new(0,520,1,0);nm.BackgroundTransparency=1;nm.Font=Enum.Font.GothamBold;nm.TextSize=36
   nm.TextXAlignment=Enum.TextXAlignment.Left;nm.TextColor3=C3(240,242,248);nm.Text='—';nm.Parent=row
   local val=Instance.new('TextLabel');val.Name='Score';val.Position=UDim2.new(0,620,0,0);val.Size=UDim2.new(0,300,1,0);val.BackgroundTransparency=1;val.Font=Enum.Font.GothamBlack;val.TextSize=36
   val.TextXAlignment=Enum.TextXAlignment.Right;val.TextColor3=accent;val.Text='';val.Parent=row
  end
 end
end
board('Лидерборд убийств',-16,'ТОП УБИЙСТВ','Kills',C3(255,96,72))
board('Лидерборд времени',16,'ТОП ПО ВРЕМЕНИ','Time',C3(86,196,255))
for _,v in ipairs({{-30,-14},{30,-14},{-30,14},{30,14}}) do -- клумбы-ограждения площади
 part('Тумба',Vector3.new(4,1.6,4),Vector3.new(v[1],1.1,v[2]),C3(110,108,102),M.Concrete)
 ball('Куст',3.4,Vector3.new(v[1],3,v[2]),C3(70,112,62),M.Grass)
end

-- ===== Дома =====
local palettes={C3(166,157,140),C3(179,171,151),C3(149,155,147),C3(170,165,157)}
local curtains={C3(196,170,120),C3(160,92,88),C3(110,140,160),C3(215,205,180)}
local function building(x,z,rot,idx)
 local model=Instance.new('Model');model.Name='Хрущёвка '..idx;model.Parent=w
 local cf=CFrame.new(x,0,z)*CFrame.Angles(0,rad(rot),0)
 local function block(n,size,offset,col,mat)
  return part(n,size,cf*CFrame.new(offset),col,mat,model)
 end
 local pal=palettes[idx%#palettes+1]
 block('Фасад',Vector3.new(73,47,24),Vector3.new(0,23.5,0),pal)
 block('Крыша',Vector3.new(76,1.5,27),Vector3.new(0,47.5,0),C3(77,79,78))
 block('Цоколь',Vector3.new(74,2.6,25),Vector3.new(0,1.3,0),C3(103,105,102))
 for _,sz in ipairs({{76,.9,.5,0,13.3},{76,.9,.5,0,-13.3}}) do block('Парапет',Vector3.new(sz[1],sz[2]+1,sz[3]),Vector3.new(sz[4],48.4,sz[5]),C3(98,100,98)) end
 for _,sx in ipairs({-37.7,37.7}) do block('Парапет',Vector3.new(.5,1.9,27),Vector3.new(sx,48.4,0),C3(98,100,98)) end
 for f=1,4 do for _,side in ipairs({-1,1}) do block('Карниз',Vector3.new(73.6,.5,.5),Vector3.new(0,f*8.4+2.2,side*12.2),C3(205,201,188)) end end
 for col=-4,4 do
  for floor=1,5 do
   local y=4.5+(floor-1)*8.4
   local wx=col*7.3
   for _,side in ipairs({-1,1}) do
    local zz=side*12.15
    local lit=rng:NextNumber()<.28
    local glass=block('Окно',Vector3.new(3.4,4.1,.15),Vector3.new(wx,y+2,zz),lit and C3(236,208,140) or C3(83,110,121),lit and M.Neon or M.Glass)
    if not lit then glass.Transparency=.17 end
    glass.CanCollide=false
    if rng:NextNumber()<.3 then block('Штора',Vector3.new(1.5,3.2,.1),Vector3.new(wx+(rng:NextNumber()<.5 and -.9 or .9),y+2.2,zz+side*.1),curtains[rng:NextInteger(1,#curtains)],M.Fabric).CanCollide=false end
    block('Рама',Vector3.new(3.6,.15,.25),Vector3.new(wx,y+4.05,zz+side*.12),C3(218,214,200)).CanCollide=false
    block('Рама вертикальная',Vector3.new(.15,4.2,.25),Vector3.new(wx,y+2,zz+side*.12),C3(218,214,200)).CanCollide=false
    block('Подоконник',Vector3.new(4,.23,.65),Vector3.new(wx,y-.13,zz+side*.3),C3(193,191,180))
    if col%3==0 and floor>1 then
     block('Балкон плита',Vector3.new(5,.35,2.6),Vector3.new(wx,y-.25,zz+side*1.1),C3(112,115,114))
     block('Балкон ограда',Vector3.new(5,2,.2),Vector3.new(wx,y+1,zz+side*2.35),C3(105,113,113),M.Metal)
    elseif floor>1 and rng:NextNumber()<.08 then
     block('Кондиционер',Vector3.new(2.2,1.4,1.3),Vector3.new(wx+2.6,y+1,zz+side*.7),C3(222,224,226),M.Metal)
    end
   end
  end
 end
 for _,dx in ipairs({-23,0,23}) do
  block('Подъезд дверь',Vector3.new(4.5,6,.3),Vector3.new(dx,3.6,12.3),C3(71,88,85),M.Metal)
  block('Подъезд рама',Vector3.new(5.3,.4,.5),Vector3.new(dx,6.8,12.3),C3(190,188,178))
  block('Козырёк',Vector3.new(7,.35,4),Vector3.new(dx,7.4,13.9),C3(93,98,95))
  block('Ступень',Vector3.new(5,.4,2),Vector3.new(dx,.4,14),C3(134,132,125))
  local lamp=block('Лампа подъезда',Vector3.new(.9,.3,.9),Vector3.new(dx,7.1,13.9),C3(255,230,170),M.Neon);lamp.CanCollide=false
 end
 for _,dx in ipairs({-36,36}) do block('Водосток',Vector3.new(.5,47,.5),Vector3.new(dx,23.5,12.4),C3(95,98,96),M.Metal).CanCollide=false end
 -- крыша
 block('Вентблок',Vector3.new(6,3,5),Vector3.new(rng:NextInteger(-24,-10),49.8,rng:NextInteger(-3,3)),C3(120,122,120),M.Concrete)
 local tx=rng:NextInteger(8,26)
 block('Бак',Vector3.new(5,5,5),Vector3.new(tx,51,0),C3(100,110,108),M.Metal).Shape=Enum.PartType.Cylinder
 block('Антенна',Vector3.new(.25,9,.25),Vector3.new(rng:NextInteger(-5,5),53,-3),C3(160,160,160),M.Metal)
 block('Антенна перекладина',Vector3.new(4,.2,.2),Vector3.new(0,55,-3),C3(160,160,160),M.Metal)
end
local placements={{-255,-200,0},{-130,-275,0},{130,-275,0},{255,-200,90},{255,-45,90},{255,130,90},{130,275,180},{-130,275,180},{-255,155,90},{-255,-35,90},{0,-250,0},{0,250,180}}
for i,b in ipairs(placements) do building(b[1],b[2],b[3],i) end

-- ===== Мелочи двора =====
local function bench(x,z,rot)
 local cf=CFrame.new(x,0,z)*CFrame.Angles(0,rad(rot),0)
 part('Скамейка сиденье',Vector3.new(10,.55,2.5),cf*CFrame.new(0,2,0),C3(117,76,49),M.Wood)
 part('Скамейка спинка',Vector3.new(10,2.4,.45),cf*CFrame.new(0,3.1,1.15),C3(117,76,49),M.Wood)
 for _,xx in ipairs({-4,4}) do part('Ножка',Vector3.new(.5,2,.5),cf*CFrame.new(xx,1,0),C3(61,65,66),M.Metal) end
end
for _,b in ipairs({{-42,-40,0},{42,-40,180},{-42,40,0},{42,40,180},{-160,80,90},{160,-80,90},{-155,-135,0},{155,135,180},{-75,150,0},{75,-150,180}}) do bench(b[1],b[2],b[3]) end
local function tree(x,z,scale)
 cyl('Ствол',2*scale,13*scale,Vector3.new(x,6.5*scale,z),C3(91,72,54),M.Wood)
 for i=1,4 do ball('Листва',(9+i)*scale,Vector3.new(x+(i-2.5)*3*scale,(14+(i%2)*2)*scale,z+((i*7)%3-1)*2*scale),C3(60+i*4,96+i*3,58+i*2),M.Grass) end
end
for _,v in ipairs({{-160,-175},{-120,-130},{-160,175},{-110,125},{160,175},{110,125},{160,-175},{110,-125},{-35,155},{35,155},{-35,-155},{35,-155},{-185,0},{185,0},{0,185},{0,-185}}) do tree(v[1],v[2],.8+(math.abs(v[1])%3)*.1) end
for _,x in ipairs({-195,195}) do for _,z in ipairs({-190,-70,70,190}) do
 part('Фонарный столб',Vector3.new(.65,16,.65),Vector3.new(x,8,z),C3(62,66,70),M.Metal)
 part('Фонарь кронштейн',Vector3.new(.3,.3,3),Vector3.new(x,16.2,z+(x<0 and 1.2 or -1.2)),C3(62,66,70),M.Metal)
 local lamp=part('Фонарь',Vector3.new(3,1.1,2),Vector3.new(x,16.5,z),C3(255,226,177),M.Neon);lamp.CanCollide=false
 local light=Instance.new('PointLight');light.Range=26;light.Brightness=.7;light.Parent=lamp
end end
for _,v in ipairs({{-135,-80},{135,80},{-140,105},{140,-105}}) do
 local x,z=v[1],v[2]
 part('Гараж',Vector3.new(20,9,13),Vector3.new(x,4.5,z),C3(113,120,116),M.Metal)
 part('Гараж ворота',Vector3.new(15,7,.3),Vector3.new(x,3.7,z+6.7),C3(78,89,89),M.CorrugatedMetal)
 part('Гараж крыша',Vector3.new(21,.5,14),Vector3.new(x,9.3,z),C3(76,77,76),M.Metal)
end
for _,v in ipairs({{-60,0},{60,0},{0,-110},{0,110}}) do
 local x,z=v[1],v[2]
 part('Клумба земля',Vector3.new(13,.4,7),Vector3.new(x,.4,z),C3(88,72,58),M.Ground)
 part('Клумба бортик',Vector3.new(14,.6,8),Vector3.new(x,.2,z),C3(150,147,138))
 for i=-2,2 do ball('Цветы',1.2,Vector3.new(x+i*2,1.2,z),C3(184,82+(i+2)*20,93),M.Grass) end
end
-- детская площадка
part('Песочница',Vector3.new(17,.4,17),Vector3.new(-120,.3,25),C3(187,163,112),M.Sand)
for _,v in ipairs({{-129,16},{-111,16},{-129,34},{-111,34}}) do part('Борт песочницы',Vector3.new(2,1,2),Vector3.new(v[1],.7,v[2]),C3(119,80,52),M.Wood) end
for _,z in ipairs({-30,30}) do part('Турник стойка',Vector3.new(.6,8,.6),Vector3.new(125,4,z),C3(61,92,119),M.Metal) end
part('Турник перекладина',Vector3.new(.55,.55,60),Vector3.new(125,8,0),C3(61,92,119),M.Metal)
do -- горка
 local gx,gz=-100,45
 part('Горка площадка',Vector3.new(5,.4,5),Vector3.new(gx,6,gz),C3(198,150,60),M.Wood)
 for _,o in ipairs({{-2.2,-2.2},{2.2,-2.2},{-2.2,2.2},{2.2,2.2}}) do part('Горка стойка',Vector3.new(.4,6,.4),Vector3.new(gx+o[1],3,gz+o[2]),C3(61,92,119),M.Metal) end
 part('Горка скат',Vector3.new(3.2,.3,9),CFrame.new(gx,3,gz+7)*CFrame.Angles(rad(-34),0,0),C3(210,70,60),M.SmoothPlastic)
 for i=0,4 do part('Горка лестница',Vector3.new(3,.25,.8),Vector3.new(gx,.8+i*1.1,gz-3.2),C3(61,92,119),M.Metal) end
end
do -- качели
 local sx,sz=-140,60
 for _,dx in ipairs({-7,7}) do
  part('Качели стойка',Vector3.new(.5,9,.5),CFrame.new(sx+dx,4.5,sz+1.5)*CFrame.Angles(rad(12),0,0),C3(200,60,50),M.Metal)
  part('Качели стойка',Vector3.new(.5,9,.5),CFrame.new(sx+dx,4.5,sz-1.5)*CFrame.Angles(rad(-12),0,0),C3(200,60,50),M.Metal)
 end
 part('Качели перекладина',Vector3.new(15,.5,.5),Vector3.new(sx,8.8,sz),C3(200,60,50),M.Metal)
 for _,dx in ipairs({-3,3}) do
  for _,cx in ipairs({-.8,.8}) do part('Цепь',Vector3.new(.1,5.5,.1),Vector3.new(sx+dx+cx,6,sz),C3(110,110,110),M.Metal).CanCollide=false end
  part('Качели сиденье',Vector3.new(2,.3,.9),Vector3.new(sx+dx,3.2,sz),C3(60,60,64),M.Wood)
 end
end
-- машины
local carColors={C3(150,40,40),C3(60,80,120),C3(190,190,185),C3(55,60,58),C3(170,140,60),C3(90,110,90)}
local function car(x,z,rot,col)
 local cf=CFrame.new(x,0,z)*CFrame.Angles(0,rad(rot),0)
 local model=Instance.new('Model');model.Name='Машина';model.Parent=w
 part('Кузов',Vector3.new(14,2.2,6.2),cf*CFrame.new(0,2.1,0),col,M.Metal,model)
 part('Кабина',Vector3.new(7,2,5.6),cf*CFrame.new(-.6,4.2,0),col,M.Metal,model)
 local g=part('Стёкла',Vector3.new(7.2,1.5,5.7),cf*CFrame.new(-.6,4.3,0),C3(70,95,105),M.Glass,model);g.Transparency=.25;g.CanCollide=false
 part('Бампер',Vector3.new(14.4,.7,6.4),cf*CFrame.new(0,1.2,0),C3(50,52,54),M.Metal,model)
 for _,wp in ipairs({{-4.2,3.1},{4.2,3.1},{-4.2,-3.1},{4.2,-3.1}}) do
  local wheel=part('Колесо',Vector3.new(1,2.8,2.8),cf*CFrame.new(wp[1],1.4,wp[2])*CFrame.Angles(0,rad(90),0),C3(25,25,27),M.Rubber,model);wheel.Shape=Enum.PartType.Cylinder
 end
 for _,s in ipairs({-2,2}) do
  local h=part('Фара',Vector3.new(.3,.7,1.1),cf*CFrame.new(7.1,2.4,s),C3(255,240,200),M.Neon,model);h.CanCollide=false
  local t=part('Стоп',Vector3.new(.3,.6,1),cf*CFrame.new(-7.1,2.4,s),C3(180,30,30),M.Neon,model);t.CanCollide=false
 end
end
local carSpots={{-70,-212,0},{70,-208,0},{-70,214,0},{72,210,0},{-212,-110,90},{212,110,90},{-212,100,90},{212,-100,90},{-18,-236,0}}
for i,s in ipairs(carSpots) do car(s[1],s[2],s[3],carColors[(i-1)%#carColors+1]) end
-- мусорные баки и контейнеры (укрытия в бою)
local function dumpster(x,z,rot)
 local cf=CFrame.new(x,0,z)*CFrame.Angles(0,rad(rot),0)
 part('Бак',Vector3.new(6,3.6,3.4),cf*CFrame.new(0,2.4,0),C3(46,98,66),M.Metal)
 part('Бак крышка',Vector3.new(6.2,.4,3.6),cf*CFrame.new(0,4.4,.1)*CFrame.Angles(rad(-6),0,0),C3(33,70,48),M.Metal)
 for _,xx in ipairs({-2.4,2.4}) do local wh=part('Колёсико',Vector3.new(.4,.9,.9),cf*CFrame.new(xx,.5,1.4),C3(20,20,20),M.Rubber);wh.Shape=Enum.PartType.Cylinder end
end
for _,v in ipairs({{-110,-110,20},{110,110,200},{-30,-215,0},{30,215,180},{-215,45,90},{215,-45,270}}) do dumpster(v[1],v[2],v[3]) end
for _,v in ipairs({{-20,-60},{20,60},{-95,95},{95,-95},{-60,-130},{60,130}}) do
 cyl('Урна',1.6,2.2,Vector3.new(v[1],1.1,v[2]),C3(52,56,58),M.Metal)
end
-- забор по периметру + невидимые стены
for i=-25,25 do
 for _,s in ipairs({-1,1}) do
  part('Столб забора',Vector3.new(.5,6,.5),Vector3.new(i*12,3,s*304),C3(70,74,78),M.Metal)
  part('Столб забора',Vector3.new(.5,6,.5),Vector3.new(s*304,3,i*12),C3(70,74,78),M.Metal)
 end
end
for _,s in ipairs({-1,1}) do
 for _,h in ipairs({1.5,3.5,5.5}) do
  part('Забор перекладина',Vector3.new(620,.3,.3),Vector3.new(0,h,s*304),C3(88,92,96),M.Metal)
  part('Забор перекладина',Vector3.new(.3,.3,620),Vector3.new(s*304,h,0),C3(88,92,96),M.Metal)
 end
 local wallA=part('Стена',Vector3.new(624,160,2),Vector3.new(0,80,s*311),C3(255,255,255),M.SmoothPlastic);wallA.Transparency=1
 local wallB=part('Стена',Vector3.new(2,160,624),Vector3.new(s*311,80,0),C3(255,255,255),M.SmoothPlastic);wallB.Transparency=1
end

-- ===== Спавны (центр занят площадью) =====
local locations={{0,52},{70,70},{-70,-70},{70,-70},{-70,70},{0,145},{0,-145},{145,0},{-145,0},{185,115},{-185,-115},{115,-185},{-115,185}}
for i,pt in ipairs(locations) do
 local spawn=Instance.new('SpawnLocation');spawn.Name='Spawn_'..i;spawn.Size=Vector3.new(8,1,8);spawn.Position=Vector3.new(pt[1],.6,pt[2]);spawn.Anchored=true;spawn.Neutral=true;spawn.AllowTeamChangeOnTouch=false;spawn.Transparency=.65;spawn.Color=C3(89,99,100);spawn.Parent=w
end
