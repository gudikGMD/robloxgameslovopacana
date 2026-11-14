-- R6Animations v0.8: процедурные анимации на ключевых кадрах (без загрузки Animation ID).
-- Позы задаются в понятных единицах, оси суставов пересчитываются правильно.
--   Руки  {вперёд°, в сторону°, поперёк°}   (0 = вдоль тела, 90 = горизонтально вперёд, 170 = над головой)
--   W тело {наклон вперёд°, поворот вправо°, крен вправо°}
--   H голова {вверх°, поворот вправо°, наклон вправо°}
--   Ноги  {вперёд°}
local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local TweenService=game:GetService('TweenService')
local event=RS:WaitForChild('StreetAction')
local rad=math.rad
local NAMES={R='Right Shoulder',L='Left Shoulder',H='Neck',W='RootJoint',RH='Right Hip',LH='Left Hip'}
local rest=setmetatable({},{__mode='k'})
local tokens={}

local function joints(char)
 local torso=char and char:FindFirstChild('Torso');local hrp=char and char:FindFirstChild('HumanoidRootPart')
 if not torso or not hrp then return end
 local out={}
 for key,name in pairs(NAMES) do
  local m=(key=='W' and hrp or torso):FindFirstChild(name)
  if m and m:IsA('Motor6D') then out[key]=m end
 end
 return out
end

local function bodyRot(a)
 a=a or {}
 return CFrame.Angles(0,rad(-(a[2] or 0)),0)*CFrame.Angles(rad(-(a[1] or 0)),0,0)*CFrame.Angles(0,0,rad(-(a[3] or 0)))
end
local function goal(key,restC0,a,Rw)
 local R
 if key=='R' or key=='L' then
  if not a then return restC0 end
  local s=key=='R' and 1 or -1
  R=CFrame.Angles(0,rad((a[3] or 0)*s),0)*CFrame.Angles(rad(a[1] or 0),0,0)*CFrame.Angles(0,0,rad((a[2] or 0)*s))
 elseif key=='W' then
  if not a then return restC0 end
  R=bodyRot(a)
 elseif key=='H' then
  if not a then return restC0 end
  R=CFrame.Angles(0,rad(-(a[2] or 0)),0)*CFrame.Angles(rad(a[1] or 0),0,0)*CFrame.Angles(0,0,rad(-(a[3] or 0)))
 else -- ноги: компенсируем поворот корпуса, чтобы ноги не крутились вместе с ним
  local comp=CFrame.new():Lerp(Rw,.85):Inverse()
  R=comp*CFrame.Angles(rad(a and a[1] or 0),0,0)
 end
 return CFrame.new(restC0.Position)*R*restC0.Rotation
end

local function merge(a,b) local o={} for k,v in pairs(a) do o[k]=v end for k,v in pairs(b or {}) do o[k]=v end return o end
local Q,B,QI=Enum.EasingStyle.Quad,Enum.EasingStyle.Quint,Enum.EasingStyle.Sine
local OUT,IN,INOUT=Enum.EasingDirection.Out,Enum.EasingDirection.In,Enum.EasingDirection.InOut
local function fr(dur,pose,style,dir,hold) return {dur=dur,pose=pose,style=style or Q,dir=dir or OUT,hold=hold or 0} end

-- Характер каждого бойца
local PARAM={
 Siply ={f=90, lean=10,twist=24,o=10,roll=0, tilt=0,  chop=false,stance=14},
 Diesel={f=96, lean=18,twist=34,o=8, roll=0, tilt=-8, chop=false,stance=22},
 Bitok ={f=100,lean=16,twist=28,o=12,roll=0, tilt=0,  chop=true, stance=16},
 Major ={f=88, lean=6, twist=14,o=6, roll=0, tilt=0,  chop=false,stance=10},
 Yura  ={f=84, lean=10,twist=30,o=34,roll=10,tilt=6,  chop=false,stance=12},
 Jack  ={f=94, lean=8, twist=26,o=22,roll=14,tilt=14, chop=false,stance=18},
}

local function punchFrames(fighter,index)
 local P=PARAM[fighter] or PARAM.Siply
 local third=index==3
 local right=(index%2==1)
 local A,Bk=right and 'R' or 'L',right and 'L' or 'R'
 local sg=right and 1 or -1
 local LF,LB=right and 'LH' or 'RH',right and 'RH' or 'LH'
 local wind,hit
 if third then
  wind={[A]={165,P.o+10,0},[Bk]={70,0,20},W={-10,38*sg,P.roll*sg},H={-8,10*sg,P.tilt},[LF]={P.stance*.5},[LB]={-P.stance*.5}}
  hit ={[A]={55,0,P.chop and 40 or 55},[Bk]={50,0,25},W={P.lean+18,-(P.twist+14)*sg,-P.roll*sg},H={-14,-10*sg,P.tilt},[LF]={P.stance*1.1},[LB]={-P.stance*.9}}
  return {fr(.17,wind,Q,INOUT),fr(.10,hit,B,OUT,.1)}
 end
 wind={[A]=P.chop and {145,14,0} or {25,P.o,0},[Bk]={85,0,25},W={-6,P.twist*.7*sg,P.roll*sg},H={0,8*sg,P.tilt},[LF]={P.stance*.5},[LB]={-P.stance*.4}}
 hit ={[A]=P.chop and {58,0,30} or {P.f,0,22},[Bk]={80,0,28},W={P.lean,-P.twist*sg,-P.roll*sg},H={-6,-12*sg,P.tilt*.5},[LF]={P.stance*.9},[LB]={-P.stance*.7}}
 return {fr(.06,wind,Q,OUT),fr(.07,hit,B,OUT,.05)}
end

-- Навыки: общий набор + индивидуальные замены
local function throw(P)
 return {wind={R={172,12,0},L={60,0,25},W={-14,32,P.roll},H={-14,10,P.tilt},LH={14},RH={-10}},
         hit ={R={58,0,10},L={40,0,25},W={22,-34,-P.roll},H={10,-8,0},LH={26},RH={-18}},t1=.2,t2=.08}
end
local OV={
 Major={
  ['4']=function(P) return {wind={R={120,0,0},L={110,0,10},W={-6,0,0}},hit={R={178,0,0},L={160,0,8},W={-12,0,0},H={20,0,0}},t1=.16,t2=.06} end,
  S=function(P) return {wind={R={84,0,16},L={84,0,16},W={0,0,0},H={0,0,0}},hit={R={92,0,18},L={90,0,18},W={5,-4,0},H={-4,0,0}},t1=.1,t2=.04} end,
 },
 Yura={
  ['1']=throw,
  S=function(P) return {wind={R={70,0,40},L={70,0,40},W={-14,0,0},H={38,0,0}},hit={R={80,0,40},L={80,0,40},W={18,0,0},H={-24,0,0}},t1=.3,t2=.1} end,
 },
 Jack={['4']=throw},
 Bitok={['4']=function(P) return {wind={R={176,10,0},L={150,10,0},W={-18,20,0},H={-14,0,0},LH={10},RH={-12}},hit={R={46,0,10},L={60,0,20},W={30,-30,0},H={14,0,0},LH={30},RH={-22}},t1=.24,t2=.08} end},
}
local function skillFrames(fighter,index,special)
 local P=PARAM[fighter] or PARAM.Siply
 local key=special and 'S' or tostring(index)
 local spec=OV[fighter] and OV[fighter][key]
 local def
 if spec then def=spec(P)
 elseif index==1 then
  def={wind={R={165,12,0},L={165,12,0},W={-14,0,P.roll},H={-12,0,P.tilt}},hit={R={55,0,10},L={55,0,10},W={P.lean+22,0,0},H={14,0,0},LH={20},RH={-12}},t1=.2,t2=.08}
 elseif index==2 then
  def={wind={R={60,40,0},L={60,40,0},W={-5,70,P.roll},H={0,25,P.tilt}},hit={R={80,95,0},L={40,15,0},W={8,-95,-P.roll},H={0,-30,0}},t1=.2,t2=.08}
 elseif index==3 then
  def={wind={R={70,35,0},L={70,35,0},W={-8,0,0},H={-6,0,0}},hit={R={100,0,38},L={100,0,38},W={P.lean+14,0,0},H={6,0,0},LH={24},RH={-14}},t1=.2,t2=.08}
 else
  def={wind={R={10,10,0},L={60,0,25},W={22,28,0},H={6,10,0},LH={20},RH={-16}},hit={R={172,0,12},L={55,0,25},W={-14,-28,0},H={18,0,0},LH={10},RH={-8}},t1=.2,t2=.08}
 end
 return {fr(def.t1,def.wind,Q,INOUT),fr(def.t2,def.hit,B,OUT,.12)}
end

local function ultFrames(fighter)
 local gather={R={-15,35,0},L={-15,35,0},W={22,0,0},H={14,0,0},LH={18},RH={-18}}
 local burst={R={170,40,0},L={170,40,0},W={-16,0,0},H={30,0,0},LH={8},RH={-8}}
 if fighter=='Diesel' then burst={R={95,70,40},L={95,70,40},W={8,0,0},H={-8,0,0},LH={18},RH={-18}}
 elseif fighter=='Bitok' then burst={R={175,10,0},L={20,25,0},W={-10,20,0},H={25,0,0},LH={8},RH={-8}}
 elseif fighter=='Major' then burst={R={150,0,20},L={20,10,0},W={-4,0,0},H={10,0,0}}
 elseif fighter=='Yura' then burst={R={30,95,0},L={30,95,0},W={-8,0,0},H={34,0,0},LH={10},RH={-10}}
 elseif fighter=='Jack' then burst={R={160,20,0},L={20,40,0},W={-8,0,16},H={26,0,14},LH={14},RH={-6}} end
 return {fr(.3,gather,Q,INOUT),fr(.12,burst,B,OUT,.45)}
end

local function framesFor(fighter,kind,index)
 if kind=='Punch' then return punchFrames(fighter,index or 1),true
 elseif kind=='Skill' then return skillFrames(fighter,index or 1,false),true
 elseif kind=='Special' then return skillFrames(fighter,1,true),true
 elseif kind=='Ult' then return ultFrames(fighter),false
 elseif kind=='Dash' then
  return {fr(.055,{R={-48,20,0},L={-48,-20,0},W={42,0,0},H={-14,0,0},LH={42},RH={-30}},QI,OUT,.11),fr(.09,{R={-20,10,0},L={-20,-10,0},W={20,0,0},H={-6,0,0},LH={-20},RH={32}},Q,OUT)},false
 elseif kind=='Block' then
  local g={R={105,10,28},L={105,10,28},W={10,0,0},H={-12,0,0},LH={18},RH={-14}}
  local P=PARAM[fighter]
  if fighter=='Jack' then g=merge(g,{W={14,0,8},H={-14,0,10}}) elseif fighter=='Diesel' then g=merge(g,{W={18,0,0},LH={26},RH={-20}}) end
  return {fr(.12,g,Q,OUT)},false
 elseif kind=='Hit' then
  local side=(index or 1)%2==0 and -1 or 1
  local pose={R={-30,35*side,0},L={-20,-30*side,0},W={-23,15*side,8*side},H={24,-15*side,8*side},LH={-14},RH={12}}
  if index==3 then pose={R={-40,20,0},L={-40,-20,0},W={-34,0,0},H={35,0,0},LH={-22},RH={-18}} end
  return {fr(.07,pose,Q,OUT,.045),fr(.16,{R={30,5,0},L={30,5,0},W={9,-7*side,0},H={-8,8*side,0}},QI,OUT)},false
 end
end

local function setTrails(char,on)
 local props=char and char:FindFirstChild('FighterProp');if not props then return end
 for _,d in ipairs(props:GetDescendants()) do if d:IsA('Trail') then d.Enabled=on end end
end

local function play(player,kind,index,hold)
 local char=player.Character;local hum=char and char:FindFirstChildOfClass('Humanoid')
 if not hum or hum.Health<=0 then return end
 local motors=joints(char);if not motors then return end
 local id=player.UserId
 tokens[id]=(tokens[id] or 0)+1;local token=tokens[id]
 rest[char]=rest[char] or {}
 local r=rest[char]
 for k,m in pairs(motors) do r[k]=r[k] or m.C0 end
 local frames,strike=framesFor(player:GetAttribute('Fighter') or 'Siply',kind,index)
 if not frames then return end
 task.spawn(function()
  if strike then setTrails(char,true) end
  for _,f in ipairs(frames) do
   if tokens[id]~=token or player.Character~=char then return end
   local Rw=bodyRot(f.pose.W)
   for k,m in pairs(motors) do
    if m.Parent then TweenService:Create(m,TweenInfo.new(f.dur,f.style,f.dir),{C0=goal(k,r[k],f.pose[k],Rw)}):Play() end
   end
   task.wait(f.dur+f.hold)
  end
  if tokens[id]~=token or player.Character~=char then return end
  if strike then setTrails(char,false) end
  if hold then return end
  for k,m in pairs(motors) do if m.Parent and r[k] then TweenService:Create(m,TweenInfo.new(.24,Q,OUT),{C0=r[k]}):Play() end end
 end)
end
local function reset(player)
 local char=player.Character;tokens[player.UserId]=(tokens[player.UserId] or 0)+1
 local r=char and rest[char];if not r then return end
 setTrails(char,false)
 for k,m in pairs(joints(char) or {}) do if r[k] and m.Parent then TweenService:Create(m,TweenInfo.new(.2,Q,OUT),{C0=r[k]}):Play() end end
end

event.OnClientEvent:Connect(function(kind,data)
 if kind~='Animate' or type(data)~='table' then return end
 local p=Players:GetPlayerByUserId(data.userId or 0);if not p then return end
 if data.action=='BlockEnd' then reset(p)
 elseif data.action=='Block' then play(p,'Block',1,true)
 else play(p,data.action,data.index,false) end
end)
Players.PlayerRemoving:Connect(function(p) tokens[p.UserId]=nil end)

-- Оранжевая подсветка бойца, пока активна ульта
local function ultAura(p)
 local function refresh()
  local c=p.Character;if not c then return end
  local h=c:FindFirstChild('UltGlow')
  if p:GetAttribute('UltActive') then
   if not h then
    h=Instance.new('Highlight');h.Name='UltGlow';h.FillColor=Color3.fromRGB(255,140,40);h.FillTransparency=.82
    h.OutlineColor=Color3.fromRGB(255,210,120);h.OutlineTransparency=.15;h.Parent=c
   end
  elseif h then h:Destroy() end
 end
 p:GetAttributeChangedSignal('UltActive'):Connect(refresh)
 p.CharacterAdded:Connect(function() task.wait(.3);refresh() end)
 refresh()
end
for _,p in ipairs(Players:GetPlayers()) do ultAura(p) end
Players.PlayerAdded:Connect(ultAura)
