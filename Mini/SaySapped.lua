local SaySapped = CreateFrame("Frame")
SaySapped:SetScript("OnEvent",function(_, _, _, eventType, _, _, _, _, _, _, destName, _, _, spellID)
if ((eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_AURA_REFRESH")
and (spellID == 6770)
and (destName == UnitName("player")))
then
  SendChatMessage("<< 有贼 >>", "SAY")
end
end)
SaySapped:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
