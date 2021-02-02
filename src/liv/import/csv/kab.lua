local kab = {}

local map = {
  ["TYP KABELU"] = "typ",
  ["DÉLKA 1"] = "dlzka1",
  ["DÉLKA 2"] = "dlzka2",
  ["ODKUD +"] = "skrina",
  ["KAM +"] = "cskrina"
}
function kab.process(head, lines)
  local knaz = ""
  for k, v in pairs(head) do
    if v == "NÁZEV KABELU" then
      knaz = k
      break
    end
  end

  local data = {}
  for i=1, #lines do
    local ln = lines[i]
    local l = {}
    local valid = true
    for hk, hv in pairs(head) do
      local nk = map[hv]

      if nk then
        l[nk] = ln[hk]
--      else
--        l[hv] = ln[hk]
        if nk:sub(1,5) ~= "dlzka" then
          if #l[nk] == 0 then
            valid = false
            break
          end
        end
      end
    end

    if valid then
      data[ln[knaz]] = l
    end
  end

  return data
end

kab.headers = {"NÁZEV KABELU", "TYP KABELU", "DÉLKA 1", "DÉLKA 2", "ODKUD +", "KAM +"}
return kab
