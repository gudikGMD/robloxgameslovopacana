-- Лидерборды на центральной площади: глобальный топ (OrderedDataStore) + живые данные игроков на сервере.
-- Если DataStore недоступен (например, в Studio не включён API), показываются игроки текущего сервера.
local Players=game:GetService('Players')
local DSS=game:GetService('DataStoreService')
local killsStore=DSS:GetOrderedDataStore('StreetBattles_Top_Kills_v08')
local timeStore=DSS:GetOrderedDataStore('StreetBattles_Top_Time_v08')
local yard=workspace:WaitForChild('StreetCourtyard',30);if not yard then return end
local boards=yard:WaitForChild('Leaderboards',30);if not boards then return end
task.wait(1)
local screens={Kills={},Time={}}
for _,d in ipairs(boards:GetDescendants()) do
 local kind=d:IsA('BasePart') and d:GetAttribute('Board')
 if kind and screens[kind] then table.insert(screens[kind],d) end
end
local nameCache={}
local function nameOf(id)
 for _,p in ipairs(Players:GetPlayers()) do if p.UserId==id then return p.Name end end
 if nameCache[id] then return nameCache[id] end
 local ok,n=pcall(function() return Players:GetNameFromUserIdAsync(id) end)
 nameCache[id]=ok and n or ('Игрок '..id);return nameCache[id]
end
local function fmtTime(sec)
 sec=math.floor(sec);local h=sec//3600;local m=(sec%3600)//60
 if h>0 then return h..' ч '..m..' мин' end
 return m..' мин'
end
local function collect(store,attr)
 local map={}
 local ok,page=pcall(function() return store:GetSortedAsync(false,10):GetCurrentPage() end)
 if ok and page then for _,e in ipairs(page) do local id=tonumber(e.key);if id then map[id]=tonumber(e.value) or 0 end end end
 for _,p in ipairs(Players:GetPlayers()) do -- живые значения онлайн-игроков
  local live=tonumber(p:GetAttribute(attr)) or 0
  if live>0 then map[p.UserId]=math.max(map[p.UserId] or 0,live) end
 end
 local list={}
 for id,v in pairs(map) do table.insert(list,{id=id,v=v}) end
 table.sort(list,function(a,b) return a.v>b.v end)
 return list
end
local function render(kind,list,formatter)
 for _,screen in ipairs(screens[kind]) do
  for _,gui in ipairs(screen:GetChildren()) do
   if gui:IsA('SurfaceGui') then
    for i=1,10 do
     local row=gui:FindFirstChild('Row'..i,true)
     if row then
      local e=list[i]
      row.PlayerName.Text=e and nameOf(e.id) or '—'
      row.Score.Text=e and formatter(e.v) or ''
     end
    end
   end
  end
 end
end
while true do
 render('Kills',collect(killsStore,'Kills'),function(v) return tostring(v) end)
 render('Time',collect(timeStore,'PlaySeconds'),fmtTime)
 task.wait(30)
end
