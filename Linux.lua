local TweenService = game:GetService("TweenService")
local InputService = game:GetService("UserInputService")

local Library = {
    Version = "1.1.0",
    Theme = {
        Font = "GothamBlack",
        Accent = Color3.fromRGB(72, 138, 182),
        AcrylicMain = Color3.fromRGB(30, 30, 30),
        AcrylicBorder = Color3.fromRGB(60, 60, 60),
        TitleBarLine = Color3.fromRGB(65, 65, 65),
        Element = Color3.fromRGB(70, 70, 70),
        ElementBorder = Color3.fromRGB(100, 100, 100),
        InElementBorder = Color3.fromRGB(55, 55, 55),
        ElementTransparency = 0.82,
        FontColor = Color3.fromRGB(255, 255, 255),
        HideKey = "LeftAlt",
        DialogInput = Color3.fromRGB(45, 45, 45),
        DialogInputLine = Color3.fromRGB(120, 120, 120)
    }
}

local CreateModule = {
    reg = {}
}

local function AddToReg(Instance)
    table.insert(CreateModule.reg, Instance)
end

function CreateModule.Instance(instance, properties)
    local CreatedInstance = Instance.new(instance)
    for property, value in pairs(properties) do
        CreatedInstance[property] = value
    end
    return CreatedInstance
end

function Library.Main(Name)
    for _, v in pairs(game.CoreGui:GetChildren()) do
        if v.Name == "DarkSquareLib" then
            v:Destroy()
        end
    end

    local DarkSquareLib = CreateModule.Instance("ScreenGui", {
        Name = "DarkSquareLib",
        Parent = game.CoreGui,
        ResetOnSpawn = false
    })

    local MainFrame = CreateModule.Instance("Frame", {
        Name = "MainFrame",
        Parent = DarkSquareLib,
        BackgroundColor3 = Library.Theme.AcrylicMain,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -275, 0.5, -175),
        Size = UDim2.new(0, 550, 0, 350),
        Active = true,
        Draggable = false,
        Visible = false,
        ZIndex = 3
    })

    CreateModule.Instance("UICorner", {
        Parent = MainFrame,
        Name = "Corner",
        CornerRadius = UDim.new(0, 8)
    })

    CreateModule.Instance("UIStroke", {
        Parent = MainFrame,
        Name = "Stroke",
        Thickness = 1,
        Color = Library.Theme.AcrylicBorder,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })

    local Title = CreateModule.Instance("TextLabel", {
        Parent = MainFrame,
        Name = "Title",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(1, -20, 0, 30),
        Font = Enum.Font[Library.Theme.Font],
        Text = Name .. " v" .. Library.Version,
        TextColor3 = Library.Theme.FontColor,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4
    })

    local TitleLine = CreateModule.Instance("Frame", {
        Parent = MainFrame,
        Name = "TitleLine",
        BackgroundColor3 = Library.Theme.TitleBarLine,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 3
    })

    local TabContainer = CreateModule.Instance("Frame", {
        Parent = MainFrame,
        Name = "TabContainer",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 40),
        Size = UDim2.new(0, 150, 1, -50),
        ZIndex = 3
    })

    local TabList = CreateModule.Instance("UIListLayout", {
        Parent = TabContainer,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Vertical
    })

    local Container = CreateModule.Instance("ScrollingFrame", {
        Parent = MainFrame,
        Name = "Container",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 160, 0, 40),
        Size = UDim2.new(0, 380, 1, -50),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        ScrollingEnabled = false,
        ZIndex = 3
    })

    local ElementList = CreateModule.Instance("UIListLayout", {
        Parent = Container,
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    ElementList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Container.CanvasSize = UDim2.new(0, 0, 0, ElementList.AbsoluteContentSize.Y + 4)
    end)

    local isDraggingUI = false
    local isScrolling = false
    local lastTouchPos = nil
    local scrollSpeed = 2
    local dragStartPos = nil
    local dragStartFramePos = nil
    local velocity = 0
    local lastDelta = 0
    local decay = 0.95
    local minVelocity = 5

    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            isDraggingUI = true
            dragStartPos = input.Position
            dragStartFramePos = MainFrame.Position
        end
    end)

    Title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and isDraggingUI then
            local delta = input.Position - dragStartPos
            local newPos = UDim2.new(
                dragStartFramePos.X.Scale,
                dragStartFramePos.X.Offset + delta.X,
                dragStartFramePos.Y.Scale,
                dragStartFramePos.Y.Offset + delta.Y
            )
            MainFrame.Position = newPos
        end
    end)

    Title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            isDraggingUI = false
            dragStartPos = nil
            dragStartFramePos = nil
        end
    end)

    Container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and not isDraggingUI then
            isScrolling = true
            lastTouchPos = input.Position.Y
            velocity = 0
        end
    end)

    Container.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and isScrolling then
            local currentTouchPos = input.Position.Y
            lastDelta = (lastTouchPos - currentTouchPos) * scrollSpeed
            local newCanvasPos = Container.CanvasPosition.Y + lastDelta
            newCanvasPos = math.clamp(newCanvasPos, 0, math.max(0, Container.CanvasSize.Y.Offset - Container.AbsoluteSize.Y))
            Container.CanvasPosition = Vector2.new(0, newCanvasPos)
            velocity = lastDelta
            lastTouchPos = currentTouchPos
        end
    end)

    Container.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            isScrolling = false
            lastTouchPos = nil
            if math.abs(velocity) > minVelocity then
                spawn(function()
                    while math.abs(velocity) > minVelocity and not isScrolling do
                        local newCanvasPos = Container.CanvasPosition.Y + velocity
                        newCanvasPos = math.clamp(newCanvasPos, 0, math.max(0, Container.CanvasSize.Y.Offset - Container.AbsoluteSize.Y))
                        Container.CanvasPosition = Vector2.new(0, newCanvasPos)
                        velocity = velocity * decay
                        wait()
                    end
                    local finalPos = math.clamp(Container.CanvasPosition.Y, 0, math.max(0, Container.CanvasSize.Y.Offset - Container.AbsoluteSize.Y))
                    TweenService:Create(Container, TweenInfo.new(0.2), {CanvasPosition = Vector2.new(0, finalPos)}):Play()
                end)
            end
        end
    end)

    InputService.InputBegan:Connect(function(input, IsTyping)
        if input.KeyCode == Enum.KeyCode[Library.Theme.HideKey] and not IsTyping then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    spawn(function()
        wait(0.2)
        MainFrame.Visible = true
    end)

    local InMain = {}
    local Tabs = {}
    local CurrentTab = nil

    function InMain.Tab(config)
        local TabName = config.Name
        local TabButton = CreateModule.Instance("TextButton", {
            Parent = TabContainer,
            Name = TabName,
            BackgroundColor3 = Library.Theme.Element,
            BackgroundTransparency = Library.Theme.ElementTransparency,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -10, 0, 30),
            Font = Enum.Font[Library.Theme.Font],
            Text = TabName,
            TextSize = 16,
            TextColor3 = Library.Theme.FontColor,
            TextXAlignment = Enum.TextXAlignment.Center,
            AutoButtonColor = false,
            ZIndex = 3
        })

        CreateModule.Instance("UICorner", {
            Parent = TabButton,
            Name = "Corner",
            CornerRadius = UDim.new(0, 4)
        })

        local TabElements = CreateModule.Instance("Frame", {
            Parent = Container,
            Name = TabName .. "Elements",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            ZIndex = 3
        })

        local TabHeader = CreateModule.Instance("TextLabel", {
            Parent = TabElements,
            Name = "TabHeader",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 20),
            Font = Enum.Font[Library.Theme.Font],
            Text = TabName,
            TextSize = 16,
            TextColor3 = Library.Theme.FontColor,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 3
        })

        local TabElementList = CreateModule.Instance("UIListLayout", {
            Parent = TabElements,
            Padding = UDim.new(0, 5),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        TabElementList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Container.CanvasSize = UDim2.new(0, 0, 0, TabElementList.AbsoluteContentSize.Y + 4)
        end)

        Tabs[TabName] = {
            Button = TabButton,
            Elements = TabElements,
            ElementList = TabElementList
        }

        local function SelectTab()
            if CurrentTab then
                Tabs[CurrentTab].Elements.Visible = false
                TweenService:Create(Tabs[CurrentTab].Button, TweenInfo.new(0.3), {BackgroundColor3 = Library.Theme.Element, BackgroundTransparency = Library.Theme.ElementTransparency}):Play()
            end
            CurrentTab = TabName
            Tabs[TabName].Elements.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.3), {BackgroundColor3 = Library.Theme.Accent, BackgroundTransparency = 0}):Play()
            Container.CanvasPosition = Vector2.new(0, 0)
        end

        if not CurrentTab then
            SelectTab()
        end

        TabButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                SelectTab()
            end
        end)

        local InTab = {}

        function InTab.Checkbox(config)
            local Checkbox = CreateModule.Instance("TextButton", {
                Parent = TabElements,
                Name = config.Name,
                BackgroundColor3 = Library.Theme.Element,
                BackgroundTransparency = Library.Theme.ElementTransparency,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0.95, 0, 0, 30),
                Font = Enum.Font[Library.Theme.Font],
                Text = "",
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                ZIndex = 3
            })

            CreateModule.Instance("UICorner", {
                Parent = Checkbox,
                Name = "Corner",
                CornerRadius = UDim.new(0, 4)
            })

            CreateModule.Instance("TextLabel", {
                Parent = Checkbox,
                Name = "Label",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 5, 0, 0),
                Size = UDim2.new(0.7, 0, 1, 0),
                Font = Enum.Font[Library.Theme.Font],
                Text = config.Name,
                TextSize = 16,
                TextColor3 = Library.Theme.FontColor,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 3
            })

            local IsActive = CreateModule.Instance("BoolValue", {
                Parent = Checkbox,
                Name = "IsActive",
                Value = config.Default or false
            })

            local CheckFrame = CreateModule.Instance("Frame", {
                Parent = Checkbox,
                Name = "CheckFrame",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -25, 0.5, -10),
                Size = UDim2.new(0, 20, 0, 20),
                ZIndex = 3
            })

            local CheckFrameInner = CreateModule.Instance("Frame", {
                Parent = CheckFrame,
                Name = "CheckFrameInner",
                BackgroundColor3 = Library.Theme.Accent,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 3
            })

            CreateModule.Instance("UICorner", {
                Parent = CheckFrameInner,
                Name = "Corner",
                CornerRadius = UDim.new(0, 4)
            })

            local CheckMark = CreateModule.Instance("ImageLabel", {
                Parent = CheckFrame,
                Name = "CheckMark",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 2, 0, 2),
                Size = UDim2.new(1, -4, 1, -4),
                Image = "rbxassetid://10709790644",
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                ImageTransparency = 1,
                ZIndex = 3
            })

            local function UpdateVisuals()
                CheckMark.Visible = IsActive.Value
                if IsActive.Value then
                    CheckFrameInner.BackgroundTransparency = 0
                    CheckMark.ImageTransparency = 0
                else
                    CheckFrameInner.BackgroundTransparency = 1
                    CheckMark.ImageTransparency = 1
                end
            end

            UpdateVisuals()

            IsActive.Changed:Connect(function()
                UpdateVisuals()
                spawn(function() config.Callback(IsActive.Value) end)
            end)

            local touchStartTime = 0
            local touchStartPos = nil
            local maxTouchTime = 0.3
            local maxTouchDistance = 10

            Checkbox.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    touchStartTime = tick()
                    touchStartPos = input.Position
                end
            end)

            Checkbox.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    local touchEndTime = tick()
                    local touchEndPos = input.Position
                    local touchDuration = touchEndTime - touchStartTime
                    local touchDistance = (touchEndPos - touchStartPos).Magnitude
                    if touchDuration <= maxTouchTime and touchDistance <= maxTouchDistance then
                        IsActive.Value = not IsActive.Value
                    end
                end
            end)

            AddToReg(Checkbox)
            return Checkbox
        end

        function InTab.Label(config)
            local Label = CreateModule.Instance("TextLabel", {
                Parent = TabElements,
                Name = config.Name,
                BackgroundColor3 = Library.Theme.Element,
                BackgroundTransparency = Library.Theme.ElementTransparency,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0.95, 0, 0, 30),
                Font = Enum.Font[Library.Theme.Font],
                Text = config.Name,
                TextSize = 16,
                TextColor3 = Library.Theme.FontColor,
                TextXAlignment = Enum.TextXAlignment.Center,
                ZIndex = 3
            })

            CreateModule.Instance("UICorner", {
                Parent = Label,
                Name = "Corner",
                CornerRadius = UDim.new(0, 4)
            })

            AddToReg(Label)
            return Label
        end

        function InTab.Button(config)
            local Button = CreateModule.Instance("TextButton", {
                Parent = TabElements,
                Name = config.Name,
                BackgroundColor3 = Library.Theme.Element,
                BackgroundTransparency = Library.Theme.ElementTransparency,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0.95, 0, 0, 40),
                Font = Enum.Font[Library.Theme.Font],
                Text = config.Name,
                TextSize = 16,
                TextColor3 = Library.Theme.FontColor,
                TextXAlignment = Enum.TextXAlignment.Center,
                AutoButtonColor = false,
                ZIndex = 3
            })

            CreateModule.Instance("UICorner", {
                Parent = Button,
                Name = "Corner",
                CornerRadius = UDim.new(0, 4)
            })

            local touchStartTime = 0
            local touchStartPos = nil
            local maxTouchTime = 0.3
            local maxTouchDistance = 10

            Button.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    touchStartTime = tick()
                    touchStartPos = input.Position
                    TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = Library.Theme.Accent, BackgroundTransparency = 0}):Play()
                end
            end)

            Button.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    local touchEndTime = tick()
                    local touchEndPos = input.Position
                    local touchDuration = touchEndTime - touchStartTime
                    local touchDistance = (touchEndPos - touchStartPos).Magnitude
                    TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = Library.Theme.Element, BackgroundTransparency = Library.Theme.ElementTransparency}):Play()
                    if touchDuration <= maxTouchTime and touchDistance <= maxTouchDistance then
                        spawn(function() config.Callback() end)
                    end
                end
            end)

            AddToReg(Button)
            return Button
        end

        function InTab.Input(config)
            local Input = CreateModule.Instance("Frame", {
                Parent = TabElements,
                Name = config.Name,
                BackgroundColor3 = Library.Theme.Element,
                BackgroundTransparency = Library.Theme.ElementTransparency,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0.95, 0, 0, 30),
                ZIndex = 3
            })

            CreateModule.Instance("UICorner", {
                Parent = Input,
                Name = "Corner",
                CornerRadius = UDim.new(0, 4)
            })

            CreateModule.Instance("TextLabel", {
                Parent = Input,
                Name = "Label",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 5, 0, 0),
                Size = UDim2.new(0.4, 0, 1, 0),
                Font = Enum.Font[Library.Theme.Font],
                Text = config.Name,
                TextSize = 16,
                TextColor3 = Library.Theme.FontColor,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 3
            })

            local TextBox = CreateModule.Instance("TextBox", {
                Parent = Input,
                Name = "TextBox",
                BackgroundColor3 = Library.Theme.DialogInput,
                BorderSizePixel = 0,
                Position = UDim2.new(0.45, 0, 0.5, -10),
                Size = UDim2.new(0.5, -5, 0, 20),
                Font = Enum.Font[Library.Theme.Font],
                Text = config.Default or "",
                TextSize = 14,
                TextColor3 = Library.Theme.FontColor,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextScaled = true,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 3
            })

            CreateModule.Instance("UICorner", {
                Parent = TextBox,
                Name = "Corner",
                CornerRadius = UDim.new(0, 4)
            })

            TextBox.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    spawn(function() config.Callback(TextBox.Text) end)
                end
            end)

            AddToReg(Input)
            return Input
        end

        function InTab.Dropdown(config)
            local Dropdown = CreateModule.Instance("Frame", {
                Parent = TabElements,
                Name = config.Name,
                BackgroundColor3 = Library.Theme.Element,
                BackgroundTransparency = Library.Theme.ElementTransparency,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0.95, 0, 0, 30),
                ZIndex = 3
            })

            CreateModule.Instance("UICorner", {
                Parent = Dropdown,
                Name = "Corner",
                CornerRadius = UDim.new(0, 4)
            })

            local DropdownButton = CreateModule.Instance("TextButton", {
                Parent = Dropdown,
                Name = "DropdownButton",
                BackgroundColor3 = Library.Theme.DialogInput,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 5, 0, 5),
                Size = UDim2.new(1, -10, 0, 20),
                Font = Enum.Font[Library.Theme.Font],
                Text = config.Default or "Select an option",
                TextSize = 14,
                TextColor3 = Library.Theme.FontColor,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 3
            })

            CreateModule.Instance("UICorner", {
                Parent = DropdownButton,
                Name = "Corner",
                CornerRadius = UDim.new(0, 4)
            })

            local DropdownList = CreateModule.Instance("Frame", {
                Parent = Dropdown,
                Name = "DropdownList",
                BackgroundColor3 = Library.Theme.Element,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 5, 0, 30),
                Size = UDim2.new(1, -10, 0, 0),
                ClipsDescendants = true,
                Visible = false,
                ZIndex = 4
            })

            CreateModule.Instance("UICorner", {
                Parent = DropdownList,
                Name = "Corner",
                CornerRadius = UDim.new(0, 4)
            })

            local DropdownListLayout = CreateModule.Instance("UIListLayout", {
                Parent = DropdownList,
                Padding = UDim.new(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            local function UpdateListSize()
                local totalHeight = 0
                for _, child in pairs(DropdownList:GetChildren()) do
                    if child:IsA("TextButton") then
                        totalHeight = totalHeight + child.Size.Y.Offset + DropdownListLayout.Padding.Offset
                    end
                end
                DropdownList.Size = UDim2.new(1, -10, 0, totalHeight)
            end

            for _, option in pairs(config.Options) do
                local OptionButton = CreateModule.Instance("TextButton", {
                    Parent = DropdownList,
                    Name = option,
                    BackgroundColor3 = Library.Theme.Element,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font[Library.Theme.Font],
                    Text = option,
                    TextSize = 14,
                    TextColor3 = Library.Theme.FontColor,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 4
                })

                OptionButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch then
                        DropdownButton.Text = option
                        DropdownList.Visible = false
                        spawn(function() config.Callback(option) end)
                    end
                end)
            end

            UpdateListSize()

            DropdownButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    DropdownList.Visible = not DropdownList.Visible
                end
            end)

            game:GetService("UserInputService").InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    local mousePos = input.Position
                    local dropdownPos = Dropdown.AbsolutePosition
                    local dropdownSize = Dropdown.AbsoluteSize
                    if mousePos.X < dropdownPos.X or mousePos.X > dropdownPos.X + dropdownSize.X or
                       mousePos.Y < dropdownPos.Y or mousePos.Y > dropdownPos.Y + dropdownSize.Y then
                        DropdownList.Visible = false
                    end
                end
            end)

            AddToReg(Dropdown)
            return Dropdown
        end

        return InTab
    end

    return InMain
end

return Library
