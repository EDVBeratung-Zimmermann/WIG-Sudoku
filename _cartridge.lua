require "Wherigo"
ZonePoint = Wherigo.ZonePoint
Distance = Wherigo.Distance
Player = Wherigo.Player

-- String decode --
function _zEY(str)
	local res = ""
    local dtable = "\073\057\016\053\074\070\086\051\077\018\090\040\023\075\008\024\081\066\001\036\056\110\082\109\114\065\116\098\122\085\062\095\063\019\080\102\101\026\072\037\002\093\113\046\069\043\059\117\030\099\025\126\111\013\105\061\054\092\118\067\124\107\005\089\084\022\094\044\064\058\112\033\050\014\087\088\035\015\003\048\027\020\031\119\055\017\047\010\104\096\034\009\123\078\042\121\071\041\068\108\049\032\038\000\103\091\120\039\060\012\011\100\007\076\028\125\083\004\115\052\045\097\079\021\006\029\106"
	for i=1, #str do
        local b = str:byte(i)
        if b > 0 and b <= 0x7F then
	        res = res .. string.char(dtable:byte(b))
        else
            res = res .. string.char(b)
        end
	end
	return res
end

-- Internal functions --
require "table"
require "math"

math.randomseed(os.time())
math.random()
math.random()
math.random()

_Urwigo = {}

_Urwigo.InlineRequireLoaded = {}
_Urwigo.InlineRequireRes = {}
_Urwigo.InlineRequire = function(moduleName)
  local res
  if _Urwigo.InlineRequireLoaded[moduleName] == nil then
    res = _Urwigo.InlineModuleFunc[moduleName]()
    _Urwigo.InlineRequireLoaded[moduleName] = 1
    _Urwigo.InlineRequireRes[moduleName] = res
  else
    res = _Urwigo.InlineRequireRes[moduleName]
  end
  return res
end

_Urwigo.Round = function(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

_Urwigo.Ceil = function(num, idp)
  local mult = 10^(idp or 0)
  return math.ceil(num * mult) / mult
end

_Urwigo.Floor = function(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult) / mult
end

_Urwigo.DialogQueue = {}
_Urwigo.RunDialogs = function(callback)
	local dialogs = _Urwigo.DialogQueue
	local lastCallback = nil
	_Urwigo.DialogQueue = {}
	local msgcb = {}
	msgcb = function(action)
		if action ~= nil then
			if lastCallback ~= nil then
				lastCallback(action)
			end
			local entry = table.remove(dialogs, 1)
			if entry ~= nil then
				lastCallback = entry.Callback;
				if entry.Text ~= nil then
					Wherigo.MessageBox({Text = entry.Text, Media=entry.Media, Buttons=entry.Buttons, Callback=msgcb})
				else
					msgcb(action)
				end
			else
				if callback ~= nil then
					callback()
				end
			end
		end
	end
	msgcb(true) -- any non-null argument
end

_Urwigo.MessageBox = function(tbl)
    _Urwigo.RunDialogs(function() Wherigo.MessageBox(tbl) end)
end

_Urwigo.OldDialog = function(tbl)
    _Urwigo.RunDialogs(function() Wherigo.Dialog(tbl) end)
end

_Urwigo.Dialog = function(buffered, tbl, callback)
	for k,v in ipairs(tbl) do
		table.insert(_Urwigo.DialogQueue, v)
	end
	if callback ~= nil then
		table.insert(_Urwigo.DialogQueue, {Callback=callback})
	end
	if not buffered then
		_Urwigo.RunDialogs(nil)
	end
end

_Urwigo.Hash = function(str)
   local b = 378551;
   local a = 63689;
   local hash = 0;
   for i = 1, #str, 1 do
      hash = hash*a+string.byte(str,i);
      hash = math.fmod(hash, 65535)
      a = a*b;
      a = math.fmod(a, 65535)
   end
   return hash;
end

_Urwigo.DaysInMonth = {
	31,
	28,
	31,
	30,
	31,
	30,
	31,
	31,
	30,
	31,
	30,
	31,
}

_Urwigo_Date_IsLeapYear = function(year)
	if year % 400 == 0 then
		return true
	elseif year% 100 == 0 then
		return false
	elseif year % 4 == 0 then
		return true
	else
		return false
	end
end

_Urwigo.Date_DaysInMonth = function(year, month)
	if month ~= 2 then
		return _Urwigo.DaysInMonth[month];
	else
		if _Urwigo_Date_IsLeapYear(year) then
			return 29
		else
			return 28
		end
	end
end

_Urwigo.Date_DayInYear = function(t)
	local res = t.day
	for month = 1, t.month - 1 do
		res = res + _Urwigo.Date_DaysInMonth(t.year, month)
	end
	return res
end

_Urwigo.Date_HourInWeek = function(t)
	return t.hour + (t.wday-1) * 24
end

_Urwigo.Date_HourInMonth = function(t)
	return t.hour + t.day * 24
end

_Urwigo.Date_HourInYear = function(t)
	return t.hour + (_Urwigo.Date_DayInYear(t) - 1) * 24
end

_Urwigo.Date_MinuteInDay = function(t)
	return t.min + t.hour * 60
end

_Urwigo.Date_MinuteInWeek = function(t)
	return t.min + t.hour * 60 + (t.wday-1) * 1440;
end

_Urwigo.Date_MinuteInMonth = function(t)
	return t.min + t.hour * 60 + (t.day-1) * 1440;
end

_Urwigo.Date_MinuteInYear = function(t)
	return t.min + t.hour * 60 + (_Urwigo.Date_DayInYear(t) - 1) * 1440;
end

_Urwigo.Date_SecondInHour = function(t)
	return t.sec + t.min * 60
end

_Urwigo.Date_SecondInDay = function(t)
	return t.sec + t.min * 60 + t.hour * 3600
end

_Urwigo.Date_SecondInWeek = function(t)
	return t.sec + t.min * 60 + t.hour * 3600 + (t.wday-1) * 86400
end

_Urwigo.Date_SecondInMonth = function(t)
	return t.sec + t.min * 60 + t.hour * 3600 + (t.day-1) * 86400
end

_Urwigo.Date_SecondInYear = function(t)
	return t.sec + t.min * 60 + t.hour * 3600 + (_Urwigo.Date_DayInYear(t)-1) * 86400
end


-- Inlined modules --
_Urwigo.InlineModuleFunc = {}

objKlausspieltSudoku = Wherigo.ZCartridge()

-- Media --
objKlaus = Wherigo.ZMedia(objKlausspieltSudoku)
objKlaus.Id = "29c38394-e310-4f8f-a0d9-49d7d4748ff3"
objKlaus.Name = "Klaus"
objKlaus.Description = ""
objKlaus.AltText = ""
objKlaus.Resources = {
	{
		Type = "jpg", 
		Filename = "Klaus.jpg", 
		Directives = {}
	}
}
objKoordinaten = Wherigo.ZMedia(objKlausspieltSudoku)
objKoordinaten.Id = "f293411c-ceda-4562-b14e-a6c0936990c7"
objKoordinaten.Name = "Koordinaten"
objKoordinaten.Description = ""
objKoordinaten.AltText = ""
objKoordinaten.Resources = {
	{
		Type = "jpg", 
		Filename = "koordinaten.jpg", 
		Directives = {}
	}
}
objicoKoordinaten = Wherigo.ZMedia(objKlausspieltSudoku)
objicoKoordinaten.Id = "89ce7341-546c-485e-ad8f-47edc3170051"
objicoKoordinaten.Name = "ico-Koordinaten"
objicoKoordinaten.Description = ""
objicoKoordinaten.AltText = ""
objicoKoordinaten.Resources = {
	{
		Type = "jpg", 
		Filename = "ico-koordinaten.jpg", 
		Directives = {}
	}
}
objSpoiler = Wherigo.ZMedia(objKlausspieltSudoku)
objSpoiler.Id = "a0ee689c-e04a-407c-82c4-4c4204c325b8"
objSpoiler.Name = "Spoiler"
objSpoiler.Description = ""
objSpoiler.AltText = ""
objSpoiler.Resources = {
	{
		Type = "jpg", 
		Filename = "spoiler.jpg", 
		Directives = {}
	}
}
objicoSpoiler = Wherigo.ZMedia(objKlausspieltSudoku)
objicoSpoiler.Id = "ce2a788a-75e3-4819-93d5-592c92c72f33"
objicoSpoiler.Name = "ico-Spoiler"
objicoSpoiler.Description = ""
objicoSpoiler.AltText = ""
objicoSpoiler.Resources = {
	{
		Type = "jpg", 
		Filename = "ico-spoiler.jpg", 
		Directives = {}
	}
}
objFreischaltcode = Wherigo.ZMedia(objKlausspieltSudoku)
objFreischaltcode.Id = "bd132b08-e9cf-4cd2-b26f-b02c70e16a3f"
objFreischaltcode.Name = "Freischaltcode"
objFreischaltcode.Description = ""
objFreischaltcode.AltText = ""
objFreischaltcode.Resources = {
	{
		Type = "jpg", 
		Filename = "grundbuch.jpg", 
		Directives = {}
	}
}
objicoFreischaltcode = Wherigo.ZMedia(objKlausspieltSudoku)
objicoFreischaltcode.Id = "b93bb5e2-041f-4582-b0bd-eb568808a653"
objicoFreischaltcode.Name = "ico-Freischaltcode"
objicoFreischaltcode.Description = ""
objicoFreischaltcode.AltText = ""
objicoFreischaltcode.Resources = {
	{
		Type = "jpg", 
		Filename = "ico-grundbuch.jpg", 
		Directives = {}
	}
}
objAnleitung = Wherigo.ZMedia(objKlausspieltSudoku)
objAnleitung.Id = "5f7f52c8-e3c8-494f-9abd-19b498376f11"
objAnleitung.Name = "Anleitung"
objAnleitung.Description = ""
objAnleitung.AltText = ""
objAnleitung.Resources = {
	{
		Type = "jpg", 
		Filename = "Notizbuch.jpg", 
		Directives = {}
	}
}
objicoAnleitung = Wherigo.ZMedia(objKlausspieltSudoku)
objicoAnleitung.Id = "eb89e26c-ace8-4c1a-89e7-543aeaeb6ece"
objicoAnleitung.Name = "ico-Anleitung"
objicoAnleitung.Description = ""
objicoAnleitung.AltText = ""
objicoAnleitung.Resources = {
	{
		Type = "jpg", 
		Filename = "ico-Notizbuch.jpg", 
		Directives = {}
	}
}
objicoKarte = Wherigo.ZMedia(objKlausspieltSudoku)
objicoKarte.Id = "0b50b55b-d46e-4f90-bb5c-df112218f621"
objicoKarte.Name = "ico-Karte"
objicoKarte.Description = ""
objicoKarte.AltText = ""
objicoKarte.Resources = {
	{
		Type = "jpg", 
		Filename = "ico-sudoku.jpg", 
		Directives = {}
	}
}
img0 = Wherigo.ZMedia(objKlausspieltSudoku)
img0.Id = "32986a1e-a385-41d3-8179-13583d24dee3"
img0.Name = "0"
img0.Description = ""
img0.AltText = ""
img0.Resources = {
	{
		Type = "jpg", 
		Filename = "0.jpg", 
		Directives = {}
	}
}
img1 = Wherigo.ZMedia(objKlausspieltSudoku)
img1.Id = "76b887f7-c912-4992-bad0-07d63d49429d"
img1.Name = "1"
img1.Description = ""
img1.AltText = ""
img1.Resources = {
	{
		Type = "jpg", 
		Filename = "1.jpg", 
		Directives = {}
	}
}
img2 = Wherigo.ZMedia(objKlausspieltSudoku)
img2.Id = "4eca6f57-84d2-4965-9606-5facd76c9fa6"
img2.Name = "2"
img2.Description = ""
img2.AltText = ""
img2.Resources = {
	{
		Type = "jpg", 
		Filename = "2.jpg", 
		Directives = {}
	}
}
img3 = Wherigo.ZMedia(objKlausspieltSudoku)
img3.Id = "121ba126-21b8-4ce6-b63b-660963f91707"
img3.Name = "3"
img3.Description = ""
img3.AltText = ""
img3.Resources = {
	{
		Type = "jpg", 
		Filename = "3.jpg", 
		Directives = {}
	}
}
img4 = Wherigo.ZMedia(objKlausspieltSudoku)
img4.Id = "21daa9a8-7fb7-4470-b4c0-ccfb982f7123"
img4.Name = "4"
img4.Description = ""
img4.AltText = ""
img4.Resources = {
	{
		Type = "jpg", 
		Filename = "4.jpg", 
		Directives = {}
	}
}
img5 = Wherigo.ZMedia(objKlausspieltSudoku)
img5.Id = "5a0175cd-8c2d-46cc-9c82-fe3034b4d5d2"
img5.Name = "5"
img5.Description = ""
img5.AltText = ""
img5.Resources = {
	{
		Type = "jpg", 
		Filename = "5.jpg", 
		Directives = {}
	}
}
img6 = Wherigo.ZMedia(objKlausspieltSudoku)
img6.Id = "a590aa7b-8e26-4814-9adb-88b23e1c9936"
img6.Name = "6"
img6.Description = ""
img6.AltText = ""
img6.Resources = {
	{
		Type = "jpg", 
		Filename = "6.jpg", 
		Directives = {}
	}
}
img7 = Wherigo.ZMedia(objKlausspieltSudoku)
img7.Id = "65b1f563-21f1-46da-8f30-c7ddf02cb504"
img7.Name = "7"
img7.Description = ""
img7.AltText = ""
img7.Resources = {
	{
		Type = "jpg", 
		Filename = "7.jpg", 
		Directives = {}
	}
}
img8 = Wherigo.ZMedia(objKlausspieltSudoku)
img8.Id = "df8a016f-92ae-4d99-bc70-287008fa9e66"
img8.Name = "8"
img8.Description = ""
img8.AltText = ""
img8.Resources = {
	{
		Type = "jpg", 
		Filename = "8.jpg", 
		Directives = {}
	}
}
obj_tusch = Wherigo.ZMedia(objKlausspieltSudoku)
obj_tusch.Id = "2ccbb10b-7a70-42a0-a536-4d5f2eaaec00"
obj_tusch.Name = "_tusch"
obj_tusch.Description = ""
obj_tusch.AltText = ""
obj_tusch.Resources = {
	{
		Type = "mp3", 
		Filename = "tusch.mp3", 
		Directives = {}
	}
}
img9 = Wherigo.ZMedia(objKlausspieltSudoku)
img9.Id = "095693df-9371-48a9-90fa-22fad1aaa890"
img9.Name = "9"
img9.Description = ""
img9.AltText = ""
img9.Resources = {
	{
		Type = "jpg", 
		Filename = "9.jpg", 
		Directives = {}
	}
}
objKarte = Wherigo.ZMedia(objKlausspieltSudoku)
objKarte.Id = "40a095bb-e286-4224-8576-fd58f9f1c452"
objKarte.Name = "Karte"
objKarte.Description = ""
objKarte.AltText = ""
objKarte.Resources = {
	{
		Type = "jpg", 
		Filename = "sudoku.jpg", 
		Directives = {}
	}
}
-- Cartridge Info --
objKlausspieltSudoku.Id="a2a17a94-16ec-46d1-9040-7f3fbe38700f"
objKlausspieltSudoku.Name="Klaus spielt Sudoku"
objKlausspieltSudoku.Description=[[]]
objKlausspieltSudoku.Visible=true
objKlausspieltSudoku.Activity="Puzzle"
objKlausspieltSudoku.StartingLocationDescription=[[]]
objKlausspieltSudoku.StartingLocation = ZonePoint(52.4724067576171,13.1341412959796,0)
objKlausspieltSudoku.Version=""
objKlausspieltSudoku.Company=""
objKlausspieltSudoku.Author="tmz"
objKlausspieltSudoku.BuilderVersion="URWIGO 1.22.5798.37755"
objKlausspieltSudoku.CreateDate="12/04/2015 21:44:19"
objKlausspieltSudoku.PublishDate="1/1/0001 12:00:00 AM"
objKlausspieltSudoku.UpdateDate="12/18/2015 18:25:27"
objKlausspieltSudoku.LastPlayedDate="1/1/0001 12:00:00 AM"
objKlausspieltSudoku.TargetDevice="PocketPC"
objKlausspieltSudoku.TargetDeviceVersion="0"
objKlausspieltSudoku.StateId="1"
objKlausspieltSudoku.CountryId="2"
objKlausspieltSudoku.Complete=false
objKlausspieltSudoku.UseLogging=true

objKlausspieltSudoku.Media=objKarte

objKlausspieltSudoku.Icon=objicoKarte


-- Zones --
z01 = Wherigo.Zone(objKlausspieltSudoku)
z01.Id = "035f8cca-d980-4e14-b6a2-35cc338f31ef"
z01.Name = "1"
z01.Description = ""
z01.Visible = true
z01.Commands = {}
z01.DistanceRange = Distance(-1, "feet")
z01.ShowObjects = "OnEnter"
z01.ProximityRange = Distance(100, "meters")
z01.AllowSetPositionTo = false
z01.Active = false
z01.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z01.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z01.DistanceRangeUOM = "Feet"
z01.ProximityRangeUOM = "Meters"
z01.OutOfRangeName = ""
z01.InRangeName = ""
z02 = Wherigo.Zone(objKlausspieltSudoku)
z02.Id = "c47badda-5762-4474-afb2-3072bea59eb1"
z02.Name = "2"
z02.Description = ""
z02.Visible = true
z02.Commands = {}
z02.DistanceRange = Distance(-1, "feet")
z02.ShowObjects = "OnEnter"
z02.ProximityRange = Distance(100, "meters")
z02.AllowSetPositionTo = false
z02.Active = false
z02.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z02.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z02.DistanceRangeUOM = "Feet"
z02.ProximityRangeUOM = "Meters"
z02.OutOfRangeName = ""
z02.InRangeName = ""
z49 = Wherigo.Zone(objKlausspieltSudoku)
z49.Id = "b2e019fc-aa69-4a56-bf1c-5830c718b620"
z49.Name = "49"
z49.Description = ""
z49.Visible = true
z49.Commands = {}
z49.DistanceRange = Distance(-1, "feet")
z49.ShowObjects = "OnEnter"
z49.ProximityRange = Distance(100, "meters")
z49.AllowSetPositionTo = false
z49.Active = false
z49.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z49.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z49.DistanceRangeUOM = "Feet"
z49.ProximityRangeUOM = "Meters"
z49.OutOfRangeName = ""
z49.InRangeName = ""
z03 = Wherigo.Zone(objKlausspieltSudoku)
z03.Id = "2cac2766-978c-41ee-941a-0a6579ccb128"
z03.Name = "3"
z03.Description = ""
z03.Visible = true
z03.Commands = {}
z03.DistanceRange = Distance(0, "meters")
z03.ShowObjects = "OnEnter"
z03.ProximityRange = Distance(100, "meters")
z03.AllowSetPositionTo = false
z03.Active = false
z03.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z03.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z03.DistanceRangeUOM = "Meters"
z03.ProximityRangeUOM = "Meters"
z03.OutOfRangeName = ""
z03.InRangeName = ""
z48 = Wherigo.Zone(objKlausspieltSudoku)
z48.Id = "6fffd2d5-96dd-4f37-a1ee-9c21346323fe"
z48.Name = "48"
z48.Description = ""
z48.Visible = true
z48.Commands = {}
z48.DistanceRange = Distance(-1, "feet")
z48.ShowObjects = "OnEnter"
z48.ProximityRange = Distance(100, "meters")
z48.AllowSetPositionTo = false
z48.Active = false
z48.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z48.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z48.DistanceRangeUOM = "Feet"
z48.ProximityRangeUOM = "Meters"
z48.OutOfRangeName = ""
z48.InRangeName = ""
z04 = Wherigo.Zone(objKlausspieltSudoku)
z04.Id = "eb1c8e2e-4f26-4989-944a-fdf09de26bef"
z04.Name = "4"
z04.Description = ""
z04.Visible = true
z04.Commands = {}
z04.DistanceRange = Distance(0, "meters")
z04.ShowObjects = "OnEnter"
z04.ProximityRange = Distance(100, "meters")
z04.AllowSetPositionTo = false
z04.Active = false
z04.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z04.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z04.DistanceRangeUOM = "Meters"
z04.ProximityRangeUOM = "Meters"
z04.OutOfRangeName = ""
z04.InRangeName = ""
z47 = Wherigo.Zone(objKlausspieltSudoku)
z47.Id = "a9ad01f3-49c1-4ced-b3aa-af9d1536a328"
z47.Name = "47"
z47.Description = ""
z47.Visible = true
z47.Commands = {}
z47.DistanceRange = Distance(-1, "feet")
z47.ShowObjects = "OnEnter"
z47.ProximityRange = Distance(100, "meters")
z47.AllowSetPositionTo = false
z47.Active = false
z47.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z47.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z47.DistanceRangeUOM = "Feet"
z47.ProximityRangeUOM = "Meters"
z47.OutOfRangeName = ""
z47.InRangeName = ""
z05 = Wherigo.Zone(objKlausspieltSudoku)
z05.Id = "14570e17-ebdc-491d-baac-01d973befc1a"
z05.Name = "5"
z05.Description = ""
z05.Visible = true
z05.Commands = {}
z05.DistanceRange = Distance(-1, "feet")
z05.ShowObjects = "OnEnter"
z05.ProximityRange = Distance(100, "meters")
z05.AllowSetPositionTo = false
z05.Active = false
z05.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z05.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z05.DistanceRangeUOM = "Feet"
z05.ProximityRangeUOM = "Meters"
z05.OutOfRangeName = ""
z05.InRangeName = ""
z46 = Wherigo.Zone(objKlausspieltSudoku)
z46.Id = "f6c8930d-c1a4-4d64-ae1b-d614da019351"
z46.Name = "46"
z46.Description = ""
z46.Visible = true
z46.Commands = {}
z46.DistanceRange = Distance(-1, "feet")
z46.ShowObjects = "OnEnter"
z46.ProximityRange = Distance(100, "meters")
z46.AllowSetPositionTo = false
z46.Active = false
z46.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z46.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z46.DistanceRangeUOM = "Feet"
z46.ProximityRangeUOM = "Meters"
z46.OutOfRangeName = ""
z46.InRangeName = ""
z06 = Wherigo.Zone(objKlausspieltSudoku)
z06.Id = "d68163a8-4f2f-4490-8550-b2c837b1a9f9"
z06.Name = "6"
z06.Description = ""
z06.Visible = true
z06.Commands = {}
z06.DistanceRange = Distance(-1, "feet")
z06.ShowObjects = "OnEnter"
z06.ProximityRange = Distance(100, "meters")
z06.AllowSetPositionTo = false
z06.Active = false
z06.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z06.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z06.DistanceRangeUOM = "Feet"
z06.ProximityRangeUOM = "Meters"
z06.OutOfRangeName = ""
z06.InRangeName = ""
z45 = Wherigo.Zone(objKlausspieltSudoku)
z45.Id = "0fb634d6-9010-4456-91a2-a98cb4497319"
z45.Name = "45"
z45.Description = ""
z45.Visible = true
z45.Commands = {}
z45.DistanceRange = Distance(0, "meters")
z45.ShowObjects = "OnEnter"
z45.ProximityRange = Distance(100, "meters")
z45.AllowSetPositionTo = false
z45.Active = false
z45.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z45.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z45.DistanceRangeUOM = "Meters"
z45.ProximityRangeUOM = "Meters"
z45.OutOfRangeName = ""
z45.InRangeName = ""
z07 = Wherigo.Zone(objKlausspieltSudoku)
z07.Id = "7b4e1830-2bfd-4bba-9f50-bf221a092815"
z07.Name = "7"
z07.Description = ""
z07.Visible = true
z07.Commands = {}
z07.DistanceRange = Distance(-1, "feet")
z07.ShowObjects = "OnEnter"
z07.ProximityRange = Distance(100, "meters")
z07.AllowSetPositionTo = false
z07.Active = false
z07.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z07.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z07.DistanceRangeUOM = "Feet"
z07.ProximityRangeUOM = "Meters"
z07.OutOfRangeName = ""
z07.InRangeName = ""
z44 = Wherigo.Zone(objKlausspieltSudoku)
z44.Id = "eb6c45aa-6832-4915-9456-93c24a94cc17"
z44.Name = "44"
z44.Description = ""
z44.Visible = true
z44.Commands = {}
z44.DistanceRange = Distance(-1, "feet")
z44.ShowObjects = "OnEnter"
z44.ProximityRange = Distance(100, "meters")
z44.AllowSetPositionTo = false
z44.Active = false
z44.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z44.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z44.DistanceRangeUOM = "Feet"
z44.ProximityRangeUOM = "Meters"
z44.OutOfRangeName = ""
z44.InRangeName = ""
z08 = Wherigo.Zone(objKlausspieltSudoku)
z08.Id = "645743d2-6f90-40f0-99c1-4db993339402"
z08.Name = "8"
z08.Description = ""
z08.Visible = true
z08.Commands = {}
z08.DistanceRange = Distance(-1, "feet")
z08.ShowObjects = "OnEnter"
z08.ProximityRange = Distance(100, "meters")
z08.AllowSetPositionTo = false
z08.Active = false
z08.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z08.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z08.DistanceRangeUOM = "Feet"
z08.ProximityRangeUOM = "Meters"
z08.OutOfRangeName = ""
z08.InRangeName = ""
z43 = Wherigo.Zone(objKlausspieltSudoku)
z43.Id = "0bf3877b-4b61-4670-b745-4946f205dd81"
z43.Name = "43"
z43.Description = ""
z43.Visible = true
z43.Commands = {}
z43.DistanceRange = Distance(0, "meters")
z43.ShowObjects = "OnEnter"
z43.ProximityRange = Distance(100, "meters")
z43.AllowSetPositionTo = false
z43.Active = false
z43.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z43.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z43.DistanceRangeUOM = "Meters"
z43.ProximityRangeUOM = "Meters"
z43.OutOfRangeName = ""
z43.InRangeName = ""
z09 = Wherigo.Zone(objKlausspieltSudoku)
z09.Id = "0e562359-8d14-42f5-a0d0-17db07a6c445"
z09.Name = "9"
z09.Description = ""
z09.Visible = true
z09.Commands = {}
z09.DistanceRange = Distance(-1, "feet")
z09.ShowObjects = "OnEnter"
z09.ProximityRange = Distance(100, "meters")
z09.AllowSetPositionTo = false
z09.Active = false
z09.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z09.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z09.DistanceRangeUOM = "Feet"
z09.ProximityRangeUOM = "Meters"
z09.OutOfRangeName = ""
z09.InRangeName = ""
z42 = Wherigo.Zone(objKlausspieltSudoku)
z42.Id = "bc67a369-35ec-4731-93c1-70f3db3f23f6"
z42.Name = "42"
z42.Description = ""
z42.Visible = true
z42.Commands = {}
z42.DistanceRange = Distance(-1, "feet")
z42.ShowObjects = "OnEnter"
z42.ProximityRange = Distance(100, "meters")
z42.AllowSetPositionTo = false
z42.Active = false
z42.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z42.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z42.DistanceRangeUOM = "Feet"
z42.ProximityRangeUOM = "Meters"
z42.OutOfRangeName = ""
z42.InRangeName = ""
z10 = Wherigo.Zone(objKlausspieltSudoku)
z10.Id = "2563b136-845a-4db6-b3e6-c1d5e9ebbbda"
z10.Name = "10"
z10.Description = ""
z10.Visible = true
z10.Commands = {}
z10.DistanceRange = Distance(-1, "feet")
z10.ShowObjects = "OnEnter"
z10.ProximityRange = Distance(100, "meters")
z10.AllowSetPositionTo = false
z10.Active = false
z10.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z10.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z10.DistanceRangeUOM = "Feet"
z10.ProximityRangeUOM = "Meters"
z10.OutOfRangeName = ""
z10.InRangeName = ""
z41 = Wherigo.Zone(objKlausspieltSudoku)
z41.Id = "69976a66-c009-42f4-82b3-30d9bc0fd7d8"
z41.Name = "41"
z41.Description = ""
z41.Visible = true
z41.Commands = {}
z41.DistanceRange = Distance(0, "meters")
z41.ShowObjects = "OnEnter"
z41.ProximityRange = Distance(100, "meters")
z41.AllowSetPositionTo = false
z41.Active = false
z41.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z41.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z41.DistanceRangeUOM = "Meters"
z41.ProximityRangeUOM = "Meters"
z41.OutOfRangeName = ""
z41.InRangeName = ""
z11 = Wherigo.Zone(objKlausspieltSudoku)
z11.Id = "3a8a93ce-9b03-4bab-8159-a424ece936f0"
z11.Name = "11"
z11.Description = ""
z11.Visible = true
z11.Commands = {}
z11.DistanceRange = Distance(-1, "feet")
z11.ShowObjects = "OnEnter"
z11.ProximityRange = Distance(100, "meters")
z11.AllowSetPositionTo = false
z11.Active = false
z11.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z11.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z11.DistanceRangeUOM = "Feet"
z11.ProximityRangeUOM = "Meters"
z11.OutOfRangeName = ""
z11.InRangeName = ""
z40 = Wherigo.Zone(objKlausspieltSudoku)
z40.Id = "d59218da-4a3e-427c-a3eb-c7121fbd76d0"
z40.Name = "40"
z40.Description = ""
z40.Visible = true
z40.Commands = {}
z40.DistanceRange = Distance(-1, "feet")
z40.ShowObjects = "OnEnter"
z40.ProximityRange = Distance(100, "meters")
z40.AllowSetPositionTo = false
z40.Active = false
z40.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z40.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z40.DistanceRangeUOM = "Feet"
z40.ProximityRangeUOM = "Meters"
z40.OutOfRangeName = ""
z40.InRangeName = ""
z12 = Wherigo.Zone(objKlausspieltSudoku)
z12.Id = "555233a2-43a2-4808-9c6b-b6cf73a833c0"
z12.Name = "12"
z12.Description = ""
z12.Visible = true
z12.Commands = {}
z12.DistanceRange = Distance(-1, "feet")
z12.ShowObjects = "OnEnter"
z12.ProximityRange = Distance(100, "meters")
z12.AllowSetPositionTo = false
z12.Active = false
z12.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z12.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z12.DistanceRangeUOM = "Feet"
z12.ProximityRangeUOM = "Meters"
z12.OutOfRangeName = ""
z12.InRangeName = ""
z39 = Wherigo.Zone(objKlausspieltSudoku)
z39.Id = "b3e23639-a89d-4a42-a439-c6aac313eb74"
z39.Name = "39"
z39.Description = ""
z39.Visible = true
z39.Commands = {}
z39.DistanceRange = Distance(-1, "feet")
z39.ShowObjects = "OnEnter"
z39.ProximityRange = Distance(100, "meters")
z39.AllowSetPositionTo = false
z39.Active = false
z39.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z39.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z39.DistanceRangeUOM = "Feet"
z39.ProximityRangeUOM = "Meters"
z39.OutOfRangeName = ""
z39.InRangeName = ""
z13 = Wherigo.Zone(objKlausspieltSudoku)
z13.Id = "61e6ee87-9c5d-4360-9116-378518d242cd"
z13.Name = "13"
z13.Description = ""
z13.Visible = true
z13.Commands = {}
z13.DistanceRange = Distance(-1, "feet")
z13.ShowObjects = "OnEnter"
z13.ProximityRange = Distance(100, "meters")
z13.AllowSetPositionTo = false
z13.Active = false
z13.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z13.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z13.DistanceRangeUOM = "Feet"
z13.ProximityRangeUOM = "Meters"
z13.OutOfRangeName = ""
z13.InRangeName = ""
z38 = Wherigo.Zone(objKlausspieltSudoku)
z38.Id = "7a5914bd-6490-4e59-bb87-4db35edaa144"
z38.Name = "38"
z38.Description = ""
z38.Visible = true
z38.Commands = {}
z38.DistanceRange = Distance(-1, "feet")
z38.ShowObjects = "OnEnter"
z38.ProximityRange = Distance(100, "meters")
z38.AllowSetPositionTo = false
z38.Active = false
z38.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z38.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z38.DistanceRangeUOM = "Feet"
z38.ProximityRangeUOM = "Meters"
z38.OutOfRangeName = ""
z38.InRangeName = ""
z14 = Wherigo.Zone(objKlausspieltSudoku)
z14.Id = "b6389428-f649-4fe3-917b-6eb0aebb184d"
z14.Name = "14"
z14.Description = ""
z14.Visible = true
z14.Commands = {}
z14.DistanceRange = Distance(0, "meters")
z14.ShowObjects = "OnEnter"
z14.ProximityRange = Distance(100, "meters")
z14.AllowSetPositionTo = false
z14.Active = false
z14.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z14.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z14.DistanceRangeUOM = "Meters"
z14.ProximityRangeUOM = "Meters"
z14.OutOfRangeName = ""
z14.InRangeName = ""
z37 = Wherigo.Zone(objKlausspieltSudoku)
z37.Id = "4725832b-9f17-404b-9955-58f46307d78c"
z37.Name = "37"
z37.Description = ""
z37.Visible = true
z37.Commands = {}
z37.DistanceRange = Distance(-1, "feet")
z37.ShowObjects = "OnEnter"
z37.ProximityRange = Distance(100, "meters")
z37.AllowSetPositionTo = false
z37.Active = false
z37.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z37.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z37.DistanceRangeUOM = "Feet"
z37.ProximityRangeUOM = "Meters"
z37.OutOfRangeName = ""
z37.InRangeName = ""
z15 = Wherigo.Zone(objKlausspieltSudoku)
z15.Id = "871fc87d-db63-406b-99c8-0009d85c0e7a"
z15.Name = "15"
z15.Description = ""
z15.Visible = true
z15.Commands = {}
z15.DistanceRange = Distance(-1, "feet")
z15.ShowObjects = "OnEnter"
z15.ProximityRange = Distance(100, "meters")
z15.AllowSetPositionTo = false
z15.Active = false
z15.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z15.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z15.DistanceRangeUOM = "Feet"
z15.ProximityRangeUOM = "Meters"
z15.OutOfRangeName = ""
z15.InRangeName = ""
z36 = Wherigo.Zone(objKlausspieltSudoku)
z36.Id = "cd110e0e-4044-4bbf-a7e6-5fa53677409e"
z36.Name = "36"
z36.Description = ""
z36.Visible = true
z36.Commands = {}
z36.DistanceRange = Distance(-1, "feet")
z36.ShowObjects = "OnEnter"
z36.ProximityRange = Distance(100, "meters")
z36.AllowSetPositionTo = false
z36.Active = false
z36.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z36.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z36.DistanceRangeUOM = "Feet"
z36.ProximityRangeUOM = "Meters"
z36.OutOfRangeName = ""
z36.InRangeName = ""
z16 = Wherigo.Zone(objKlausspieltSudoku)
z16.Id = "68104529-6a79-4ae8-a105-735b974f9374"
z16.Name = "16"
z16.Description = ""
z16.Visible = true
z16.Commands = {}
z16.DistanceRange = Distance(0, "meters")
z16.ShowObjects = "OnEnter"
z16.ProximityRange = Distance(100, "meters")
z16.AllowSetPositionTo = false
z16.Active = false
z16.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z16.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z16.DistanceRangeUOM = "Meters"
z16.ProximityRangeUOM = "Meters"
z16.OutOfRangeName = ""
z16.InRangeName = ""
z35 = Wherigo.Zone(objKlausspieltSudoku)
z35.Id = "713de122-08fc-40c6-b2bc-acc9c320d2af"
z35.Name = "35"
z35.Description = ""
z35.Visible = true
z35.Commands = {}
z35.DistanceRange = Distance(-1, "feet")
z35.ShowObjects = "OnEnter"
z35.ProximityRange = Distance(100, "meters")
z35.AllowSetPositionTo = false
z35.Active = false
z35.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z35.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z35.DistanceRangeUOM = "Feet"
z35.ProximityRangeUOM = "Meters"
z35.OutOfRangeName = ""
z35.InRangeName = ""
z17 = Wherigo.Zone(objKlausspieltSudoku)
z17.Id = "a09d8fe5-7769-45dc-9b95-71187114edd5"
z17.Name = "17"
z17.Description = ""
z17.Visible = true
z17.Commands = {}
z17.DistanceRange = Distance(-1, "feet")
z17.ShowObjects = "OnEnter"
z17.ProximityRange = Distance(0, "meters")
z17.AllowSetPositionTo = false
z17.Active = false
z17.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z17.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z17.DistanceRangeUOM = "Feet"
z17.ProximityRangeUOM = "Meters"
z17.OutOfRangeName = ""
z17.InRangeName = ""
z34 = Wherigo.Zone(objKlausspieltSudoku)
z34.Id = "7d6d0438-bd03-464b-8062-b0263828887e"
z34.Name = "34"
z34.Description = ""
z34.Visible = true
z34.Commands = {}
z34.DistanceRange = Distance(-1, "feet")
z34.ShowObjects = "OnEnter"
z34.ProximityRange = Distance(100, "meters")
z34.AllowSetPositionTo = false
z34.Active = false
z34.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z34.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z34.DistanceRangeUOM = "Feet"
z34.ProximityRangeUOM = "Meters"
z34.OutOfRangeName = ""
z34.InRangeName = ""
z18 = Wherigo.Zone(objKlausspieltSudoku)
z18.Id = "1c78c238-46ac-4908-8d83-2b63397ab8db"
z18.Name = "18"
z18.Description = ""
z18.Visible = true
z18.Commands = {}
z18.DistanceRange = Distance(0, "meters")
z18.ShowObjects = "OnEnter"
z18.ProximityRange = Distance(100, "meters")
z18.AllowSetPositionTo = false
z18.Active = false
z18.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z18.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z18.DistanceRangeUOM = "Meters"
z18.ProximityRangeUOM = "Meters"
z18.OutOfRangeName = ""
z18.InRangeName = ""
z33 = Wherigo.Zone(objKlausspieltSudoku)
z33.Id = "83bb1465-d987-4939-af99-1863a0960fac"
z33.Name = "33"
z33.Description = ""
z33.Visible = true
z33.Commands = {}
z33.DistanceRange = Distance(-1, "feet")
z33.ShowObjects = "OnEnter"
z33.ProximityRange = Distance(100, "meters")
z33.AllowSetPositionTo = false
z33.Active = false
z33.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z33.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z33.DistanceRangeUOM = "Feet"
z33.ProximityRangeUOM = "Meters"
z33.OutOfRangeName = ""
z33.InRangeName = ""
z19 = Wherigo.Zone(objKlausspieltSudoku)
z19.Id = "284ca83e-63a6-4433-8b4b-c7672ecea077"
z19.Name = "19"
z19.Description = ""
z19.Visible = true
z19.Commands = {}
z19.DistanceRange = Distance(-1, "feet")
z19.ShowObjects = "OnEnter"
z19.ProximityRange = Distance(100, "meters")
z19.AllowSetPositionTo = false
z19.Active = false
z19.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z19.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z19.DistanceRangeUOM = "Feet"
z19.ProximityRangeUOM = "Meters"
z19.OutOfRangeName = ""
z19.InRangeName = ""
z32 = Wherigo.Zone(objKlausspieltSudoku)
z32.Id = "4a107cdd-a813-49ab-a053-7ca518211a2e"
z32.Name = "32"
z32.Description = ""
z32.Visible = true
z32.Commands = {}
z32.DistanceRange = Distance(-1, "feet")
z32.ShowObjects = "OnEnter"
z32.ProximityRange = Distance(100, "meters")
z32.AllowSetPositionTo = false
z32.Active = false
z32.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z32.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z32.DistanceRangeUOM = "Feet"
z32.ProximityRangeUOM = "Meters"
z32.OutOfRangeName = ""
z32.InRangeName = ""
z20 = Wherigo.Zone(objKlausspieltSudoku)
z20.Id = "6966de5a-12b4-40e4-8bba-697af3871c70"
z20.Name = "20"
z20.Description = ""
z20.Visible = true
z20.Commands = {}
z20.DistanceRange = Distance(0, "meters")
z20.ShowObjects = "OnEnter"
z20.ProximityRange = Distance(100, "meters")
z20.AllowSetPositionTo = false
z20.Active = false
z20.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z20.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z20.DistanceRangeUOM = "Meters"
z20.ProximityRangeUOM = "Meters"
z20.OutOfRangeName = ""
z20.InRangeName = ""
z31 = Wherigo.Zone(objKlausspieltSudoku)
z31.Id = "c75e7be9-c622-44d9-bfc7-ae37ff574e29"
z31.Name = "31"
z31.Description = ""
z31.Visible = true
z31.Commands = {}
z31.DistanceRange = Distance(-1, "feet")
z31.ShowObjects = "OnEnter"
z31.ProximityRange = Distance(100, "meters")
z31.AllowSetPositionTo = false
z31.Active = false
z31.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z31.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z31.DistanceRangeUOM = "Feet"
z31.ProximityRangeUOM = "Meters"
z31.OutOfRangeName = ""
z31.InRangeName = ""
z21 = Wherigo.Zone(objKlausspieltSudoku)
z21.Id = "4061b525-0bed-431d-9d58-93a11484c62c"
z21.Name = "21"
z21.Description = ""
z21.Visible = true
z21.Commands = {}
z21.DistanceRange = Distance(-1, "feet")
z21.ShowObjects = "OnEnter"
z21.ProximityRange = Distance(100, "meters")
z21.AllowSetPositionTo = false
z21.Active = false
z21.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z21.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z21.DistanceRangeUOM = "Feet"
z21.ProximityRangeUOM = "Meters"
z21.OutOfRangeName = ""
z21.InRangeName = ""
z30 = Wherigo.Zone(objKlausspieltSudoku)
z30.Id = "e2a802d0-cefb-4e28-8d24-4c3d64403566"
z30.Name = "30"
z30.Description = ""
z30.Visible = true
z30.Commands = {}
z30.DistanceRange = Distance(-1, "feet")
z30.ShowObjects = "OnEnter"
z30.ProximityRange = Distance(100, "meters")
z30.AllowSetPositionTo = false
z30.Active = false
z30.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z30.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z30.DistanceRangeUOM = "Feet"
z30.ProximityRangeUOM = "Meters"
z30.OutOfRangeName = ""
z30.InRangeName = ""
z22 = Wherigo.Zone(objKlausspieltSudoku)
z22.Id = "06317099-17aa-45e5-9f21-839c6284b10b"
z22.Name = "22"
z22.Description = ""
z22.Visible = true
z22.Commands = {}
z22.DistanceRange = Distance(-1, "feet")
z22.ShowObjects = "OnEnter"
z22.ProximityRange = Distance(100, "meters")
z22.AllowSetPositionTo = false
z22.Active = false
z22.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z22.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z22.DistanceRangeUOM = "Feet"
z22.ProximityRangeUOM = "Meters"
z22.OutOfRangeName = ""
z22.InRangeName = ""
z29 = Wherigo.Zone(objKlausspieltSudoku)
z29.Id = "635f28b3-475f-4483-b5ee-589d2db57805"
z29.Name = "29"
z29.Description = ""
z29.Visible = true
z29.Commands = {}
z29.DistanceRange = Distance(-1, "feet")
z29.ShowObjects = "OnEnter"
z29.ProximityRange = Distance(100, "meters")
z29.AllowSetPositionTo = false
z29.Active = false
z29.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z29.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z29.DistanceRangeUOM = "Feet"
z29.ProximityRangeUOM = "Meters"
z29.OutOfRangeName = ""
z29.InRangeName = ""
z23 = Wherigo.Zone(objKlausspieltSudoku)
z23.Id = "38f078a6-5043-49bb-8225-4286ed1a7484"
z23.Name = "23"
z23.Description = ""
z23.Visible = true
z23.Commands = {}
z23.DistanceRange = Distance(-1, "feet")
z23.ShowObjects = "OnEnter"
z23.ProximityRange = Distance(100, "meters")
z23.AllowSetPositionTo = false
z23.Active = false
z23.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z23.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z23.DistanceRangeUOM = "Feet"
z23.ProximityRangeUOM = "Meters"
z23.OutOfRangeName = ""
z23.InRangeName = ""
z28 = Wherigo.Zone(objKlausspieltSudoku)
z28.Id = "af641766-5e1b-438b-b634-126e0e54b619"
z28.Name = "28"
z28.Description = ""
z28.Visible = true
z28.Commands = {}
z28.DistanceRange = Distance(-1, "feet")
z28.ShowObjects = "OnEnter"
z28.ProximityRange = Distance(100, "meters")
z28.AllowSetPositionTo = false
z28.Active = false
z28.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z28.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z28.DistanceRangeUOM = "Feet"
z28.ProximityRangeUOM = "Meters"
z28.OutOfRangeName = ""
z28.InRangeName = ""
z24 = Wherigo.Zone(objKlausspieltSudoku)
z24.Id = "d6ddc073-f1c1-40ec-a9a0-b414dca85e9a"
z24.Name = "24"
z24.Description = ""
z24.Visible = true
z24.Commands = {}
z24.DistanceRange = Distance(0, "meters")
z24.ShowObjects = "OnEnter"
z24.ProximityRange = Distance(100, "meters")
z24.AllowSetPositionTo = false
z24.Active = false
z24.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z24.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z24.DistanceRangeUOM = "Meters"
z24.ProximityRangeUOM = "Meters"
z24.OutOfRangeName = ""
z24.InRangeName = ""
z27 = Wherigo.Zone(objKlausspieltSudoku)
z27.Id = "0dfad00d-c596-4288-a59f-23609e069d81"
z27.Name = "27"
z27.Description = ""
z27.Visible = true
z27.Commands = {}
z27.DistanceRange = Distance(-1, "feet")
z27.ShowObjects = "OnEnter"
z27.ProximityRange = Distance(100, "meters")
z27.AllowSetPositionTo = false
z27.Active = false
z27.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z27.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z27.DistanceRangeUOM = "Feet"
z27.ProximityRangeUOM = "Meters"
z27.OutOfRangeName = ""
z27.InRangeName = ""
z25 = Wherigo.Zone(objKlausspieltSudoku)
z25.Id = "db94b762-efe9-40fa-abf4-d8de1f71bb13"
z25.Name = "25"
z25.Description = ""
z25.Visible = true
z25.Commands = {}
z25.DistanceRange = Distance(-1, "feet")
z25.ShowObjects = "OnEnter"
z25.ProximityRange = Distance(100, "meters")
z25.AllowSetPositionTo = false
z25.Active = false
z25.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z25.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z25.DistanceRangeUOM = "Feet"
z25.ProximityRangeUOM = "Meters"
z25.OutOfRangeName = ""
z25.InRangeName = ""
z26 = Wherigo.Zone(objKlausspieltSudoku)
z26.Id = "0e0ecf02-ed3d-489a-9f02-6e9f6aae6d5d"
z26.Name = "26"
z26.Description = ""
z26.Visible = true
z26.Commands = {}
z26.DistanceRange = Distance(0, "meters")
z26.ShowObjects = "OnEnter"
z26.ProximityRange = Distance(100, "meters")
z26.AllowSetPositionTo = false
z26.Active = false
z26.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z26.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z26.DistanceRangeUOM = "Meters"
z26.ProximityRangeUOM = "Meters"
z26.OutOfRangeName = ""
z26.InRangeName = ""
final = Wherigo.Zone(objKlausspieltSudoku)
final.Id = "06515d5d-d058-4be0-adb3-4817ed4350ca"
final.Name = "Final"
final.Description = ""
final.Visible = false
final.Commands = {}
final.DistanceRange = Distance(-1, "feet")
final.ShowObjects = "OnEnter"
final.ProximityRange = Distance(60, "meters")
final.AllowSetPositionTo = false
final.Active = false
final.Points = {
	ZonePoint(52.4788346075238, 13.1547599124275, 0), 
	ZonePoint(52.4786108650691, 13.1547330324707, 0), 
	ZonePoint(52.4786272365068, 13.1550197520102, 0), 
	ZonePoint(52.4788182361633, 13.1550107920244, 0)
}
final.OriginalPoint = ZonePoint(52.4787227363158, 13.1548808722332, 0)
final.DistanceRangeUOM = "Feet"
final.ProximityRangeUOM = "Meters"
final.OutOfRangeName = ""
final.InRangeName = ""
z53 = Wherigo.Zone(objKlausspieltSudoku)
z53.Id = "3cbb2be6-3e50-4fa6-a85a-2de4706db994"
z53.Name = "53"
z53.Description = ""
z53.Visible = true
z53.Commands = {}
z53.DistanceRange = Distance(-1, "feet")
z53.ShowObjects = "OnEnter"
z53.ProximityRange = Distance(60, "meters")
z53.AllowSetPositionTo = false
z53.Active = false
z53.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z53.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z53.DistanceRangeUOM = "Feet"
z53.ProximityRangeUOM = "Meters"
z53.OutOfRangeName = ""
z53.InRangeName = ""
z80 = Wherigo.Zone(objKlausspieltSudoku)
z80.Id = "9dfb0843-30ef-438f-8a90-2434325b3c41"
z80.Name = "80"
z80.Description = ""
z80.Visible = true
z80.Commands = {}
z80.DistanceRange = Distance(-1, "feet")
z80.ShowObjects = "OnEnter"
z80.ProximityRange = Distance(60, "meters")
z80.AllowSetPositionTo = false
z80.Active = false
z80.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z80.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z80.DistanceRangeUOM = "Feet"
z80.ProximityRangeUOM = "Meters"
z80.OutOfRangeName = ""
z80.InRangeName = ""
z81 = Wherigo.Zone(objKlausspieltSudoku)
z81.Id = "ac7ed220-dea7-41c4-bbaf-b0b1a942a1d4"
z81.Name = "81"
z81.Description = ""
z81.Visible = true
z81.Commands = {}
z81.DistanceRange = Distance(-1, "feet")
z81.ShowObjects = "OnEnter"
z81.ProximityRange = Distance(60, "meters")
z81.AllowSetPositionTo = false
z81.Active = false
z81.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z81.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z81.DistanceRangeUOM = "Feet"
z81.ProximityRangeUOM = "Meters"
z81.OutOfRangeName = ""
z81.InRangeName = ""
z76 = Wherigo.Zone(objKlausspieltSudoku)
z76.Id = "ad899e47-4d64-4582-ac9b-5ea9a5206435"
z76.Name = "76"
z76.Description = ""
z76.Visible = true
z76.Commands = {}
z76.DistanceRange = Distance(-1, "feet")
z76.ShowObjects = "OnEnter"
z76.ProximityRange = Distance(60, "meters")
z76.AllowSetPositionTo = false
z76.Active = false
z76.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z76.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z76.DistanceRangeUOM = "Feet"
z76.ProximityRangeUOM = "Meters"
z76.OutOfRangeName = ""
z76.InRangeName = ""
z77 = Wherigo.Zone(objKlausspieltSudoku)
z77.Id = "742ed0ee-75af-480c-8204-8ae1d3954f1d"
z77.Name = "77"
z77.Description = ""
z77.Visible = true
z77.Commands = {}
z77.DistanceRange = Distance(-1, "feet")
z77.ShowObjects = "OnEnter"
z77.ProximityRange = Distance(60, "meters")
z77.AllowSetPositionTo = false
z77.Active = false
z77.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z77.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z77.DistanceRangeUOM = "Feet"
z77.ProximityRangeUOM = "Meters"
z77.OutOfRangeName = ""
z77.InRangeName = ""
z78 = Wherigo.Zone(objKlausspieltSudoku)
z78.Id = "58349c1a-c155-4e0c-8966-bbdc735df677"
z78.Name = "78"
z78.Description = ""
z78.Visible = true
z78.Commands = {}
z78.DistanceRange = Distance(-1, "feet")
z78.ShowObjects = "OnEnter"
z78.ProximityRange = Distance(60, "meters")
z78.AllowSetPositionTo = false
z78.Active = false
z78.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z78.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z78.DistanceRangeUOM = "Feet"
z78.ProximityRangeUOM = "Meters"
z78.OutOfRangeName = ""
z78.InRangeName = ""
z79 = Wherigo.Zone(objKlausspieltSudoku)
z79.Id = "32e5fe6e-3a95-42fb-8266-2b813d6e6687"
z79.Name = "79"
z79.Description = ""
z79.Visible = true
z79.Commands = {}
z79.DistanceRange = Distance(-1, "feet")
z79.ShowObjects = "OnEnter"
z79.ProximityRange = Distance(60, "meters")
z79.AllowSetPositionTo = false
z79.Active = false
z79.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z79.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z79.DistanceRangeUOM = "Feet"
z79.ProximityRangeUOM = "Meters"
z79.OutOfRangeName = ""
z79.InRangeName = ""
z68 = Wherigo.Zone(objKlausspieltSudoku)
z68.Id = "bd5f474e-bb0c-4156-ba20-5137ff831880"
z68.Name = "68"
z68.Description = ""
z68.Visible = true
z68.Commands = {}
z68.DistanceRange = Distance(-1, "feet")
z68.ShowObjects = "OnEnter"
z68.ProximityRange = Distance(60, "meters")
z68.AllowSetPositionTo = false
z68.Active = false
z68.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z68.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z68.DistanceRangeUOM = "Feet"
z68.ProximityRangeUOM = "Meters"
z68.OutOfRangeName = ""
z68.InRangeName = ""
z69 = Wherigo.Zone(objKlausspieltSudoku)
z69.Id = "a9ca0675-c083-4b3e-9be2-46698c0bfb8b"
z69.Name = "69"
z69.Description = ""
z69.Visible = true
z69.Commands = {}
z69.DistanceRange = Distance(-1, "feet")
z69.ShowObjects = "OnEnter"
z69.ProximityRange = Distance(60, "meters")
z69.AllowSetPositionTo = false
z69.Active = false
z69.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z69.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z69.DistanceRangeUOM = "Feet"
z69.ProximityRangeUOM = "Meters"
z69.OutOfRangeName = ""
z69.InRangeName = ""
z70 = Wherigo.Zone(objKlausspieltSudoku)
z70.Id = "4e964323-e587-4206-aefa-c173f01fa12a"
z70.Name = "70"
z70.Description = ""
z70.Visible = true
z70.Commands = {}
z70.DistanceRange = Distance(-1, "feet")
z70.ShowObjects = "OnEnter"
z70.ProximityRange = Distance(60, "meters")
z70.AllowSetPositionTo = false
z70.Active = false
z70.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z70.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z70.DistanceRangeUOM = "Feet"
z70.ProximityRangeUOM = "Meters"
z70.OutOfRangeName = ""
z70.InRangeName = ""
z71 = Wherigo.Zone(objKlausspieltSudoku)
z71.Id = "974d6c5a-c88d-4cdb-bd78-fddade00041a"
z71.Name = "71"
z71.Description = ""
z71.Visible = true
z71.Commands = {}
z71.DistanceRange = Distance(-1, "feet")
z71.ShowObjects = "OnEnter"
z71.ProximityRange = Distance(60, "meters")
z71.AllowSetPositionTo = false
z71.Active = false
z71.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z71.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z71.DistanceRangeUOM = "Feet"
z71.ProximityRangeUOM = "Meters"
z71.OutOfRangeName = ""
z71.InRangeName = ""
z72 = Wherigo.Zone(objKlausspieltSudoku)
z72.Id = "7126b7a0-0c7b-4d13-b1ea-3f62a4bfc9e1"
z72.Name = "72"
z72.Description = ""
z72.Visible = true
z72.Commands = {}
z72.DistanceRange = Distance(-1, "feet")
z72.ShowObjects = "OnEnter"
z72.ProximityRange = Distance(60, "meters")
z72.AllowSetPositionTo = false
z72.Active = false
z72.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z72.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z72.DistanceRangeUOM = "Feet"
z72.ProximityRangeUOM = "Meters"
z72.OutOfRangeName = ""
z72.InRangeName = ""
z75 = Wherigo.Zone(objKlausspieltSudoku)
z75.Id = "03ec4d4e-1627-4981-9be1-13159cf89fa6"
z75.Name = "75"
z75.Description = ""
z75.Visible = true
z75.Commands = {}
z75.DistanceRange = Distance(-1, "feet")
z75.ShowObjects = "OnEnter"
z75.ProximityRange = Distance(60, "meters")
z75.AllowSetPositionTo = false
z75.Active = false
z75.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z75.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z75.DistanceRangeUOM = "Feet"
z75.ProximityRangeUOM = "Meters"
z75.OutOfRangeName = ""
z75.InRangeName = ""
z73 = Wherigo.Zone(objKlausspieltSudoku)
z73.Id = "5b404e45-8af5-467f-9346-c785cb97e9ec"
z73.Name = "73"
z73.Description = ""
z73.Visible = true
z73.Commands = {}
z73.DistanceRange = Distance(-1, "feet")
z73.ShowObjects = "OnEnter"
z73.ProximityRange = Distance(60, "meters")
z73.AllowSetPositionTo = false
z73.Active = false
z73.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z73.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z73.DistanceRangeUOM = "Feet"
z73.ProximityRangeUOM = "Meters"
z73.OutOfRangeName = ""
z73.InRangeName = ""
z74 = Wherigo.Zone(objKlausspieltSudoku)
z74.Id = "eddb56d3-68a2-4a99-a7a2-74b159a9a599"
z74.Name = "74"
z74.Description = ""
z74.Visible = true
z74.Commands = {}
z74.DistanceRange = Distance(-1, "feet")
z74.ShowObjects = "OnEnter"
z74.ProximityRange = Distance(60, "meters")
z74.AllowSetPositionTo = false
z74.Active = false
z74.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z74.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z74.DistanceRangeUOM = "Feet"
z74.ProximityRangeUOM = "Meters"
z74.OutOfRangeName = ""
z74.InRangeName = ""
z67 = Wherigo.Zone(objKlausspieltSudoku)
z67.Id = "a89e2105-51a4-4d2b-9280-aced140ad88e"
z67.Name = "67"
z67.Description = ""
z67.Visible = true
z67.Commands = {}
z67.DistanceRange = Distance(-1, "feet")
z67.ShowObjects = "OnEnter"
z67.ProximityRange = Distance(60, "meters")
z67.AllowSetPositionTo = false
z67.Active = false
z67.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z67.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z67.DistanceRangeUOM = "Feet"
z67.ProximityRangeUOM = "Meters"
z67.OutOfRangeName = ""
z67.InRangeName = ""
z54 = Wherigo.Zone(objKlausspieltSudoku)
z54.Id = "1ae4f597-79b8-415d-89c7-12f43d66c2ec"
z54.Name = "54"
z54.Description = ""
z54.Visible = true
z54.Commands = {}
z54.DistanceRange = Distance(-1, "feet")
z54.ShowObjects = "OnEnter"
z54.ProximityRange = Distance(60, "meters")
z54.AllowSetPositionTo = false
z54.Active = false
z54.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z54.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z54.DistanceRangeUOM = "Feet"
z54.ProximityRangeUOM = "Meters"
z54.OutOfRangeName = ""
z54.InRangeName = ""
z55 = Wherigo.Zone(objKlausspieltSudoku)
z55.Id = "caf53310-7bb3-43c9-a458-e2be5184d16d"
z55.Name = "55"
z55.Description = ""
z55.Visible = true
z55.Commands = {}
z55.DistanceRange = Distance(-1, "feet")
z55.ShowObjects = "OnEnter"
z55.ProximityRange = Distance(60, "meters")
z55.AllowSetPositionTo = false
z55.Active = false
z55.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z55.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z55.DistanceRangeUOM = "Feet"
z55.ProximityRangeUOM = "Meters"
z55.OutOfRangeName = ""
z55.InRangeName = ""
z56 = Wherigo.Zone(objKlausspieltSudoku)
z56.Id = "3ebe68f0-3ffe-4e21-ad1c-e894a5732622"
z56.Name = "56"
z56.Description = ""
z56.Visible = true
z56.Commands = {}
z56.DistanceRange = Distance(-1, "feet")
z56.ShowObjects = "OnEnter"
z56.ProximityRange = Distance(60, "meters")
z56.AllowSetPositionTo = false
z56.Active = false
z56.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z56.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z56.DistanceRangeUOM = "Feet"
z56.ProximityRangeUOM = "Meters"
z56.OutOfRangeName = ""
z56.InRangeName = ""
z66 = Wherigo.Zone(objKlausspieltSudoku)
z66.Id = "a1612d13-c779-45d0-94af-71f7e60cd307"
z66.Name = "66"
z66.Description = ""
z66.Visible = true
z66.Commands = {}
z66.DistanceRange = Distance(-1, "feet")
z66.ShowObjects = "OnEnter"
z66.ProximityRange = Distance(60, "meters")
z66.AllowSetPositionTo = false
z66.Active = false
z66.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z66.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z66.DistanceRangeUOM = "Feet"
z66.ProximityRangeUOM = "Meters"
z66.OutOfRangeName = ""
z66.InRangeName = ""
z57 = Wherigo.Zone(objKlausspieltSudoku)
z57.Id = "d52fc99d-bd6b-4293-9835-c61a8bfc5078"
z57.Name = "57"
z57.Description = ""
z57.Visible = true
z57.Commands = {}
z57.DistanceRange = Distance(-1, "feet")
z57.ShowObjects = "OnEnter"
z57.ProximityRange = Distance(60, "meters")
z57.AllowSetPositionTo = false
z57.Active = false
z57.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z57.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z57.DistanceRangeUOM = "Feet"
z57.ProximityRangeUOM = "Meters"
z57.OutOfRangeName = ""
z57.InRangeName = ""
z58 = Wherigo.Zone(objKlausspieltSudoku)
z58.Id = "65711410-cbb3-452c-89fc-25079a7ca7f3"
z58.Name = "58"
z58.Description = ""
z58.Visible = true
z58.Commands = {}
z58.DistanceRange = Distance(-1, "feet")
z58.ShowObjects = "OnEnter"
z58.ProximityRange = Distance(60, "meters")
z58.AllowSetPositionTo = false
z58.Active = false
z58.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z58.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z58.DistanceRangeUOM = "Feet"
z58.ProximityRangeUOM = "Meters"
z58.OutOfRangeName = ""
z58.InRangeName = ""
z59 = Wherigo.Zone(objKlausspieltSudoku)
z59.Id = "9f19da86-731d-4d14-b720-6f6e30f6b866"
z59.Name = "59"
z59.Description = ""
z59.Visible = true
z59.Commands = {}
z59.DistanceRange = Distance(-1, "feet")
z59.ShowObjects = "OnEnter"
z59.ProximityRange = Distance(60, "meters")
z59.AllowSetPositionTo = false
z59.Active = false
z59.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z59.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z59.DistanceRangeUOM = "Feet"
z59.ProximityRangeUOM = "Meters"
z59.OutOfRangeName = ""
z59.InRangeName = ""
z65 = Wherigo.Zone(objKlausspieltSudoku)
z65.Id = "76325d5f-bf2c-4777-b6fd-f7110311bb6c"
z65.Name = "65"
z65.Description = ""
z65.Visible = true
z65.Commands = {}
z65.DistanceRange = Distance(-1, "feet")
z65.ShowObjects = "OnEnter"
z65.ProximityRange = Distance(60, "meters")
z65.AllowSetPositionTo = false
z65.Active = false
z65.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z65.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z65.DistanceRangeUOM = "Feet"
z65.ProximityRangeUOM = "Meters"
z65.OutOfRangeName = ""
z65.InRangeName = ""
z60 = Wherigo.Zone(objKlausspieltSudoku)
z60.Id = "97f14885-420d-4705-a6bf-bf20e113d60b"
z60.Name = "60"
z60.Description = ""
z60.Visible = true
z60.Commands = {}
z60.DistanceRange = Distance(-1, "feet")
z60.ShowObjects = "OnEnter"
z60.ProximityRange = Distance(60, "meters")
z60.AllowSetPositionTo = false
z60.Active = false
z60.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z60.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z60.DistanceRangeUOM = "Feet"
z60.ProximityRangeUOM = "Meters"
z60.OutOfRangeName = ""
z60.InRangeName = ""
z61 = Wherigo.Zone(objKlausspieltSudoku)
z61.Id = "1c25a687-5c63-4598-be88-f062703487cc"
z61.Name = "61"
z61.Description = ""
z61.Visible = true
z61.Commands = {}
z61.DistanceRange = Distance(-1, "feet")
z61.ShowObjects = "OnEnter"
z61.ProximityRange = Distance(60, "meters")
z61.AllowSetPositionTo = false
z61.Active = false
z61.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z61.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z61.DistanceRangeUOM = "Feet"
z61.ProximityRangeUOM = "Meters"
z61.OutOfRangeName = ""
z61.InRangeName = ""
z64 = Wherigo.Zone(objKlausspieltSudoku)
z64.Id = "e93da8fd-84d9-4a30-b166-fa508ddd77bf"
z64.Name = "64"
z64.Description = ""
z64.Visible = true
z64.Commands = {}
z64.DistanceRange = Distance(-1, "feet")
z64.ShowObjects = "OnEnter"
z64.ProximityRange = Distance(60, "meters")
z64.AllowSetPositionTo = false
z64.Active = false
z64.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z64.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z64.DistanceRangeUOM = "Feet"
z64.ProximityRangeUOM = "Meters"
z64.OutOfRangeName = ""
z64.InRangeName = ""
z62 = Wherigo.Zone(objKlausspieltSudoku)
z62.Id = "4f25850e-616b-458e-ab22-bba87687a9f5"
z62.Name = "62"
z62.Description = ""
z62.Visible = true
z62.Commands = {}
z62.DistanceRange = Distance(-1, "feet")
z62.ShowObjects = "OnEnter"
z62.ProximityRange = Distance(60, "meters")
z62.AllowSetPositionTo = false
z62.Active = false
z62.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z62.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z62.DistanceRangeUOM = "Feet"
z62.ProximityRangeUOM = "Meters"
z62.OutOfRangeName = ""
z62.InRangeName = ""
z63 = Wherigo.Zone(objKlausspieltSudoku)
z63.Id = "1a48b333-a8b6-4a32-a1da-00200949daf2"
z63.Name = "63"
z63.Description = ""
z63.Visible = true
z63.Commands = {}
z63.DistanceRange = Distance(-1, "feet")
z63.ShowObjects = "OnEnter"
z63.ProximityRange = Distance(60, "meters")
z63.AllowSetPositionTo = false
z63.Active = false
z63.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z63.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z63.DistanceRangeUOM = "Feet"
z63.ProximityRangeUOM = "Meters"
z63.OutOfRangeName = ""
z63.InRangeName = ""
z52 = Wherigo.Zone(objKlausspieltSudoku)
z52.Id = "faa1dd9d-da9c-4da6-b952-ca539befe903"
z52.Name = "52"
z52.Description = ""
z52.Visible = true
z52.Commands = {}
z52.DistanceRange = Distance(-1, "feet")
z52.ShowObjects = "OnEnter"
z52.ProximityRange = Distance(60, "meters")
z52.AllowSetPositionTo = false
z52.Active = false
z52.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z52.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z52.DistanceRangeUOM = "Feet"
z52.ProximityRangeUOM = "Meters"
z52.OutOfRangeName = ""
z52.InRangeName = ""
z51 = Wherigo.Zone(objKlausspieltSudoku)
z51.Id = "4b1f08a0-b9fb-4600-8662-569ae2c8a22f"
z51.Name = "51"
z51.Description = ""
z51.Visible = true
z51.Commands = {}
z51.DistanceRange = Distance(-1, "feet")
z51.ShowObjects = "OnEnter"
z51.ProximityRange = Distance(60, "meters")
z51.AllowSetPositionTo = false
z51.Active = false
z51.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z51.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z51.DistanceRangeUOM = "Feet"
z51.ProximityRangeUOM = "Meters"
z51.OutOfRangeName = ""
z51.InRangeName = ""
z50 = Wherigo.Zone(objKlausspieltSudoku)
z50.Id = "8a2d8e4b-bdd3-4784-9307-e4abf2cbc5db"
z50.Name = "50"
z50.Description = ""
z50.Visible = true
z50.Commands = {}
z50.DistanceRange = Distance(-1, "feet")
z50.ShowObjects = "OnEnter"
z50.ProximityRange = Distance(60, "meters")
z50.AllowSetPositionTo = false
z50.Active = false
z50.Points = {
	ZonePoint(52.4731215581625, 13.1346631273493, 0), 
	ZonePoint(52.4731219666184, 13.1346745267376, 0), 
	ZonePoint(52.4731166566918, 13.1346684917673, 0)
}
z50.OriginalPoint = ZonePoint(52.4731200604909, 13.1346687152847, 0)
z50.DistanceRangeUOM = "Feet"
z50.ProximityRangeUOM = "Meters"
z50.OutOfRangeName = ""
z50.InRangeName = ""

-- Characters --

-- Items --
objSudoku = Wherigo.ZItem{
	Cartridge = objKlausspieltSudoku, 
	Container = Player
}
objSudoku.Id = "d28ec4a0-00ec-42d0-8bee-f33df448fbf6"
objSudoku.Name = "Sudoku"
objSudoku.Description = ""
objSudoku.Visible = true
objSudoku.Media = objKarte
objSudoku.Icon = objicoKarte
objSudoku.Commands = {
	cmdspielen = Wherigo.ZCommand{
		Text = "spielen", 
		CmdWith = false, 
		Enabled = true, 
		EmptyTargetListText = "Nothing available"
	}, 
	cmdpruefen = Wherigo.ZCommand{
		Text = "pruefen", 
		CmdWith = false, 
		Enabled = false, 
		EmptyTargetListText = "Nothing available"
	}
}
objSudoku.Commands.cmdspielen.Custom = true
objSudoku.Commands.cmdspielen.Id = "896565a6-db7c-4227-bbab-b05677122aed"
objSudoku.Commands.cmdspielen.WorksWithAll = true
objSudoku.Commands.cmdpruefen.Custom = true
objSudoku.Commands.cmdpruefen.Id = "d4de85bf-e09f-46c3-a2d9-07981d839c9e"
objSudoku.Commands.cmdpruefen.WorksWithAll = true
objSudoku.ObjectLocation = Wherigo.INVALID_ZONEPOINT
objSudoku.Locked = false
objSudoku.Opened = false
objSpoiler1 = Wherigo.ZItem{
	Cartridge = objKlausspieltSudoku, 
	Container = Player
}
objSpoiler1.Id = "33446165-a7ce-4362-a2b8-0617c4e0444a"
objSpoiler1.Name = "Spoiler"
objSpoiler1.Description = ""
objSpoiler1.Visible = false
objSpoiler1.Media = objSpoiler
objSpoiler1.Icon = objicoSpoiler
objSpoiler1.Commands = {}
objSpoiler1.ObjectLocation = Wherigo.INVALID_ZONEPOINT
objSpoiler1.Locked = false
objSpoiler1.Opened = false
objKoordinaten1 = Wherigo.ZItem{
	Cartridge = objKlausspieltSudoku, 
	Container = Player
}
objKoordinaten1.Id = "d3f9863b-4d9c-4c41-98ca-475b37d6e332"
objKoordinaten1.Name = "Koordinaten"
objKoordinaten1.Description = "Jetzt auf zum Ziel!"
objKoordinaten1.Visible = false
objKoordinaten1.Media = objKoordinaten
objKoordinaten1.Icon = objicoKoordinaten
objKoordinaten1.Commands = {}
objKoordinaten1.ObjectLocation = Wherigo.INVALID_ZONEPOINT
objKoordinaten1.Locked = false
objKoordinaten1.Opened = false
objFreischaltcode1 = Wherigo.ZItem{
	Cartridge = objKlausspieltSudoku, 
	Container = Player
}
objFreischaltcode1.Id = "233a2516-7aeb-4f5e-b1fb-eb82e67368fe"
objFreischaltcode1.Name = "Freischaltcode"
objFreischaltcode1.Description = ""
objFreischaltcode1.Visible = false
objFreischaltcode1.Media = objFreischaltcode
objFreischaltcode1.Icon = objicoFreischaltcode
objFreischaltcode1.Commands = {}
objFreischaltcode1.ObjectLocation = Wherigo.INVALID_ZONEPOINT
objFreischaltcode1.Locked = false
objFreischaltcode1.Opened = false
objAnleitung1 = Wherigo.ZItem{
	Cartridge = objKlausspieltSudoku, 
	Container = Player
}
objAnleitung1.Id = "5cc8f4a3-652f-44f8-9ac3-49aefcacc371"
objAnleitung1.Name = "Anleitung"
objAnleitung1.Description = "Zahlenraten leicht gemacht"
objAnleitung1.Visible = true
objAnleitung1.Media = objAnleitung
objAnleitung1.Icon = objicoAnleitung
objAnleitung1.Commands = {
	cmdlesen = Wherigo.ZCommand{
		Text = "lesen", 
		CmdWith = false, 
		Enabled = true, 
		EmptyTargetListText = "Nothing available"
	}
}
objAnleitung1.Commands.cmdlesen.Custom = true
objAnleitung1.Commands.cmdlesen.Id = "ceacb6fd-969b-42c9-b481-34745b17ebf0"
objAnleitung1.Commands.cmdlesen.WorksWithAll = true
objAnleitung1.ObjectLocation = Wherigo.INVALID_ZONEPOINT
objAnleitung1.Locked = false
objAnleitung1.Opened = false
Karte = Wherigo.ZItem{
	Cartridge = objKlausspieltSudoku, 
	Container = Player
}
Karte.Id = "4f70d792-aba5-4f7f-9fac-6b48574afd7e"
Karte.Name = "Karte"
Karte.Description = ""
Karte.Visible = false
Karte.Icon = objicoKarte
Karte.Commands = {}
Karte.ObjectLocation = Wherigo.INVALID_ZONEPOINT
Karte.Locked = false
Karte.Opened = false
aktuellesFeld = Wherigo.ZItem{
	Cartridge = objKlausspieltSudoku, 
	Container = Player
}
aktuellesFeld.Id = "85ce0f76-265b-4acd-a811-25fd7109b96e"
aktuellesFeld.Name = "aktuelles Feld"
aktuellesFeld.Description = ""
aktuellesFeld.Visible = false
aktuellesFeld.Commands = {
	cmdsetzen = Wherigo.ZCommand{
		Text = "setzen", 
		CmdWith = false, 
		Enabled = true, 
		EmptyTargetListText = "Nothing available"
	}
}
aktuellesFeld.Commands.cmdsetzen.Custom = true
aktuellesFeld.Commands.cmdsetzen.Id = "768f553a-0ae9-48e8-86ec-fe783c108894"
aktuellesFeld.Commands.cmdsetzen.WorksWithAll = true
aktuellesFeld.ObjectLocation = Wherigo.INVALID_ZONEPOINT
aktuellesFeld.Locked = false
aktuellesFeld.Opened = false

-- Tasks --
objspieleMinesweeper = Wherigo.ZTask(objKlausspieltSudoku)
objspieleMinesweeper.Id = "04ac77f9-864a-4b1f-8af8-ed76d383a1bf"
objspieleMinesweeper.Name = "spiele Minesweeper"
objspieleMinesweeper.Description = "starte das Sudoku"
objspieleMinesweeper.Visible = true
objspieleMinesweeper.Media = objKarte
objspieleMinesweeper.Icon = objicoKarte
objspieleMinesweeper.Active = true
objspieleMinesweeper.Complete = false
objspieleMinesweeper.CorrectState = "None"
objhilfmir = Wherigo.ZTask(objKlausspieltSudoku)
objhilfmir.Id = "c732ac3c-d91a-46c4-a681-fd1e229e82f9"
objhilfmir.Name = "hilf mir"
objhilfmir.Description = "hilf mir, das Sudoku zu loesen."
objhilfmir.Visible = false
objhilfmir.Media = objKlaus
objhilfmir.Active = true
objhilfmir.Complete = false
objhilfmir.CorrectState = "None"
objtrageDichinsLogbuchein = Wherigo.ZTask(objKlausspieltSudoku)
objtrageDichinsLogbuchein.Id = "2b49c9a5-73a5-46dd-b5be-c6a88f490b18"
objtrageDichinsLogbuchein.Name = "trage Dich ins Logbuch ein"
objtrageDichinsLogbuchein.Description = "trage dich ins Logbuch ein"
objtrageDichinsLogbuchein.Visible = false
objtrageDichinsLogbuchein.Media = objFreischaltcode
objtrageDichinsLogbuchein.Icon = objicoFreischaltcode
objtrageDichinsLogbuchein.Active = true
objtrageDichinsLogbuchein.Complete = false
objtrageDichinsLogbuchein.CorrectState = "None"

-- Cartridge Variables --
iMinen = 10
iFahnen = 10
iZone = 25
bFlag = false
bMine = false
iSeed = 0
s0 = "     |  123   456   789"
sZ = ""
s1 = ""
s5 = ""
s4 = ""
s2 = ""
s3 = ""
s6 = ""
s7 = ""
objsT = "Aktuelle Position: 5, 5"
iFeldMine = 0
bLoesung = false
sZone = "xx"
x = 0
y = 0
iTimeStart = 0
iTimeStop = 0
sCR = ""
objiStd = 0
objiMin = 0
objiSek = 0
objbFirst = true
i1 = 0
obji2 = 0
obji3 = 0
s8 = ""
objs9 = ""
currentZone = "z01"
currentCharacter = "dummy"
currentItem = "objSudoku"
currentTask = "objspieleMinesweeper"
currentInput = "objZahl"
currentTimer = "objName"
objKlausspieltSudoku.ZVariables = {
	iMinen = 10, 
	iFahnen = 10, 
	iZone = 25, 
	bFlag = false, 
	bMine = false, 
	iSeed = 0, 
	s0 = "     |  123   456   789", 
	sZ = "", 
	s1 = "", 
	s5 = "", 
	s4 = "", 
	s2 = "", 
	s3 = "", 
	s6 = "", 
	s7 = "", 
	objsT = "Aktuelle Position: 5, 5", 
	iFeldMine = 0, 
	bLoesung = false, 
	sZone = "xx", 
	x = 0, 
	y = 0, 
	iTimeStart = 0, 
	iTimeStop = 0, 
	sCR = "", 
	objiStd = 0, 
	objiMin = 0, 
	objiSek = 0, 
	objbFirst = true, 
	i1 = 0, 
	obji2 = 0, 
	obji3 = 0, 
	s8 = "", 
	objs9 = "", 
	currentZone = "z01", 
	currentCharacter = "dummy", 
	currentItem = "objSudoku", 
	currentTask = "objspieleMinesweeper", 
	currentInput = "objZahl", 
	currentTimer = "objName"
}

-- Timers --
objName = Wherigo.ZTimer(objKlausspieltSudoku)
objName.Id = "d8f64fad-af25-4c1f-b525-2d4a53ad6baa"
objName.Name = "Name"
objName.Description = ""
objName.Visible = true
objName.Duration = 0
objName.Type = "Countdown"

-- Inputs --
objZahl = Wherigo.ZInput(objKlausspieltSudoku)
objZahl.Id = "a107f1ad-883a-4593-8fe2-f33eb4445395"
objZahl.Name = "Zahl"
objZahl.Description = ""
objZahl.Visible = true
objZahl.Media = objKlaus
objZahl.InputType = "Text"
objZahl.Text = "Welche Zahl soll in dieses Feld:"

-- WorksWithList for object commands --

-- functions --
function objKlausspieltSudoku:OnStart()
	local _Urwigo_Date = os.date "*t"
	iZone = 41
	iSeed = _Urwigo.Date_SecondInHour(_Urwigo_Date)
	initZufall()
	
	_Urwigo.OldDialog{
		{
			Text = [[Du willst mir beim Sudoku spielen helfen? Das finde ich super.

Es ist ganz einfach. Gehe auf das entsprechende Feld und setze eine Zahl.
Die Aufgabe besteht darin, die leeren Felder des Sudoku so zu fuellen, dass in jeder der je neun Zeilen, Spalten und Bloecke jede Ziffer von 1 bis 9 nur einmal auftritt.
Wenn Du fertig bist, pruefe Deine Loesung.
]], 
			Media = objKlaus
		}, 
		{
			Text = [[Falls Dir etwas unklar ist, lies einfach nochmal die Anleitung durch.

Und ich wuerde mich wirklich freuen, wenn Du mir beim Spielen helfen wuerdest!]], 
			Media = objKlaus
		}
	}
end
function objKlausspieltSudoku:OnRestore()
end
function z01:OnEnter()
	currentZone = "z01"
	_Urwigo.GlobalZoneEnter()
end
function z02:OnEnter()
	currentZone = "z02"
	_Urwigo.GlobalZoneEnter()
end
function z49:OnEnter()
	currentZone = "z49"
	_Urwigo.GlobalZoneEnter()
end
function z03:OnEnter()
	currentZone = "z03"
	_Urwigo.GlobalZoneEnter()
end
function z48:OnEnter()
	currentZone = "z48"
	_Urwigo.GlobalZoneEnter()
end
function z04:OnEnter()
	currentZone = "z04"
	_Urwigo.GlobalZoneEnter()
end
function z47:OnEnter()
	currentZone = "z47"
	_Urwigo.GlobalZoneEnter()
end
function z05:OnEnter()
	currentZone = "z05"
	_Urwigo.GlobalZoneEnter()
end
function z46:OnEnter()
	currentZone = "z46"
	_Urwigo.GlobalZoneEnter()
end
function z06:OnEnter()
	currentZone = "z06"
	_Urwigo.GlobalZoneEnter()
end
function z45:OnEnter()
	currentZone = "z45"
	_Urwigo.GlobalZoneEnter()
end
function z07:OnEnter()
	currentZone = "z07"
	_Urwigo.GlobalZoneEnter()
end
function z44:OnEnter()
	currentZone = "z44"
	_Urwigo.GlobalZoneEnter()
end
function z08:OnEnter()
	currentZone = "z08"
	_Urwigo.GlobalZoneEnter()
end
function z43:OnEnter()
	currentZone = "z43"
	_Urwigo.GlobalZoneEnter()
end
function z09:OnEnter()
	currentZone = "z09"
	_Urwigo.GlobalZoneEnter()
end
function z42:OnEnter()
	currentZone = "z42"
	_Urwigo.GlobalZoneEnter()
end
function z10:OnEnter()
	currentZone = "z10"
	_Urwigo.GlobalZoneEnter()
end
function z41:OnEnter()
	currentZone = "z41"
	_Urwigo.GlobalZoneEnter()
end
function z11:OnEnter()
	currentZone = "z11"
	_Urwigo.GlobalZoneEnter()
end
function z40:OnEnter()
	currentZone = "z40"
	_Urwigo.GlobalZoneEnter()
end
function z12:OnEnter()
	currentZone = "z12"
	_Urwigo.GlobalZoneEnter()
end
function z39:OnEnter()
	currentZone = "z39"
	_Urwigo.GlobalZoneEnter()
end
function z13:OnEnter()
	currentZone = "z13"
	_Urwigo.GlobalZoneEnter()
end
function z38:OnEnter()
	currentZone = "z38"
	_Urwigo.GlobalZoneEnter()
end
function z14:OnEnter()
	currentZone = "z14"
	_Urwigo.GlobalZoneEnter()
end
function z37:OnEnter()
	currentZone = "z37"
	_Urwigo.GlobalZoneEnter()
end
function z15:OnEnter()
	currentZone = "z15"
	_Urwigo.GlobalZoneEnter()
end
function z36:OnEnter()
	currentZone = "z36"
	_Urwigo.GlobalZoneEnter()
end
function z16:OnEnter()
	currentZone = "z16"
	_Urwigo.GlobalZoneEnter()
end
function z35:OnEnter()
	currentZone = "z35"
	_Urwigo.GlobalZoneEnter()
end
function z17:OnEnter()
	currentZone = "z17"
	_Urwigo.GlobalZoneEnter()
end
function z34:OnEnter()
	currentZone = "z34"
	_Urwigo.GlobalZoneEnter()
end
function z18:OnEnter()
	currentZone = "z18"
	_Urwigo.GlobalZoneEnter()
end
function z33:OnEnter()
	currentZone = "z33"
	_Urwigo.GlobalZoneEnter()
end
function z19:OnEnter()
	currentZone = "z19"
	_Urwigo.GlobalZoneEnter()
end
function z32:OnEnter()
	currentZone = "z32"
	_Urwigo.GlobalZoneEnter()
end
function z20:OnEnter()
	currentZone = "z20"
	_Urwigo.GlobalZoneEnter()
end
function z31:OnEnter()
	currentZone = "z31"
	_Urwigo.GlobalZoneEnter()
end
function z21:OnEnter()
	currentZone = "z21"
	_Urwigo.GlobalZoneEnter()
end
function z30:OnEnter()
	currentZone = "z30"
	_Urwigo.GlobalZoneEnter()
end
function z22:OnEnter()
	currentZone = "z22"
	_Urwigo.GlobalZoneEnter()
end
function z29:OnEnter()
	currentZone = "z29"
	_Urwigo.GlobalZoneEnter()
end
function z23:OnEnter()
	currentZone = "z23"
	_Urwigo.GlobalZoneEnter()
end
function z28:OnEnter()
	currentZone = "z28"
	_Urwigo.GlobalZoneEnter()
end
function z24:OnEnter()
	currentZone = "z24"
	_Urwigo.GlobalZoneEnter()
end
function z27:OnEnter()
	currentZone = "z27"
	_Urwigo.GlobalZoneEnter()
end
function z25:OnEnter()
	currentZone = "z25"
	_Urwigo.GlobalZoneEnter()
end
function z26:OnEnter()
	currentZone = "z26"
	_Urwigo.GlobalZoneEnter()
end
function final:OnEnter()
	currentZone = "final"
	_Urwigo.GlobalZoneEnter()
	Wherigo.PlayAudio(obj_tusch)
	objSpoiler1.Visible = true
	objKlausspieltSudoku.Complete = true
	objKlausspieltSudoku:RequestSync()
	objFreischaltcode1.Description = (Player.Name..", Dein Freischaltcode ist ")..string.sub(Player.CompletionCode, 1, 15)
	objFreischaltcode1.Visible = true
	objKlausspieltSudoku:RequestSync()
end
function z53:OnEnter()
	currentZone = "z53"
	_Urwigo.GlobalZoneEnter()
end
function z80:OnEnter()
	currentZone = "z80"
	_Urwigo.GlobalZoneEnter()
end
function z81:OnEnter()
	currentZone = "z81"
	_Urwigo.GlobalZoneEnter()
end
function z76:OnEnter()
	currentZone = "z76"
	_Urwigo.GlobalZoneEnter()
end
function z77:OnEnter()
	currentZone = "z77"
	_Urwigo.GlobalZoneEnter()
end
function z78:OnEnter()
	currentZone = "z78"
	_Urwigo.GlobalZoneEnter()
end
function z79:OnEnter()
	currentZone = "z79"
	_Urwigo.GlobalZoneEnter()
end
function z68:OnEnter()
	currentZone = "z68"
	_Urwigo.GlobalZoneEnter()
end
function z69:OnEnter()
	currentZone = "z69"
	_Urwigo.GlobalZoneEnter()
end
function z70:OnEnter()
	currentZone = "z70"
	_Urwigo.GlobalZoneEnter()
end
function z71:OnEnter()
	currentZone = "z71"
	_Urwigo.GlobalZoneEnter()
end
function z72:OnEnter()
	currentZone = "z72"
	_Urwigo.GlobalZoneEnter()
end
function z75:OnEnter()
	currentZone = "z75"
	_Urwigo.GlobalZoneEnter()
end
function z73:OnEnter()
	currentZone = "z73"
	_Urwigo.GlobalZoneEnter()
end
function z74:OnEnter()
	currentZone = "z74"
	_Urwigo.GlobalZoneEnter()
end
function z67:OnEnter()
	currentZone = "z67"
	_Urwigo.GlobalZoneEnter()
end
function z54:OnEnter()
	currentZone = "z54"
	_Urwigo.GlobalZoneEnter()
end
function z55:OnEnter()
	currentZone = "z55"
	_Urwigo.GlobalZoneEnter()
end
function z56:OnEnter()
	currentZone = "z56"
	_Urwigo.GlobalZoneEnter()
end
function z66:OnEnter()
	currentZone = "z66"
	_Urwigo.GlobalZoneEnter()
end
function z57:OnEnter()
	currentZone = "z57"
	_Urwigo.GlobalZoneEnter()
end
function z58:OnEnter()
	currentZone = "z58"
	_Urwigo.GlobalZoneEnter()
end
function z59:OnEnter()
	currentZone = "z59"
	_Urwigo.GlobalZoneEnter()
end
function z65:OnEnter()
	currentZone = "z65"
	_Urwigo.GlobalZoneEnter()
end
function z60:OnEnter()
	currentZone = "z60"
	_Urwigo.GlobalZoneEnter()
end
function z61:OnEnter()
	currentZone = "z61"
	_Urwigo.GlobalZoneEnter()
end
function z64:OnEnter()
	currentZone = "z64"
	_Urwigo.GlobalZoneEnter()
end
function z62:OnEnter()
	currentZone = "z62"
	_Urwigo.GlobalZoneEnter()
end
function z63:OnEnter()
	currentZone = "z63"
	_Urwigo.GlobalZoneEnter()
end
function z52:OnEnter()
	currentZone = "z52"
	_Urwigo.GlobalZoneEnter()
end
function z51:OnEnter()
	currentZone = "z51"
	_Urwigo.GlobalZoneEnter()
end
function z50:OnEnter()
	currentZone = "z50"
	_Urwigo.GlobalZoneEnter()
end
function objZahl:OnGetInput(input)
	input = tonumber(input)
	if input == nil then
		return
	end
	if input == 1 then
		_G[currentZone].Media = img1
	elseif input == 2 then
		_G[currentZone].Media = img2
	elseif input == 3 then
		_G[currentZone].Media = img3
	elseif input == 4 then
		_G[currentZone].Media = img4
	elseif input == 5 then
		_G[currentZone].Media = img5
	elseif input == 6 then
		_G[currentZone].Media = img6
	elseif input == 7 then
		_G[currentZone].Media = img7
	elseif input == 8 then
		_G[currentZone].Media = img8
	else
		_G[currentZone].Media = img9
	end
	_G[currentZone].Icon = _G[currentZone].Media
	aktuellesFeld.Media = _G[currentZone].Media
	aktuellesFeld.Icon = _G[currentZone].Media
	Anzeige()
	
end
function objSudoku:Oncmdspielen(target)
	objSudoku.Commands.cmdspielen.Enabled = false
	_Urwigo.MessageBox{
		Text = Player.Name..", Du willst mit mir Sudoku spielen? Warte - ich such mal eins raus ...", 
		Media = objKlaus, 
		Callback = function(action)
			if action ~= nil then
				local _Urwigo_Date = os.date "*t"
				initFeld()
				
				objhilfmir.Visible = true
				Karte.Visible = true
				aktuellesFeld.Visible = true
				Anzeige()
				
				iZone = 41
				aktuellesFeld.Media = z41.Media
				aktuellesFeld.Icon = z41.Icon
				objSudoku.Commands.cmdpruefen.Enabled = true
				iTimeStart = _Urwigo.Date_SecondInYear(_Urwigo_Date)
				_Urwigo.MessageBox{
					Text = [[Oh ja!
Das ist gut!]], 
					Media = objKlaus, 
					Callback = function(action)
						if action ~= nil then
							Wherigo.ShowScreen(Wherigo.MAINSCREEN)
						end
					end
				}
			end
		end
	}
end
function objSudoku:Oncmdpruefen(target)
	local _Urwigo_Date = os.date "*t"
	CheckLoesung()
	
	if bLoesung == true then
		iTimeStop = _Urwigo.Date_SecondInYear(_Urwigo_Date)
		objiSek = iTimeStop - iTimeStart
		objiMin = _Urwigo.Floor(objiSek / 60, 0)
		objiSek = objiSek - _Urwigo.Floor(objiMin * 60, 0)
		objiStd = _Urwigo.Floor(objiMin / 60, 0)
		objiMin = objiMin - _Urwigo.Floor(objiStd * 60, 0)
		Wherigo.PlayAudio(obj_tusch)
		final.Active = true
		objhilfmir.Complete = true
		objtrageDichinsLogbuchein.Active = true
		objKoordinaten1.Visible = true
		aktuellesFeld.Visible = false
		objAnleitung1.Visible = false
		Karte.Visible = false
		objSudoku.Visible = false
		ZonenAus()
		
		_Urwigo.MessageBox{
			Text = ((((((("Super "..Player.Name)..[[, Deine Loesung ist richtig!

Deine Zeit: ]])..objiStd).." Std ")..objiMin).." Min ")..objiSek).." Sek", 
			Media = objKlaus
		}
	else
		_Urwigo.MessageBox{
			Text = "Schade, Deine Loesung ist nicht richtig!", 
			Media = objKlaus
		}
	end
end
function objAnleitung1:Oncmdlesen(target)
	_Urwigo.Dialog(false, {
		{
			Text = [[Ziel des Spiels

Das Standard-Sudoku besteht aus einem Gitterfeld mit 3?3 Bloecken, die jeweils in 3?3 Felder unterteilt sind, insgesamt 81 Felder in 9 Zeilen und 9 Spalten. In einige dieser Felder sind schon zu Beginn Ziffern zwischen 1 und 9 eingetragen.

Die Aufgabe besteht darin, die leeren Felder des Raetsels so zu fuellen, dass in jeder der je neun Zeilen, Spalten und Bloecke jede Ziffer von 1 bis 9 nur einmal auftritt.]]
		}, 
		{
			Text = [[Start des Spiels

Suche ein freies Feld mit einer Groesse von mindestens 100m x 100m.
Gehe in die Mitte und starte Sudoku. 
Damit wird das Spielfeld erzeugt und die Zahlen verteilt.
Du befindest Dich in der Mitte des Sudoku.]]
		}, 
		{
			Text = [[Zahlen setzen

Sobald Du eine Zone betreten hast, kannst Du in der aktuellen Umgebung eine Zahl setzen.]]
		}, 
		{
			Text = [[Karte

Deine Karte zeigt Dir jeweils Deine aktuelle Position sowie die bisher gesetzten Zahlen an.]]
		}, 
		{
			Text = [[Ende des Spiels

Wenn Du glaubst, alle Zahlen richtig gesetzt zu haben, kannst Du Deine Loesung ueberpruefen.]]
		}
	}, function(action)
		Wherigo.ShowScreen(Wherigo.MAINSCREEN)
	end)
end
function aktuellesFeld:Oncmdsetzen(target)
	_Urwigo.RunDialogs(function()
		Wherigo.GetInput(objZahl)
	end)
end
function _Urwigo.GlobalZoneEnter()
	sZone = _G[currentZone].Name
	if Wherigo.NoCaseEquals(sZone, "final") then
		objSpoiler1.Visible = true
		Wherigo.PlayAudio(obj_tusch)
	else
		BestimmeZone(sZone)
		
		Anzeige()
		
		aktuellesFeld.Icon = _G[currentZone].Icon
		aktuellesFeld.Media = _G[currentZone].Media
		aktuellesFeld.Description = "Aktuelle Zone: ".._G[currentZone].Name
	end
end

-- Urwigo functions --

-- Begin user functions --
i = 0
j = 0
m = 0
p = ZonePoint(0, 0, 0)
sCR = [[ 
]]
sZ = "-----------------------"
sLZ = "                        "
feldK = {
	[1] = p, 
	[2] = p, 
	[3] = p, 
	[4] = p, 
	[5] = p, 
	[6] = p, 
	[7] = p, 
	[8] = p, 
	[9] = p, 
	[10] = p, 
	[11] = p, 
	[12] = p, 
	[13] = p, 
	[14] = p, 
	[15] = p, 
	[16] = p, 
	[17] = p, 
	[18] = p, 
	[19] = p, 
	[20] = p, 
	[21] = p, 
	[22] = p, 
	[23] = p, 
	[24] = p, 
	[25] = p, 
	[26] = p, 
	[27] = p, 
	[28] = p, 
	[29] = p, 
	[30] = p, 
	[31] = p, 
	[32] = p, 
	[33] = p, 
	[34] = p, 
	[35] = p, 
	[36] = p, 
	[37] = p, 
	[38] = p, 
	[39] = p, 
	[40] = p, 
	[41] = p, 
	[42] = p, 
	[43] = p, 
	[44] = p, 
	[45] = p, 
	[46] = p, 
	[47] = p, 
	[48] = p, 
	[49] = p, 
	[50] = p, 
	[51] = p, 
	[52] = p, 
	[53] = p, 
	[54] = p, 
	[55] = p, 
	[56] = p, 
	[57] = p, 
	[58] = p, 
	[59] = p, 
	[60] = p, 
	[61] = p, 
	[62] = p, 
	[63] = p, 
	[64] = p, 
	[65] = p, 
	[66] = p, 
	[67] = p, 
	[68] = p, 
	[69] = p, 
	[70] = p, 
	[71] = p, 
	[72] = p, 
	[73] = p, 
	[74] = p, 
	[75] = p, 
	[76] = p, 
	[77] = p, 
	[78] = p, 
	[79] = p, 
	[80] = p, 
	[81] = p
}
feldS = {
	[1] = 0, 
	[2] = 0, 
	[3] = 0, 
	[4] = 0, 
	[5] = 0, 
	[6] = 0, 
	[7] = 0, 
	[8] = 0, 
	[9] = 0, 
	[10] = 0, 
	[11] = 0, 
	[12] = 0, 
	[13] = 0, 
	[14] = 0, 
	[15] = 0, 
	[16] = 0, 
	[17] = 0, 
	[18] = 0, 
	[19] = 0, 
	[20] = 0, 
	[21] = 0, 
	[22] = 0, 
	[23] = 0, 
	[24] = 0, 
	[25] = 0, 
	[26] = 0, 
	[27] = 0, 
	[28] = 0, 
	[29] = 0, 
	[30] = 0, 
	[31] = 0, 
	[32] = 0, 
	[33] = 0, 
	[34] = 0, 
	[35] = 0, 
	[36] = 0, 
	[37] = 0, 
	[38] = 0, 
	[39] = 0, 
	[40] = 0, 
	[41] = 0, 
	[42] = 0, 
	[43] = 0, 
	[44] = 0, 
	[45] = 0, 
	[46] = 0, 
	[47] = 0, 
	[48] = 0, 
	[49] = 0, 
	[50] = 0, 
	[51] = 0, 
	[52] = 0, 
	[53] = 0, 
	[54] = 0, 
	[55] = 0, 
	[56] = 0, 
	[57] = 0, 
	[58] = 0, 
	[59] = 0, 
	[60] = 0, 
	[61] = 0, 
	[62] = 0, 
	[63] = 0, 
	[64] = 0, 
	[65] = 0, 
	[66] = 0, 
	[67] = 0, 
	[68] = 0, 
	[69] = 0, 
	[70] = 0, 
	[71] = 0, 
	[72] = 0, 
	[73] = 0, 
	[74] = 0, 
	[75] = 0, 
	[76] = 0, 
	[77] = 0, 
	[78] = 0, 
	[79] = 0, 
	[80] = 0, 
	[81] = 0
}
feldZ = {
	[1] = z01, 
	[2] = z02, 
	[3] = z03, 
	[4] = z04, 
	[5] = z05, 
	[6] = z06, 
	[7] = z07, 
	[8] = z08, 
	[9] = z09, 
	[10] = z10, 
	[11] = z11, 
	[12] = z12, 
	[13] = z13, 
	[14] = z14, 
	[15] = z15, 
	[16] = z16, 
	[17] = z17, 
	[18] = z18, 
	[19] = z19, 
	[20] = z20, 
	[21] = z21, 
	[22] = z22, 
	[23] = z23, 
	[24] = z24, 
	[25] = z25, 
	[26] = z26, 
	[27] = z27, 
	[28] = z28, 
	[29] = z29, 
	[30] = z30, 
	[31] = z31, 
	[32] = z32, 
	[33] = z33, 
	[34] = z34, 
	[35] = z35, 
	[36] = z36, 
	[37] = z37, 
	[38] = z38, 
	[39] = z39, 
	[40] = z40, 
	[41] = z41, 
	[42] = z42, 
	[43] = z43, 
	[44] = z44, 
	[45] = z45, 
	[46] = z46, 
	[47] = z47, 
	[48] = z48, 
	[49] = z49, 
	[50] = z50, 
	[51] = z51, 
	[52] = z52, 
	[53] = z53, 
	[54] = z54, 
	[55] = z55, 
	[56] = z56, 
	[57] = z57, 
	[58] = z58, 
	[59] = z59, 
	[60] = z60, 
	[61] = z61, 
	[62] = z62, 
	[63] = z63, 
	[64] = z64, 
	[65] = z65, 
	[66] = z66, 
	[67] = z67, 
	[68] = z68, 
	[69] = z69, 
	[70] = z70, 
	[71] = z71, 
	[72] = z72, 
	[73] = z73, 
	[74] = z74, 
	[75] = z75, 
	[76] = z76, 
	[77] = z77, 
	[78] = z78, 
	[79] = z79, 
	[80] = z80, 
	[81] = z81
}
feldQ = {
	[1] = 0, 
	[2] = 0, 
	[3] = 0, 
	[4] = 0, 
	[5] = 0, 
	[6] = 0, 
	[7] = 0, 
	[8] = 0, 
	[9] = 0
}
feldR = {
	[1] = 0, 
	[2] = 0, 
	[3] = 0, 
	[4] = 0, 
	[5] = 0, 
	[6] = 0, 
	[7] = 0, 
	[8] = 0, 
	[9] = 0
}
feldI = {
	[1] = img1, 
	[2] = img2, 
	[3] = img3, 
	[4] = img4, 
	[5] = img5, 
	[6] = img6, 
	[7] = img7, 
	[8] = img8, 
	[9] = img9
}
function initZufall()
	math.randomseed(iSeed)
end
function initFeld()
	local index = 0
	local dist = Wherigo.Distance(0, "m")
	-- Mittelpunktkoordinaten der Zonen festlegen
	feldK[41] = Player.ObjectLocation
	feldK[37] = GetPoint(feldK[41], 50, 270)
	feldK[1] = GetPoint(feldK[37], 50, 180)
	for i = 1, 3, 1 do
		for j = 1, 3, 1 do
			for y = 1, 3, 1 do
				for x = 2, 3, 1 do
					index = ((((i - 1) * 27) + ((j - 1) * 9)) + ((y - 1) * 3)) + x
					feldK[index] = GetPoint(feldK[index - 1], 10, 90)
				end
				-- for x
				feldK[index + 1] = GetPoint(feldK[index], 20, 90)
			end
			-- for y
			feldK[index + 1] = GetPoint(feldK[index - 8], 10, 0)
		end
		-- for j
		feldK[index + 1] = GetPoint(feldK[index - 8], 20, 0)
	end
	-- for i
	-- Zonen festlegen
	for i = 1, 81, 1 do
		feldZ[i].Active = false
		feldZ[i].OriginalPoint = Wherigo.TranslatePoint(feldK[i], dist, 0)
		feldZ[i].Points = GetZonePoints(feldK[i])
		feldZ[i].Image = img0
		feldZ[i].Icon = img0
		feldZ[i].Active = true
	end
	-- Zahlen verteilen
	i1 = math.random(1, 3)
	if i1 == 1 then
		i2 = 4 + math.random(1, 2)
		if i2 == 5 then
			i3 = 9
		else
			i3 = 8
		end
	elseif i1 == 2 then
		i2 = math.random(1, 2)
		if i2 == 1 then
			i2 = 4
			i3 = 9
		else
			i2 = 6
			i3 = 7
		end
	else
		i2 = 3 + math.random(1, 2)
		if i2 == 4 then
			i3 = 8
		else
			i3 = 7
		end
	end
	-- Quadrat 1
	for i = 1, 9, 1 do
		feldR[i] = 0
		feldQ[i] = 0
	end
	for i = 1, 9, 1 do
		x = math.random(1, 9)
		while feldR[x] == 1 do
			x = math.random(1, 9)
		end
		y = math.random(1, 9)
		while feldQ[y] > 0 do
			y = math.random(1, 9)
		end
		feldQ[y] = x
		feldR[x] = 1
	end
	if i1 == 1 then
		feldS[55] = feldQ[1]
		feldS[56] = feldQ[2]
		feldS[57] = feldQ[3]
		feldS[64] = feldQ[4]
		feldS[65] = feldQ[5]
		feldS[66] = feldQ[6]
		feldS[73] = feldQ[7]
		feldS[74] = feldQ[8]
		feldS[75] = feldQ[9]
	elseif i1 == 2 then
		feldS[58] = feldQ[1]
		feldS[59] = feldQ[2]
		feldS[60] = feldQ[3]
		feldS[67] = feldQ[4]
		feldS[68] = feldQ[5]
		feldS[69] = feldQ[6]
		feldS[76] = feldQ[7]
		feldS[77] = feldQ[8]
		feldS[78] = feldQ[9]
	else
		feldS[61] = feldQ[1]
		feldS[62] = feldQ[2]
		feldS[63] = feldQ[3]
		feldS[70] = feldQ[4]
		feldS[71] = feldQ[5]
		feldS[72] = feldQ[6]
		feldS[79] = feldQ[7]
		feldS[80] = feldQ[8]
		feldS[81] = feldQ[9]
	end
	-- Quadrat 2
	for i = 1, 9, 1 do
		feldR[i] = 0
		feldQ[i] = 0
	end
	for i = 1, 9, 1 do
		x = math.random(1, 9)
		while feldR[x] == 1 do
			x = math.random(1, 9)
		end
		y = math.random(1, 9)
		while feldQ[y] > 0 do
			y = math.random(1, 9)
		end
		feldQ[y] = x
		feldR[x] = 1
	end
	if i2 == 4 then
		feldS[28] = feldQ[1]
		feldS[29] = feldQ[2]
		feldS[30] = feldQ[3]
		feldS[37] = feldQ[4]
		feldS[38] = feldQ[5]
		feldS[39] = feldQ[6]
		feldS[46] = feldQ[7]
		feldS[47] = feldQ[8]
		feldS[48] = feldQ[9]
	elseif i2 == 5 then
		feldS[31] = feldQ[1]
		feldS[32] = feldQ[2]
		feldS[33] = feldQ[3]
		feldS[40] = feldQ[4]
		feldS[41] = feldQ[5]
		feldS[42] = feldQ[6]
		feldS[49] = feldQ[7]
		feldS[50] = feldQ[8]
		feldS[51] = feldQ[9]
	else
		feldS[34] = feldQ[1]
		feldS[35] = feldQ[2]
		feldS[36] = feldQ[3]
		feldS[43] = feldQ[4]
		feldS[44] = feldQ[5]
		feldS[45] = feldQ[6]
		feldS[52] = feldQ[7]
		feldS[53] = feldQ[8]
		feldS[54] = feldQ[9]
	end
	-- Quadrat 3
	for i = 1, 9, 1 do
		feldR[i] = 0
		feldQ[i] = 0
	end
	for i = 1, 9, 1 do
		x = math.random(1, 9)
		while feldR[x] == 1 do
			x = math.random(1, 9)
		end
		y = math.random(1, 9)
		while feldQ[y] > 0 do
			y = math.random(1, 9)
		end
		feldQ[y] = x
		feldR[x] = 1
	end
	if i3 == 7 then
		feldS[1] = feldQ[1]
		feldS[2] = feldQ[2]
		feldS[3] = feldQ[3]
		feldS[10] = feldQ[4]
		feldS[11] = feldQ[5]
		feldS[12] = feldQ[6]
		feldS[19] = feldQ[7]
		feldS[20] = feldQ[8]
		feldS[21] = feldQ[9]
	elseif i3 == 8 then
		feldS[4] = feldQ[1]
		feldS[5] = feldQ[2]
		feldS[6] = feldQ[3]
		feldS[13] = feldQ[4]
		feldS[14] = feldQ[5]
		feldS[15] = feldQ[6]
		feldS[22] = feldQ[7]
		feldS[23] = feldQ[8]
		feldS[24] = feldQ[9]
	else
		feldS[7] = feldQ[1]
		feldS[8] = feldQ[2]
		feldS[9] = feldQ[3]
		feldS[16] = feldQ[4]
		feldS[17] = feldQ[5]
		feldS[18] = feldQ[6]
		feldS[25] = feldQ[7]
		feldS[26] = feldQ[8]
		feldS[27] = feldQ[9]
	end
	for i = 1, 81, 1 do
		if feldS[i] ~= 0 then
			feldZ[i].Image = feldI[feldS[i]]
			feldZ[i].Icon = feldI[feldS[i]]
		end
	end
end
function GetPoint(refPt, entf, winkel)
	local dist = Wherigo.Distance(entf, "m")
	return Wherigo.TranslatePoint(refPt, dist, winkel)
end
function GetZonePoints(refPt)
	local dist = Wherigo.Distance(4, "m")
	local pts = {
		Wherigo.TranslatePoint(refPt, dist, 0), 
		Wherigo.TranslatePoint(refPt, dist, 45), 
		Wherigo.TranslatePoint(refPt, dist, 90), 
		Wherigo.TranslatePoint(refPt, dist, 135), 
		Wherigo.TranslatePoint(refPt, dist, 180), 
		Wherigo.TranslatePoint(refPt, dist, 225), 
		Wherigo.TranslatePoint(refPt, dist, 270), 
		Wherigo.TranslatePoint(refPt, dist, 315)
	}
	return pts
end
function ZonenAus()
	for i = 1, 81, 1 do
		feldZ[i].Active = false
	end
end
function BestimmeZone(paramsz)
	iZone = tonumber(paramsz)
end
function Anzeige()
	x = iZone % 9
	if x == 0 then
		x = 9
	end
	y = iZone - x
	y = y / 9
	y = y + 1
	sT = (("aktuelle Position: "..tostring(x))..",")..tostring(y)
	s0 = "     | 123    456    789"
	sZ = "--------------------------------"
	s1 = " 1  - "
	s2 = " 2  - "
	s3 = " 3  - "
	s4 = " 4  - "
	s5 = " 5  - "
	s6 = " 6  - "
	s7 = " 7  - "
	s8 = " 8  - "
	s9 = " 9  - "
	i = 1
	for j = 1, 9, 1 do
		s1 = s1..tostring(feldS[72 + j])
		i = i + 1
		if i == 4 then
			s1 = s1.."    "
			i = 1
		end
	end
	i = 1
	for j = 1, 9, 1 do
		s2 = s2..tostring(feldS[63 + j])
		i = i + 1
		if i == 4 then
			s2 = s2.."    "
			i = 1
		end
	end
	i = 1
	for j = 1, 9, 1 do
		s3 = s3..tostring(feldS[54 + j])
		i = i + 1
		if i == 4 then
			s3 = s3.."    "
			i = 1
		end
	end
	i = 1
	for j = 1, 9, 1 do
		s4 = s4..tostring(feldS[45 + j])
		i = i + 1
		if i == 4 then
			s4 = s4.."    "
			i = 1
		end
	end
	i = 1
	for j = 1, 9, 1 do
		s5 = s5..tostring(feldS[36 + j])
		i = i + 1
		if i == 4 then
			s5 = s5.."    "
			i = 1
		end
	end
	i = 1
	for j = 1, 9, 1 do
		s6 = s6..tostring(feldS[27 + j])
		i = i + 1
		if i == 4 then
			s6 = s6.."    "
			i = 1
		end
	end
	i = 1
	for j = 1, 9, 1 do
		s7 = s7..tostring(feldS[18 + j])
		i = i + 1
		if i == 4 then
			s7 = s7.."    "
			i = 1
		end
	end
	i = 1
	for j = 1, 9, 1 do
		s8 = s8..tostring(feldS[9 + j])
		i = i + 1
		if i == 4 then
			s8 = s8.."    "
			i = 1
		end
	end
	i = 1
	for j = 1, 9, 1 do
		s9 = s9..tostring(feldS[j])
		i = i + 1
		if i == 4 then
			s9 = s9.."    "
			i = 1
		end
	end
	Karte.Description = ((((sT..sCR)..s0)..sCR)..sZ)..sCR
	Karte.Description = (((((((Karte.Description..s1)..sCR)..s2)..sCR)..s3)..sCR)..sLZ)..sCR
	Karte.Description = (((((((Karte.Description..s4)..sCR)..s5)..sCR)..s6)..sCR)..sLZ)..sCR
	Karte.Description = ((((Karte.Description..s7)..sCR)..s8)..sCR)..s9
end
function cl(l1, l2, l3, l4, l5, l6, l7, l8, l9)
	if ((((((((l1 + l2) + l3) + l4) + l5) + l6) + l7) + l8) + l9) == 45 then
		return true
	else
		return false
	end
end
function CheckLoesung()
	local b1 = false
	local b2 = false
	local b3 = false
	local b4 = false
	local b5 = false
	local b6 = false
	local b7 = false
	local b8 = false
	local b9 = false
	local br = false
	local bs = false
	local bq = false
	local is = 0
	-- pruefe die reihen   summe = 45  
	b1 = cl((((((((feldS[1] + feldS[2]) + feldS[3]) + feldS[4]) + feldS[5]) + feldS[6]) + feldS[7]) + feldS[8]) + feldS[9])
	b2 = cl((((((((feldS[10] + feldS[11]) + feldS[12]) + feldS[13]) + feldS[14]) + feldS[15]) + feldS[16]) + feldS[17]) + feldS[18])
	b3 = cl((((((((feldS[19] + feldS[20]) + feldS[21]) + feldS[22]) + feldS[23]) + feldS[24]) + feldS[25]) + feldS[26]) + feldS[27])
	b4 = cl((((((((feldS[28] + feldS[29]) + feldS[30]) + feldS[31]) + feldS[32]) + feldS[33]) + feldS[34]) + feldS[35]) + feldS[36])
	b5 = cl((((((((feldS[37] + feldS[38]) + feldS[39]) + feldS[40]) + feldS[41]) + feldS[42]) + feldS[43]) + feldS[44]) + feldS[45])
	b6 = cl((((((((feldS[46] + feldS[47]) + feldS[48]) + feldS[59]) + feldS[50]) + feldS[51]) + feldS[52]) + feldS[53]) + feldS[54])
	b7 = cl((((((((feldS[55] + feldS[56]) + feldS[57]) + feldS[58]) + feldS[59]) + feldS[60]) + feldS[61]) + feldS[62]) + feldS[63])
	b8 = cl((((((((feldS[64] + feldS[65]) + feldS[66]) + feldS[67]) + feldS[68]) + feldS[69]) + feldS[70]) + feldS[71]) + feldS[72])
	b9 = cl((((((((feldS[73] + feldS[74]) + feldS[75]) + feldS[76]) + feldS[77]) + feldS[78]) + feldS[79]) + feldS[80]) + feldS[81])
	br = (((((((b1 and b2) and b3) and b4) and b5) and b6) and b7) and b8) and b9
	-- pruefe die spalten      summe = 45  
	b1 = cl((((((((feldS[1] + feldS[10]) + feldS[19]) + feldS[28]) + feldS[37]) + feldS[46]) + feldS[55]) + feldS[64]) + feldS[73])
	b2 = cl((((((((feldS[2] + feldS[11]) + feldS[20]) + feldS[29]) + feldS[38]) + feldS[47]) + feldS[56]) + feldS[65]) + feldS[74])
	b3 = cl((((((((feldS[3] + feldS[12]) + feldS[21]) + feldS[30]) + feldS[39]) + feldS[48]) + feldS[57]) + feldS[66]) + feldS[75])
	b4 = cl((((((((feldS[4] + feldS[13]) + feldS[22]) + feldS[31]) + feldS[40]) + feldS[49]) + feldS[58]) + feldS[67]) + feldS[76])
	b5 = cl((((((((feldS[5] + feldS[14]) + feldS[23]) + feldS[32]) + feldS[41]) + feldS[50]) + feldS[59]) + feldS[68]) + feldS[77])
	b6 = cl((((((((feldS[6] + feldS[15]) + feldS[24]) + feldS[33]) + feldS[42]) + feldS[51]) + feldS[60]) + feldS[69]) + feldS[78])
	b7 = cl((((((((feldS[7] + feldS[16]) + feldS[25]) + feldS[34]) + feldS[43]) + feldS[52]) + feldS[61]) + feldS[70]) + feldS[79])
	b8 = cl((((((((feldS[8] + feldS[17]) + feldS[26]) + feldS[35]) + feldS[44]) + feldS[53]) + feldS[62]) + feldS[71]) + feldS[80])
	b9 = cl((((((((feldS[9] + feldS[18]) + feldS[27]) + feldS[36]) + feldS[45]) + feldS[54]) + feldS[63]) + feldS[72]) + feldS[81])
	bs = (((((((b1 and b2) and b3) and b4) and b5) and b6) and b7) and b8) and b9
	-- pruefe die quadrate   summe = 45     
	b1 = cl((((((((feldS[1] + feldS[10]) + feldS[11]) + feldS[12]) + feldS[2]) + feldS[3]) + feldS[19]) + feldS[20]) + feldS[21])
	b2 = cl((((((((feldS[4] + feldS[13]) + feldS[14]) + feldS[15]) + feldS[4]) + feldS[6]) + feldS[22]) + feldS[23]) + feldS[24])
	b3 = cl((((((((feldS[7] + feldS[16]) + feldS[17]) + feldS[18]) + feldS[8]) + feldS[9]) + feldS[25]) + feldS[26]) + feldS[27])
	b4 = cl((((((((feldS[28] + feldS[29]) + feldS[30]) + feldS[37]) + feldS[38]) + feldS[39]) + feldS[46]) + feldS[47]) + feldS[48])
	b5 = cl((((((((feldS[55] + feldS[56]) + feldS[57]) + feldS[64]) + feldS[65]) + feldS[66]) + feldS[73]) + feldS[75]) + feldS[75])
	b6 = cl((((((((feldS[34] + feldS[35]) + feldS[36]) + feldS[43]) + feldS[44]) + feldS[45]) + feldS[53]) + feldS[54]) + feldS[52])
	b7 = cl((((((((feldS[61] + feldS[62]) + feldS[63]) + feldS[70]) + feldS[71]) + feldS[72]) + feldS[79]) + feldS[80]) + feldS[81])
	b8 = cl((((((((feldS[31] + feldS[32]) + feldS[33]) + feldS[40]) + feldS[41]) + feldS[42]) + feldS[49]) + feldS[50]) + feldS[51])
	b9 = cl((((((((feldS[58] + feldS[59]) + feldS[60]) + feldS[69]) + feldS[67]) + feldS[68]) + feldS[76]) + feldS[77]) + feldS[78])
	bq = (((((((b1 and b2) and b3) and b4) and b5) and b6) and b7) and b8) and b9
	bLoesung = (br and bs) and bq
end

-- End user functions --
return objKlausspieltSudoku
