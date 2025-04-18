local TweenService = game:GetService("TweenService")
local InputService = game:GetService("UserInputService")

local Library = {
    Version = "1.2.0",
    Theme = {
        Font = "Gotham",
        Accent = Color3.fromRGB(85, 170, 255),
        MainBackground = Color3.fromRGB(25, 25, 25),
        Border = Color3.fromRGB(50, 50, 50),
        ElementBackground = Color3.fromRGB(35, 35, 35),
        ElementHover = Color3.fromRGB(45, 45, 45),
        FontColor = Color3.fromRGB(220, 220, 220),
        HideKey = "LeftAlt"
    }
}

local CreateModule = {
    reg = {}
}

local function AddToReg(Instance)
    table.insert(CreateModule.reg, Instance)
end

function CreateModule.Instance(class, properties)
    local instance = Instance.new(class)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

function Library.Main(title)
    for _, v in pairs(game.CoreGui:GetChildren()) do
        if v.Name == "DarkSquareLib" then
            v:Destroy()
        end
    end

    local ScreenGui = CreateModule.Instance("ScreenGui", {
        Name = "DarkSquareLib",
        Parent = game.CoreGui,
        ResetOnSpawn = false
    })

    local MainFrame = CreateModule.Instance("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Library.Theme.MainBackground,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -275, 0.5, -175),
        Size = UDim2.new(0, 550, 0, 350),
        Active = true,
        Visible = false,
        ZIndex = 10
    })

    CreateModule.Instance("UICorner", {
        Parent = MainFrame,
        CornerRadius = UDim.new(0, 10)
    })

    CreateModule.Instance("UIStroke", {
        Parent = MainFrame,
        Thickness = 1,
        Color = Library.Theme.Border
    })

    local Title = CreateModule.Instance("TextLabel", {
        Parent = MainFrame,
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 5),
        Size = UDim2.new(1, -30, 0, 25),
        Font = Enum.Font[Library.Theme.Font],
        Text = title .. " v" .. Library.Version,
        TextColor3 = Library.Theme.FontColor,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 11
    })

    local TitleLine = CreateModule.Instance("Frame", {
        Parent = MainFrame,
        Name = "TitleLine",
        BackgroundColor3 = Library.Theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 11
    })

    local TabContainer = CreateModule.Instance("Frame", {
        Parent = MainFrame,
        Name = "TabContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 40),
        Size = UDim2.new(0, 140, 1, -50),
        ZIndex = 11
    })

    local TabList = CreateModule.Instance("UIListLayout", {
        Parent = TabContainer,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local ElementContainer = CreateModule.Instance("ScrollingFrame", {
        Parent = MainFrame,
        Name = "ElementContainer",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 155, 0, 40),
        Size = UDim2.new(0, 385, 1, -50),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        ZIndex = 11
    })

    local ElementList = CreateModule.Instance("UIListLayout", {
        Parent = ElementContainer,
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    ElementList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ElementContainer.CanvasSize = UDim2.new(0, 0, 0, ElementList.AbsoluteContentSize.Y + 10)
    end)

    local isDragging = false
    local isScrolling = false
    local dragStartPos
    local frameStartPos
    local lastTouchPos
    local velocity = 0
    local decay = 0.92
    local scrollSpeed = 2

    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStartPos = input.Position
            frameStartPos = MainFrame.Position
        end
    end)

    Title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and isDragging then
            local delta = input.Position - dragStartPos
            MainFrame.Position = UDim2.new(
                frameStartPos.X.Scale,
                frameStartPos.X.Offset + delta.X,
                frameStartPos.Y.Scale,
                frameStartPos.Y.Offset + delta.Y
            )
        end
    end)

    Title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    ElementContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and not isDragging then
            isScrolling = true
            lastTouchPos = input.Position.Y
            velocity = 0
        end
    end)

    ElementContainer.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and isScrolling then
            local delta = (lastTouchPos - input.Position.Y) * scrollSpeed
            local newPos = math.clamp(ElementContainer.CanvasPosition.Y + delta, 0, math.max(0, ElementContainer.CanvasSize.Y.Offset - ElementContainer.AbsoluteSize.Y))
            ElementContainer.CanvasPosition = Vector2.new(0, newPos)
            velocity = delta
            lastTouchPos = input.Position.Y
        end
    end)

    ElementContainer.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            isScrolling = false
            if math.abs(velocity) > 5 then
                spawn(function()
                    while math.abs(velocity) > 5 and not isScrolling do
                        local newPos = math.clamp(ElementContainer.CanvasPosition.Y + velocity, 0, math.max(0, ElementContainer.CanvasSize.Y.Offset - ElementContainer.AbsoluteSize.Y))
                        ElementContainer.CanvasPosition = Vector2.new(0, newPos)
                        velocity = velocity * decay
                        wait()
                    end
                    TweenService:Create(ElementContainer, TweenInfo.new(0.2), {CanvasPosition = Vector2.new(0, ElementContainer.CanvasPosition.Y)}):Play()
                end)
            end
        end
    end)

    InputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode[Library.Theme.HideKey] then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    spawn(function()
        wait(0.1)
        MainFrame.Visible = true
    end)

    local Tabs = {}
    local CurrentTab

    function Library:Tab(config)
        local TabName = config.Name
        local TabButton = CreateModule.Instance("TextButton", {
            Parent = TabContainer,
            Name = TabName,
            BackgroundColor3 = Library.Theme.ElementBackground,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -10, 0, 28),
            Font = Enum.Font[Library.Theme.Font],
            Text = TabName,
            TextColor3 = Library.Theme.FontColor,
            TextSize = 14,
            ZIndex = 12
        })

        CreateModule.Instance("UICorner", {
            Parent = TabButton,
            CornerRadius = UDim.new(0, 6)
        })

        local TabContent = CreateModule.Instance("Frame", {
            Parent = ElementContainer,
            Name = TabName .. "Content",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            ZIndex = 12
        })

        local TabHeader = CreateModule.Instance("TextLabel", {
            Parent = TabContent,
            Name = "TabHeader",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -20, 0, 20),
            Font = Enum.Font[Library.Theme.Font],
            Text = TabName,
            TextColor3 = Library.Theme.FontColor,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 12
        })

        local ContentList = CreateModule.Instance("UIListLayout", {
            Parent = TabContent,
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Tabs[TabName] = {
            Button = TabButton,
            Content = TabContent,
            List = ContentList
        }

        local function SelectTab()
            if CurrentTab then
                Tabs[CurrentTab].Content.Visible = false
                TweenService:Create(Tabs[CurrentTab].Button, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.ElementBackground}):Play()
            end
            CurrentTab = TabName
            Tabs[TabName].Content.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Accent}):Play()
            ElementContainer.CanvasPosition = Vector2.new(0, 0)
        end

        if not CurrentTab then
            SelectTab()
        end

        TabButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                SelectTab()
            end
        end)

        local TabElements = {}

        function TabElements:Checkbox(config)
            local Checkbox = CreateModule.Instance("Frame", {
                Parent = TabContent,
                Name = config.Name,
                BackgroundColor3 = Library.Theme.ElementBackground,
                BorderSizePixel = 0,
                Size = UDim2.new(0.95, 0, 0, 32),
                ZIndex = 12
            })

            CreateModule.Instance("UICorner", {
                Parent = Checkbox,
                CornerRadius = UDim.new(0, 6)
            })

            local Label = CreateModule.Instance("TextLabel", {
                Parent = Checkbox,
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(0.7, 0, 1, 0),
                Font = Enum.Font[Library.Theme.Font],
                Text = config.Name,
                TextColor3 = Library.Theme.FontColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 12
            })

            local CheckBoxFrame = CreateModule.Instance("Frame", {
                Parent = Checkbox,
                Name = "CheckBoxFrame",
                BackgroundColor3 = Library.Theme.Accent,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -26, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                ZIndex = 12
            })

            CreateModule.Instance("UICorner", {
                Parent = CheckBoxFrame,
                CornerRadius = UDim.new(0, 4)
            })

            local IsChecked = config.Default or false
            CheckBoxFrame.BackgroundTransparency = IsChecked and 0 or 1

            Checkbox.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    IsChecked = not IsChecked
                    TweenService:Create(CheckBoxFrame, TweenInfo.new(0.2), {BackgroundTransparency = IsChecked and 0 or 1}):Play()
                    spawn(function() config.Callback(IsChecked) end)
                end
            end)

            AddToReg(Checkbox)
            return Checkbox
        end

        function TabElements:Label(config)
            local Label = CreateModule.Instance("TextLabel", {
                Parent = TabContent,
                Name = config.Name,
                BackgroundColor3 = Library.Theme.ElementBackground,
                BorderSizePixel = 0,
                Size = UDim2.new(0.95, 0, 0, 32),
                Font = Enum.Font[Library.Theme.Font],
                Text = config.Name,
                TextColor3 = Library.Theme.FontColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Center,
                ZIndex = 12
            })

            CreateModule.Instance("UICorner", {
                Parent = Label,
                CornerRadius = UDim.new(0, 6)
            })

            AddToReg(Label)
            return Label
        end

        function TabElements:Button(config)
            local Button = CreateModule.Instance("TextButton", {
                Parent = TabContent,
                Name = config.Name,
                BackgroundColor3 = Library.Theme.ElementBackground,
                BorderSizePixel = 0,
                Size = UDim2.new(0.95, 0, 0, 40),
                Font = Enum.Font[Library.Theme.Font],
                Text = config.Name,
                TextColor3 = Library.Theme.FontColor,
                TextSize = 14,
                ZIndex = 12
            })

            CreateModule.Instance("UICorner", {
                Parent = Button,
                CornerRadius = UDim.new(0, 6)
            })

            Button.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.Accent}):Play()
                end
            end)

            Button.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.ElementBackground}):Play()
                    spawn(function() config.Callback() end)
                end
            end)

            AddToReg(Button)
            return Button
        end

        function TabElements:Input(config)
            local Input = CreateModule.Instance("Frame", {
                Parent = TabContent,
                Name = config.Name,
                BackgroundColor3 = Library.Theme.ElementBackground,
                BorderSizePixel = 0,
                Size = UDim2.new(0.95, 0, 0, 32),
                ZIndex = 12
            })

            CreateModule.Instance("UICorner", {
                Parent = Input,
                CornerRadius = UDim.new(0, 6)
            })

            CreateModule.Instance("TextLabel", {
                Parent = Input,
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(0.4, 0, 1, 0),
                Font = Enum.Font[Library.Theme.Font],
                Text = config.Name,
                TextColor3 = Library.Theme.FontColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 12
            })

            local TextBox = CreateModule.Instance("TextBox", {
                Parent = Input,
                Name = "TextBox",
                BackgroundColor3 = Library.Theme.ElementHover,
                BorderSizePixel = 0,
                Position = UDim2.new(0.45, 0, 0.5, -10),
                Size = UDim2.new(0.5, -10, 0, 20),
                Font = Enum.Font[Library.Theme.Font],
                Text = config.Default or "",
                TextColor3 = Library.Theme.FontColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 12
            })

            CreateModule.Instance("UICorner", {
                Parent = TextBox,
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

        function TabElements:Dropdown(config)
            local Dropdown = CreateModule.Instance("Frame", {
                Parent = TabContent,
                Name = config.Name,
                BackgroundColor3 = Library.Theme.ElementBackground,
                BorderSizePixel = 0,
                Size = UDim2.new(0.95, 0, 0, 32),
                ZIndex = 12
            })

            CreateModule.Instance("UICorner", {
                Parent = Dropdown,
                CornerRadius = UDim.new(0, 6)
            })

            local DropdownButton = CreateModule.Instance("TextButton", {
                Parent = Dropdown,
                Name = "DropdownButton",
                BackgroundColor3 = Library.Theme.ElementHover,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 6),
                Size = UDim2.new(1, -20, 0, 20),
                Font = Enum.Font[Library.Theme.Font],
                Text = config.Default or config.Options[1] or "Select",
                TextColor3 = Library.Theme.FontColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 13
            })

            CreateModule.Instance("UICorner", {
                Parent = DropdownButton,
                CornerRadius = UDim.new(0, 4)
            })

            local DropdownList = CreateModule.Instance("Frame", {
                Parent = Dropdown,
                Name = "DropdownList",
                BackgroundColor3 = Library.Theme.ElementBackground,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 32),
                Size = UDim2.new(1, -20, 0, 0),
                ClipsDescendants = true,
                Visible = false,
                ZIndex = 14
            })

            CreateModule.Instance("UICorner", {
                Parent = DropdownList,
                CornerRadius = UDim.new(0, 6)
            })

            local ListLayout = CreateModule.Instance("UIListLayout", {
                Parent = DropdownList,
                Padding = UDim.new(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            local function UpdateListSize()
                local height = #config.Options * 22 + (#config.Options - 1) * ListLayout.Padding.Offset
                DropdownList.Size = UDim2.new(1, -20, 0, math.min(height, 100))
            end

            for _, option in pairs(config.Options) do
                local OptionButton = CreateModule.Instance("TextButton", {
                    Parent = DropdownList,
                    Name = option,
                    BackgroundColor3 = Library.Theme.ElementBackground,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 22),
                    Font = Enum.Font[Library.Theme.Font],
                    Text = option,
                    TextColor3 = Library.Theme.FontColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 15
                })

                OptionButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch then
                        DropdownButton.Text = option
                        DropdownList.Visible = false
                        spawn(function() config.Callback(option) end)
                    end
                end)

                OptionButton.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch then
                        TweenService:Create(OptionButton, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.ElementHover}):Play()
                    end
                end)

                OptionButton.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch then
                        TweenService:Create(OptionButton, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.ElementBackground}):Play()
                    end
                end)
            end

            UpdateListSize()

            DropdownButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    DropdownList.Visible = not DropdownList.Visible
                end
            end)

            InputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch and DropdownList.Visible then
                    local pos = input.Position
                    local absPos = DropdownList.AbsolutePosition
                    local absSize = DropdownList.AbsoluteSize
                    if pos.X < absPos.X or pos.X > absPos.X + absSize.X or pos.Y < absPos.Y or pos.Y > absPos.Y + absSize.Y then
                        DropdownList.Visible = false
                    end
                end
            end)

            AddToReg(Dropdown)
            return Dropdown
        end

        return TabElements
    end

    return Library
end

return Library
