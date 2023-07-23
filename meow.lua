local Ctrl_click_tp = false
  local plrs = game:GetService'Players'
  local plr = plrs.LocalPlayer
  local mouse = plr:GetMouse()
  local rep = game:GetService'ReplicatedStorage'
  local uis = game:GetService'UserInputService'
  local ts = game:GetService'TweenService'
  local rs = game:GetService'RunService'.RenderStepped
  local function findplr(Target)
      local name = Target
      local found = false
      for _,v in pairs(game.Players:GetPlayers()) do 
          if not found and (v.Name:lower():sub(1,#name) == name:lower() or v.DisplayName:lower():sub(1,#name) == name:lower()) then
              name = v
              found = true
          end
      end
      if name ~= nil and name ~= Target then
          return name
      end
  end
  local function Notify(title,text,duration)
      game:GetService'StarterGui':SetCore('SendNotification',{
          Title = tostring(title),
          Text = tostring(text),
          Duration = tonumber(duration),
      })
  end
  local function AddCd(tool,Cd)
      local cd = Instance.new('IntValue',tool)
      cd.Name = 'ClientCD'
      game.Debris:AddItem(cd,Cd)
  end
  local function Shoot(firstPos,nextPos,Revolver)
      if Revolver:FindFirstChild'Barrel' and Revolver.Barrel:FindFirstChild'Attachment' then
          if Revolver.Barrel.Attachment:FindFirstChild'Sound' then
              local SoundClone = Revolver.Barrel.Attachment.Sound:Clone()
              SoundClone.Name = 'Uncopy'
              SoundClone.Parent = Revolver.Barrel.Attachment
              SoundClone:Play()
              game.Debris:AddItem(SoundClone, 1)
          end
          local FilterTable = {}
          table.insert(FilterTable, plr.Character)
          table.insert(FilterTable, game.Workspace['Target Filter'])
          for _, v in pairs(game.Workspace:GetDescendants()) do
              if v.ClassName == 'Accessory' then
                  table.insert(FilterTable, v)
              end
          end
          local a_1, a_2, a_3 = game.Workspace:FindPartOnRayWithIgnoreList(Ray.new(firstPos, (nextPos - firstPos).Unit * 100), FilterTable)
          local BulletCl = rep['Revolver Bullet']:Clone()
          game.Debris:AddItem(BulletCl, 1)
          BulletCl.Parent = game.Workspace['Target Filter']
          local mg = (firstPos - a_2).Magnitude
          BulletCl.Size = Vector3.new(0.2, 0.2, mg)
          BulletCl.CFrame = CFrame.new(firstPos, nextPos) * CFrame.new(0, 0, -mg / 2)
          ts:Create(BulletCl, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
              Size = Vector3.new(0.05, 0.05, mg), 
              Transparency = 1
          }):Play()
          if a_1 then
              local expPart = Instance.new'Part'
              game.Debris:AddItem(expPart, 2)
              expPart.Name = 'Exploding Neon Part'
              expPart.Anchored = true
              expPart.CanCollide = false
              expPart.Shape = 'Ball'
              expPart.Material = Enum.Material.Neon
              expPart.BrickColor = BulletCl.BrickColor
              expPart.Size = Vector3.new(0.1, 0.1, 0.1)
              expPart.Parent = game.Workspace['Target Filter']
              expPart.Position = a_2
              ts:Create(expPart, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
                  Size = Vector3.new(2, 2, 2), 
                  Transparency = 1
              }):Play()
              if Revolver:FindFirstChild'DamageRemote' and a_1.Parent:FindFirstChild'Humanoid' then
                  Revolver.DamageRemote:FireServer(a_1.Parent.Humanoid)
              end
          end
      end
  end
  mouse.Button1Down:connect(function()
      if not uis:IsKeyDown(Enum.KeyCode.LeftControl) then return end if not mouse.Hit then return end 
      if plr.Character and plr.Character:FindFirstChild'HumanoidRootPart' then
          plr.Character:FindFirstChild'HumanoidRootPart'.CFrame = mouse.Hit + Vector3.new(0,5,0)
      end
  end)
  local tar
  plr:GetMouse().KeyDown:Connect(function(key)
      if key == 'r' then
          tar = nil
          for _,v in next,workspace:GetDescendants() do
              if v.Name == 'SelectedPlayer' then
                  v:Destroy()
              end
          end
          local n_plr, dist
          for _, v in pairs(game.Players:GetPlayers()) do
              if v ~= plr and plr.Character and plr.Character:FindFirstChild'HumanoidRootPart' then
                  local distance = v:DistanceFromCharacter(plr.Character.HumanoidRootPart.Position)
                  if v.Character and (not dist or distance <= dist) and v.Character:FindFirstChildOfClass'Humanoid' and v.Character:FindFirstChildOfClass'Humanoid'.Health>0 and v.Character:FindFirstChild'HumanoidRootPart' then
                      dist = distance
                      n_plr = v
                  end
              end
          end
          local sp = Instance.new('SelectionBox',n_plr.Character.HumanoidRootPart)
          sp.Name = 'SelectedPlayer'
          sp.Adornee = n_plr.Character.HumanoidRootPart
          tar = n_plr
      elseif key == 'q' and tar and plr.Character then
          for _,v in next,plr.Character:GetDescendants() do
              if v:IsA'Tool' and v.Name ~= 'Kawaii Revolver' and not v:FindFirstChild'ClientCD' and v:FindFirstChild'DamageRemote' and v:FindFirstChild'Cooldown' and tar and tar.Character and tar.Character:FindFirstChildOfClass'Humanoid' then
                  AddCd(v,v.Cooldown.Value)
                  v.DamageRemote:FireServer(tar.Character:FindFirstChildOfClass'Humanoid')
                  if v:FindFirstChild'Attack' and plr.Character:FindFirstChildOfClass'Humanoid' then
                      plr.Character:FindFirstChildOfClass'Humanoid':LoadAnimation(v.Attack):Play()
                  end
                  if v:FindFirstChild'Blade' then
                      for _,x in next,v.Blade:GetChildren() do
                          if x.Name == 'SwingSound' then
                              x:Play()
                              wait(0.12)
                                 elseif x.Name == 'HitSound' then
                              x:Play()
                          end
                      end
                  end
              elseif v:IsA'Tool' and v.Name == 'Kawaii Revolver' and not v:FindFirstChild'ClientCD' and v:FindFirstChild'ReplicateRemote' and v:FindFirstChild'Barrel' and v.Barrel:FindFirstChild'Attachment' and tar and tar.Character and tar.Character:FindFirstChild'HumanoidRootPart' then
                  v.Parent = plr.Character
                  AddCd(v,2)
                  rs:wait()
                  Shoot(v.Barrel.Attachment.WorldPosition,tar.Character.HumanoidRootPart.Position,v)
                  v.ReplicateRemote:FireServer(tar.Character.HumanoidRootPart.Position)
              end
          end
      elseif key == 'c' and plr:FindFirstChild'Backpack' then
          local guns = 0
          for _,v in next,plr.Backpack:GetChildren() do
              if guns<= 10 and plr.Character and plr.Character:FindFirstChild'Head' and v.Name == 'Kawaii Revolver' and not v:FindFirstChild'ClientCD' and v:FindFirstChild'ReplicateRemote' and v:FindFirstChild'Barrel' and v.Barrel:FindFirstChild'Attachment' then
                  guns = guns+1
                  AddCd(v,2)
                  v.Parent = plr.Character
                  Shoot(plr.Character.Head.Position,mouse.Hit.p,v)
                  v.ReplicateRemote:FireServer(mouse.Hit.p)
                  v.Parent = plr.Backpack
              end
          end
      elseif key == 'q' and tar and plr.Character then
          for _,v in next,plr.Character:GetDescendants() do
              if v:IsA'Tool' and v.Name ~= 'Kawaii Revolver' and not v:FindFirstChild'ClientCD' and v:FindFirstChild'DamageRemote' and v:FindFirstChild'Cooldown' and tar and tar.Character and tar.Character:FindFirstChildOfClass'Humanoid' then
                  AddCd(v,v.Cooldown.Value)
                  v.DamageRemote:FireServer(tar.Character:FindFirstChildOfClass'Humanoid')
                  if v:FindFirstChild'Attack' and plr.Character:FindFirstChildOfClass'Humanoid' then
                      plr.Character:FindFirstChildOfClass'Humanoid':LoadAnimation(v.Attack):Play()
                  end
                  if v:FindFirstChild'Blade' then
                      for _,x in next,v.Blade:GetChildren() do
                          if x.Name == 'SwingSound' then
                              x:Play()
                              wait(0.12)
                                 elseif x.Name == 'HitSound' then
                              x:Play()
                          end
                      end
                  end
              elseif v:IsA'Tool' and v.Name == 'Kawaii Revolver' and not v:FindFirstChild'ClientCD' and v:FindFirstChild'ReplicateRemote' and v:FindFirstChild'Barrel' and v.Barrel:FindFirstChild'Attachment' and tar and tar.Character and tar.Character:FindFirstChild'HumanoidRootPart' then
                  v.Parent = plr.Character
                  AddCd(v,2)
                  rs:wait()
                  Shoot(v.Barrel.Attachment.WorldPosition,tar.Character.HumanoidRootPart.Position,v)
                  v.ReplicateRemote:FireServer(tar.Character.HumanoidRootPart.Position)
              end
          end
      elseif key == 'v' then
          function autoVoid()
              for i,v in pairs(plr.Character:GetChildren()) do
                   if v:IsA('Tool') then
                repeat v.DamageRemote:FireServer(tar.Character:FindFirstChildOfClass'Humanoid')
                wait(0.3)
                until tar.Character.Ragdolled.Value == true
          end
          end
          end
          
          autoVoid()
          
          if tar.Character.Ragdolled.Value == true then
          repeat plr.Character.HumanoidRootPart.CFrame = tar.Character.HumanoidRootPart.CFrame
          wait(0.1)
          until tar.Character["Being Carried"].Value == true or tar.Character.Humanoid.Health <= 0
          repeat plr.Character.PickupRemote:FireServer()
          wait(0.3)
          until tar.Character["Being Carried"].Value == true
          if tar.Character["Being Carried"].Value == true then
          plr.Character.HumanoidRootPart.CFrame = CFrame.new(211.890457, -462.331085, 255.280075, 0.666543722, -0.0616444983, 0.742912769, 1.33772478e-08, 0.996575117, 0.0826925635, -0.745465934, -0.0551182032, 0.664260924)
          wait(0.6)
          game.Players.LocalPlayer.Character.Humanoid.Health = '0'
          end
          end
  local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
  
  local Window = Rayfield:CreateWindow({
      Name = "Chaos script",
      LoadingTitle = "stfu",
      LoadingSubtitle = "dry my balls out",
      ConfigurationSaving = {
          Enabled = true,
          FileName = "Who Cares",
      },
      KeySystem = true,
      KeySettings = {
          Title = "CHAOS SCRIPT",
          Subtitle = "Key System",
          Note = "Join the discord for key (https://discord.gg/Kcm6PGRW)",
          Key = "fatalIsGay"
      }
  })
  Rayfield:Notify("suck my dick","https://discord.gg/Kcm6PGRW",10010348543)
  
  local MainTab = Window:CreateTab("Main")
  local Section = MainTab:CreateSection("Main mfs")
  
  local Button1 = MainTab:CreateButton({
      Name = "Ctrl Click Tp",
      Callback = function(bool)
          Ctrl_click_tp = bool
      end
  })
  
  local Button2 = MainTab:CreateButton({
      Name = "Lock Nearest (Q)",
      Callback = function()
          tar = nil
          for _,v in next,workspace:GetDescendants() do
              if v.Name == 'SelectedPlayer' then
                  v:Destroy()
              end
          end
          local n_plr, dist
          for _, v in pairs(game.Players:GetPlayers()) do
              if v ~= plr and plr.Character and plr.Character:FindFirstChild'HumanoidRootPart' then
                  local distance = v:DistanceFromCharacter(plr.Character.HumanoidRootPart.Position)
                  if v.Character and (not dist or distance <= dist) and v.Character:FindFirstChildOfClass'Humanoid' and v.Character:FindFirstChildOfClass'Humanoid'.Health>0 and v.Character:FindFirstChild'HumanoidRootPart' then
                      dist = distance
                      n_plr = v
                  end
              end
          end
          local sp = Instance.new('SelectionBox',n_plr.Character.HumanoidRootPart)
          sp.Name = 'SelectedPlayer'
          sp.Adornee = n_plr.Character.HumanoidRootPart
          tar = n_plr
      end
  })
  local Button3 = MainTab:CreateButton({
      Name = "Lock Nearest (T) (invisible)",
      Callback = function()
      tar = nil
          for _,v in next,plr.Character:GetDescendants() do
              if v:IsA'Tool' and v.Name ~= 'Kawaii Revolver' and not v:FindFirstChild'ClientCD' and v:FindFirstChild'DamageRemote' and v:FindFirstChild'Cooldown' and tar and tar.Character and tar.Character:FindFirstChildOfClass'Humanoid' then
                  AddCd(v,v.Cooldown.Value)
                  v.DamageRemote:FireServer(tar.Character:FindFirstChildOfClass'Humanoid')
                  if v:FindFirstChild'Attack' and plr.Character:FindFirstChildOfClass'Humanoid' then
                      plr.Character:FindFirstChildOfClass'Humanoid':LoadAnimation(v.Attack):Play()
                  end
                  if v:FindFirstChild'Blade' then
                      for _,x in next,v.Blade:GetChildren() do
                          if x.Name == 'SwingSound' then
                              x:Play()
                              wait(0.12)
                                 elseif x.Name == 'HitSound' then
                              x:Play()
                          end
                      end
                  end 
              end
              end
              end
  })
  local Button4 = MainTab:CreateButton({
      Name = "Hit Locked (Q)",
      Callback = function()
          for _,v in next,plr.Character:GetDescendants() do
              if v:IsA'Tool' and v.Name ~= 'Kawaii Revolver' and not v:FindFirstChild'ClientCD' and v:FindFirstChild'DamageRemote' and v:FindFirstChild'Cooldown' and tar and tar.Character and tar.Character:FindFirstChildOfClass'Humanoid' then
                  AddCd(v,v.Cooldown.Value)
                  v.DamageRemote:FireServer(tar.Character:FindFirstChildOfClass'Humanoid')
                  if v:FindFirstChild'Attack' and plr.Character:FindFirstChildOfClass'Humanoid' then
                      plr.Character:FindFirstChildOfClass'Humanoid':LoadAnimation(v.Attack):Play()
                  end
                  if v:FindFirstChild'Blade' then
                      for _,x in next,v.Blade:GetChildren() do
                          if x.Name == 'SwingSound' then
                              x:Play()
                              wait(0.12)
                                 elseif x.Name == 'HitSound' then
                              x:Play()
                          end
                      end
                  end
              end
              end
              end
  })
  local Button5 = MainTab:CreateButton({
      Name = "Sniper Rifle (C)",
      Callback = function()
          wait(2)
          local guns = 0
          for _,v in next,plr.Backpack:GetChildren() do
              if guns<=10 and plr.Character and plr.Character:FindFirstChild'Head' and v.Name == 'Kawaii Revolver' and not v:FindFirstChild'ClientCD' and v:FindFirstChild'ReplicateRemote' and v:FindFirstChild'Barrel' and v.Barrel:FindFirstChild'Attachment' then
                  guns = guns+1
                  AddCd(v,2)
                  v.Parent = plr.Character
                  Shoot(plr.Character.Head.Position,mouse.Hit.p,v)
                  v.ReplicateRemote:FireServer(mouse.Hit.p)
                  v.Parent = plr.Backpack
              end
          end
      end
  })
  local Button6 = MainTab:CreateButton({
      Name = "AutoVoid shit (V) USE SCYTHE FOR IT",
  })
  
  local MiscTab = Window:CreateTab("Misc")
  
  local Button = MiscTab:CreateButton({
      Name = "Anti Fling",
      Callback = function()
          -- // Constants \\ --
  -- [ Services ] --
  local Services = setmetatable({}, {__index = function(Self, Index)
      local NewService = game.GetService(game, Index)
      if NewService then
      Self[Index] = NewService
      end
      return NewService
      end})
      
      -- [ LocalPlayer ] --
      local LocalPlayer = Services.Players.LocalPlayer
      
      -- // Functions \\ --
      local function PlayerAdded(Player)
         local Detected = false
         local Character;
         local PrimaryPart;
      
         local function CharacterAdded(NewCharacter)
             Character = NewCharacter
             repeat
                 wait()
                 PrimaryPart = NewCharacter:FindFirstChild("HumanoidRootPart")
             until PrimaryPart
             Detected = false
         end
      
         CharacterAdded(Player.Character or Player.CharacterAdded:Wait())
         Player.CharacterAdded:Connect(CharacterAdded)
         Services.RunService.Heartbeat:Connect(function()
             if (Character and Character:IsDescendantOf(workspace)) and (PrimaryPart and PrimaryPart:IsDescendantOf(Character)) then
                 if PrimaryPart.AssemblyAngularVelocity.Magnitude > 50 or PrimaryPart.AssemblyLinearVelocity.Magnitude > 100 then
                     if Detected == false then
                         game.StarterGui:SetCore("ChatMakeSystemMessage", {
                             Text = "Fling Exploit detected, Player: " .. tostring(Player);
                             Color = Color3.fromRGB(255, 200, 0);
                         })
                     end
                     Detected = true
                     for i,v in ipairs(Character:GetDescendants()) do
                         if v:IsA("BasePart") then
                             v.CanCollide = false
                             v.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                             v.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                             v.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
                         end
                     end
                     PrimaryPart.CanCollide = false
                     PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                     PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                     PrimaryPart.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
                 end
             end
         end)
      end
      
      -- // Event Listeners \\ --
      for i,v in ipairs(Services.Players:GetPlayers()) do
         if v ~= LocalPlayer then
             PlayerAdded(v)
         end
      end
      Services.Players.PlayerAdded:Connect(PlayerAdded)
      
      local LastPosition = nil
      Services.RunService.Heartbeat:Connect(function()
         pcall(function()
             local PrimaryPart = LocalPlayer.Character.PrimaryPart
             if PrimaryPart.AssemblyLinearVelocity.Magnitude > 250 or PrimaryPart.AssemblyAngularVelocity.Magnitude > 250 then
                 PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                 PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                 PrimaryPart.CFrame = LastPosition
      
                 game.StarterGui:SetCore("ChatMakeSystemMessage", {
                     Text = "You were flung. Neutralizing velocity.";
                     Color = Color3.fromRGB(255, 0, 0);
                 })
             elseif PrimaryPart.AssemblyLinearVelocity.Magnitude < 50 or PrimaryPart.AssemblyAngularVelocity.Magnitude > 50 then
                 LastPosition = PrimaryPart.CFrame
             end
         end)
      end)
  end,
  })
  
  local Slider = MiscTab:CreateSlider({
      Name = "Walkspeed",
      Range = {16, 1000},
      Increment = 1,
      Suffix = "Walkspeed",
      CurrentValue = 16,
      Flag = "Slider1",
      Callback = function(v)
          plr.Character.Humanoid.WalkSpeed = v
      end,
  })
  
  local Slider2 = MiscTab:CreateSlider({
      Name = "JumpPower",
      Range = {16, 1000},
      Increment = 1,
      Suffix = "JumpPower",
      CurrentValue = 16,
      Flag = "Slider1",
      Callback = function(v)
          plr.Character.Humanoid.JumpPower = v
      end,
  })
  
  local Credits = Window:CreateTab("Credits")
  local Section3 = Credits:CreateSection("Credits ok")
  
  local Button = Credits:CreateButton({
      Name = "Made by mfs",
      Callback = function()
          library:Notify("why would u press the button mf")
          end
  })
