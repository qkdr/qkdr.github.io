--------------------------------------------------------------------------------
--                          مكتبة Luna للواجهات الفخمة                         --
--      إضافة قسم “أخبار” مخصص بالمدير وإشعارات تلقائية للاعبين               --
--------------------------------------------------------------------------------
local Luna = {}

---------------------------------------------
-- إعدادات عامة قابلة للتعديل
---------------------------------------------
local settings = {
    openSound       = "rbxassetid://6042053626",
    buttonSound     = "rbxassetid://6026984224",
    warningSound    = "rbxassetid://6042055798",
    backgroundImage = "rbxassetid://13577851314",
    buttonColor     = Color3.fromRGB(40, 40, 40),
    accentColor     = Color3.fromRGB(0, 170, 100),
    textColor       = Color3.fromRGB(255, 255, 255),
    cornerRadius    = UDim.new(0, 12),
    transparency    = 0.2,
    telegramLink    = "https://t.me/YourChannelLink",
    folderIcon      = "rbxassetid://123456789",
    managerId       = 12345678,            -- ضع هنا UserId الخاص بالمدير
    notificationTime = 5                   -- مدة ظهور الإشعار بالثواني
}

---------------------------------------------
-- بيانات المجلدات والأخبار
---------------------------------------------
local externalFolders = {}
local newsData = {}  -- جدول الأخبار: { title, details, timestamp }

---------------------------------------------
-- خدمات Roblox
---------------------------------------------
local TweenService       = game:GetService("TweenService")
local Players            = game:GetService("Players")
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local LocalPlayer        = Players.LocalPlayer

--------------------------------------------------------------------------------
-- HELPER: إنشاء إشعار سريع في الشاشة
--------------------------------------------------------------------------------
local function showNotification(parentGui, message)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 50)
    frame.Position = UDim2.new(0.5, -150, 0, 20)
    frame.BackgroundColor3 = settings.accentColor
    frame.BackgroundTransparency = 0.3
    frame.ZIndex = 99
    frame.Parent = parentGui

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextColor3 = settings.textColor
    label.Text = message

    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -150, 0, 40)
    }):Play()

    delay(settings.notificationTime, function()
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0, 40)
        }):Play():Wait()
        frame:Destroy()
    end)
end

--------------------------------------------------------------------------------
-- دالة إضافة خبر جديد (يستخدمها المدير)
--------------------------------------------------------------------------------
function Luna:AddNews(title, details)
    local ts = os.date("!*t")
    local timestamp = string.format("%02d:%02d – %02d/%02d/%04d",
        ts.hour, ts.min, ts.day, ts.month, ts.year)
    table.insert(newsData, 1, { title = title, details = details, timestamp = timestamp })

    -- إشعار لجميع اللاعبين داخل اللعبة
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            -- نستخدم RemoteEvent في الواقع، هنا نفترض اللاعب داخل اللعبة
        end
    end
    -- إشعار للاعب الحالي
    showNotification(LocalPlayer:WaitForChild("PlayerGui"), "خبر جديد: " .. title)
end

--------------------------------------------------------------------------------
-- دالة إنشاء واجهة “الأخبار”
--------------------------------------------------------------------------------
local function createNewsInterface(parentGui)
    if parentGui:FindFirstChild("NewsInterface") then
        parentGui.NewsInterface:Destroy()
    end

    local frame = Instance.new("Frame")
    frame.Name = "NewsInterface"
    frame.Size = UDim2.new(0, 500, 0, 400)
    frame.Position = UDim2.new(0.5, -250, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.BackgroundTransparency = settings.transparency
    frame.ZIndex = 50
    frame.Parent = parentGui

    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Size = UDim2.new(0,500,0,400),
        Position = UDim2.new(0.5,-250,0.5,-200)
    }):Play()

    -- Title
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0,40)
    title.Position = UDim2.new(0,0,0,0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.TextColor3 = settings.textColor
    title.Text = "📰 الأخبار"
    
    -- Content container
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1,-20,1,-80)
    scroll.Position = UDim2.new(0,10,0,50)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0,10)

    -- لكل خبر، ننشئ إطار
    for i, news in ipairs(newsData) do
        local newsFrame = Instance.new("Frame", scroll)
        newsFrame.Size = UDim2.new(1,0,0,100)
        newsFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
        newsFrame.BackgroundTransparency = 0.2
        newsFrame.ZIndex = 51

        local corner = Instance.new("UICorner", newsFrame)
        corner.CornerRadius = settings.cornerRadius

        -- Title
        local ntitle = Instance.new("TextLabel", newsFrame)
        ntitle.Size = UDim2.new(1,-20,0,25)
        ntitle.Position = UDim2.new(0,10,0,5)
        ntitle.BackgroundTransparency = 1
        ntitle.Font = Enum.Font.GothamBold
        ntitle.TextSize = 20
        ntitle.TextColor3 = settings.accentColor
        ntitle.Text = news.title

        -- Details
        local ndet = Instance.new("TextLabel", newsFrame)
        ndet.Size = UDim2.new(1,-20,0,45)
        ndet.Position = UDim2.new(0,10,0,30)
        ndet.BackgroundTransparency = 1
        ndet.Font = Enum.Font.Gotham
        ndet.TextSize = 16
        ndet.TextColor3 = settings.textColor
        ndet.TextWrapped = true
        ndet.Text = news.details

        -- Timestamp
        local nts = Instance.new("TextLabel", newsFrame)
        nts.Size = UDim2.new(1,-20,0,20)
        nts.Position = UDim2.new(0,10,1,-25)
        nts.BackgroundTransparency = 1
        nts.Font = Enum.Font.GothamItalic
        nts.TextSize = 14
        nts.TextColor3 = Color3.fromRGB(180,180,180)
        nts.TextXAlignment = Enum.TextXAlignment.Right
        nts.Text = news.timestamp

        -- Tween عند الظهور
        newsFrame.Size = UDim2.new(1,0,0,0)
        TweenService:Create(newsFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {Size = UDim2.new(1,0,0,100)}):Play()
    end

    -- زر “Add News” للمدير فقط
    if LocalPlayer.UserId == settings.managerId then
        local addBtn = Instance.new("TextButton", frame)
        addBtn.Size = UDim2.new(0,120,0,40)
        addBtn.Position = UDim2.new(1,-130,1,-50)
        addBtn.BackgroundColor3 = settings.accentColor
        addBtn.Font = Enum.Font.GothamBold
        addBtn.TextSize = 18
        addBtn.TextColor3 = settings.textColor
        addBtn.Text = "➕ إضافة خبر"
        addBtn.ZIndex = 52

        local corner = Instance.new("UICorner", addBtn)
        corner.CornerRadius = settings.cornerRadius

        addBtn.MouseButton1Click:Connect(function()
            -- مثال بسيط: استخدم Prompt لتلقي العنوان والتفاصيل
            showNotification(frame, "برمجة إضافة الأخبار هنا")
            -- في الواقع يمكنك فتح Frame جديد مع TextBoxes وأزرار حفظ
        end)
    end

    return frame
end

--------------------------------------------------------------------------------
-- تعديل createOptionPanel ليضيف زر “News”
--------------------------------------------------------------------------------
local function createOptionPanel(parentGui)
    if parentGui:FindFirstChild("OptionPanel") then
        parentGui.OptionPanel:Destroy()
    end

    local panel = Instance.new("Frame")
    panel.Name = "OptionPanel"
    panel.Size = UDim2.new(0, 200, 0, 140)
    panel.Position = UDim2.new(0.95, -220, 0.5, -70)
    panel.BackgroundColor3 = settings.buttonColor
    panel.BackgroundTransparency = 0.2
    panel.ZIndex = 60
    panel.Parent = parentGui

    local corner = Instance.new("UICorner", panel)
    corner.CornerRadius = settings.cornerRadius

    local function makeBtn(text, ypos, onClick)
        local b = Instance.new("TextButton", panel)
        b.Size = UDim2.new(1,-20,0,40)
        b.Position = UDim2.new(0,10,0,ypos)
        b.BackgroundColor3 = settings.accentColor
        b.Font = Enum.Font.GothamBold
        b.TextSize = 18
        b.TextColor3 = settings.textColor
        b.Text = text
        b.ZIndex = 61
        local c = Instance.new("UICorner", b)
        c.CornerRadius = settings.cornerRadius
        b.MouseButton1Click:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0,200,120)}):Play()
            onClick()
            panel:Destroy()
        end)
        return b
    end

    makeBtn("📂 قائمة السكربتات", 10, function()
        createMainInterface(parentGui)
    end)

    makeBtn("📰 الأخبار", 60, function()
        createNewsInterface(parentGui)
    end)

    makeBtn("ℹ️ معلومات", 110, function()
        createInfoInterface(parentGui)
    end)

    return panel
end

--------------------------------------------------------------------------------
-- الدالة الأساسية Show() لبدء الواجهة
--------------------------------------------------------------------------------
function Luna:Show()
    local gui = LocalPlayer:WaitForChild("PlayerGui")
    createCircularMenu()
    -- يتم فتح OptionPanel عند الضغط على الدائرة
end

--------------------------------------------------------------------------------
-- الدوال القديمة (AddFolder, AddLockedFolder) تبقى كما هي
--------------------------------------------------------------------------------
function Luna:AddFolder(folderData)
    folderData.locked = false
    table.insert(externalFolders, folderData)
end
function Luna:AddLockedFolder(folderData)
    folderData.locked = true
    table.insert(externalFolders, folderData)
end

--------------------------------------------------------------------------------
-- تفعيل إنشاء القائمة الدائرية
--------------------------------------------------------------------------------
local function createCircularMenu()
    if LocalPlayer.PlayerGui:FindFirstChild("CircularMenuGUI") then
        LocalPlayer.PlayerGui.CircularMenuGUI:Destroy()
    end
    local sg = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    sg.Name = "CircularMenuGUI"

    local btn = Instance.new("ImageButton", sg)
    btn.Name = "CircularButton"
    btn.Size = UDim2.new(0,60,0,60)
    btn.Position = UDim2.new(0.95,-30,0.5,-30)
    btn.BackgroundColor3 = settings.accentColor
    btn.Image = "rbxassetid://7059346373"
    btn.ZIndex = 70
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = settings.cornerRadius

    btn.MouseButton1Click:Connect(function()
        createOptionPanel(sg)
    end)
end

return Luna
