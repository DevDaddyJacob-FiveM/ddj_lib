--- Options Fields
---@field x? number X coordinate (0.0-1.0)
---@field y? number Y coordinate (0.0-1.0)
---@field coords? {x: number, y: number} Alternative to x/y
---@field text? string The text to display
---@field colour? {r: number, g: number, b: number, a: number} Text color
---@field scaleX? number X scale
---@field scaleY? number Y scale
---@field scale? {x: number, y: number} Alternative to scaleX/scaleY
---@field font? number Font ID (0-5)
---@field alignment? number Text alignment (0=center, 1=left, 2=right)
---@field outline? boolean Whether to draw text outline
---@field wrap? number Text wrap width
---@field force? boolean Force draw even when pause menu is active

---Draws 2D text on the screen for this frame
---@param drawOptions Options for drawing the text
function drawText2DThisFrame(drawOptions)
	local x = drawOptions.x ~= nil and drawOptions.x or (drawOptions.coords ~= nil and drawOptions.coords.x or 0.5)
	local y = drawOptions.y ~= nil and drawOptions.y or (drawOptions.coords ~= nil and drawOptions.coords.y or 0.8)
	local text = drawOptions.text ~= nil and drawOptions.text or ""
	local colour = drawOptions.colour ~= nil and drawOptions.colour or { r = 255, g = 255, b = 255, a = 255 }
	local scaleX = drawOptions.scaleX ~= nil and drawOptions.scaleX or (drawOptions.scale ~= nil and drawOptions.scale.x or 0.0)
	local scaleY = drawOptions.scaleY ~= nil and drawOptions.scaleY or (drawOptions.scale ~= nil and drawOptions.scale.y or 0.5)
	local font = drawOptions.font ~= nil and drawOptions.font or 4
	local alignment = drawOptions.alignment ~= nil and drawOptions.alignment or 0
	local outline = drawOptions.outline ~= nil and drawOptions.outline or true
	local wrap = drawOptions.wrap ~= nil and drawOptions.wrap or 0
	local force = drawOptions.force ~= nil and drawOptions.force or false

	if (force == false and IsPauseMenuActive()) or text == nil or text == "" then
		return
	end

	local height = 1080.0
	local resWidth, resHeight = GetScreenActiveResolution()
	local ratio = resWidth / resHeight
	local width = height * ratio

	SetTextFont(font)
	SetTextScale(scaleX, scaleY)
	SetTextColour(colour.r, colour.g, colour.b, colour.a)

	if outline == true then
		SetTextOutline()
	end

	if wrap ~= 0 then
		SetTextWrap(x, (x + wrap) / width)
	end

	if alignment == 0 then
		SetTextCentre(true)
	elseif alignment == 2 then
		SetTextRightJustify(true)
		SetTextWrap(0, x)
	end

	BeginTextCommandDisplayText("jamyfafi")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(x, y)
end