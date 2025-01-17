local RandomScheduler = require("nvim-training.random_scheduler")

local exported_schedulers = { RandomScheduler = RandomScheduler }
for i, v in pairs(exported_schedulers) do
	exported_schedulers[string.lower(i)] = exported_schedulers[i]
end

return exported_schedulers
