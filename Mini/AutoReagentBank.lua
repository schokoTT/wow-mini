--[[
The MIT License

Copyright (c) 2009

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

--print("AutoReagentBank loaded")
-- 简易本地化模版
local locale = GetLocale()
local L = setmetatable({}, {__index=function(t,i) return i end})
local cL = function(en, cn, tw)
    return locale == 'zhCN' and cn or locale == 'zhTW' and tw or en
end


local frame = CreateFrame("Frame")
frame:RegisterEvent("BANKFRAME_OPENED")
frame:SetScript("OnEvent", function(self, event, ...)
	if not BankFrameItemButton_Update_OLD then
		BankFrameItemButton_Update_OLD = BankFrameItemButton_Update
		
		BankFrameItemButton_Update = function(button)
			if BankFrameItemButton_Update_PASS == false then
				BankFrameItemButton_Update_OLD(button)
			else
				BankFrameItemButton_Update_PASS = false
			end
		end
	end
	
	BankFrameItemButton_Update_PASS = true
	DepositReagentBank()
	print(cL("Reagents deposited into Reagent Bank.","<自动> 背包中材料-->'材料银行'。","<自動> 背包中材料-->'材料銀行'。"))
end)

