-- v0.7: keyboard HUD at bottom right, compact functional mobile controls.
local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local UIS=game:GetService('UserInputService')
local RunService=game:GetService('RunService')
local TweenService=game:GetService('TweenService')
local player=Players.LocalPlayer
local cfg=require(RS:WaitForChild('GameConfig'))
local remote=RS:WaitForChild('StreetAction')
local pg=player:WaitForChild('PlayerGui')
local old=pg:FindFirstChild('StreetBattlesUI');if old then old:Destroy() end
local gui=Instance.new('ScreenGui');gui.Name='StreetBattlesUI';gui.ResetOnSpawn=false;gui.IgnoreGuiInset=false;gui.Parent=pg
local function new(class,props,parent)
 local obj=Instance.new(class)
 for k,v in pairs(props) do obj[k]=v end
 obj.Parent=parent;return obj
end
local function corner(obj,r) new('UICorner',{CornerRadius=UDim.new(0,r or 7)},obj) end
local function stroke(obj) new('UIStroke',{Color=Color3.fromRGB(118,125,134),Thickness=1,Transparency=.45},obj) end
local mobile=UIS.TouchEnabled
local dark=Color3.fromRGB(25,29,35);local light=Color3.fromRGB(241,241,236)
local choose=new('TextButton',{Name='ChooseFighter',AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,12),Size=UDim2.fromOffset(mobile and 130 or 170,mobile and 35 or 40),Text='БОЙЦЫ [M]',TextSize=mobile and 13 or 16,Font=Enum.Font.GothamBold,TextColor3=light,BackgroundColor3=dark},gui);corner(choose);stroke(choose)
local panel=new('Frame',{Visible=false,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,mobile and 55 or 62),Size=UDim2.fromOffset(mobile and 238 or 280,340),BackgroundColor3=dark},gui);corner(panel);stroke(panel)
new('TextLabel',{Size=UDim2.new(1,0,0,35),BackgroundTransparency=1,Text='ВЫБЕРИ БОЙЦА',TextColor3=light,TextSize=16,Font=Enum.Font.GothamBold},panel)
local list=new('Frame',{Position=UDim2.fromOffset(10,39),Size=UDim2.new(1,-20,1,-47),BackgroundTransparency=1},panel)
new('UIListLayout',{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},list)
for _,id in ipairs(cfg.Order) do
 local c=cfg.Characters[id]
 local b=new('TextButton',{Size=UDim2.new(1,0,0,43),BackgroundColor3=Color3.fromRGB(49,54,62),Text=c.name..' · '..c.item,TextColor3=light,TextSize=mobile and 12 or 14,Font=Enum.Font.GothamBold},list);corner(b,5)
 b.Activated:Connect(function() panel.Visible=false;if player:GetAttribute('Fighter')~=id then remote:FireServer('Select',id) end end)
end
choose.Activated:Connect(function() panel.Visible=not panel.Visible end)
local skills=new('Frame',{Name='Skills',AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,mobile and -9 or -19,1,mobile and -105 or -24),Size=mobile and UDim2.fromOffset(235,188) or UDim2.fromOffset(250,306),BackgroundTransparency=1},gui)
local layout=new('UIGridLayout',{CellPadding=mobile and UDim2.fromOffset(4,4) or UDim2.fromOffset(0,5),CellSize=mobile and UDim2.fromOffset(75,58) or UDim2.fromOffset(250,32),FillDirection=Enum.FillDirection.Horizontal,FillDirectionMaxCells=mobile and 3 or 1,SortOrder=Enum.SortOrder.LayoutOrder},skills)
local keys={'Z','X','C','V','B','Q','F','R'}
local buttons={};local cooldowns={}
local function action(key,held)
 if key=='Z' then remote:FireServer('Skill',1)
 elseif key=='X' then remote:FireServer('Skill',2)
 elseif key=='C' then remote:FireServer('Skill',3)
 elseif key=='V' then remote:FireServer('Skill',4)
 elseif key=='B' then remote:FireServer('Ult')
 elseif key=='Q' then remote:FireServer('Dash')
 elseif key=='F' then remote:FireServer('Block',held)
 elseif key=='R' then remote:FireServer('Special') end
end
for i,key in ipairs(keys) do
 local b=new('TextButton',{Name='Skill'..key,LayoutOrder=i,Text='',TextWrapped=true,TextColor3=light,TextSize=mobile and 11 or 13,Font=Enum.Font.GothamBold,BackgroundColor3=dark,AutoButtonColor=true},skills)
 corner(b,5);stroke(b);buttons[key]=b
 if key~='F' then b.Activated:Connect(function() if not panel.Visible then action(key,true) end end)
 else
  b.MouseButton1Down:Connect(function() if not panel.Visible then action('F',true) end end)
  b.MouseButton1Up:Connect(function() action('F',false) end)
  b.MouseLeave:Connect(function() action('F',false) end)
  if mobile then b.TouchLongPress:Connect(function(_,state) if state==Enum.UserInputState.End then action('F',false) end end) end
 end
end
if mobile then
 local punch=new('TextButton',{Name='Punch',AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-18,1,-20),Size=UDim2.fromOffset(73,73),Text='УДАР',TextSize=15,Font=Enum.Font.GothamBlack,TextColor3=light,BackgroundColor3=Color3.fromRGB(125,52,44)},gui);corner(punch,37);stroke(punch)
 punch.Activated:Connect(function() if not panel.Visible then remote:FireServer('Punch') end end)
end
local notice=new('TextLabel',{Position=UDim2.new(.2,0,.07,0),Size=UDim2.new(.6,0,0,38),BackgroundTransparency=1,Text='',TextColor3=light,TextSize=18,Font=Enum.Font.GothamBold},gui)
local function skillName(key)
 local c=cfg.Characters[player:GetAttribute('Fighter') or 'Siply'] or cfg.Characters.Siply
 if key=='Z' then return c.skills[1][1] elseif key=='X' then return c.skills[2][1] elseif key=='C' then return c.skills[3][1] elseif key=='V' then return c.skills[4][1] elseif key=='B' then return c.ult.name elseif key=='Q' then return 'Рывок' elseif key=='F' then return 'Блок' elseif key=='R' then return c.special and c.special[1] or '' end
 return ''
end
local function fx(data)
 if type(data)~='table' or typeof(data.position)~='Vector3' then return end
 local pos=data.position;local kind=data.kind or 'Hit'
 local color=kind=='Break' and Color3.fromRGB(255,75,67) or kind=='Guard' and Color3.fromRGB(90,180,255) or kind=='Dash' and Color3.fromRGB(190,210,235) or Color3.fromRGB(255,218,117)
 local count=kind=='Break' and 13 or kind=='Dash' and 9 or 7
 for i=1,count do
  local spark=Instance.new('Part');spark.Name='StreetFX';spark.Shape=Enum.PartType.Ball;spark.Material=Enum.Material.Neon;spark.Color=color;spark.Size=Vector3.new(.22,.22,.22);spark.Anchored=true;spark.CanCollide=false;spark.CanTouch=false;spark.CanQuery=false;spark.Position=pos+Vector3.new(0,1,0);spark.Parent=workspace
  local direction=Vector3.new(math.random(-10,10)/10,math.random(0,12)/10,math.random(-10,10)/10)
  local tw=TweenService:Create(spark,TweenInfo.new(.28,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=spark.Position+direction*3,Transparency=1,Size=Vector3.new(.04,.04,.04)})
  tw:Play();tw.Completed:Connect(function() spark:Destroy() end)
 end
end
remote.OnClientEvent:Connect(function(kind,data)
 if kind=='Cooldown' and data and data.key then cooldowns[data.key]=os.clock()+(data.duration or 0)
 elseif kind=='FX' then fx(data)
 elseif kind=='Message' and data and data.text then
  notice.Text=data.text;local msg=data.text
  task.delay(2,function() if notice.Text==msg then notice.Text='' end end)
 end
end)
UIS.InputBegan:Connect(function(input,processed)
 if input.KeyCode==Enum.KeyCode.M and not UIS:GetFocusedTextBox() then panel.Visible=not panel.Visible;return end
 if processed or panel.Visible or UIS:GetFocusedTextBox() then return end
 if input.UserInputType==Enum.UserInputType.MouseButton1 then remote:FireServer('Punch');return end
 local key=input.KeyCode.Name
 if buttons[key] then action(key,true) end
end)
UIS.InputEnded:Connect(function(input) if input.KeyCode==Enum.KeyCode.F then action('F',false) end end)
local elapsed=0
RunService.RenderStepped:Connect(function(dt)
 elapsed+=dt;if elapsed<.1 then return end;elapsed=0
 for _,key in ipairs(keys) do
  local b=buttons[key];local name=skillName(key)
  b.Visible=(key~='R' or name~='')
  local remaining=math.max(0,(cooldowns[key] or 0)-os.clock())
  local extra=remaining>0 and string.format('  %.1fs',remaining) or ''
  if key=='B' then extra='  '..tostring(player:GetAttribute('UltCharge') or 0)..'%' end
  if mobile then b.Text=key..'\n'..(remaining>0 and string.format('%.1fs',remaining) or name) else b.Text='['..key..']  '..name..extra end
  b.BackgroundColor3=remaining>0 and Color3.fromRGB(61,57,60) or dark
 end
end)

-- Дополнительная локальная реакция камеры при получении удара.
local camera=workspace.CurrentCamera
local shakeUntil=0
local shakePower=0
remote.OnClientEvent:Connect(function(kind,data)
 if kind=='HitReact' and type(data)=='table' then
  shakeUntil=os.clock()+.22
  shakePower=math.clamp(tonumber(data.power) or 12,8,40)/160
 end
end)
RunService:BindToRenderStep('StreetHitCamera',Enum.RenderPriority.Camera.Value+1,function()
 if os.clock()<shakeUntil then
  local k=(shakeUntil-os.clock())/.22
  local x=(math.random()-.5)*shakePower*k
  local y=(math.random()-.5)*shakePower*k
  workspace.CurrentCamera.CFrame=workspace.CurrentCamera.CFrame*CFrame.new(x,y,0)
 end
end)
