-- Street Battles v0.8: server-authoritative PvP, предметы бойцов, реакция на удары, глобальные топы.
local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local DSS=game:GetService('DataStoreService')
local RunService=game:GetService('RunService')
local C=require(RS:WaitForChild('GameConfig'))
local remote=RS:FindFirstChild('StreetAction') or Instance.new('RemoteEvent')
remote.Name='StreetAction';remote.Parent=RS
local profiles={}
local store=DSS:GetDataStore('StreetBattles_Simple_v05')
local function send(p,k,d) remote:FireClient(p,k,d or {}) end
local function anim(p,k,i,t) remote:FireAllClients('Animate',{userId=p.UserId,action=k,index=i,duration=t or .5}) end
local function hum(p) return p.Character and p.Character:FindFirstChildOfClass('Humanoid') end
local function root(p) return p.Character and p.Character:FindFirstChild('HumanoidRootPart') end
local function get(p) return profiles[p] end
-- ===== Предметы бойцов: добавляются ПОВЕРХ аватара игрока, внешность не меняется =====
local MAT=Enum.Material
local function mk(parent,base,name,size,color,mat,offset,shape,transp)
 local v=Instance.new('Part');v.Name=name;v.Size=size;v.Color=color;v.Material=mat or MAT.Metal
 v.CanCollide=false;v.CanTouch=false;v.CanQuery=false;v.Massless=true;v.CastShadow=true
 v.TopSurface=Enum.SurfaceType.Smooth;v.BottomSurface=Enum.SurfaceType.Smooth
 if shape then v.Shape=shape end
 if transp then v.Transparency=transp end
 v.CFrame=base.CFrame*offset;v.Parent=parent
 local w=Instance.new('WeldConstraint');w.Part0=base;w.Part1=v;w.Parent=v
 return v
end
local function rod(parent,base,name,a,b,thick,color,mat,transp) -- цилиндр между двумя точками (в координатах base)
 local mid=(a+b)/2;local len=(b-a).Magnitude
 local up=math.abs((b-a).Unit.Y)>.99 and Vector3.new(0,0,1) or Vector3.yAxis
 local cf=CFrame.lookAt(mid,b,up)*CFrame.Angles(0,math.rad(90),0)
 return mk(parent,base,name,Vector3.new(len,thick,thick),color,mat,cf,Enum.PartType.Cylinder,transp)
end
local function trail(part,pa,pb,color)
 local a0=Instance.new('Attachment');a0.Position=pa;a0.Parent=part
 local a1=Instance.new('Attachment');a1.Position=pb;a1.Parent=part
 local t=Instance.new('Trail');t.Name='SwingTrail';t.Attachment0=a0;t.Attachment1=a1;t.Lifetime=.22;t.MinLength=.05
 t.Color=ColorSequence.new(color);t.Transparency=NumberSequence.new(.35,1);t.LightEmission=.4;t.Enabled=false;t.Parent=part
end
local function equip(p)
 local ch=p.Character;local s=get(p);if not ch or not s then return end
 local old=ch:FindFirstChild('FighterProp');if old then old:Destroy() end
 local right=ch:FindFirstChild('Right Arm');local left=ch:FindFirstChild('Left Arm');local head=ch:FindFirstChild('Head');local torso=ch:FindFirstChild('Torso')
 if not (right and left and head and torso) then return end
 local f=Instance.new('Folder');f.Name='FighterProp';f.Parent=ch
 local V=Vector3.new;local CF=CFrame.new;local ang=CFrame.Angles;local rad=math.rad
 local C3=Color3.fromRGB
 if s.fighter=='Siply' then -- КАСТЕТ на правой руке
  local plate=mk(f,right,'Кастет основа',V(1.08,.3,.34),C3(168,170,176),MAT.Metal,CF(0,-.76,-.6))
  mk(f,right,'Кастет накладка',V(1.1,.12,.4),C3(95,97,104),MAT.Metal,CF(0,-.6,-.58))
  for i=0,3 do
   mk(f,right,'Кастет кольцо',V(.22,.4,.4),C3(150,152,160),MAT.Metal,CF(-.375+.25*i,-.98,-.52)*ang(0,rad(90),0),Enum.PartType.Cylinder)
   mk(f,right,'Кастет шип',V(.12,.16,.12),C3(210,210,214),MAT.Metal,CF(-.375+.25*i,-.74,-.84))
  end
  trail(plate,V(-.5,0,0),V(.5,0,0),C3(220,224,235))
 elseif s.fighter=='Diesel' then -- БИНТЫ на обеих руках
  for ai,arm in ipairs({left,right}) do
   for j=0,5 do
    mk(f,arm,'Бинт',V(1.07,.17,1.07),(j%2==0) and C3(236,229,212) or C3(209,199,178),MAT.Fabric,CF(0,-.18-j*.14,0)*ang(rad((j%2)*3),rad(j*9),0))
   end
   local fist=mk(f,arm,'Бинт кулак',V(1.13,.4,1.13),C3(244,238,222),MAT.Fabric,CF(0,-.9,0))
   mk(f,arm,'Бинт край',V(.07,.75,.2),C3(226,218,198),MAT.Fabric,CF(.46,-.5,.1)*ang(0,0,rad(8)))
   if ai==2 then trail(fist,V(-.55,0,0),V(.55,0,0),C3(255,235,200)) end
  end
 elseif s.fighter=='Bitok' then -- БИТА за спиной + ремень через грудь
  local a=V(-.75,-1.0,.85);local b=V(.75,2.15,.85);local m=a+(b-a)*.4
  rod(f,torso,'Бита рукоять',a,m,.26,C3(28,28,30),MAT.Fabric)
  rod(f,torso,'Бита ствол',m,b,.56,C3(160,108,62),MAT.Wood)
  rod(f,torso,'Бита торец',b,b+(b-a).Unit*.12,.5,C3(120,80,45),MAT.Wood)
  mk(f,torso,'Бита набалдашник',V(.38,.38,.38),C3(28,28,30),MAT.Fabric,CF(a),Enum.PartType.Ball)
  mk(f,torso,'Ремень грудь',V(2.9,.22,.08),C3(62,46,36),MAT.Fabric,CF(0,0,-.53)*ang(0,0,rad(-40)))
  mk(f,torso,'Ремень спина',V(2.9,.22,.08),C3(62,46,36),MAT.Fabric,CF(0,0,.53)*ang(0,0,rad(-40)))
  mk(f,torso,'Пряжка',V(.3,.3,.1),C3(190,170,90),MAT.Metal,CF(.3,.25,-.58)*ang(0,0,rad(-40)))
 elseif s.fighter=='Major' then -- ПИСТОЛЕТ в кобуре на поясе
  mk(f,torso,'Ремень',V(2.14,.36,1.14),C3(26,25,24),MAT.Fabric,CF(0,-.8,0))
  mk(f,torso,'Пряжка',V(.46,.3,.1),C3(205,180,85),MAT.Metal,CF(0,-.8,-.58))
  mk(f,torso,'Кобура',V(.46,1.05,.8),C3(40,34,29),MAT.Fabric,CF(1.2,-1.0,-.02))
  mk(f,torso,'Кобура крепление',V(.2,.5,.3),C3(30,26,22),MAT.Fabric,CF(1.05,-.5,0))
  mk(f,torso,'Пистолет ствол',V(.26,.98,.38),C3(44,46,50),MAT.Metal,CF(1.2,-.95,-.42))
  mk(f,torso,'Пистолет рукоять',V(.28,.6,.3),C3(30,30,32),MAT.SmoothPlastic,CF(1.2,-.4,-.22)*ang(rad(-16),0,0))
  mk(f,torso,'Пистолет курок',V(.1,.2,.1),C3(160,160,165),MAT.Metal,CF(1.2,-.55,-.58))
 elseif s.fighter=='Yura' then -- ШАПКА-УШАНКА
  local fur=C3(150,140,125);local cloth=C3(78,66,52)
  mk(f,head,'Шапка верх',V(2.2,.55,1.3),cloth,MAT.Fabric,CF(0,.66,0))
  mk(f,head,'Шапка макушка',V(1.7,.25,1.0),C3(90,77,60),MAT.Fabric,CF(0,.98,0))
  mk(f,head,'Шапка мех',V(2.34,.3,1.44),fur,MAT.Fabric,CF(0,.4,0))
  for _,sx in ipairs({-1,1}) do
   mk(f,head,'Ушанка',V(.3,.95,1.0),cloth,MAT.Fabric,CF(sx*1.14,-.05,0)*ang(0,0,rad(sx*-6)))
   mk(f,head,'Ушанка мех',V(.36,.2,1.06),fur,MAT.Fabric,CF(sx*1.16,-.55,0))
  end
  mk(f,head,'Шапка затылок',V(2.1,.6,.2),cloth,MAT.Fabric,CF(0,.3,.68))
  mk(f,head,'Кокарда',V(.34,.34,.08),C3(215,55,45),MAT.SmoothPlastic,CF(0,.62,-.7)*ang(0,0,rad(45)))
 else -- Jack: БУТЫЛКА в правой руке
  local g=C3(48,124,72)
  local body=rod(f,right,'Бутылка корпус',V(0,-1.25,-.62),V(0,-.25,-.62),.64,g,MAT.Glass,.2)
  rod(f,right,'Бутылка плечо',V(0,-.25,-.62),V(0,0,-.62),.42,g,MAT.Glass,.2)
  rod(f,right,'Бутылка горлышко',V(0,0,-.62),V(0,.62,-.62),.24,g,MAT.Glass,.2)
  rod(f,right,'Бутылка пробка',V(0,.62,-.62),V(0,.76,-.62),.3,C3(196,165,60),MAT.Metal)
  rod(f,right,'Бутылка жидкость',V(0,-1.18,-.62),V(0,-.5,-.62),.5,C3(190,160,70),MAT.Neon,.45)
  mk(f,right,'Этикетка',V(.52,.46,.08),C3(232,226,206),MAT.SmoothPlastic,CF(0,-.78,-.96))
  trail(body,V(-.5,0,0),V(.5,0,0),C3(170,240,190))
 end
end
local function update(p)
 local s=get(p);local h=hum(p);if not s or not h then return end
 local now=os.clock();local cfg=C.Characters[s.fighter]
 h.WalkSpeed=(now<s.lockUntil or now<s.stunUntil) and 0 or cfg.speed*(now<s.slowUntil and .6 or 1)*(s.block and .55 or 1)
 p:SetAttribute('Fighter',s.fighter);p:SetAttribute('Blocking',s.block);p:SetAttribute('UltCharge',math.floor(s.charge));p:SetAttribute('UltActive',now<s.ultUntil)
 p:SetAttribute('Kills',s.kills);p:SetAttribute('PlaySeconds',math.floor(s.seconds))
end
local function knock(p,source,power)
 local r=root(p);local from=root(source);if r and from then r.AssemblyLinearVelocity=from.CFrame.LookVector*power+Vector3.new(0,10,0) end
end
local function effectAt(position,kind)
 remote:FireAllClients('FX',{position=position,kind=kind})
end
local function apply(p,target,damage,stun,breaker,force)
 local s=get(p);local t=get(target);local h=hum(target);if not s or not t or not h or h.Health<=0 then return false end
 local now=os.clock();if t.dodgeUntil>now then return false end
 if t.block and not breaker then send(target,'Message',{text='Блок!'});local rr=root(target);if rr then effectAt(rr.Position,'Guard') end;return false end
 if t.block and breaker then t.block=false;t.blockReady=now+4;t.stunUntil=math.max(t.stunUntil,now+.8);anim(target,'BlockEnd');send(target,'Message',{text='Блок пробит!'});local rr=root(target);if rr then effectAt(rr.Position,'Break') end end
 local cfg=C.Characters[s.fighter];local mult=s.ultUntil>now and cfg.ult.mult or 1
 local actual=damage*mult
 if t.fighter=='Jack' then actual=actual*.85 end
 h:TakeDamage(actual)
 local hitRoot=root(target);if hitRoot then effectAt(hitRoot.Position,'Hit') end
 anim(target,'Hit',math.random(1,3),.32)
 send(target,'HitReact',{direction=(root(p) and root(target) and (root(target).Position-root(p).Position).Unit) or Vector3.new(0,0,-1),power=force or 0})
 t.stunUntil=math.max(t.stunUntil,now+stun)
 if force and force>0 then knock(target,p,force) end
 s.charge=math.min(100,s.charge+math.max(5,damage*.7))
 t.charge=math.min(100,t.charge+damage*.35)
 t.lastAttacker=p;t.lastHitAt=now
 if s.fighter=='Diesel' then s.stacks=math.min(5,s.stacks+1);s.stacksAt=now end
 update(p);update(target)
 return true
end
local function targets(p,range,angle)
 local r=root(p);if not r then return {} end
 local list={}
 for _,other in ipairs(Players:GetPlayers()) do
  local hr=root(other);local hh=hum(other)
  if other~=p and hr and hh and hh.Health>0 then
   local delta=hr.Position-r.Position;local d=delta.Magnitude
   if d>0 and d<=range and r.CFrame.LookVector:Dot(delta.Unit)>=(angle or .15) then table.insert(list,{p=other,d=d}) end
  end
 end
 table.sort(list,function(a,b) return a.d<b.d end)
 return list
end
local function attack(p,damage,range,stun,breaker,force,aoe)
 local ts=targets(p,range);local limit=aoe and 5 or 1
 for i=1,math.min(limit,#ts) do apply(p,ts[i].p,damage,stun,breaker,force) end
end
local function dummy(p,blocking)
 if game.PrivateServerId=='' then send(p,'Message',{text='Dummy доступны только на приватном сервере'});return end
 local r=root(p);if not r then return end
 local model=Instance.new('Model');model.Name=blocking and 'block_dummy' or 'dummy';model.Parent=workspace
 local base=Instance.new('Part');base.Name='HumanoidRootPart';base.Size=Vector3.new(2,4,1);base.Anchored=true;base.CFrame=r.CFrame*CFrame.new(0,0,-9);base.Parent=model
 local h=Instance.new('Humanoid');h.MaxHealth=500;h.Health=500;h.Parent=model
 local tag=Instance.new('BillboardGui');tag.Size=UDim2.fromOffset(180,35);tag.StudsOffset=Vector3.new(0,3,0);tag.AlwaysOnTop=true;tag.Parent=base
 local txt=Instance.new('TextLabel');txt.Size=UDim2.fromScale(1,1);txt.BackgroundTransparency=1;txt.TextColor3=Color3.new(1,1,1);txt.Text=blocking and 'BLOCK DUMMY' or 'DUMMY';txt.Parent=tag
 task.delay(180,function() if model.Parent then model:Destroy() end end)
end
local function save(p)
 local s=get(p);if not s then return end
 local data={kills=s.kills,seconds=math.floor(s.seconds)}
 pcall(function() DSS:GetOrderedDataStore('StreetBattles_Top_Kills_v08'):SetAsync(tostring(p.UserId),data.kills) end)
 pcall(function() DSS:GetOrderedDataStore('StreetBattles_Top_Time_v08'):SetAsync(tostring(p.UserId),data.seconds) end)
 local ok,err=pcall(function() store:UpdateAsync(tostring(p.UserId),function(old)
  old=type(old)=='table' and old or {};old.kills=math.max(tonumber(old.kills) or 0,data.kills);old.seconds=math.max(tonumber(old.seconds) or 0,data.seconds);return old
 end) end)
 if not ok then warn('StreetBattles save:',err) end
end
Players.PlayerAdded:Connect(function(p)
 local saved={};local ok,result=pcall(function() return store:GetAsync(tostring(p.UserId)) end)
 if ok and type(result)=='table' then saved=result end
 local s={fighter='Siply',kills=tonumber(saved.kills) or 0,seconds=tonumber(saved.seconds) or 0,charge=0,ultUntil=0,stunUntil=0,lockUntil=0,slowUntil=0,dodgeUntil=0,block=false,blockReady=0,cooldowns={},combo=0,stacks=0,stacksAt=0,lastAttacker=nil,lastHitAt=0}
 profiles[p]=s
 local ls=Instance.new('Folder');ls.Name='leaderstats';ls.Parent=p
 local kv=Instance.new('IntValue');kv.Name='Kills';kv.Value=s.kills;kv.Parent=ls
 local donated=Instance.new('IntValue');donated.Name='Donated';donated.Value=0;donated.Parent=ls -- Пока нет подтвержденных покупок; не начислять вручную
 p.CharacterAdded:Connect(function(ch)
  s.block=false;s.stunUntil=0;s.lockUntil=0;s.ultUntil=0;s.charge=0;s.cooldowns={};s.combo=0
  local h=ch:WaitForChild('Humanoid',10);if not h then return end
  h.MaxHealth=C.Characters[s.fighter].hp;h.Health=h.MaxHealth
  h.Died:Connect(function()
   local killer=s.lastAttacker
   if killer and killer~=p and get(killer) and os.clock()-s.lastHitAt<12 and game.PrivateServerId=='' then
    local k=get(killer);k.kills+=1;killer.leaderstats.Kills.Value=k.kills;send(killer,'Message',{text='+1 убийство'});update(killer)
   end
  end)
  task.wait(.25);if not ch.Parent then return end;equip(p);update(p)
 end)
 p.Chatted:Connect(function(msg) if msg=='/dummy' then dummy(p,false) elseif msg=='/block_dummy' then dummy(p,true) end end)
 update(p);send(p,'Message',{text='Сиплый выбран по умолчанию'})
end)
Players.PlayerRemoving:Connect(function(p) save(p);profiles[p]=nil end)
game:BindToClose(function() for _,p in ipairs(Players:GetPlayers()) do save(p) end end)
remote.OnServerEvent:Connect(function(p,action,arg)
 if type(action)~='string' then return end
 local s=get(p);local h=hum(p);if not s or not h or h.Health<=0 then return end
 local now=os.clock()
 if action=='Select' then
  if type(arg)~='string' or not C.Characters[arg] or now<(s.cooldowns.Select or 0) then return end
  s.cooldowns.Select=now+1;s.fighter=arg;s.charge=0;s.ultUntil=0;s.cooldowns={Select=now+1};s.block=false
  send(p,'Selected',{fighter=arg});p:LoadCharacter();return
 end
 if action=='Block' then
  if arg==true then
   if now<s.blockReady or now<s.stunUntil or now<s.lockUntil then send(p,'Message',{text='Блок ещё восстанавливается'});return end
   s.block=true;anim(p,'Block',1,.2)
  else
   if s.block then s.block=false;s.blockReady=now+3;anim(p,'BlockEnd') end
  end
  update(p);return
 end
 if now<s.stunUntil or now<s.lockUntil or s.block then return end
 if action=='Dash' then
  if now<(s.cooldowns.Dash or 0) then return end
  local r=root(p);if not r or r.Anchored then return end
  local dir=r.CFrame.LookVector
  -- Дэш не зависит от единичного импульса: скорость поддерживается всё время рывка.
  local flat=Vector3.new(dir.X,0,dir.Z)
  if flat.Magnitude<.1 then flat=Vector3.new(0,0,-1) end
  flat=flat.Unit
  s.cooldowns.Dash=now+3;s.lockUntil=now+.24;s.dodgeUntil=now+.16
  anim(p,'Dash',1,.24);effectAt(r.Position,'Dash')
  send(p,'Cooldown',{key='Q',duration=3});update(p)
  local ch=p.Character;local att=Instance.new('Attachment');att.Name='StreetDashAttachment';att.Parent=r
  local lv=Instance.new('LinearVelocity');lv.Name='StreetDashVelocity';lv.Attachment0=att
  lv.RelativeTo=Enum.ActuatorRelativeTo.World;lv.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector
  lv.VectorVelocity=flat*82;lv.MaxForce=100000;lv.Parent=r
  local started=os.clock();local conn
  conn=RunService.Heartbeat:Connect(function()
   if not r.Parent or p.Character~=ch or not hum(p) or hum(p).Health<=0 or os.clock()-started>.23 then
    conn:Disconnect();lv:Destroy();att:Destroy();return
   end
   local rayParams=RaycastParams.new();rayParams.FilterType=Enum.RaycastFilterType.Exclude;rayParams.FilterDescendantsInstances={ch}
   local wall=workspace:Raycast(r.Position,flat*3.5,rayParams)
   if wall and math.abs(wall.Normal.Y)<.6 then
    conn:Disconnect();lv:Destroy();att:Destroy();return
   end
  end)
  return
 end
 if action=='Punch' then
  if now<(s.cooldowns.Punch or 0) then return end
  s.combo=(s.combo%3)+1;local third=s.combo==3
  local duration=third and .68 or .36
  s.cooldowns.Punch=now+duration;s.lockUntil=now+(third and .43 or .22)
  anim(p,'Punch',s.combo,duration);update(p)
  task.delay(third and .27 or .13,function() if get(p)==s and hum(p) and hum(p).Health>0 then attack(p,third and 10 or 5,6,third and .35 or .12,false,third and 24 or 0) end end)
  return
 end
 if action=='Ult' then
  if s.charge<100 or s.ultUntil>now then return end
  local u=C.Characters[s.fighter].ult;s.charge=0;s.ultUntil=now+u.duration;s.cooldowns={};s.lockUntil=now+1.1
  anim(p,'Ult',1,1.1);send(p,'Message',{text='УЛЬТА: '..u.name});update(p)
  return
 end
 local cfg=C.Characters[s.fighter];local skill;local key;local index=1
 if action=='Skill' and type(arg)=='number' and arg>=1 and arg<=4 and arg%1==0 then index=arg;skill=cfg.skills[arg];key=({'Z','X','C','V'})[arg]
 elseif action=='Special' then skill=cfg.special;key='R' end
 if not skill or now<(s.cooldowns[key] or 0) then return end
 local cd=skill[2];s.cooldowns[key]=now+cd;s.lockUntil=now+.55
 if (s.fighter=='Diesel' and index==2) or (s.fighter=='Jack' and index==2) then s.dodgeUntil=now+.5 end
 anim(p,action=='Special' and 'Special' or 'Skill',index,.6)
 send(p,'Cooldown',{key=key,duration=cd});send(p,'Message',{text=skill[1]});update(p)
 task.delay(.28,function()
  if get(p)~=s or not hum(p) or hum(p).Health<=0 then return end
  attack(p,skill[3],skill[4],skill[5],skill[6],skill[6] and 36 or 0,false)
  if s.fighter=='Yura' and index==2 then for _,t in ipairs(targets(p,skill[4])) do local other=get(t.p);if other then other.slowUntil=os.clock()+2 end end end
 end)
end)
task.spawn(function()
 while task.wait(.25) do
  for p,s in pairs(profiles) do
   s.seconds+=.25
   if s.fighter=='Diesel' and os.clock()-s.stacksAt>3 then s.stacks=0 end
   update(p)
  end
 end
end)
task.spawn(function() while task.wait(120) do for p in pairs(profiles) do save(p) end end end)
